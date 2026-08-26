package DAO;

import config.DBContext;
import model.CancelRequestModel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class CancelRequestDAO {

    private static final Set<String> VALID_REASONS = Set.of(
            "CHANGED_MIND",
            "WRONG_PRODUCT",
            "FOUND_CHEAPER",
            "LONG_DELIVERY",
            "OTHER");

    private static final Set<String> VALID_STATUSES = Set.of(
            CancelRequestModel.STATUS_PENDING,
            CancelRequestModel.STATUS_APPROVED,
            CancelRequestModel.STATUS_REJECTED);

    public boolean hasActiveRequest(int transactionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM CancelRequest WHERE TransactionID = ? AND Status = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.setString(2, CancelRequestModel.STATUS_PENDING);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public CancelRequestModel findById(int id) throws SQLException {
        String sql = "SELECT cr.ID, cr.TransactionID, cr.UserID, cr.Reason, cr.CustomReason, "
                + "       cr.BankName, cr.BankAccountNumber, cr.BankAccountHolder, "
                + "       cr.Status, cr.StaffNote, cr.Created_at, cr.Updated_at, "
                + "       cr.Processed_by, cr.Processed_at, "
                + "       u.Name AS ProcessedByName "
                + "FROM CancelRequest cr "
                + "LEFT JOIN `User` u ON cr.Processed_by = u.ID "
                + "WHERE cr.ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapRequest(rs);
                }
            }
        }
        return null;
    }

    public CancelRequestModel findActiveRequest(int transactionId) throws SQLException {
        String sql = "SELECT cr.ID, cr.TransactionID, cr.UserID, cr.Reason, cr.CustomReason, "
                + "       cr.BankName, cr.BankAccountNumber, cr.BankAccountHolder, "
                + "       cr.Status, cr.StaffNote, cr.Created_at, cr.Updated_at, "
                + "       cr.Processed_by, cr.Processed_at, "
                + "       u.Name AS ProcessedByName "
                + "FROM CancelRequest cr "
                + "LEFT JOIN `User` u ON cr.Processed_by = u.ID "
                + "WHERE cr.TransactionID = ? AND cr.Status = ? "
                + "ORDER BY cr.Created_at DESC LIMIT 1";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.setString(2, CancelRequestModel.STATUS_PENDING);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapRequest(rs);
                }
            }
        }
        return null;
    }

    public CancelRequestModel findLatestRequest(int transactionId) throws SQLException {
        String sql = "SELECT cr.ID, cr.TransactionID, cr.UserID, cr.Reason, cr.CustomReason, "
                + "       cr.BankName, cr.BankAccountNumber, cr.BankAccountHolder, "
                + "       cr.Status, cr.StaffNote, cr.Created_at, cr.Updated_at, "
                + "       cr.Processed_by, cr.Processed_at, "
                + "       u.Name AS ProcessedByName "
                + "FROM CancelRequest cr "
                + "LEFT JOIN `User` u ON cr.Processed_by = u.ID "
                + "WHERE cr.TransactionID = ? "
                + "ORDER BY cr.Created_at DESC LIMIT 1";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapRequest(rs);
                }
            }
        }
        return null;
    }

    public int createRequest(int transactionId, int userId, String reason, String customReason) throws SQLException {
        return createRequest(transactionId, userId, reason, customReason, null, null, null);
    }

    public int createRequest(int transactionId, int userId, String reason, String customReason,
            String bankName, String bankAccountNumber, String bankAccountHolder) throws SQLException {
        if (!VALID_REASONS.contains(reason)) {
            throw new SQLException("Invalid cancel reason: " + reason);
        }
        if (hasActiveRequest(transactionId)) {
            throw new SQLException("A pending cancel request already exists for this order");
        }
        String sql = "INSERT INTO CancelRequest (TransactionID, UserID, Reason, CustomReason, "
                + "BankName, BankAccountNumber, BankAccountHolder, Status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, transactionId);
            statement.setInt(2, userId);
            statement.setString(3, reason);
            if (customReason == null || customReason.isBlank()) {
                statement.setNull(4, Types.VARCHAR);
            } else {
                statement.setString(4, customReason.trim());
            }
            if (bankName == null || bankName.isBlank()) {
                statement.setNull(5, Types.VARCHAR);
            } else {
                statement.setString(5, bankName.trim());
            }
            if (bankAccountNumber == null || bankAccountNumber.isBlank()) {
                statement.setNull(6, Types.VARCHAR);
            } else {
                statement.setString(6, bankAccountNumber.trim());
            }
            if (bankAccountHolder == null || bankAccountHolder.isBlank()) {
                statement.setNull(7, Types.VARCHAR);
            } else {
                statement.setString(7, bankAccountHolder.trim());
            }
            statement.setString(8, CancelRequestModel.STATUS_PENDING);
            int affected = statement.executeUpdate();
            if (affected == 0) {
                return 0;
            }
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Approve a cancel request: update the request status to APPROVED, set
     * the order status to CANCELLED, and record the staff who processed it.
     * All happens in a single transaction so the two can't drift.
     */
    public boolean approveRequest(int requestId, int orderId, int staffId, String staffNote) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                String updateRequest = "UPDATE CancelRequest SET Status = ?, StaffNote = ?, "
                        + "Processed_by = ?, Processed_at = CURRENT_TIMESTAMP "
                        + "WHERE ID = ? AND Status = ?";
                int updated;
                try (PreparedStatement statement = connection.prepareStatement(updateRequest)) {
                    statement.setString(1, CancelRequestModel.STATUS_APPROVED);
                    if (staffNote == null || staffNote.isBlank()) {
                        statement.setNull(2, Types.VARCHAR);
                    } else {
                        statement.setString(2, staffNote.trim());
                    }
                    statement.setInt(3, staffId);
                    statement.setInt(4, requestId);
                    statement.setString(5, CancelRequestModel.STATUS_PENDING);
                    updated = statement.executeUpdate();
                }
                if (updated == 0) {
                    connection.rollback();
                    return false;
                }

                String updateOrder = "UPDATE `Transaction` SET Status = ?, Updated_by = ?, Updated_at = CURRENT_TIMESTAMP "
                        + "WHERE ID = ?";
                try (PreparedStatement statement = connection.prepareStatement(updateOrder)) {
                    statement.setString(1, "CANCELLED");
                    statement.setInt(2, staffId);
                    statement.setInt(3, orderId);
                    if (statement.executeUpdate() == 0) {
                        connection.rollback();
                        return false;
                    }
                }

                connection.commit();
                return true;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    public boolean rejectRequest(int requestId, int staffId, String staffNote) throws SQLException {
        String sql = "UPDATE CancelRequest SET Status = ?, StaffNote = ?, "
                + "Processed_by = ?, Processed_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? AND Status = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, CancelRequestModel.STATUS_REJECTED);
            if (staffNote == null || staffNote.isBlank()) {
                statement.setNull(2, Types.VARCHAR);
            } else {
                statement.setString(2, staffNote.trim());
            }
            statement.setInt(3, staffId);
            statement.setInt(4, requestId);
            statement.setString(5, CancelRequestModel.STATUS_PENDING);
            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Mark a cancel request as APPROVED after VNPay sandbox refund succeeded.
     * Mirrors {@link RefundDAO#decide} in the refund flow: only flips PENDING
     * -> APPROVED and records who processed it.
     *
     * @param requestId cancel request id
     * @param staffId  manager id who initiated the refund
     * @return true if the row was transitioned
     */
    public boolean markRefundApproved(int requestId, int staffId) throws SQLException {
        String sql = "UPDATE CancelRequest SET Status = ?, "
                + "Processed_by = ?, Processed_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? AND Status = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, CancelRequestModel.STATUS_APPROVED);
            statement.setInt(2, staffId);
            statement.setInt(3, requestId);
            statement.setString(4, CancelRequestModel.STATUS_PENDING);
            return statement.executeUpdate() > 0;
        }
    }

    public List<CancelRequestModel> findPendingRequests(String keyword, String sort) throws SQLException {
        StringBuilder sql = new StringBuilder()
                .append("SELECT cr.ID, cr.TransactionID, cr.UserID, cr.Reason, cr.CustomReason, ")
                .append("       cr.BankName, cr.BankAccountNumber, cr.BankAccountHolder, ")
                .append("       cr.Status, cr.StaffNote, cr.Created_at, cr.Updated_at, ")
                .append("       cr.Processed_by, cr.Processed_at, ")
                .append("       u.Name AS ProcessedByName, ")
                .append("       cust.Name AS CustomerName, cust.Username AS CustomerUsername, ")
                .append("       o.Status AS OrderStatus, o.Total_price AS OrderTotal, ")
                .append("       o.Type AS OrderType, o.Method AS OrderMethod ")
                .append("FROM CancelRequest cr ")
                .append("JOIN `Transaction` o ON cr.TransactionID = o.ID ")
                .append("JOIN `User` cust ON cr.UserID = cust.ID ")
                .append("LEFT JOIN `User` u ON cr.Processed_by = u.ID ")
                .append("WHERE cr.Status = ? ");

        List<Object> params = new ArrayList<>();
        params.add(CancelRequestModel.STATUS_PENDING);

        String normalized = keyword == null ? "" : keyword.trim();
        if (!normalized.isEmpty()) {
            sql.append("AND (cust.Name LIKE ? OR cust.Username LIKE ? OR CAST(cr.TransactionID AS CHAR) LIKE ?) ");
            String like = "%" + normalized + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        String order = sort == null ? "newest" : sort;
        if ("oldest".equals(order)) {
            sql.append("ORDER BY cr.Created_at ASC, cr.ID ASC ");
        } else {
            sql.append("ORDER BY cr.Created_at DESC, cr.ID DESC ");
        }

        List<CancelRequestModel> requests = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    CancelRequestModel request = mapRequest(rs);
                    request.setReason(request.getReason());
                    requests.add(request);
                }
            }
        }
        return requests;
    }

    public List<CancelRequestModel> findHistoryRequests(String keyword, String sort) throws SQLException {
        StringBuilder sql = new StringBuilder()
                .append("SELECT cr.ID, cr.TransactionID, cr.UserID, cr.Reason, cr.CustomReason, ")
                .append("       cr.BankName, cr.BankAccountNumber, cr.BankAccountHolder, ")
                .append("       cr.Status, cr.StaffNote, cr.Created_at, cr.Updated_at, ")
                .append("       cr.Processed_by, cr.Processed_at, ")
                .append("       u.Name AS ProcessedByName, ")
                .append("       cust.Name AS CustomerName, cust.Username AS CustomerUsername, ")
                .append("       o.Status AS OrderStatus, o.Total_price AS OrderTotal, ")
                .append("       o.Type AS OrderType, o.Method AS OrderMethod ")
                .append("FROM CancelRequest cr ")
                .append("JOIN `Transaction` o ON cr.TransactionID = o.ID ")
                .append("JOIN `User` cust ON cr.UserID = cust.ID ")
                .append("LEFT JOIN `User` u ON cr.Processed_by = u.ID ")
                .append("WHERE cr.Status IN (?, ?) ");

        List<Object> params = new ArrayList<>();
        params.add(CancelRequestModel.STATUS_APPROVED);
        params.add(CancelRequestModel.STATUS_REJECTED);

        String normalized = keyword == null ? "" : keyword.trim();
        if (!normalized.isEmpty()) {
            sql.append("AND (cust.Name LIKE ? OR cust.Username LIKE ? OR CAST(cr.TransactionID AS CHAR) LIKE ?) ");
            String like = "%" + normalized + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        String order = sort == null ? "newest" : sort;
        if ("oldest".equals(order)) {
            sql.append("ORDER BY cr.Processed_at ASC, cr.ID ASC ");
        } else {
            sql.append("ORDER BY cr.Processed_at DESC, cr.ID DESC ");
        }

        List<CancelRequestModel> requests = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRequest(rs));
                }
            }
        }
        return requests;
    }

    public int countPending() throws SQLException {
        String sql = "SELECT COUNT(*) FROM CancelRequest WHERE Status = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, CancelRequestModel.STATUS_PENDING);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countApproved() throws SQLException {
        String sql = "SELECT COUNT(*) FROM CancelRequest WHERE Status = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, CancelRequestModel.STATUS_APPROVED);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countRejected() throws SQLException {
        String sql = "SELECT COUNT(*) FROM CancelRequest WHERE Status = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, CancelRequestModel.STATUS_REJECTED);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public Set<String> findValidReasons() {
        return new LinkedHashSet<>(VALID_REASONS);
    }

    public static String formatReason(String code) {
        if (code == null) {
            return "";
        }
        switch (code) {
            case "CHANGED_MIND":
                return "Changed my mind";
            case "WRONG_PRODUCT":
                return "Ordered wrong product";
            case "FOUND_CHEAPER":
                return "Found a cheaper price";
            case "LONG_DELIVERY":
                return "Delivery takes too long";
            case "OTHER":
                return "Other reason";
            default:
                return code;
        }
    }

    private CancelRequestModel mapRequest(ResultSet rs) throws SQLException {
        CancelRequestModel request = new CancelRequestModel();
        request.setId(rs.getInt("ID"));
        request.setTransactionId(rs.getInt("TransactionID"));
        request.setUserId(rs.getInt("UserID"));
        request.setReason(rs.getString("Reason"));
        request.setCustomReason(rs.getString("CustomReason"));
        request.setBankName(rs.getString("BankName"));
        request.setBankAccountNumber(rs.getString("BankAccountNumber"));
        request.setBankAccountHolder(rs.getString("BankAccountHolder"));
        request.setStatus(rs.getString("Status"));
        request.setStaffNote(rs.getString("StaffNote"));
        request.setCreatedAt(rs.getTimestamp("Created_at"));
        request.setUpdatedAt(rs.getTimestamp("Updated_at"));
        int processedBy = rs.getInt("Processed_by");
        request.setProcessedBy(rs.wasNull() ? null : processedBy);
        request.setProcessedByName(rs.getString("ProcessedByName"));
        request.setProcessedAt(rs.getTimestamp("Processed_at"));
        try {
            request.setOrderStatus(rs.getString("OrderStatus"));
            request.setOrderMethod(rs.getString("OrderMethod"));
            request.setOrderTotal(rs.getBigDecimal("OrderTotal"));
        } catch (SQLException ignored) {
            // Columns not present in this result set (e.g. lookup-by-id query)
        }
        return request;
    }
}
