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
 * Manager-side complaint handling: list open / closed complaints, view the
 * chatbox thread, post replies, and resolve / reject the complaint.
 */
@WebServlet(name = "ManagerComplaintController", urlPatterns = {"/manager/complaint"})
public class ManagerComplaintController extends HttpServlet {

    private static final Set<String> VALID_RESOLUTIONS = Set.of(
            ComplaintModel.RESOLUTION_REFUND,
            ComplaintModel.RESOLUTION_REPLACE,
            ComplaintModel.RESOLUTION_OTHER);

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

        String idParam = request.getParameter("id");
        if (idParam != null) {
            showDetail(request, response, user, parseInt(idParam, 0));
            return;
        }

        list(request, response);
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
            action = "reply";
        }

        switch (action.toLowerCase()) {
            case "resolve":
                handleResolve(request, response, user);
                return;
            case "reject":
                handleReject(request, response, user);
                return;
            case "reply":
            default:
                handleReply(request, response, user);
        }
    }

    private void list(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String view = request.getParameter("view");
        if (view == null || view.isBlank()) {
            view = "open";
        }
        String keyword = request.getParameter("q");
        try {
            List<ComplaintModel> complaints;
            if ("closed".equalsIgnoreCase(view)) {
                complaints = complaintDAO.findClosedForManager(keyword);
            } else {
                view = "open";
                complaints = complaintDAO.findOpenForManager(keyword);
            }
            request.setAttribute("complaints", complaints);
            request.setAttribute("selectedView", view);
            request.setAttribute("keyword", keyword == null ? "" : keyword);
            request.setAttribute("totalOpen", complaintDAO.countOpen());
            request.setAttribute("totalResolved", complaintDAO.countResolved());
            request.setAttribute("totalRejected", complaintDAO.countRejected());
            request.getRequestDispatcher("/views/manager/complaint-list.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load complaint list", exception);
        }
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response,
            UserModel user, int complaintId) throws ServletException, IOException {
        if (complaintId <= 0) {
            redirectList(request, response, "Invalid complaint id", true);
            return;
        }
        try {
            ComplaintModel complaint = complaintDAO.findById(complaintId);
            if (complaint == null) {
                redirectList(request, response, "Complaint not found", true);
                return;
            }
            List<ComplaintMessageModel> messages = complaintDAO.findMessages(complaintId);
            OrderModel order = orderDAO.findOrderDetail(complaint.getTransactionId());
            List<OrderItemModel> orderItems = order == null
                    ? java.util.Collections.emptyList()
                    : orderDAO.findOrderItems(complaint.getTransactionId());
            request.setAttribute("complaint", complaint);
            request.setAttribute("messages", messages);
            request.setAttribute("order", order);
            request.setAttribute("orderItems", orderItems);
            request.setAttribute("managerUser", user);
            request.getRequestDispatcher("/views/manager/complaint-detail.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load complaint", exception);
        }
    }

    private void handleReply(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        String content = request.getParameter("content");
        if (complaintId <= 0 || content == null || content.trim().isEmpty()) {
            redirectDetail(request, response, complaintId, "Reply cannot be empty", true);
            return;
        }
        if (content.length() > 2000) {
            redirectDetail(request, response, complaintId, "Reply is too long", true);
            return;
        }
        try {
            ComplaintModel complaint = complaintDAO.findById(complaintId);
            if (complaint == null) {
                redirectList(request, response, "Complaint not found", true);
                return;
            }
            if (complaint.isClosed()) {
                redirectDetail(request, response, complaintId, "Complaint already closed", true);
                return;
            }
            String role = "Manager".equalsIgnoreCase(user.getRoleName())
                    ? ComplaintMessageModel.ROLE_MANAGER
                    : ComplaintMessageModel.ROLE_STAFF;
            complaintDAO.postMessage(complaintId, user.getId(), role, content.trim());
            redirectDetail(request, response, complaintId, "Reply sent", false);
        } catch (SQLException exception) {
            redirectDetail(request, response, complaintId, "Database error: " + exception.getMessage(), true);
        }
    }

    private void handleResolve(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        String resolution = request.getParameter("resolution");
        String note = request.getParameter("note");

        if (complaintId <= 0) {
            redirectList(request, response, "Invalid complaint id", true);
            return;
        }
        if (resolution == null || !VALID_RESOLUTIONS.contains(resolution)) {
            redirectDetail(request, response, complaintId, "Please choose a resolution", true);
            return;
        }

        try {
            boolean ok = complaintDAO.resolveComplaint(complaintId, user.getId(), resolution, note);
            if (!ok) {
                redirectDetail(request, response, complaintId, "Cannot resolve complaint", true);
                return;
            }
            redirectDetail(request, response, complaintId, "Complaint resolved", false);
        } catch (SQLException exception) {
            redirectDetail(request, response, complaintId, "Database error: " + exception.getMessage(), true);
        }
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        String note = request.getParameter("note");
        if (complaintId <= 0) {
            redirectList(request, response, "Invalid complaint id", true);
            return;
        }
        try {
            boolean ok = complaintDAO.rejectComplaint(complaintId, user.getId(), note);
            if (!ok) {
                redirectDetail(request, response, complaintId, "Cannot reject complaint", true);
                return;
            }
            redirectDetail(request, response, complaintId, "Complaint rejected", false);
        } catch (SQLException exception) {
            redirectDetail(request, response, complaintId, "Database error: " + exception.getMessage(), true);
        }
    }

    private void handlePoll(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws IOException {
        int complaintId = parseInt(request.getParameter("complaintId"), 0);
        long sinceMillis = parseLong(request.getParameter("since"), 0L);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            ComplaintModel complaint = complaintDAO.findById(complaintId);
            if (complaint == null) {
                out.write("{\"error\":\"not_found\"}");
                return;
            }
            java.sql.Timestamp since = new java.sql.Timestamp(sinceMillis);
            List<ComplaintMessageModel> messages = complaintDAO.findMessagesSince(complaintId, since);
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

    private void redirectDetail(HttpServletRequest request, HttpServletResponse response,
            int complaintId, String message, boolean isError) throws IOException {
        String param = isError ? "error=" : "message=";
        response.sendRedirect(request.getContextPath() + "/manager/complaint?id="
                + complaintId + "&" + param
                + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }

    private void redirectList(HttpServletRequest request, HttpServletResponse response,
            String message, boolean isError) throws IOException {
        String param = isError ? "error=" : "message=";
        response.sendRedirect(request.getContextPath() + "/manager/complaint?"
                + param + URLEncoder.encode(message, StandardCharsets.UTF_8));
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
            appendJsonField(sb, "id", String.valueOf(m.getId()), false);
            appendJsonField(sb, "senderId", String.valueOf(m.getSenderId()), true);
            appendJsonField(sb, "senderRole", m.getSenderRole(), true);
            appendJsonField(sb, "senderName", m.getSenderName(), true);
            appendJsonField(sb, "content", m.getContent(), true);
            appendJsonField(sb, "createdAt",
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

    private void appendJsonField(StringBuilder sb, String key, String value, boolean appendComma) {
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
