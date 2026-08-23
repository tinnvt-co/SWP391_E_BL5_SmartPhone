package DAO;

import config.DBContext;
import model.ComplaintMessageModel;
import model.ComplaintModel;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Data Access Object for {@link ComplaintModel} and
 * {@link ComplaintMessageModel}.
 */
public class ComplaintDAO {

    private static final Set<String> VALID_CATEGORIES = Set.of(
            ComplaintModel.CATEGORY_NOT_RECEIVED,
            ComplaintModel.CATEGORY_WRONG_ITEM,
            ComplaintModel.CATEGORY_DAMAGED,
            ComplaintModel.CATEGORY_DEFECTIVE,
            ComplaintModel.CATEGORY_LATE_DELIVERY,
            ComplaintModel.CATEGORY_OTHER);

    private static final Set<String> OPEN_STATUSES = Set.of(
            ComplaintModel.STATUS_OPEN,
            ComplaintModel.STATUS_IN_PROGRESS);

    private static final Set<String> CLOSED_STATUSES = Set.of(
            ComplaintModel.STATUS_RESOLVED,
            ComplaintModel.STATUS_CLOSED,
            ComplaintModel.STATUS_REJECTED);

    public Set<String> findValidCategories() {
        return new LinkedHashSet<>(VALID_CATEGORIES);
    }

