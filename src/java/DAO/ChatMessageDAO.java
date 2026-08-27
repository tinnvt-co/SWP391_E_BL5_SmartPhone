package DAO;

import config.DBContext;
import model.ChatMessageModel;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for ChatMessageModel.
 */
public class ChatMessageDAO {

    /**
     * Lấy tất cả message của 1 conversation (cho load ban đầu).
     */
    public List<ChatMessageModel> findByConversation(int conversationId) throws SQLException {
        String sql = "SELECT m.ID, m.ConversationID, m.SenderID, m.SenderRole, m.Content, m.CreatedAt, "
                + "       u.Name AS SenderName "
                + "FROM ChatMessage m "
                + "LEFT JOIN `User` u ON m.SenderID = u.ID "
                + "WHERE m.ConversationID = ? "
                + "ORDER BY m.CreatedAt ASC, m.ID ASC";
        List<ChatMessageModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, conversationId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMessage(rs));
                }
            }
        }
        return list;
    }

    /**
     * Lấy message mới hơn timestamp (cho polling).
     */
    public List<ChatMessageModel> findMessagesSince(int conversationId, Timestamp since) throws SQLException {
        String sql = "SELECT m.ID, m.ConversationID, m.SenderID, m.SenderRole, m.Content, m.CreatedAt, "
                + "       u.Name AS SenderName "
                + "FROM ChatMessage m "
                + "LEFT JOIN `User` u ON m.SenderID = u.ID "
                + "WHERE m.ConversationID = ? AND m.CreatedAt > ? "
                + "ORDER BY m.CreatedAt ASC, m.ID ASC";
        List<ChatMessageModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, conversationId);
            st.setTimestamp(2, since);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMessage(rs));
                }
            }
        }
        return list;
    }

    /**
     * Lưu message mới.
     */
    public int save(ChatMessageModel message) throws SQLException {
        String sql = "INSERT INTO ChatMessage (ConversationID, SenderID, SenderRole, Content, CreatedAt) "
                + "VALUES (?, ?, ?, ?, NOW())";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            st.setInt(1, message.getConversationId());
            st.setInt(2, message.getSenderId());
            st.setString(3, message.getSenderRole());
            st.setString(4, message.getContent());
            st.executeUpdate();
            try (ResultSet rs = st.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    /**
     * Đếm message trong conversation.
     */
    public int countByConversation(int conversationId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ChatMessage WHERE ConversationID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, conversationId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private ChatMessageModel mapMessage(ResultSet rs) throws SQLException {
        ChatMessageModel m = new ChatMessageModel();
        m.setId(rs.getInt("ID"));
        m.setConversationId(rs.getInt("ConversationID"));
        m.setSenderId(rs.getInt("SenderID"));
        m.setSenderRole(rs.getString("SenderRole"));
        m.setContent(rs.getString("Content"));
        m.setCreatedAt(rs.getTimestamp("CreatedAt"));
        m.setSenderName(rs.getString("SenderName"));
        return m;
    }
}
