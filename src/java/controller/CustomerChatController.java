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
 * Controller cho customer: mở/tin nhắn/đóng conversation.
 *
 * URL: /customer/chat
 * GET  - Hiển thị widget chatbox (load messages)
 * POST - action=send|close
 */
@WebServlet(name = "CustomerChatController", urlPatterns = {"/customer/chat"})
public class CustomerChatController extends HttpServlet {

    private final ConversationDAO conversationDAO = new ConversationDAO();
    private final ChatMessageDAO messageDAO = new ChatMessageDAO();
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

        // Check if this is a direct request (not include)
        boolean isDirectRequest = request.getAttribute("jakarta.servlet.include.request_uri") == null
                && request.getAttribute("javax.servlet.include.request_uri") == null;

        try {
            // If direct request, show full page (customer-chat.jsp)
            if (isDirectRequest) {
                String conversationIdParam = request.getParameter("conversationId");
                int conversationId = 0;
                if (conversationIdParam != null && !conversationIdParam.isBlank()) {
                    try {
                        conversationId = Integer.parseInt(conversationIdParam);
                    } catch (NumberFormatException ignored) {}
                }

                List<ConversationModel> allConversations = conversationDAO.findByUser(user.getId());
                request.setAttribute("conversations", allConversations);

                ConversationModel selectedConv = null;
                if (conversationId > 0) {
                    for (ConversationModel c : allConversations) {
                        if (c.getId() == conversationId) {
                            selectedConv = c;
                            break;
                        }
                    }
                } else if (!allConversations.isEmpty()) {
                    selectedConv = allConversations.get(0);
                }

                request.setAttribute("selectedConversation", selectedConv);
                if (selectedConv != null) {
                    List<ChatMessageModel> messages = messageDAO.findByConversation(selectedConv.getId());
                    request.setAttribute("messages", messages);
                }

                request.getRequestDispatcher("/views/customer/customer-chat.jsp").forward(request, response);
                return;
            }

            // Otherwise (include), load widget data
            ConversationModel conv = conversationDAO.findOpenConversation(user.getId());
            request.setAttribute("chatConversation", conv);
            if (conv != null) {
                List<ChatMessageModel> messages = messageDAO.findByConversation(conv.getId());
                request.setAttribute("chatMessages", messages);
            }
        } catch (SQLException ex) {
            if (isDirectRequest) {
                redirectBack(request, response, "Cannot load chat. Please try again.");
            }
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

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "send" -> handleSend(request, response, user);
                case "close" -> handleClose(request, response, user);
                default -> redirectBack(request, response, "Invalid action");
            }
        } catch (SQLException ex) {
            redirectBack(request, response, "Database error: " + ex.getMessage());
        }
    }

    private void handleSend(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws SQLException, IOException {
        String content = request.getParameter("content");
        if (content == null || content.trim().isEmpty()) {
            redirectBack(request, response, "Message cannot be empty");
            return;
        }
        if (content.length() > MAX_MESSAGE_LENGTH) {
            redirectBack(request, response, "Message is too long (max 2000 characters)");
            return;
        }

        int conversationId = 0;
        String conversationIdParam = request.getParameter("conversationId");
        if (conversationIdParam != null && !conversationIdParam.isBlank()) {
            try {
                conversationId = Integer.parseInt(conversationIdParam);
            } catch (NumberFormatException ignored) {}
        }

        // Nếu không có conversationId, tìm conversation mở
        if (conversationId <= 0) {
            ConversationModel conv = conversationDAO.findOpenConversation(user.getId());
            if (conv != null) {
                conversationId = conv.getId();
            }
        }

        // Tạo conversation mới nếu chưa có
        if (conversationId <= 0) {
            conversationId = conversationDAO.create(user.getId());
            if (conversationId < 0) {
                redirectBack(request, response, "Cannot start conversation");
                return;
            }
        }

        ChatMessageModel message = new ChatMessageModel(
                conversationId, user.getId(), "CUSTOMER", content.trim()
        );
        int msgId = messageDAO.save(message);

        // Cập nhật last message của conversation
        Timestamp now = new Timestamp(System.currentTimeMillis());
        conversationDAO.updateLastMessage(conversationId, content.trim(), now);

        // Redirect về trang chat
        response.sendRedirect(request.getContextPath() + "/customer/chat?conversationId=" + conversationId + "&flash=" + URLEncoder.encode("Message sent!", StandardCharsets.UTF_8));
    }

    private void handleClose(HttpServletRequest request, HttpServletResponse response, UserModel user)
            throws SQLException, IOException {
        // Close disabled: chat is always open
        redirectBack(request, response, "Close is disabled");
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        String referer = request.getHeader("Referer");
        String target = (referer != null && !referer.isBlank())
                ? referer
                : request.getContextPath() + "/home";
        response.sendRedirect(target + (target.contains("?") ? "&" : "?") + "flash="
                + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }
}
