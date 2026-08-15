package controller;

import DAO.SalesStatsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.SalesStatsModel;
import model.TopBrandModel;
import model.TopProductModel;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

@WebServlet(name = "SalesStatsController", urlPatterns = {"/manager/sales-stats"})
public class SalesStatsController extends HttpServlet {

    private final SalesStatsDAO dao = new SalesStatsDAO();
    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat MONTH_FMT = new SimpleDateFormat("MMM yyyy");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String range = req.getParameter("range");
            if (range == null || range.isBlank()) {
                range = "12m";
            }

            int year;
            try {
                year = Integer.parseInt(req.getParameter("year"));
            } catch (Exception e) {
                year = Calendar.getInstance().get(Calendar.YEAR);
            }

            Date[] dates = resolveRange(range, year);
            Timestamp from = new Timestamp(dates[0].getTime());
            Timestamp to = new Timestamp(dates[1].getTime());

            SalesStatsModel overview = dao.getOverview(from, to);
            List<SalesStatsModel> daily = dao.getRevenueByDay(from, to);
            List<SalesStatsModel> monthly = new ArrayList<>();
            List<SalesStatsModel> chartData;

            boolean isMonthlyView = "12m".equalsIgnoreCase(range) || range == null;
            if (isMonthlyView) {
                monthly = buildYearMonthBuckets(year, dao);
                chartData = monthly;
            } else {
                chartData = fillMissingDays(daily, dates[0], dates[1]);
            }

            List<TopProductModel> topProducts = dao.getTopProducts(from, to, 10);
            List<TopBrandModel> topBrands = dao.getTopBrands(from, to, 8);

            BigDecimal avgOrderValue = BigDecimal.ZERO;
            if (overview != null && overview.getOrderCount() > 0 && overview.getRevenue() != null) {
                avgOrderValue = overview.getRevenue()
                        .divide(BigDecimal.valueOf(overview.getOrderCount()), 0, RoundingMode.HALF_UP);
            }

            int currentYear = Calendar.getInstance().get(Calendar.YEAR);
            List<Integer> years = new ArrayList<>();
            for (int y = currentYear; y >= currentYear - 4; y--) {
                years.add(y);
            }

            req.setAttribute("overview", overview);
            req.setAttribute("avgOrderValue", avgOrderValue);
            req.setAttribute("chartData", chartData);
            req.setAttribute("topProducts", topProducts);
            req.setAttribute("topBrands", topBrands);
            req.setAttribute("range", range);
            req.setAttribute("year", year);
            req.setAttribute("years", years);
            req.setAttribute("isMonthlyView", isMonthlyView);
            req.setAttribute("monthFmt", MONTH_FMT);
            req.setAttribute("fromDate", DATE_FMT.format(dates[0]));
            req.setAttribute("toDate", DATE_FMT.format(dates[1]));

            req.getRequestDispatcher("/views/manager/sales-stats.jsp").forward(req, resp);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load sales statistics", ex);
        }
    }

    private Date[] resolveRange(String range, int year) {
        Date to = new Date();
        Date from;
        Calendar cal = Calendar.getInstance();
        cal.setTime(to);
        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);
        to = cal.getTime();

        cal.setTime(to);
        switch (range) {
            case "7":
                cal.add(Calendar.DAY_OF_MONTH, -6);
                break;
            case "30":
                cal.add(Calendar.DAY_OF_MONTH, -29);
                break;
            case "90":
                cal.add(Calendar.DAY_OF_MONTH, -89);
                break;
            case "month":
                cal.set(Calendar.DAY_OF_MONTH, 1);
                cal.set(Calendar.HOUR_OF_DAY, 0);
                cal.set(Calendar.MINUTE, 0);
                cal.set(Calendar.SECOND, 0);
                break;
            case "year":
                cal.set(year, Calendar.JANUARY, 1, 0, 0, 0);
                cal.set(Calendar.MILLISECOND, 0);
                from = cal.getTime();
                cal.set(year, Calendar.DECEMBER, 31, 23, 59, 59);
                return new Date[]{from, cal.getTime()};
            default: // 12m
                cal.set(year, Calendar.JANUARY, 1, 0, 0, 0);
                cal.set(Calendar.MILLISECOND, 0);
                from = cal.getTime();
                cal.set(year, Calendar.DECEMBER, 31, 23, 59, 59);
                return new Date[]{from, cal.getTime()};
        }
        from = cal.getTime();
        return new Date[]{from, to};
    }

    private List<SalesStatsModel> buildYearMonthBuckets(int year, SalesStatsDAO dao) throws SQLException {
        Timestamp from = Timestamp.valueOf(year + "-01-01 00:00:00");
        Timestamp to = Timestamp.valueOf(year + "-12-31 23:59:59");
        List<SalesStatsModel> raw = dao.getRevenueByMonth(from, to);

        Calendar cal = Calendar.getInstance();
        cal.set(year, Calendar.JANUARY, 1, 0, 0, 0);
        cal.set(Calendar.MILLISECOND, 0);

        List<SalesStatsModel> months = new ArrayList<>();
        for (int m = 0; m < 12; m++) {
            String key = year + "-" + String.format("%02d", m + 1);
            BigDecimal rev = BigDecimal.ZERO;
            int orders = 0;
            int qty = 0;
            for (SalesStatsModel r : raw) {
                if (r.getPeriod() != null && r.getPeriod().startsWith(key)) {
                    rev = r.getRevenue() != null ? r.getRevenue() : BigDecimal.ZERO;
                    orders = r.getOrderCount();
                    qty = r.getProductSold();
                    break;
                }
            }
            SalesStatsModel bucket = new SalesStatsModel(MONTH_FMT.format(cal.getTime()), rev, orders, qty);
            bucket.setFromDate(new Timestamp(cal.getTimeInMillis()));
            months.add(bucket);
            cal.add(Calendar.MONTH, 1);
        }
        return months;
    }

    private List<SalesStatsModel> fillMissingDays(List<SalesStatsModel> raw, Date from, Date to) {
        java.util.Map<String, SalesStatsModel> map = new java.util.HashMap<>();
        for (SalesStatsModel r : raw) {
            if (r.getPeriod() != null) {
                map.put(r.getPeriod(), r);
            }
        }

        List<SalesStatsModel> filled = new ArrayList<>();
        Calendar cal = Calendar.getInstance();
        cal.setTime(from);
        Calendar end = Calendar.getInstance();
        end.setTime(to);
        while (!cal.after(end)) {
            String key = DATE_FMT.format(cal.getTime());
            SalesStatsModel m = map.get(key);
            if (m != null) {
                filled.add(m);
            } else {
                SalesStatsModel empty = new SalesStatsModel(key, BigDecimal.ZERO, 0, 0);
                filled.add(empty);
            }
            cal.add(Calendar.DAY_OF_MONTH, 1);
        }
        return filled;
    }
}
