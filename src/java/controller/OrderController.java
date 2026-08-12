package controller;

import DAO.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Set;
import model.OrderModel;

@WebServlet(name = "OrderController", urlPatterns = {"/staff/orders"})
public class OrderController extends HttpServlet {
    private static final int MAX_SEARCH_LENGTH = 100;
    private static final Set<String> VALID_STATUSES = Set.of(
            "PENDING", "CONFIRMED", "PROCESSING", "PAID", "SHIPPING", "DELIVERED",
            "COMPLETED", "CANCEL_REQUESTED", "CANCELLED");
    private static final Set<String> VALID_TYPES = Set.of("ORDER", "IMPORT", "ALL");
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = value(request.getParameter("action"), "list");
            if ("detail".equals(action)) {
                showDetail(request, response);
                return;
            }
            listOrders(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load orders from database", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = value(request.getParameter("action"), "update-status");

        try {
            if ("update-status".equals(action)) {
                int orderId = integer(request.getParameter("id"), 0);
                String status = request.getParameter("status");
                Integer updatedBy = integerOrNull(request.getParameter("updatedBy"));
                if (orderId <= 0 || status == null || !VALID_STATUSES.contains(status)) {
                    redirectBack(request, response, "Invalid request");
                    return;
                }
                boolean ok = orderDAO.updateStatus(orderId, status, updatedBy);
                redirectBack(request, response, ok ? "Order status updated" : "Cannot update order");
            }
        } catch (SQLException exception) {
            redirectBack(request, response, "Database error: " + exception.getMessage());
        }
    }

    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = normalizeKeyword(request.getParameter("q"));
        String status = normalizeStatus(request.getParameter("status"));
        String type = normalizeType(request.getParameter("type"));
        String sort = normalizeSort(request.getParameter("sort"));

        String validationError = validateSearch(keyword);

        if (validationError != null) {
            request.setAttribute("orders", java.util.Collections.emptyList());
            request.setAttribute("validationError", validationError);
        } else {
            boolean excludeImport = "ORDER".equals(type);
            request.setAttribute("orders",
                    orderDAO.findOrders(keyword, status, type, sort, excludeImport));
        }

        request.setAttribute("statuses", orderDAO.findAllStatuses());
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedType", "ALL".equals(type) ? "ALL" : type);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("totalToday", orderDAO.countTodaysOrders());
        request.setAttribute("totalProcessing", orderDAO.countProcessing());
        request.setAttribute("totalDelivered", orderDAO.countDelivered());
        request.setAttribute("totalCancelled", orderDAO.countCancelled());

        request.getRequestDispatcher("/views/staff/order-list.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int orderId = integer(request.getParameter("id"), 0);
        OrderModel order = orderDAO.findOrderDetail(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }
        request.setAttribute("order", order);
        request.getRequestDispatcher("/views/staff/order-detail.jsp").forward(request, response);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response,
                              String message) throws IOException {
        String referer = request.getHeader("Referer");
        String base = referer != null && !referer.isBlank()
                ? referer
                : request.getContextPath() + "/staff/orders";
        int qIndex = base.indexOf('?');
        String path = qIndex >= 0 ? base.substring(0, qIndex) : base;
        String query = qIndex >= 0 ? base.substring(qIndex + 1) : "";
        StringBuilder cleaned = new StringBuilder();
        if (!query.isEmpty()) {
            for (String pair : query.split("&")) {
                int eq = pair.indexOf('=');
                String key = eq >= 0 ? pair.substring(0, eq) : pair;
                if (key.equals("status") || key.equals("message")) continue;
                if (cleaned.length() > 0) cleaned.append('&');
                cleaned.append(pair);
            }
        }
        StringBuilder target = new StringBuilder(path);
        target.append("?");
        if (cleaned.length() > 0) target.append(cleaned).append('&');
        target.append("message=").append(java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
        response.sendRedirect(target.toString());
    }

    static int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (Exception exception) {
            return fallback;
        }
    }

    static Integer integerOrNull(String input) {
        int result = integer(input, 0);
        return result > 0 ? result : null;
    }

    static String value(String input, String fallback) {
        return input == null || input.isBlank() ? fallback : input;
    }

    private String normalizeKeyword(String input) {
        if (input == null) return "";
        return input.trim().replaceAll("\\s+", " ");
    }

    private String normalizeStatus(String input) {
        if (input == null || input.isBlank()) return "";
        return VALID_STATUSES.contains(input) ? input : "";
    }

    private String normalizeType(String input) {
        if (input == null || input.isBlank()) return "ALL";
        return VALID_TYPES.contains(input) ? input : "ALL";
    }

    private String normalizeSort(String input) {
        if (input == null || input.isBlank()) return "newest";
        return Set.of("newest", "oldest", "total-desc", "total-asc").contains(input) ? input : "newest";
    }

    private String validateSearch(String keyword) {
        if (keyword.length() > MAX_SEARCH_LENGTH) {
            return "Search keyword must not exceed 100 characters.";
        }
        for (int index = 0; index < keyword.length(); index++) {
            if (Character.isISOControl(keyword.charAt(index))) {
                return "Search keyword contains invalid characters.";
            }
        }
        return null;
    }
}