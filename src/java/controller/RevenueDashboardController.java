package controller;

import DAO.SalesStatsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ChannelSlice;
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

@WebServlet(name = "RevenueDashboardController", urlPatterns = {"/manager/revenue"})
public class RevenueDashboardController extends HttpServlet {
    private final SalesStatsDAO dao = new SalesStatsDAO();
    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Date[] dates = resolveToday();
            Timestamp from = new Timestamp(dates[0].getTime());
            Timestamp to = new Timestamp(dates[1].getTime());

            SalesStatsModel today = dao.getOverview(from, to);
            List<SalesStatsModel> hourly = dao.getRevenueByHour(from, to);
            List<TopProductModel> topProducts = dao.getTopProducts(from, to, 8);
            List<TopBrandModel> topBrands = dao.getTopBrands(from, to, 5);
            List<ChannelSlice> channels = dao.getRevenueByChannel(from, to);

            BigDecimal todayRevenue = today != null && today.getRevenue() != null ? today.getRevenue() : BigDecimal.ZERO;
            int todayOrders = today != null ? today.getOrderCount() : 0;
            int todayProducts = today != null ? today.getProductSold() : 0;
            BigDecimal avgOrderValue = todayOrders > 0 ? todayRevenue.divide(BigDecimal.valueOf(todayOrders), 0, RoundingMode.HALF_UP) : BigDecimal.ZERO;

            // yesterday comparison
            Date[] yest = resolveYesterday();
            SalesStatsModel yesterday = dao.getOverview(new Timestamp(yest[0].getTime()), new Timestamp(yest[1].getTime()));
            BigDecimal yestRevenue = yesterday != null && yesterday.getRevenue() != null ? yesterday.getRevenue() : BigDecimal.ZERO;
            int yestOrders = yesterday != null ? yesterday.getOrderCount() : 0;

            BigDecimal revChange = BigDecimal.ZERO;
            if (yestRevenue.doubleValue() > 0) {
                revChange = todayRevenue.subtract(yestRevenue)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(yestRevenue, 1, RoundingMode.HALF_UP);
            }
            double orderChange = yestOrders > 0 ? (todayOrders - yestOrders) * 100.0 / yestOrders : 0;

            // estimate profit = 18% of revenue
            BigDecimal estimatedProfit = todayRevenue.multiply(BigDecimal.valueOf(0.18)).setScale(0, RoundingMode.HALF_UP);

            // hourly chart 24h
            List<SalesStatsModel> hourChart = buildHourlyChart(hourly);

            req.setAttribute("todayRevenue", todayRevenue);
            req.setAttribute("todayOrders", todayOrders);
            req.setAttribute("todayProducts", todayProducts);
            req.setAttribute("avgOrderValue", avgOrderValue);
            req.setAttribute("estimatedProfit", estimatedProfit);
            req.setAttribute("revChange", revChange);
            req.setAttribute("orderChange", orderChange);
            req.setAttribute("hourChart", hourChart);
            req.setAttribute("topProducts", topProducts);
            req.setAttribute("topBrands", topBrands);
            req.setAttribute("channels", channels);
            req.setAttribute("today", DATE_FMT.format(dates[0]));

            req.getRequestDispatcher("/views/manager/revenue-dashboard.jsp").forward(req, resp);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load revenue dashboard", ex);
        }
    }

    private Date[] resolveToday() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date from = cal.getTime();
        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);
        Date to = cal.getTime();
        return new Date[]{from, to};
    }

    private Date[] resolveYesterday() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, -1);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date from = cal.getTime();
        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);
        Date to = cal.getTime();
        return new Date[]{from, to};
    }

    private List<SalesStatsModel> buildHourlyChart(List<SalesStatsModel> hourly) {
        java.util.Map<Integer, BigDecimal> map = new java.util.HashMap<>();
        for (SalesStatsModel r : hourly) {
            try {
                map.put(Integer.parseInt(r.getPeriod()), r.getRevenue() != null ? r.getRevenue() : BigDecimal.ZERO);
            } catch (NumberFormatException ignored) {}
        }
        List<SalesStatsModel> hours = new ArrayList<>();
        for (int h = 0; h < 24; h++) {
            BigDecimal rev = map.getOrDefault(h, BigDecimal.ZERO);
            hours.add(new SalesStatsModel(String.format("%02d", h), rev, 0, 0));
        }
        return hours;
    }
}
