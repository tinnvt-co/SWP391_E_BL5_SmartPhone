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

@WebServlet(name = "ManageOrderController", urlPatterns = {"/manager/orders"})
public class ManageOrderController extends HttpServlet {
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

        request.getRequestDispatcher("/views/manager/order-list.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int orderId = integer(request.getParameter("id"), 0);
        model.OrderModel order = orderDAO.findOrderDetail(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }
        request.setAttribute("order", order);
        request.getRequestDispatcher("/views/manager/order-detail.jsp").forward(request, response);
    }

    static int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (Exception exception) {
            return fallback;
        }
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