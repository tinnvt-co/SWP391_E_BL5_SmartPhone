package controller;

import DAO.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderModel;
import model.UserModel;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

/**
 * Lets the customer mark a DELIVERED order as COMPLETED.
 * Không còn yêu cầu complaint trước khi complete (đã bỏ luồng complaint).
 */
@WebServlet(name = "CustomerCompleteOrderController", urlPatterns = {"/customer/complete-order"})
public class CustomerCompleteOrderController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserModel user = currentUser(session);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int orderId = parseInt(request.getParameter("orderId"), 0);
        if (orderId <= 0) {
            redirectBack(request, response, "Invalid order id", true);
            return;
        }
        try {
            OrderModel order = orderDAO.findOrderDetail(orderId);
            if (order == null || order.getUserId() != user.getId()) {
                redirectBack(request, response, "Order not found", true);
                return;
            }
            if (!"DELIVERED".equalsIgnoreCase(order.getStatus())) {
                redirectBack(request, response, "Only delivered orders can be marked as completed", true);
                return;
            }
            boolean ok = orderDAO.updateStatus(orderId, "COMPLETED", user.getId());
            if (!ok) {
                redirectBack(request, response, "Cannot complete order", true);
                return;
            }
            redirectBack(request, response,
                    "Order marked as completed.",
                    false);
        } catch (SQLException exception) {
            redirectBack(request, response, "Database error: " + exception.getMessage(), true);
        }
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response,
            String message, boolean isError) throws IOException {
        String referer = request.getHeader("Referer");
        String base = referer != null && !referer.isBlank()
                ? referer
                : request.getContextPath() + "/order-history";
        int qIndex = base.indexOf('?');
        String path = qIndex >= 0 ? base.substring(0, qIndex) : base;
        String query = qIndex >= 0 ? base.substring(qIndex + 1) : "";
        StringBuilder cleaned = new StringBuilder();
        if (!query.isEmpty()) {
            for (String pair : query.split("&")) {
                int eq = pair.indexOf('=');
                String key = eq >= 0 ? pair.substring(0, eq) : pair;
                if (key.equals("message") || key.equals("error")) {
                    continue;
                }
                if (cleaned.length() > 0) {
                    cleaned.append('&');
                }
                cleaned.append(pair);
            }
        }
        StringBuilder target = new StringBuilder(path);
        target.append(cleaned.length() > 0 ? "?" + cleaned + "&" : "?");
        target.append(isError ? "error=" : "message=")
                .append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        response.sendRedirect(target.toString());
    }

    private UserModel currentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object attribute = session.getAttribute("currentUser");
        return attribute instanceof UserModel ? (UserModel) attribute : null;
    }

    private int parseInt(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }
}
