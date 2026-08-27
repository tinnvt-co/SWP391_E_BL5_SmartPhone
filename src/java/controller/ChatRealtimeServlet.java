package controller;

import DAO.ChatMessageDAO;
import DAO.ConversationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ChatMessageModel;
import model.ConversationModel;
import model.UserModel;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;

/**
 * Realtime polling endpoint cho chatbox customer ↔ manager.
 *
 * <p>Endpoint:
 * GET /chat-realtime?conversationId=...&since=...</p>
 *
 * <p>Quyền truy cập:
 * - Customer: chỉ được xem conversation do chính mình tạo.
 * - Manager/Staff: được xem conversation để reply.</p>
 */
@WebServlet(
        name = "ChatRealtimeServlet",
        urlPatterns = {"/chat-realtime"}
)
public class ChatRealtimeServlet extends HttpServlet {

    private final ConversationDAO conversationDAO = new ConversationDAO();
    private final ChatMessageDAO messageDAO = new ChatMessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        UserModel user = currentUser(session);
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(response, "{\"error\":\"unauthorized\"}");
            return;
        }

        int conversationId = parseInt(request.getParameter("conversationId"), 0);
        long sinceMillis = parseLong(request.getParameter("since"), 0L);

        if (conversationId <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(response, "{\"error\":\"invalid\"}");
            return;
        }

        try {
            ConversationModel conv = conversationDAO.findById(conversationId);
            if (conv == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJson(response, "{\"error\":\"not_found\"}");
                return;
            }

            // Kiểm tra quyền: customer chỉ xem conversation của mình
            boolean isCustomer = conv.getUserId() == user.getId();
            boolean isManager = isManager(user);
            if (!isCustomer && !isManager) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                writeJson(response, "{\"error\":\"forbidden\"}");
                return;
            }

            List<ChatMessageModel> messages = messageDAO.findMessagesSince(
                    conversationId,
                    new java.sql.Timestamp(sinceMillis)
            );

            StringBuilder sb = new StringBuilder(256);
            sb.append("{\"conversationId\":").append(conv.getId());
            sb.append(",\"status\":\"").append(escape(conv.getStatus())).append("\"");
            sb.append(",\"messages\":[");
            boolean first = true;
            for (ChatMessageModel message : messages) {
                if (!first) sb.append(',');
                first = false;
                appendMessageJson(sb, message);
            }
            sb.append("]}");
            writeJson(response, sb.toString());

        } catch (SQLException ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJson(response, "{\"error\":\"database\"}");
        }
    }

    private void appendMessageJson(StringBuilder sb, ChatMessageModel message) {
        sb.append('{')
                .append("\"id\":").append(message.getId())
                .append(",\"senderId\":").append(message.getSenderId())
                .append(",\"senderRole\":\"").append(escape(message.getSenderRole())).append("\"")
                .append(",\"senderName\":\"").append(escape(message.getSenderName() != null ? message.getSenderName() : "")).append("\"")
                .append(",\"content\":\"").append(escape(message.getContent())).append("\"")
                .append(",\"createdAt\":").append(message.getCreatedAt() == null ? 0L : message.getCreatedAt().getTime())
                .append('}');
    }

    private void writeJson(HttpServletResponse response, String payload) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter writer = response.getWriter()) {
            writer.write(payload);
        }
    }

    private UserModel currentUser(HttpSession session) {
        if (session == null) return null;
        Object attr = session.getAttribute("currentUser");
        return attr instanceof UserModel ? (UserModel) attr : null;
    }

    private boolean isManager(UserModel user) {
        String role = user.getRoleName() == null ? "" : user.getRoleName().trim().toUpperCase(Locale.ROOT);
        // Chat chỉ giữa Customer và Manager. Staff/Admin không tham gia.
        return "MANAGER".equals(role);
    }

    private int parseInt(String input, int fallback) {
        try { return Integer.parseInt(input); } catch (Exception e) { return fallback; }
    }

    private long parseLong(String input, long fallback) {
        try { return Long.parseLong(input); } catch (Exception e) { return fallback; }
    }

    private String escape(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder(input.length() + 16);
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                case '<': sb.append("\\u003c"); break;
                case '>': sb.append("\\u003e"); break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else sb.append(c);
            }
        }
        return sb.toString();
    }
}
