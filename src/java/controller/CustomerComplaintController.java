package controller;

import DAO.ComplaintDAO;
import DAO.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ComplaintMessageModel;
import model.ComplaintModel;
import model.OrderItemModel;
import model.OrderModel;
import model.UserModel;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Customer-facing endpoints for the complaint flow:
 * <ul>
 *   <li>GET {@code /customer/complaint}?orderId=... → open complaint page</li>
 *   <li>POST {@code /customer/complaint}?action=create → file a new complaint</li>
 *   <li>POST {@code /customer/complaint}?action=message → append chat message</li>
 *   <li>POST {@code /customer/complaint}?action=close → close (resolve) complaint</li>
 *   <li>GET {@code /customer/complaint}?action=poll&complaintId=...&since=... → JSON polling</li>
 * </ul>
 */
@WebServlet(name = "CustomerComplaintController", urlPatterns = {"/customer/complaint"})
public class CustomerComplaintController extends HttpServlet {

    private static final Set<String> COMPLAINTABLE_STATUSES = Set.of("DELIVERED", "COMPLETED");
    private static final int MAX_DESCRIPTION_LENGTH = 2000;
    private static final int MAX_CUSTOM_REASON_LENGTH = 500;
    private static final int MAX_MESSAGE_LENGTH = 2000;

    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserModel user = currentUser(session);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("poll".equalsIgnoreCase(action)) {
            handlePoll(request, response, user);
            return;
        }
        if ("history".equalsIgnoreCase(action)) {
            handleHistory(request, response, user);
            return;
        }

        int orderId = parseInt(request.getParameter("orderId"), 0);
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        if (orderId <= 0 && complaintId > 0) {
            // Came in via a complaint-only link; resolve orderId from the complaint.
            try {
                ComplaintModel existing = complaintDAO.findById(complaintId);
                if (existing != null && existing.getUserId() == user.getId()) {
                    response.sendRedirect(request.getContextPath() + "/customer/complaint?orderId="
                            + existing.getTransactionId() + "&complaintId=" + complaintId);
                    return;
                }
            } catch (SQLException exception) {
                // Fall through to the generic redirect below.
            }
        }
        if (orderId <= 0) {
            // No specific order requested – show the customer's full complaint history.
            response.sendRedirect(request.getContextPath() + "/customer/complaint?action=history");
            return;
        }

