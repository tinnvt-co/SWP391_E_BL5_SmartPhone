package DAO;

import config.DBContext;
import model.ConversationModel;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for ConversationModel.
 * Handles conversation lifecycle: create, find, update status, assign.
 */
public class ConversationDAO {

    /**
     * Tìm conversation OPEN/IN_PROGRESS hiện tại của 1 customer.
     * Customer chỉ có tối đa 1 conversation đang mở.
     */
    public ConversationModel findOpenConversation(int userId) throws SQLException {
        String sql = "SELECT c.ID, c.UserID, c.Status, c.LastMessage, c.LastMessageAt, "
                + "       c.AssignedTo, c.ClosedBy, c.ClosedAt, c.CreatedAt, c.UpdatedAt, "
                + "       u.Name AS UserName, u.Email AS UserEmail, "
                + "       a.Name AS AssignedToName "
                + "FROM Conversation c "
                + "LEFT JOIN `User` u ON c.UserID = u.ID "
                + "LEFT JOIN `User` a ON c.AssignedTo = a.ID "
                + "WHERE c.UserID = ? AND c.Status IN ('OPEN', 'IN_PROGRESS') "
                + "ORDER BY c.CreatedAt DESC LIMIT 1";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapConversation(rs);
                }
            }
        }
        return null;
    }

    /**
     * Tìm conversation theo ID.
     */
    public ConversationModel findById(int id) throws SQLException {
        String sql = "SELECT c.ID, c.UserID, c.Status, c.LastMessage, c.LastMessageAt, "
                + "       c.AssignedTo, c.ClosedBy, c.ClosedAt, c.CreatedAt, c.UpdatedAt, "
                + "       u.Name AS UserName, u.Email AS UserEmail, "
                + "       a.Name AS AssignedToName "
                + "FROM Conversation c "
                + "LEFT JOIN `User` u ON c.UserID = u.ID "
                + "LEFT JOIN `User` a ON c.AssignedTo = a.ID "
                + "WHERE c.ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapConversation(rs);
                }
            }
        }
        return null;
    }

    /**
     * Lấy tất cả conversation của 1 customer (mới nhất trước).
     */
    public List<ConversationModel> findByUser(int userId) throws SQLException {
        String sql = "SELECT c.ID, c.UserID, c.Status, c.LastMessage, c.LastMessageAt, "
                + "       c.AssignedTo, c.ClosedBy, c.ClosedAt, c.CreatedAt, c.UpdatedAt, "
                + "       u.Name AS UserName, u.Email AS UserEmail, "
                + "       a.Name AS AssignedToName "
                + "FROM Conversation c "
                + "LEFT JOIN `User` u ON c.UserID = u.ID "
                + "LEFT JOIN `User` a ON c.AssignedTo = a.ID "
                + "WHERE c.UserID = ? "
                + "ORDER BY FIELD(c.Status,'OPEN','IN_PROGRESS','CLOSED'), c.LastMessageAt DESC";
        List<ConversationModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapConversation(rs));
                }
            }
        }
        return list;
    }

    /**
     * Tạo conversation mới cho customer.
     */
    public int create(int userId) throws SQLException {
        String sql = "INSERT INTO Conversation (UserID, Status, CreatedAt, UpdatedAt) "
                + "VALUES (?, 'OPEN', NOW(), NOW())";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            st.setInt(1, userId);
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
     * Lấy danh sách tất cả conversation cho manager/staff (phân trang).
     * Sort: OPEN/In_Progress trước → theo last message mới nhất.
     */
    public List<ConversationModel> findAllForManager(int offset, int limit, String statusFilter) throws SQLException {
        String statusCond = "";
        List<Object> params = new ArrayList<>();
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            statusCond = "AND c.Status = ?";
            params.add(statusFilter);
        }
        String sql = "SELECT c.ID, c.UserID, c.Status, c.LastMessage, c.LastMessageAt, "
                + "       c.AssignedTo, c.ClosedBy, c.ClosedAt, c.CreatedAt, c.UpdatedAt, "
                + "       u.Name AS UserName, u.Email AS UserEmail, "
                + "       a.Name AS AssignedToName "
                + "FROM Conversation c "
                + "LEFT JOIN `User` u ON c.UserID = u.ID "
                + "LEFT JOIN `User` a ON c.AssignedTo = a.ID "
                + "WHERE 1=1 " + statusCond + " "
                + "ORDER BY FIELD(c.Status,'OPEN','IN_PROGRESS','CLOSED'), c.LastMessageAt DESC "
                + "LIMIT ? OFFSET ?";
        params.add(limit);
        params.add(offset);
        List<ConversationModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapConversation(rs));
                }
            }
        }
        return list;
    }

    /**
     * Đếm tổng conversation cho manager (phân trang).
     */
    public int countAllForManager(String statusFilter) throws SQLException {
        String statusCond = "";
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            statusCond = "WHERE c.Status = ?";
        }
        String sql = "SELECT COUNT(*) FROM Conversation c " + statusCond;
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            if (!statusCond.isEmpty()) {
                st.setString(1, statusFilter);
            }
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Cập nhật LastMessage của conversation.
     */
    public void updateLastMessage(int conversationId, String message, Timestamp timestamp) throws SQLException {
        String sql = "UPDATE Conversation SET LastMessage = ?, LastMessageAt = ?, UpdatedAt = NOW() WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, message);
            st.setTimestamp(2, timestamp);
            st.setInt(3, conversationId);
            st.executeUpdate();
        }
    }

    /**
     * Gán staff/manager phụ trách conversation.
     */
    public void assignTo(int conversationId, int assignedToId) throws SQLException {
        String sql = "UPDATE Conversation SET AssignedTo = ?, Status = 'IN_PROGRESS', UpdatedAt = NOW() WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, assignedToId);
            st.setInt(2, conversationId);
            st.executeUpdate();
        }
    }

    /**
     * Đóng conversation.
     */
    public void closeConversation(int conversationId, int closedById) throws SQLException {
        String sql = "UPDATE Conversation SET Status = 'CLOSED', ClosedBy = ?, ClosedAt = NOW(), "
                + "UpdatedAt = NOW() WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, closedById);
            st.setInt(2, conversationId);
            st.executeUpdate();
        }
    }

    /**
     * Xóa conversation (manager xóa hẳn).
     */
    public void delete(int conversationId) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement st1 = connection.prepareStatement("DELETE FROM ChatMessage WHERE ConversationID = ?")) {
                    st1.setInt(1, conversationId);
                    st1.executeUpdate();
                }
                try (PreparedStatement st2 = connection.prepareStatement("DELETE FROM Conversation WHERE ID = ?")) {
                    st2.setInt(1, conversationId);
                    st2.executeUpdate();
                }
                connection.commit();
            } catch (SQLException ex) {
                connection.rollback();
                throw ex;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    /**
     * Đếm conversation OPEN/IN_PROGRESS (cho dashboard badge).
     */
    public int countOpen() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Conversation WHERE Status IN ('OPEN', 'IN_PROGRESS')";
        try (Connection connection = DBContext.getConnection(); PreparedStatement st = connection.prepareStatement(sql)) {
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private ConversationModel mapConversation(ResultSet rs) throws SQLException {
        ConversationModel c = new ConversationModel();
        c.setId(rs.getInt("ID"));
        c.setUserId(rs.getInt("UserID"));
        c.setStatus(rs.getString("Status"));
        c.setLastMessage(rs.getString("LastMessage"));
        c.setLastMessageAt(rs.getTimestamp("LastMessageAt"));
        c.setAssignedTo((Integer) rs.getObject("AssignedTo"));
        c.setClosedBy((Integer) rs.getObject("ClosedBy"));
        c.setClosedAt(rs.getTimestamp("ClosedAt"));
        c.setCreatedAt(rs.getTimestamp("CreatedAt"));
        c.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        c.setUserName(rs.getString("UserName"));
        c.setUserEmail(rs.getString("UserEmail"));
        c.setAssignedToName(rs.getString("AssignedToName"));
        return c;
    }
}
