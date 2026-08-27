package controller;

import DAO.BrandDAO;
import DAO.CancelRequestDAO;
import DAO.CategoryDAO;
import DAO.ConversationDAO;
import DAO.DiscountDAO;
import DAO.InventoryDAO;
import DAO.OrderDAO;
import DAO.ProductDAO;
import DAO.RefundDAO;
import DAO.SalesStatsDAO;
import DAO.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
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
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

@WebServlet(name = "ManagerDashboardController", urlPatterns = {"/manager", "/manager/dashboard"})
public class ManagerDashboardController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final DiscountDAO discountDAO = new DiscountDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final SalesStatsDAO salesStatsDAO = new SalesStatsDAO();
    private final RefundDAO returnRequestDAO = new RefundDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final ConversationDAO conversationDAO = new ConversationDAO();
    private final CancelRequestDAO cancelRequestDAO = new CancelRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            loadDashboard(request);
        } catch (Exception ex) {
            // Make sure dashboard still renders even if a DAO fails
            request.setAttribute("dashboardError", ex.getMessage());
            ex.printStackTrace();
            ensureDefaults(request);
        }
        request.getRequestDispatcher("/views/manager/dashboard.jsp")
                .forward(request, response);
    }

    private void loadDashboard(HttpServletRequest request) throws SQLException {
        // --- Catalog snapshot ---
        try {
            request.setAttribute("totalProducts",
                    productDAO.findAll(null, null, null, "newest", false).size());
            request.setAttribute("activeProducts", productDAO.countActive());
            request.setAttribute("outOfStockProducts", productDAO.countOutOfStock());
            request.setAttribute("totalCategories", categoryDAO.findAll(false).size());
            request.setAttribute("totalBrands", brandDAO.findAll(false).size());
            request.setAttribute("totalSuppliers", supplierDAO.countAll(null, null));
        } catch (Exception ex) {
            request.setAttribute("totalProducts", 0);
            request.setAttribute("activeProducts", 0);
            request.setAttribute("outOfStockProducts", 0);
            request.setAttribute("totalCategories", 0);
            request.setAttribute("totalBrands", 0);
            request.setAttribute("totalSuppliers", 0);
        }

        // --- Inventory snapshot ---
        try {
            int[] stockStats = inventoryDAO.getStockStats();
            request.setAttribute("stockStats", stockStats);
            List<StockModel> allStock = inventoryDAO.getAllStock(null, null, "LOW");
            request.setAttribute("lowStockItems", allStock.size() > 6 ? allStock.subList(0, 6) : allStock);
        } catch (Exception ex) {
            request.setAttribute("stockStats", new int[]{0, 0, 0});
            request.setAttribute("lowStockItems", java.util.Collections.emptyList());
        }

        // --- Discount snapshot ---
        try {
            List<DiscountModel> allDiscounts = discountDAO.findAll(false);
            request.setAttribute("totalDiscounts", allDiscounts.size());
            long activeDiscounts = allDiscounts.stream().filter(DiscountModel::isLiveNow).count();
            request.setAttribute("activeDiscounts", (int) activeDiscounts);
            request.setAttribute("activeDiscountList",
                    allDiscounts.stream().filter(DiscountModel::isLiveNow).limit(4).toList());
        } catch (Exception ex) {
            request.setAttribute("totalDiscounts", 0);
            request.setAttribute("activeDiscounts", 0);
            request.setAttribute("activeDiscountList", java.util.Collections.emptyList());
        }

        // --- Order snapshot ---
        try {
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
        } catch (Exception ex) {
            request.setAttribute("totalToday", 0);
            request.setAttribute("totalProcessing", 0);
            request.setAttribute("totalDelivered", 0);
            request.setAttribute("totalCancelled", 0);
            request.setAttribute("totalRevenue", BigDecimal.ZERO);
        }

        // --- Refund snapshot ---
        try {
            request.setAttribute("pendingRefunds", returnRequestDAO.countPending());
        } catch (Exception ex) {
            request.setAttribute("pendingRefunds", 0);
        }

        // --- Today's revenue (for today card) ---
        try {
            Date[] todayRange = resolveToday();
            SalesStatsModel todayStats = salesStatsDAO.getOverview(
                    new Timestamp(todayRange[0].getTime()),
                    new Timestamp(todayRange[1].getTime()));
            BigDecimal todayRevenue = todayStats != null && todayStats.getRevenue() != null
                    ? todayStats.getRevenue() : BigDecimal.ZERO;
            int todayOrders = todayStats != null ? todayStats.getOrderCount() : 0;
            request.setAttribute("todayRevenue", todayRevenue);
            request.setAttribute("todayOrders", todayOrders);
        } catch (Exception ex) {
            request.setAttribute("todayRevenue", BigDecimal.ZERO);
            request.setAttribute("todayOrders", 0);
        }

        // --- Top selling products (last 30 days) ---
        try {
            Date[] last30 = resolveLastDays(30);
            List<TopProductModel> topProducts = salesStatsDAO.getTopProducts(
                    new Timestamp(last30[0].getTime()),
                    new Timestamp(last30[1].getTime()), 5);
            request.setAttribute("topProducts", topProducts);
        } catch (Exception ex) {
            request.setAttribute("topProducts", java.util.Collections.emptyList());
        }

        // --- Recent orders (last 5 customer orders) ---
        try {
            List<OrderModel> recentOrders = orderDAO.findOrders(null, null, "ORDER", "newest", true);
            request.setAttribute("recentOrders",
                    recentOrders.size() > 5 ? recentOrders.subList(0, 5) : recentOrders);
        } catch (Exception ex) {
            request.setAttribute("recentOrders", java.util.Collections.emptyList());
        }

        // --- Chat & cancel-request counters (for module cards) ---
        try {
            request.setAttribute("pendingChats", conversationDAO.countOpen());
            request.setAttribute("totalPending", cancelRequestDAO.countPending());
        } catch (Exception ex) {
            request.setAttribute("pendingChats", 0);
            request.setAttribute("totalPending", 0);
        }
    }

    private void ensureDefaults(HttpServletRequest request) {
        if (request.getAttribute("totalProducts") == null) request.setAttribute("totalProducts", 0);
        if (request.getAttribute("activeProducts") == null) request.setAttribute("activeProducts", 0);
        if (request.getAttribute("outOfStockProducts") == null) request.setAttribute("outOfStockProducts", 0);
        if (request.getAttribute("totalCategories") == null) request.setAttribute("totalCategories", 0);
        if (request.getAttribute("totalBrands") == null) request.setAttribute("totalBrands", 0);
        if (request.getAttribute("totalSuppliers") == null) request.setAttribute("totalSuppliers", 0);
        if (request.getAttribute("stockStats") == null) request.setAttribute("stockStats", new int[]{0, 0, 0});
        if (request.getAttribute("lowStockItems") == null) request.setAttribute("lowStockItems", java.util.Collections.emptyList());
        if (request.getAttribute("totalDiscounts") == null) request.setAttribute("totalDiscounts", 0);
        if (request.getAttribute("activeDiscounts") == null) request.setAttribute("activeDiscounts", 0);
        if (request.getAttribute("activeDiscountList") == null) request.setAttribute("activeDiscountList", java.util.Collections.emptyList());
        if (request.getAttribute("totalToday") == null) request.setAttribute("totalToday", 0);
        if (request.getAttribute("totalProcessing") == null) request.setAttribute("totalProcessing", 0);
        if (request.getAttribute("totalDelivered") == null) request.setAttribute("totalDelivered", 0);
        if (request.getAttribute("totalCancelled") == null) request.setAttribute("totalCancelled", 0);
        if (request.getAttribute("totalRevenue") == null) request.setAttribute("totalRevenue", BigDecimal.ZERO);
        if (request.getAttribute("pendingRefunds") == null) request.setAttribute("pendingRefunds", 0);
        if (request.getAttribute("todayRevenue") == null) request.setAttribute("todayRevenue", BigDecimal.ZERO);
        if (request.getAttribute("todayOrders") == null) request.setAttribute("todayOrders", 0);
        if (request.getAttribute("topProducts") == null) request.setAttribute("topProducts", java.util.Collections.emptyList());
        if (request.getAttribute("recentOrders") == null) request.setAttribute("recentOrders", java.util.Collections.emptyList());
        if (request.getAttribute("pendingChats") == null) request.setAttribute("pendingChats", 0);
        if (request.getAttribute("totalPending") == null) request.setAttribute("totalPending", 0);
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
