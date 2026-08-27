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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

/**
 * Controller cho manager/staff: quản lý chat inbox + reply conversation.
 *
 * URL: /manager/chat
 * GET  - Danh sách conversations (inbox)
 * GET  - ?conversationId=N → Chi tiết conversation + messages
 * POST - action=reply|assign|close|delete
 */
@WebServlet(name = "ManagerChatController", urlPatterns = {"/manager/chat"})
public class ManagerChatController extends HttpServlet {

    private final ConversationDAO conversationDAO = new ConversationDAO();
    private final ChatMessageDAO messageDAO = new ChatMessageDAO();
    private static final int PAGE_SIZE = 20;
    private static final int MAX_MESSAGE_LENGTH = 2000;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        UserModel user = (UserModel) session.getAttribute("currentUser");

        // Chỉ Manager mới có quyền truy cập chat inbox. Staff không tham gia.
        if (!isManager(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only manager can access chat inbox");
            return;
        }

        int page = parseInt(request.getParameter("page"), 1);
        if (page < 1) page = 1;
        int offset = (page - 1) * PAGE_SIZE;

        try {
            List<ConversationModel> conversations = conversationDAO.findAllForManager(offset, PAGE_SIZE, null);
            int total = conversationDAO.countAllForManager(null);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            ConversationModel selectedConv = null;
            List<ChatMessageModel> messages = null;
            int conversationId = parseInt(request.getParameter("conversationId"), 0);
            if (conversationId > 0) {
                selectedConv = conversationDAO.findById(conversationId);
                if (selectedConv != null) {
                    messages = messageDAO.findByConversation(conversationId);
                }
            }

            request.setAttribute("conversations", conversations);
            request.setAttribute("total", total);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("selectedConversation", selectedConv);
            request.setAttribute("messages", messages);

            request.getRequestDispatcher("/views/manager/chat-inbox.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("flashError", "Cannot load chat list: " + ex.getMessage());
            request.setAttribute("conversations", java.util.Collections.emptyList());
            request.getRequestDispatcher("/views/manager/chat-inbox.jsp").forward(request, response);
        }
    }

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

        // Chỉ Manager mới được reply. Staff không tham gia chat.
        if (!isManager(user)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "reply" -> handleReply(request, response, user);
                case "assign" -> handleAssign(request, response, user);
                case "close" -> handleClose(request, response, user);
                case "delete" -> handleDelete(request, response, user);
                default -> redirectBack(request, response, "Invalid action");
            }
        } catch (SQLException ex) {
            redirectBack(request, response, "Database error: " + ex.getMessage());
        }
    }

    private void handleReply(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws SQLException, IOException {
        int conversationId = parseInt(request.getParameter("conversationId"), 0);
        String content = request.getParameter("content");

        if (conversationId <= 0 || content == null || content.trim().isEmpty()) {
            redirectBack(request, response, "Conversation and message are required");
            return;
        }
        if (content.length() > MAX_MESSAGE_LENGTH) {
            redirectBack(request, response, "Message is too long (max 2000 characters)");
            return;
        }

        ConversationModel conv = conversationDAO.findById(conversationId);
        if (conv == null) {
            redirectBack(request, response, "Conversation not found");
            return;
        }

        String senderRole = "MANAGER";
        ChatMessageModel message = new ChatMessageModel(conversationId, user.getId(), senderRole, content.trim());
        messageDAO.save(message);

        Timestamp now = new Timestamp(System.currentTimeMillis());
        conversationDAO.updateLastMessage(conversationId, content.trim(), now);
        conversationDAO.assignTo(conversationId, user.getId());

        response.sendRedirect(request.getContextPath() + "/manager/chat?conversationId=" + conversationId);
    }

    private void handleAssign(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws SQLException, IOException {
        int conversationId = parseInt(request.getParameter("conversationId"), 0);
        if (conversationId <= 0) {
            redirectBack(request, response, "Conversation not found");
            return;
        }
        conversationDAO.assignTo(conversationId, user.getId());
        response.sendRedirect(request.getContextPath() + "/manager/chat?conversationId=" + conversationId);
    }

    private void handleClose(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws SQLException, IOException {
        // Close disabled: chat is always open
        response.sendRedirect(request.getContextPath() + "/manager/chat?flash=" +
                URLEncoder.encode("Close is disabled", StandardCharsets.UTF_8));
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws SQLException, IOException {
        // Delete disabled - prevent deletion of conversations
        redirectBack(request, response, "Delete is disabled");
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        String conversationId = request.getParameter("conversationId");
        String base = request.getContextPath() + "/manager/chat";
        if (conversationId != null && !conversationId.isEmpty()) {
            base += "?conversationId=" + conversationId;
        }
        response.sendRedirect(base + "&flash=" + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }

    private int parseInt(String input, int fallback) {
        try { return Integer.parseInt(input); } catch (Exception e) { return fallback; }
    }

    private boolean isManager(UserModel user) {
        if (user == null) return false;
        String role = user.getRoleName() == null ? "" : user.getRoleName().trim().toUpperCase();
        // Chat chỉ giữa Customer và Manager. Staff/Admin không tham gia.
        return "MANAGER".equals(role);
    }
}