    public boolean hasOpenComplaint(int transactionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Complaint WHERE TransactionID = ? "
                + "AND Status IN (?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.setString(2, ComplaintModel.STATUS_OPEN);
            statement.setString(3, ComplaintModel.STATUS_IN_PROGRESS);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public boolean hasAnyComplaint(int transactionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Complaint WHERE TransactionID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public ComplaintModel findById(int id) throws SQLException {
        String sql = buildSelect()
                + "WHERE c.ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapComplaint(rs);
                }
            }
        }
        return null;
    }

    public ComplaintModel findOpenByTransaction(int transactionId) throws SQLException {
        String sql = buildSelect()
                + "WHERE c.TransactionID = ? AND c.Status IN (?, ?) "
                + "ORDER BY c.Created_at DESC LIMIT 1";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.setString(2, ComplaintModel.STATUS_OPEN);
            statement.setString(3, ComplaintModel.STATUS_IN_PROGRESS);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapComplaint(rs);
                }
            }
        }
        return null;
    }

    public ComplaintModel findLatestByTransaction(int transactionId) throws SQLException {
        String sql = buildSelect()
                + "WHERE c.TransactionID = ? "
                + "ORDER BY c.Created_at DESC LIMIT 1";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapComplaint(rs);
                }
            }
        }
        return null;
    }

    /**
     * Open a new complaint and post the initial description as the first
     * chat message so the conversation is consistent from the start.
     */
    public int createComplaint(int transactionId, int userId, String category,
            String customReason, String description) throws SQLException {
        if (!VALID_CATEGORIES.contains(category)) {
            throw new SQLException("Invalid complaint category: " + category);
        }
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                int complaintId;
                String insertComplaint = "INSERT INTO Complaint (TransactionID, UserID, Category, "
                        + "CustomReason, Description, Status) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(insertComplaint, PreparedStatement.RETURN_GENERATED_KEYS)) {
                    statement.setInt(1, transactionId);
                    statement.setInt(2, userId);
                    statement.setString(3, category);
                    if (customReason == null || customReason.isBlank()) {
                        statement.setNull(4, Types.VARCHAR);
                    } else {
                        statement.setString(4, customReason.trim());
                    }
                    if (description == null || description.isBlank()) {
                        statement.setNull(5, Types.VARCHAR);
                    } else {
                        statement.setString(5, description.trim());
                    }
                    statement.setString(6, ComplaintModel.STATUS_OPEN);
                    if (statement.executeUpdate() == 0) {
                        connection.rollback();
                        return 0;
                    }
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            connection.rollback();
                            return 0;
                        }
                        complaintId = keys.getInt(1);
                    }
                }

                String systemNote = buildInitialMessage(category, customReason, description);
                String insertMessage = "INSERT INTO ComplaintMessage (ComplaintID, SenderID, SenderRole, Content) "
                        + "VALUES (?, ?, ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(insertMessage)) {
                    statement.setInt(1, complaintId);
                    statement.setInt(2, userId);
                    statement.setString(3, ComplaintMessageModel.ROLE_CUSTOMER);
                    statement.setString(4, systemNote);
                    statement.executeUpdate();
                }

                connection.commit();
                return complaintId;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    public List<ComplaintMessageModel> findMessages(int complaintId) throws SQLException {
        String sql = "SELECT cm.ID, cm.ComplaintID, cm.SenderID, cm.SenderRole, cm.Content, cm.Created_at, "
                + "       u.Name AS SenderName "
                + "FROM ComplaintMessage cm "
                + "LEFT JOIN `User` u ON cm.SenderID = u.ID "
                + "WHERE cm.ComplaintID = ? "
                + "ORDER BY cm.Created_at ASC, cm.ID ASC";
        List<ComplaintMessageModel> messages = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, complaintId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    messages.add(mapMessage(rs));
                }
            }
        }
        return messages;
    }

    public List<ComplaintMessageModel> findMessagesSince(int complaintId, java.sql.Timestamp since) throws SQLException {
        String sql = "SELECT cm.ID, cm.ComplaintID, cm.SenderID, cm.SenderRole, cm.Content, cm.Created_at, "
                + "       u.Name AS SenderName "
                + "FROM ComplaintMessage cm "
                + "LEFT JOIN `User` u ON cm.SenderID = u.ID "
                + "WHERE cm.ComplaintID = ? AND cm.Created_at > ? "
                + "ORDER BY cm.Created_at ASC, cm.ID ASC";
        List<ComplaintMessageModel> messages = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, complaintId);
            statement.setTimestamp(2, since);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    messages.add(mapMessage(rs));
                }
            }
        }
        return messages;
    }

    /**
     * Append a chat message and update the parent complaint status (and
     * assigned_to on first staff reply) inside a single transaction.
     */
    public int postMessage(int complaintId, int senderId, String senderRole, String content) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                String insert = "INSERT INTO ComplaintMessage (ComplaintID, SenderID, SenderRole, Content) "
                        + "VALUES (?, ?, ?, ?)";
                int generatedId;
                try (PreparedStatement statement = connection.prepareStatement(insert, PreparedStatement.RETURN_GENERATED_KEYS)) {
                    statement.setInt(1, complaintId);
                    statement.setInt(2, senderId);
                    statement.setString(3, senderRole);
                    statement.setString(4, content.trim());
                    if (statement.executeUpdate() == 0) {
                        connection.rollback();
                        return 0;
                    }
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            connection.rollback();
                            return 0;
                        }
                        generatedId = keys.getInt(1);
                    }
                }

                String updateComplaint;
                if (ComplaintMessageModel.ROLE_CUSTOMER.equalsIgnoreCase(senderRole)) {
                    updateComplaint = "UPDATE Complaint SET Updated_at = CURRENT_TIMESTAMP WHERE ID = ?";
                    try (PreparedStatement statement = connection.prepareStatement(updateComplaint)) {
                        statement.setInt(1, complaintId);
                        statement.executeUpdate();
                    }
                } else {
                    updateComplaint = "UPDATE Complaint SET Status = ?, Assigned_to = COALESCE(Assigned_to, ?), "
                            + "Updated_at = CURRENT_TIMESTAMP WHERE ID = ?";
                    try (PreparedStatement statement = connection.prepareStatement(updateComplaint)) {
                        statement.setString(1, ComplaintModel.STATUS_IN_PROGRESS);
                        statement.setInt(2, senderId);
                        statement.setInt(3, complaintId);
                        statement.executeUpdate();
                    }
                }

                connection.commit();
                return generatedId;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    public boolean resolveComplaint(int complaintId, int staffId, String resolution, String note) throws SQLException {
        String sql = "UPDATE Complaint SET Status = ?, Resolution = ?, ResolutionNote = ?, "
                + "Closed_at = CURRENT_TIMESTAMP, Closed_by = ?, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? AND Status IN (?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, ComplaintModel.STATUS_RESOLVED);
            if (resolution == null || resolution.isBlank()) {
                statement.setNull(2, Types.VARCHAR);
            } else {
                statement.setString(2, resolution);
            }
            if (note == null || note.isBlank()) {
                statement.setNull(3, Types.VARCHAR);
            } else {
                statement.setString(3, note.trim());
            }
            statement.setInt(4, staffId);
            statement.setInt(5, complaintId);
            statement.setString(6, ComplaintModel.STATUS_OPEN);
            statement.setString(7, ComplaintModel.STATUS_IN_PROGRESS);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean rejectComplaint(int complaintId, int staffId, String note) throws SQLException {
        String sql = "UPDATE Complaint SET Status = ?, ResolutionNote = ?, "
                + "Closed_at = CURRENT_TIMESTAMP, Closed_by = ?, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? AND Status IN (?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, ComplaintModel.STATUS_REJECTED);
            if (note == null || note.isBlank()) {
                statement.setNull(2, Types.VARCHAR);
            } else {
                statement.setString(2, note.trim());
            }
            statement.setInt(3, staffId);
            statement.setInt(4, complaintId);
            statement.setString(5, ComplaintModel.STATUS_OPEN);
            statement.setString(6, ComplaintModel.STATUS_IN_PROGRESS);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean closeByCustomer(int complaintId, int customerId) throws SQLException {
        String sql = "UPDATE Complaint SET Status = ?, Closed_at = CURRENT_TIMESTAMP, Closed_by = ?, "
                + "Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? AND UserID = ? AND Status IN (?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, ComplaintModel.STATUS_CLOSED);
            statement.setInt(2, customerId);
            statement.setInt(3, complaintId);
            statement.setInt(4, customerId);
            statement.setString(5, ComplaintModel.STATUS_OPEN);
            statement.setString(6, ComplaintModel.STATUS_IN_PROGRESS);
            return statement.executeUpdate() > 0;
        }
    }

    public List<ComplaintModel> findOpenForManager(String keyword) throws SQLException {
        return findForManager(keyword, OPEN_STATUSES, "newest");
    }

    public List<ComplaintModel> findClosedForManager(String keyword) throws SQLException {
        return findForManager(keyword, CLOSED_STATUSES, "newest");
    }

    public List<ComplaintModel> findAllForCustomer(int userId) throws SQLException {
        String sql = buildSelect()
                + "WHERE c.UserID = ? "
                + "ORDER BY c.Created_at DESC, c.ID DESC";
        List<ComplaintModel> complaints = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    complaints.add(mapComplaint(rs));
                }
            }
        }
        return complaints;
    }

    public int countOpen() throws SQLException {
        return 0;
    }

    public int countResolved() throws SQLException {
        return 0;
    }

    public int countRejected() throws SQLException {
        return 0;
    }

    private List<ComplaintModel> findForManager(String keyword, Set<String> statusFilter, String sort) throws SQLException {
        return new ArrayList<>();
    }

    private String buildSelect() {
        return "SELECT c.ID, c.TransactionID, c.UserID, c.Category, c.CustomReason, c.Description, "
                + "       c.Status, c.Resolution, c.ResolutionNote, c.Assigned_to, "
                + "       c.Created_at, c.Updated_at, c.Closed_at, c.Closed_by, "
                + "       assignee.Name AS AssignedToName, "
                + "       closer.Name AS ClosedByName, "
                + "       cust.Name AS CustomerName, cust.Username AS CustomerUsername, "
                + "       o.Status AS OrderStatus, o.Total_price AS OrderTotal, o.Type AS OrderType, "
                + "       (SELECT COUNT(*) FROM ComplaintMessage cm WHERE cm.ComplaintID = c.ID) AS MessageCount "
                + "FROM Complaint c "
                + "JOIN `Transaction` o ON c.TransactionID = o.ID "
                + "JOIN `User` cust ON c.UserID = cust.ID "
                + "LEFT JOIN `User` assignee ON c.Assigned_to = assignee.ID "
                + "LEFT JOIN `User` closer ON c.Closed_by = closer.ID ";
    }

    private ComplaintModel mapComplaint(ResultSet rs) throws SQLException {
        ComplaintModel complaint = new ComplaintModel();
        complaint.setId(rs.getInt("ID"));
        complaint.setTransactionId(rs.getInt("TransactionID"));
        complaint.setUserId(rs.getInt("UserID"));
        complaint.setCategory(rs.getString("Category"));
        complaint.setCustomReason(rs.getString("CustomReason"));
        complaint.setDescription(rs.getString("Description"));
        complaint.setStatus(rs.getString("Status"));
        complaint.setResolution(rs.getString("Resolution"));
        complaint.setResolutionNote(rs.getString("ResolutionNote"));
        int assigned = rs.getInt("Assigned_to");
        complaint.setAssignedTo(rs.wasNull() ? null : assigned);
        complaint.setAssignedToName(rs.getString("AssignedToName"));
        complaint.setCreatedAt(rs.getTimestamp("Created_at"));
        complaint.setUpdatedAt(rs.getTimestamp("Updated_at"));
        complaint.setClosedAt(rs.getTimestamp("Closed_at"));
        int closedBy = rs.getInt("Closed_by");
        complaint.setClosedBy(rs.wasNull() ? null : closedBy);
        complaint.setClosedByName(rs.getString("ClosedByName"));
        complaint.setCustomerName(rs.getString("CustomerName"));
        complaint.setCustomerUsername(rs.getString("CustomerUsername"));
        complaint.setOrderStatus(rs.getString("OrderStatus"));
        BigDecimal total = rs.getBigDecimal("OrderTotal");
        complaint.setOrderTotal(total);
        complaint.setMessageCount(rs.getInt("MessageCount"));
        complaint.setOrderCode(String.format("ORD%04d", complaint.getTransactionId()));
        return complaint;
    }

    private ComplaintMessageModel mapMessage(ResultSet rs) throws SQLException {
        ComplaintMessageModel message = new ComplaintMessageModel();
        message.setId(rs.getInt("ID"));
        message.setComplaintId(rs.getInt("ComplaintID"));
        message.setSenderId(rs.getInt("SenderID"));
        message.setSenderRole(rs.getString("SenderRole"));
        message.setContent(rs.getString("Content"));
        message.setCreatedAt(rs.getTimestamp("Created_at"));
        message.setSenderName(rs.getString("SenderName"));
        return message;
    }

    private String buildInitialMessage(String category, String customReason, String description) {
        StringBuilder sb = new StringBuilder("[");
        sb.append(labelForCategory(category));
        sb.append("] ");
        if (customReason != null && !customReason.isBlank()) {
            sb.append(customReason.trim());
        }
        if (description != null && !description.isBlank()) {
            if (sb.length() > 0 && !sb.toString().endsWith(" ")) {
                sb.append(" ");
            }
            sb.append(description.trim());
        }
        return sb.toString();
    }

    private String labelForCategory(String code) {
        if (code == null) {
            return "Complaint";
        }
        switch (code) {
            case ComplaintModel.CATEGORY_NOT_RECEIVED:
                return "Product not received";
            case ComplaintModel.CATEGORY_WRONG_ITEM:
                return "Wrong item delivered";
            case ComplaintModel.CATEGORY_DAMAGED:
                return "Damaged on arrival";
            case ComplaintModel.CATEGORY_DEFECTIVE:
                return "Defective / not working";
            case ComplaintModel.CATEGORY_LATE_DELIVERY:
                return "Delivery too late";
            case ComplaintModel.CATEGORY_OTHER:
                return "Other";
            default:
                return "Complaint";
        }
    }
}
