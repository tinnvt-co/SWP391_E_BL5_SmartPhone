package controller;

import DAO.OrderDAO;
import DAO.SalesStatsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.BrandProfitModel;
import model.SalesStatsModel;
import model.TopProductModel;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "BusinessOverviewController", urlPatterns = {"/manager/business-overview"})
public class BusinessOverviewController extends HttpServlet {

    private final SalesStatsDAO salesDao = new SalesStatsDAO();
    private final OrderDAO orderDao = new OrderDAO();
    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Date[] dates = resolveDateRange(req);
            Timestamp from = new Timestamp(dates[0].getTime());
            Timestamp to = new Timestamp(dates[1].getTime());
            
            // Store range label for display
            String rangeLabel = req.getParameter("range");
            if (rangeLabel == null) rangeLabel = "custom";
            req.setAttribute("activeRange", rangeLabel);

            // Get brand profit data (revenue, capital, refund, profit by brand)
            List<BrandProfitModel> brandSummary = salesDao.getBrandProfitSummary(from, to);
            
            // Get accurate total revenue directly from Transaction table (avoids double-counting across brands)
            SalesStatsModel overview = salesDao.getOverview(from, to);
            BigDecimal totalRevenue = overview.getRevenue() != null ? overview.getRevenue() : BigDecimal.ZERO;
            int totalOrders = overview.getOrderCount();
            int totalSoldFromQuery = overview.getProductSold();
            
            // Capital and refund are summed from brand summary (per brand breakdown)
            BigDecimal totalCapital = BigDecimal.ZERO;
            BigDecimal totalRefund = BigDecimal.ZERO;
            BigDecimal totalProfit = BigDecimal.ZERO;
            int totalSold = 0;

            for (BrandProfitModel b : brandSummary) {
                totalCapital = totalCapital.add(b.getCapital() != null ? b.getCapital() : BigDecimal.ZERO);
                totalRefund = totalRefund.add(b.getRefund() != null ? b.getRefund() : BigDecimal.ZERO);
                totalSold += b.getSoldQuantity();
            }
            // Profit = Revenue - Capital - Refund (use totalRevenue from Transaction, not summed across brands)
            totalProfit = totalRevenue.subtract(totalCapital).subtract(totalRefund);
            
            // Calculate average order value
            BigDecimal avgOrderValue = BigDecimal.ZERO;
            if (totalOrders > 0) {
                avgOrderValue = totalRevenue.divide(BigDecimal.valueOf(totalOrders), 0, BigDecimal.ROUND_HALF_UP);
            }
            
            // Calculate profit margin
            BigDecimal profitMargin = BigDecimal.ZERO;
            if (totalRevenue.compareTo(BigDecimal.ZERO) > 0) {
                profitMargin = totalProfit.multiply(BigDecimal.valueOf(100))
                        .divide(totalRevenue, 1, BigDecimal.ROUND_HALF_UP);
            }

            // Prepare chart data for top brands
            List<Map<String, Object>> brandChartData = new ArrayList<>();
            double maxSold = 0;
            double maxRevenue = 0;
            
            // Find max values for scaling
            for (BrandProfitModel b : brandSummary) {
                if (b.getSoldQuantity() > maxSold) maxSold = b.getSoldQuantity();
                double revVal = b.getRevenue() != null ? b.getRevenue().doubleValue() : 0;
                if (revVal > maxRevenue) maxRevenue = revVal;
            }
            
            // Create chart data (all brands)
            String[] brandColors = {
                "#4361ee", "#7c3aed", "#f97316", "#16a34a", "#dc2626", "#0891b2", "#c026d3", "#ca8a04",
                "#6366f1", "#a855f7", "#ea580c", "#65a30d", "#e11d48", "#0d9488", "#9333ea", "#a16207"
            };
            
