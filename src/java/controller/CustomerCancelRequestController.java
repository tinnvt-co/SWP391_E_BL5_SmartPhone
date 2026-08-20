package controller;

import DAO.CancelRequestDAO;
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
import java.util.Set;

@WebServlet(name = "CustomerCancelRequestController", urlPatterns = {"/customer/cancel-request"})
public class CustomerCancelRequestController extends HttpServlet {

    private static final Set<String> NON_CANCELABLE_STATUSES = Set.of(
            "DELIVERED", "COMPLETED", "CANCELLED", "CANCEL_REQUESTED");
    private static final int MAX_CUSTOM_REASON_LENGTH = 500;
    private static final Set<String> VALID_REASONS = Set.of(
            "CHANGED_MIND", "WRONG_PRODUCT", "FOUND_CHEAPER", "LONG_DELIVERY", "OTHER");

    private final OrderDAO orderDAO = new OrderDAO();
    private final CancelRequestDAO cancelDAO = new CancelRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        UserModel user = (UserModel) session.getAttribute("currentUser");

        int orderId = parseInt(request.getParameter("orderId"), 0);
        String reason = request.getParameter("reason");
        String customReason = request.getParameter("customReason");

        if (orderId <= 0 || reason == null || !VALID_REASONS.contains(reason)) {
            redirectBack(request, response, "Invalid cancel request");
            return;
        }
        if ("OTHER".equals(reason)) {
            if (customReason == null || customReason.trim().isEmpty()) {
                redirectBack(request, response, "Please describe your reason for cancellation");
                return;
            }
            if (customReason.length() > MAX_CUSTOM_REASON_LENGTH) {
                redirectBack(request, response, "Custom reason is too long");
                return;
            }
        }

        try {
            OrderModel order = orderDAO.findOrderDetail(orderId);
            if (order == null) {
                redirectBack(request, response, "Order not found");
                return;
            }
            if (order.getUserId() != user.getId()) {
                redirectBack(request, response, "You cannot cancel this order");
                return;
            }
            if (!isCancelable(order.getStatus())) {
                redirectBack(request, response, "This order can no longer be cancelled");
                return;
            }
            if (cancelDAO.hasActiveRequest(orderId)) {
                redirectBack(request, response, "A cancellation request is already pending for this order");
                return;
            }

            String trimmedCustom = customReason == null ? null : customReason.trim();
            int created = cancelDAO.createRequest(orderId, user.getId(), reason,
                    "OTHER".equals(reason) ? trimmedCustom : null);
            if (created <= 0) {
                redirectBack(request, response, "Cannot submit cancel request");
                return;
            }

            // Mark the order as CANCEL_REQUESTED so other parts of the system
            // (order detail, staff dashboard) immediately surface the request.
            orderDAO.updateStatusWithNote(orderId, "CANCEL_REQUESTED", null,
                    "Customer requested cancellation: " + reasonLabel(reason));

            redirectBack(request, response, "Cancel request submitted. Staff will review it shortly.");
        } catch (SQLException exception) {
            redirectBack(request, response, "Database error: " + exception.getMessage());
        }
    }

    private boolean isCancelable(String status) {
        if (status == null) {
            return false;
        }
        return !NON_CANCELABLE_STATUSES.contains(status.toUpperCase());
    }

    private String reasonLabel(String code) {
        return CancelRequestDAO.formatReason(code);
    }

    private int parseInt(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response,
            String message) throws IOException {
        boolean isError = message != null && (
                message.startsWith("Cannot")
                || message.startsWith("Invalid")
                || message.startsWith("You cannot")
                || message.startsWith("This order")
                || message.startsWith("A cancellation")
                || message.startsWith("Please"));
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
        target.append("?");
        if (cleaned.length() > 0) {
            target.append(cleaned).append('&');
        }
        if (isError) {
            target.append("error=").append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        } else {
            target.append("message=").append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        }
        response.sendRedirect(target.toString());
    }
}
