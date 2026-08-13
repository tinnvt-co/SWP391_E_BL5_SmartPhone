package controller;

import DAO.BrandDAO;
import DAO.CategoryDAO;
import DAO.DiscountDAO;
import DAO.InventoryDAO;
import DAO.OrderDAO;
import DAO.ProductDAO;
import DAO.SalesStatsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.DiscountModel;
import model.OrderModel;
import model.SalesStatsModel;
import model.StockModel;
import model.TopProductModel;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class ManagerDashboardController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final DiscountDAO discountDAO = new DiscountDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final SalesStatsDAO salesStatsDAO = new SalesStatsDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // --- Catalog snapshot ---
            request.setAttribute("totalProducts",
                    productDAO.findAll(null, null, null, "newest", false).size());
            request.setAttribute("activeProducts", productDAO.countActive());
            request.setAttribute("outOfStockProducts", productDAO.countOutOfStock());
            request.setAttribute("totalCategories", categoryDAO.findAll(false).size());
            request.setAttribute("totalBrands", brandDAO.findAll(false).size());

            // --- Inventory snapshot ---
            int[] stockStats = inventoryDAO.getStockStats();
            request.setAttribute("stockStats", stockStats);
            List<StockModel> allStock = inventoryDAO.getAllStock(null, null, "LOW");
            request.setAttribute("lowStockItems", allStock.size() > 6 ? allStock.subList(0, 6) : allStock);

            // --- Discount snapshot ---
            List<DiscountModel> allDiscounts = discountDAO.findAll(false);
            request.setAttribute("totalDiscounts", allDiscounts.size());
            long activeDiscounts = allDiscounts.stream().filter(DiscountModel::isLiveNow).count();
            request.setAttribute("activeDiscounts", (int) activeDiscounts);
            request.setAttribute("activeDiscountList",
                    allDiscounts.stream().filter(DiscountModel::isLiveNow).limit(4).toList());

            // --- Order snapshot ---
            int totalToday = orderDAO.countTodaysOrders();
            int totalProcessing = orderDAO.countProcessing();
            int totalDelivered = orderDAO.countDelivered();
            int totalCancelled = orderDAO.countCancelled();
            BigDecimal totalRevenue = orderDAO.totalRevenue();
            request.setAttribute("totalToday", totalToday);
            request.setAttribute("totalProcessing", totalProcessing);
            request.setAttribute("totalDelivered", totalDelivered);
            request.setAttribute("totalCancelled", totalCancelled);
            request.setAttribute("totalRevenue", totalRevenue != null ? totalRevenue : BigDecimal.ZERO);

            // --- Today's revenue (for today card) ---
            Date[] todayRange = resolveToday();
            SalesStatsModel todayStats = salesStatsDAO.getOverview(
                    new Timestamp(todayRange[0].getTime()),
                    new Timestamp(todayRange[1].getTime()));
            BigDecimal todayRevenue = todayStats != null && todayStats.getRevenue() != null
                    ? todayStats.getRevenue() : BigDecimal.ZERO;
            int todayOrders = todayStats != null ? todayStats.getOrderCount() : 0;
            request.setAttribute("todayRevenue", todayRevenue);
            request.setAttribute("todayOrders", todayOrders);

            // --- Top selling products (last 30 days) ---
            Date[] last30 = resolveLastDays(30);
            List<TopProductModel> topProducts = salesStatsDAO.getTopProducts(
                    new Timestamp(last30[0].getTime()),
                    new Timestamp(last30[1].getTime()), 5);
            request.setAttribute("topProducts", topProducts);

            // --- Recent orders (last 5 customer orders) ---
            List<OrderModel> recentOrders = orderDAO.findOrders(null, null, "ORDER", "newest", true);
            request.setAttribute("recentOrders",
                    recentOrders.size() > 5 ? recentOrders.subList(0, 5) : recentOrders);

            request.getRequestDispatcher("/views/manager/dashboard.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load manager dashboard", exception);
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

    private Date[] resolveLastDays(int days) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);
        Date to = cal.getTime();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        cal.add(Calendar.DAY_OF_MONTH, -(days - 1));
        Date from = cal.getTime();
        return new Date[]{from, to};
    }
}