            int colorIdx = 0;
            for (BrandProfitModel b : brandSummary) {
                Map<String, Object> brandData = new LinkedHashMap<>();
                BigDecimal rev = b.getRevenue() != null ? b.getRevenue() : BigDecimal.ZERO;
                
                brandData.put("brandName", b.getBrandName());
                brandData.put("revenue", rev);
                brandData.put("soldQuantity", b.getSoldQuantity());
                
                // Calculate bar heights
                double soldH = maxSold > 0 ? (b.getSoldQuantity() * 260 / maxSold) : 3;
                double revH = maxRevenue > 0 ? (rev.doubleValue() * 260 / maxRevenue) : 3;
                
                brandData.put("soldHeight", soldH);
                brandData.put("revenueHeight", revH);
                brandData.put("barColor", brandColors[colorIdx % brandColors.length]);
                
                brandChartData.add(brandData);
                colorIdx++;
            }

            // Get top selling products
            List<TopProductModel> topProducts = salesDao.getTopProducts(from, to, 10);

            // Set request attributes
            req.setAttribute("brandSummary", brandSummary);
            req.setAttribute("brandChartData", brandChartData);
            req.setAttribute("topProducts", topProducts);
            
            req.setAttribute("totalRevenue", totalRevenue);
            req.setAttribute("totalCapital", totalCapital);
            req.setAttribute("totalRefund", totalRefund);
            req.setAttribute("totalProfit", totalProfit);
            req.setAttribute("totalSold", totalSold);
            req.setAttribute("totalOrders", totalOrders);
            req.setAttribute("avgOrderValue", avgOrderValue);
            req.setAttribute("profitMargin", profitMargin);
            
            req.setAttribute("fromDate", DATE_FMT.format(dates[0]));
            req.setAttribute("toDate", DATE_FMT.format(dates[1]));

            req.getRequestDispatcher("/views/manager/business-overview.jsp").forward(req, resp);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load business overview", ex);
        }
    }

    private Date[] resolveDateRange(HttpServletRequest req) {
        String range = req.getParameter("range");
        String monthStr = req.getParameter("month");
        String yearStr = req.getParameter("year");
        
        // Handle custom month/year filter
        if (monthStr != null && !monthStr.isEmpty() && yearStr != null && !yearStr.isEmpty()) {
            try {
                int month = Integer.parseInt(monthStr);
                int year = Integer.parseInt(yearStr);
                Calendar calFrom = Calendar.getInstance();
                Calendar calTo = Calendar.getInstance();
                
                calFrom.set(year, month - 1, 1, 0, 0, 0);
                calFrom.set(Calendar.MILLISECOND, 0);
                
                calTo.set(year, month - 1, 1, 23, 59, 59);
                calTo.set(Calendar.DAY_OF_MONTH, calTo.getActualMaximum(Calendar.DAY_OF_MONTH));
                
                return new Date[]{calFrom.getTime(), calTo.getTime()};
            } catch (NumberFormatException e) {
                // Fall through to default
            }
        }
        
        Calendar calFrom = Calendar.getInstance();
        Calendar calTo = Calendar.getInstance();
        
        if (range == null || range.isEmpty()) {
            range = "today";
        }
        
        switch (range) {
            case "7d":
                calFrom.add(Calendar.DAY_OF_MONTH, -6);
                break;
            case "30d":
                calFrom.add(Calendar.DAY_OF_MONTH, -29);
                break;
            default: // today
                calFrom.set(Calendar.HOUR_OF_DAY, 0);
                calFrom.set(Calendar.MINUTE, 0);
                calFrom.set(Calendar.SECOND, 0);
                calFrom.set(Calendar.MILLISECOND, 0);
                calTo.set(Calendar.HOUR_OF_DAY, 23);
                calTo.set(Calendar.MINUTE, 59);
                calTo.set(Calendar.SECOND, 59);
                return new Date[]{calFrom.getTime(), calTo.getTime()};
        }

        calFrom.set(Calendar.HOUR_OF_DAY, 0);
        calFrom.set(Calendar.MINUTE, 0);
        calFrom.set(Calendar.SECOND, 0);
        calFrom.set(Calendar.MILLISECOND, 0);
        
        calTo.set(Calendar.HOUR_OF_DAY, 23);
        calTo.set(Calendar.MINUTE, 59);
        calTo.set(Calendar.SECOND, 59);
        
        return new Date[]{calFrom.getTime(), calTo.getTime()};
    }
}