        try {
            OrderModel order = orderDAO.findOrderDetail(orderId);
            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/order-history?error="
                        + URLEncoder.encode("Order not found", StandardCharsets.UTF_8));
                return;
            }
            if (!COMPLAINTABLE_STATUSES.contains(order.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/order-history?error="
                        + URLEncoder.encode("Complaints are only available after delivery",
                                StandardCharsets.UTF_8));
                return;
            }

            ComplaintModel complaint = complaintDAO.findLatestByTransaction(orderId);
            boolean hasOpen = complaint != null && complaint.isOpen();

            List<OrderItemModel> orderItems = orderDAO.findOrderItems(orderId);
            request.setAttribute("order", order);
            request.setAttribute("orderItems", orderItems);
            request.setAttribute("complaint", complaint);
            request.setAttribute("hasOpenComplaint", hasOpen);
            request.setAttribute("complaintCategories", complaintDAO.findValidCategories());
            if (complaint != null) {
                request.setAttribute("messages", complaintDAO.findMessages(complaint.getId()));
            }
            request.getRequestDispatcher("/views/customer/complaint.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load complaint page", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserModel user = currentUser(session);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "create";
        }

        switch (action.toLowerCase()) {
            case "message":
                handleSendMessage(request, response, user);
                return;
            case "close":
                handleClose(request, response, user);
                return;
            case "create":
            default:
                handleCreate(request, response, user);
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int orderId = parseInt(request.getParameter("orderId"), 0);
        String category = request.getParameter("category");
        String customReason = request.getParameter("customReason");
        String description = request.getParameter("description");

        if (orderId <= 0 || category == null || !complaintDAO.findValidCategories().contains(category)) {
            redirectBack(request, response, "Invalid complaint request", true);
            return;
        }
        if (ComplaintModel.CATEGORY_OTHER.equals(category)
                && (customReason == null || customReason.trim().isEmpty())) {
            redirectBack(request, response, "Please describe your complaint", true);
            return;
        }
        if (customReason != null && customReason.length() > MAX_CUSTOM_REASON_LENGTH) {
            redirectBack(request, response, "Custom reason is too long", true);
            return;
        }
        if (description != null && description.length() > MAX_DESCRIPTION_LENGTH) {
            redirectBack(request, response, "Description is too long", true);
            return;
        }

        try {
            OrderModel order = orderDAO.findOrderDetail(orderId);
            if (order == null || order.getUserId() != user.getId()) {
                redirectBack(request, response, "Order not found", true);
                return;
            }
            if (!COMPLAINTABLE_STATUSES.contains(order.getStatus())) {
                redirectBack(request, response, "This order is not eligible for complaint", true);
                return;
            }
            if (complaintDAO.hasOpenComplaint(orderId)) {
                redirectBack(request, response, "You already have an open complaint for this order", true);
                return;
            }

            int created = complaintDAO.createComplaint(orderId, user.getId(), category,
                    customReason == null ? null : customReason.trim(),
                    description == null ? null : description.trim());
            if (created <= 0) {
                redirectBack(request, response, "Cannot submit complaint", true);
                return;
            }

            String target = request.getContextPath() + "/customer/complaint?orderId=" + orderId
                    + "&message=" + URLEncoder.encode("Complaint submitted. Our manager will respond shortly.",
                            StandardCharsets.UTF_8);
            response.sendRedirect(target);
        } catch (SQLException exception) {
            redirectBack(request, response, "Database error: " + exception.getMessage(), true);
        }
    }

    private void handleSendMessage(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        String content = request.getParameter("content");

        if (complaintId <= 0 || content == null || content.trim().isEmpty()) {
            redirectToComplaint(request, response, "Message cannot be empty", true);
            return;
        }
        if (content.length() > MAX_MESSAGE_LENGTH) {
            redirectToComplaint(request, response, "Message is too long", true);
            return;
        }

        try {
            ComplaintModel complaint = complaintDAO.findById(complaintId);
            if (complaint == null || complaint.getUserId() != user.getId()) {
                redirectBack(request, response, "Complaint not found", true);
                return;
            }
            if (complaint.isClosed()) {
                redirectToComplaint(request, response, "This complaint is already closed", true);
                return;
            }
            complaintDAO.postMessage(complaintId, user.getId(),
                    ComplaintMessageModel.ROLE_CUSTOMER, content.trim());
            redirectToComplaint(request, response, "Message sent", false);
        } catch (SQLException exception) {
            redirectToComplaint(request, response, "Database error: " + exception.getMessage(), true);
        }
    }

    private void handleClose(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        try {
            ComplaintModel complaint = complaintDAO.findById(complaintId);
            if (complaint == null || complaint.getUserId() != user.getId()) {
                redirectBack(request, response, "Complaint not found", true);
                return;
            }
            if (!complaint.isOpen()) {
                redirectToComplaint(request, response, "Complaint already closed", true);
                return;
            }
            boolean closed = complaintDAO.closeByCustomer(complaintId, user.getId());
            if (!closed) {
                redirectToComplaint(request, response, "Cannot close complaint", true);
                return;
            }
            redirectToComplaint(request, response, "Complaint closed. You can now mark the order as completed.",
                    false);
        } catch (SQLException exception) {
            redirectToComplaint(request, response, "Database error: " + exception.getMessage(), true);
        }
    }

    private void handleHistory(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws ServletException, IOException {
        try {
            List<ComplaintModel> complaints = complaintDAO.findAllForCustomer(user.getId());
            List<OrderModel> orders = new java.util.ArrayList<>();
            for (ComplaintModel c : complaints) {
                OrderModel o = orderDAO.findOrderDetail(c.getTransactionId());
                if (o != null) {
                    o.setItems(orderDAO.findOrderItems(c.getTransactionId()));
                    orders.add(o);
                }
            }
            request.setAttribute("complaints", complaints);
            request.setAttribute("orders", orders);
            request.setAttribute("complaintCategories", complaintDAO.findValidCategories());
            request.getRequestDispatcher("/views/customer/complaint-history.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load complaint history", exception);
        }
    }

    private void handlePoll(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        long sinceMillis = parseLong(request.getParameter("since"), 0L);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            if (complaintId <= 0) {
                out.write("{\"error\":\"invalid\"}");
                return;
            }
            ComplaintModel complaint = complaintDAO.findById(complaintId);
            if (complaint == null || complaint.getUserId() != user.getId()) {
                out.write("{\"error\":\"forbidden\"}");
                return;
            }
            java.sql.Timestamp since = new java.sql.Timestamp(sinceMillis);
            java.util.List<ComplaintMessageModel> messages = complaintDAO.findMessagesSince(complaintId, since);
            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("complaintId", complaint.getId());
            payload.put("status", complaint.getStatus());
            payload.put("messages", messages);
            out.write(toJson(payload));
        } catch (SQLException exception) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"database\"}");
        }
    }

    private void redirectToComplaint(HttpServletRequest request, HttpServletResponse response,
            String message, boolean isError) throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        String target;
        if (complaintId > 0) {
            target = request.getContextPath() + "/customer/complaint?complaintId=" + complaintId;
        } else {
            int orderId = parseInt(request.getParameter("orderId"), 0);
            target = request.getContextPath() + (orderId > 0
                    ? "/customer/complaint?orderId=" + orderId
                    : "/order-history");
        }
        String param = isError ? "error=" : "message=";
        response.sendRedirect(target + "&" + param
                + URLEncoder.encode(message, StandardCharsets.UTF_8));
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

    private long parseLong(String input, long fallback) {
        try {
            return Long.parseLong(input);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    /**
     * Minimal JSON serializer so we can avoid pulling in extra libraries.
     * Only used for the realtime polling endpoint.
     */
    private String toJson(Object value) {
        if (value == null) {
            return "null";
        }
        if (value instanceof Number || value instanceof Boolean) {
            return value.toString();
        }
        if (value instanceof ComplaintMessageModel) {
            ComplaintMessageModel m = (ComplaintMessageModel) value;
            StringBuilder sb = new StringBuilder("{");
            appendJsonString(sb, "id", String.valueOf(m.getId()), false);
            appendJsonString(sb, "senderId", String.valueOf(m.getSenderId()), true);
            appendJsonString(sb, "senderRole", m.getSenderRole(), true);
            appendJsonString(sb, "senderName", m.getSenderName(), true);
            appendJsonString(sb, "content", m.getContent(), true);
            appendJsonString(sb, "createdAt",
                    m.getCreatedAt() == null ? "" : String.valueOf(m.getCreatedAt().getTime()), true);
            sb.append("}");
            return sb.toString();
        }
        if (value instanceof java.util.Map) {
            java.util.Map<?, ?> map = (java.util.Map<?, ?>) value;
            StringBuilder sb = new StringBuilder("{");
            boolean first = true;
            for (java.util.Map.Entry<?, ?> entry : map.entrySet()) {
                if (!first) {
                    sb.append(',');
                }
                first = false;
                sb.append('"').append(escapeJson(String.valueOf(entry.getKey()))).append("\":");
                Object v = entry.getValue();
                if (v instanceof Number || v instanceof Boolean) {
                    sb.append(v);
                } else if (v == null) {
                    sb.append("null");
                } else {
                    sb.append(toJson(v));
                }
            }
            sb.append("}");
            return sb.toString();
        }
        if (value instanceof java.util.Collection) {
            java.util.Collection<?> col = (java.util.Collection<?>) value;
            StringBuilder sb = new StringBuilder("[");
            boolean first = true;
            for (Object item : col) {
                if (!first) {
                    sb.append(',');
                }
                first = false;
                sb.append(toJson(item));
            }
            sb.append("]");
            return sb.toString();
        }
        return "\"" + escapeJson(value.toString()) + "\"";
    }

    private void appendJsonString(StringBuilder sb, String key, String value, boolean appendComma) {
        if (appendComma) {
            sb.append(',');
        }
        sb.append('"').append(escapeJson(key)).append("\":");
        sb.append('"').append(escapeJson(value)).append('"');
    }

    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder(input.length() + 16);
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                case '\b':
                    sb.append("\\b");
                    break;
                case '\f':
                    sb.append("\\f");
                    break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }
}
