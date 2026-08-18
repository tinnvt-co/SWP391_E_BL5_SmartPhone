package DAO;

import config.DBContext;
import model.RefundItemModel;
import model.RefundModel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Persistence for the customer return/refund flow. Backed by the existing
 * `ReturnRequest` and `ReturnRequest_ProductVariant` tables (no schema change
 * required).
 *
 * Lifecycle: ACTIVE -> created by customer, waiting for manager APPROVED ->
 * manager approved the refund REJECTED -> manager rejected the refund
 *
 * The customer only creates requests; only the manager can transition to
 * APPROVED/REJECTED.
 */
public class RefundDAO {

    private static final String BANK_PREFIX = "BANK|";

    private static final Set<String> VALID_STATUSES = new LinkedHashSet<>(java.util.Arrays.asList(RefundModel.STATUS_ACTIVE,
            RefundModel.STATUS_APPROVED,
            RefundModel.STATUS_REJECTED));

    /* -------------------------------------------------------------------- */
 /*  ID generation                                                       */
 /* -------------------------------------------------------------------- */
    private int nextReturnRequestId(Connection conn) throws SQLException {
        try (Statement lock = conn.createStatement()) {
            lock.executeUpdate("LOCK TABLES `ReturnRequest` WRITE");
        }
        try {
            try (Statement read = conn.createStatement(); ResultSet rs = read.executeQuery("SELECT COALESCE(MAX(ID), 0) FROM `ReturnRequest`")) {
                return rs.next() ? rs.getInt(1) + 1 : 1;
            }
        } finally {
            try (Statement unlock = conn.createStatement()) {
                unlock.executeUpdate("UNLOCK TABLES");
            }
        }
    }

    /* -------------------------------------------------------------------- */
 /*  Mapping helpers                                                     */
 /* -------------------------------------------------------------------- */
    private RefundItemModel mapItem(ResultSet rs) throws SQLException {
        RefundItemModel it = new RefundItemModel();
        it.setReturnRequestId(rs.getInt("ReturnRequestID"));
        it.setProductVariantId(rs.getInt("ProductVariantID"));
        it.setProductName(rs.getString("ProductName"));
        int ram = rs.getInt("RAM_GB");
        int storage = rs.getInt("Storage_GB");
        it.setVariantLabel(ram + "GB / " + storage + "GB / " + rs.getString("ColorName"));
        it.setVariantImage(rs.getString("VariantImage"));
        it.setAmount(rs.getInt("Amount"));
        it.setUnitPrice(rs.getBigDecimal("UnitPrice"));
        return it;
    }

    /* -------------------------------------------------------------------- */
 /*  Customer-side reads                                                 */
 /* -------------------------------------------------------------------- */
    /**
     * All refund requests submitted by a customer (history).
     */
    public List<RefundModel> findByUserId(int userId) throws SQLException {
        String sql = "SELECT r.ID, r.Status, r.Description, r.Image, r.BackImage, "
                + "r.Created_at, r.Updated_at, r.UserID, r.TransactionID, "
                + "u.Name AS UserName, "
                + "(SELECT COUNT(*) FROM ReturnRequest_ProductVariant rpv WHERE rpv.ReturnRequestID = r.ID) AS ItemCount "
                + "FROM `ReturnRequest` r "
                + "JOIN `User` u ON u.ID = r.UserID "
                + "WHERE r.UserID = ? AND r.Status IN ('ACTIVE','APPROVED','REJECTED') "
                + "ORDER BY r.Created_at DESC, r.ID DESC";
        List<RefundModel> list = new ArrayList<>();
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RefundModel r = new RefundModel();
                    r.setId(rs.getInt("ID"));
                    r.setStatus(rs.getString("Status"));
                    r.setDescription(rs.getString("Description"));
                    r.setImage(rs.getString("Image"));
                    r.setBackImage(rs.getString("BackImage"));
                    applyBankInfo(r);
                    r.setCreatedAt(rs.getTimestamp("Created_at"));
                    r.setUpdatedAt(rs.getTimestamp("Updated_at"));
                    r.setUserId(rs.getInt("UserID"));
                    r.setUserName(rs.getString("UserName"));
                    r.setTransactionId(rs.getInt("TransactionID"));
                    r.setItemCount(rs.getInt("ItemCount"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    /**
     * Active (still waiting) refund requests for a given order id (used to lock
     * the form).
     */
    public boolean hasActiveForTransaction(int userId, int transactionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM `ReturnRequest` WHERE UserID = ? AND TransactionID = ? AND Status = 'ACTIVE'";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * A "blocking" refund is any non-rejected request (APPROVED).When a
     * customer has already started or completed a refund for an order we must
     * hide the review controls for that order's products.
     *
     * @param userId
     * @param transactionId
     * @return
     * @throws java.sql.SQLException
     */
    public boolean hasBlockingRefundForTransaction(int userId, int transactionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM `ReturnRequest` WHERE UserID = ? AND TransactionID = ? AND Status IN ('APPROVED')";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Single request with all its items (used by JSP detail pages).
     *
     * @param id
     * @return
     * @throws java.sql.SQLException
     */
    public RefundModel findDetail(int id) throws SQLException {
        String sql = "SELECT r.ID, r.Status, r.Description, r.Image, r.BackImage, "
                + "r.Created_at, r.Updated_at, r.UserID, r.TransactionID, "
                + "u.Name AS UserName "
                + "FROM `ReturnRequest` r "
                + "JOIN `User` u ON u.ID = r.UserID "
                + "WHERE r.ID = ?";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                RefundModel r = new RefundModel();
                r.setId(rs.getInt("ID"));
                r.setStatus(rs.getString("Status"));
                r.setDescription(rs.getString("Description"));
                r.setImage(rs.getString("Image"));
                r.setBackImage(rs.getString("BackImage"));
                applyBankInfo(r);
                r.setCreatedAt(rs.getTimestamp("Created_at"));
                r.setUpdatedAt(rs.getTimestamp("Updated_at"));
                r.setUserId(rs.getInt("UserID"));
                r.setUserName(rs.getString("UserName"));
                r.setTransactionId(rs.getInt("TransactionID"));
                // reviewer name (manager) — pulled from the most recent TransactionStatusHistory
                // row tied to this order. We don't alter the schema, so we use this audit trail.
                try (PreparedStatement ps2 = c.prepareStatement(
                        "SELECT rev.Name, h.Updated_at FROM `TransactionStatusHistory` h "
                        + "JOIN `User` rev ON rev.ID = h.UserID "
                        + "WHERE h.TransactionID = (SELECT TransactionID FROM `ReturnRequest` WHERE ID = ?) "
                        + "ORDER BY h.Updated_at DESC LIMIT 1")) {
                    ps2.setInt(1, id);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        if (rs2.next()) {
                            r.setReviewedByName(rs2.getString(1));
                            r.setReviewedAt(rs2.getTimestamp(2));
                        }
                    }
                }
                r.setItems(findItems(id));
                return r;
            }
        }
    }

    /**
     * Items (variants) attached to a single refund request.
     *
     * @param returnRequestId
     * @return
     * @throws java.sql.SQLException
     */
    public List<RefundItemModel> findItems(int returnRequestId) throws SQLException {
        String sql = "SELECT rpv.ReturnRequestID, rpv.ProductVariantID, "
                + "tp.Amount, tp.UnitPrice, "
                + "p.Name AS ProductName, pv.Image AS VariantImage, "
                + "pv.RAM_GB, pv.Storage_GB, pv.ColorName "
                + "FROM ReturnRequest_ProductVariant rpv "
                + "JOIN Transaction_ProductVariant tp ON tp.TransactionID = "
                + "  (SELECT r.TransactionID FROM ReturnRequest r WHERE r.ID = rpv.ReturnRequestID) "
                + "  AND tp.ProductVariantID = rpv.ProductVariantID "
                + "JOIN ProductVariant pv ON pv.ID = rpv.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID "
                + "WHERE rpv.ReturnRequestID = ?";
        List<RefundItemModel> list = new ArrayList<>();
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, returnRequestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapItem(rs));
                }
            }
        }
        return list;
    }

    /* -------------------------------------------------------------------- */
 /*  Manager-side reads                                                  */
 /* -------------------------------------------------------------------- */
    public List<RefundModel> findAllForManager(String keyword, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT r.ID, r.Status, r.Description, r.Image, r.BackImage, "
                + "r.Created_at, r.Updated_at, r.UserID, r.TransactionID, "
                + "u.Name AS UserName, "
                + "(SELECT COUNT(*) FROM ReturnRequest_ProductVariant rpv WHERE rpv.ReturnRequestID = r.ID) AS ItemCount "
                + "FROM `ReturnRequest` r "
                + "JOIN `User` u ON u.ID = r.UserID "
                + "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (u.Name LIKE ? OR r.Description LIKE ? OR CAST(r.TransactionID AS CHAR) LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && VALID_STATUSES.contains(status)) {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }
        sql.append("ORDER BY r.Created_at DESC, r.ID DESC");
        List<RefundModel> list = new ArrayList<>();
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RefundModel r = new RefundModel();
                    r.setId(rs.getInt("ID"));
                    r.setStatus(rs.getString("Status"));
                    r.setDescription(rs.getString("Description"));
                    r.setImage(rs.getString("Image"));
                    r.setBackImage(rs.getString("BackImage"));
                    applyBankInfo(r);
                    r.setCreatedAt(rs.getTimestamp("Created_at"));
                    r.setUpdatedAt(rs.getTimestamp("Updated_at"));
                    r.setUserId(rs.getInt("UserID"));
                    r.setUserName(rs.getString("UserName"));
                    r.setTransactionId(rs.getInt("TransactionID"));
                    r.setItemCount(rs.getInt("ItemCount"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    /* -------------------------------------------------------------------- */
 /*  Writes                                                              */
 /* -------------------------------------------------------------------- */
    /**
     * Creates a refund request for an entire order.The order's items are
     * mirrored into ReturnRequest_ProductVariant so the manager sees what the
     * customer wants to refund.
     *
     * @param userId
     * @param transactionId
     * @param description
     * @param imageFile
     * @return
     * @throws java.sql.SQLException
     */
    public RefundModel createForOrder(int userId, int transactionId, String description, String imageFile)
            throws SQLException {
        return createForOrder(userId, transactionId, description, imageFile, null, null, null);
    }

    public RefundModel createForOrder(int userId, int transactionId, String description, String imageFile,
            String bankName, String bankAccountNumber, String bankAccountHolder)
            throws SQLException {
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                int id = nextReturnRequestId(c);
                String sql = "INSERT INTO `ReturnRequest`(ID, Status, Description, Image, BackImage, UserID, TransactionID) "
                        + "VALUES(?, 'ACTIVE', ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.setString(2, description);
                    if (imageFile == null || imageFile.isEmpty()) {
                        ps.setNull(3, Types.VARCHAR);
                    } else {
                        ps.setString(3, imageFile);
                    }
                    String bankPayload = bankPayload(bankName, bankAccountNumber, bankAccountHolder);
                    if (bankPayload == null) {
                        ps.setNull(4, Types.VARCHAR);
                    } else {
                        ps.setString(4, bankPayload);
                    }
                    ps.setInt(5, userId);
                    ps.setInt(6, transactionId);
                    ps.executeUpdate();
                }
                // Mirror every line of the order into ReturnRequest_ProductVariant
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO ReturnRequest_ProductVariant(ReturnRequestID, ProductVariantID) "
                        + "SELECT ?, tpv.ProductVariantID "
                        + "FROM Transaction_ProductVariant tpv "
                        + "JOIN `Transaction` t ON t.ID = tpv.TransactionID "
                        + "WHERE tpv.TransactionID = ? AND t.UserID = ?")) {
                    ps.setInt(1, id);
                    ps.setInt(2, transactionId);
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
                c.commit();
                RefundModel r = new RefundModel();
                r.setId(id);
                r.setStatus("ACTIVE");
                r.setDescription(description);
                r.setImage(imageFile);
                r.setBackImage(bankPayload(bankName, bankAccountNumber, bankAccountHolder));
                applyBankInfo(r);
                r.setUserId(userId);
                r.setTransactionId(transactionId);
                return r;
            } catch (SQLException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    /**
     * Manager-only transition.Only ACTIVE -> APPROVED/REJECTED is allowed; the
     * reviewer id is persisted via a TransactionStatusHistory row so we don't
     * need to alter the ReturnRequest schema.
     *
     * @param requestId
     * @param approve
     * @param reviewerUserId
     * @return
     * @throws java.sql.SQLException
     */
    public boolean decide(int requestId, boolean approve, int reviewerUserId) throws SQLException {
        String newStatus = approve ? RefundModel.STATUS_APPROVED : RefundModel.STATUS_REJECTED;
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                int updated;
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE `ReturnRequest` SET Status = ?, Updated_at = CURRENT_TIMESTAMP WHERE ID = ? AND Status = 'ACTIVE'")) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, requestId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    c.rollback();
                    return false;
                }
                // audit row so we know who decided. We do NOT need LOCK TABLES
                // here - the UPDATE above already holds the row lock and the
                // SELECT against ReturnRequest + INSERT into TransactionStatusHistory
                // happen inside the same transaction, so concurrency is fine.
                int historyId;
                try (Statement read = c.createStatement(); ResultSet rs = read.executeQuery(
                        "SELECT COALESCE(MAX(ID), 0) FROM `TransactionStatusHistory`")) {
                    historyId = rs.next() ? rs.getInt(1) + 1 : 1;
                }
                int txId;
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT TransactionID FROM `ReturnRequest` WHERE ID = ?")) {
                    ps.setInt(1, requestId);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        txId = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO `TransactionStatusHistory`(ID, TransactionID, UserID, Updated_at) VALUES(?, ?, ?, CURRENT_TIMESTAMP)")) {
                    ps.setInt(1, historyId);
                    ps.setInt(2, txId);
                    ps.setInt(3, reviewerUserId);
                    ps.executeUpdate();
                }
                c.commit();
                return true;
            } catch (SQLException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public Set<String> findAllStatuses() {
        return new LinkedHashSet<>(VALID_STATUSES);
    }

    /**
     * Total refund requests currently waiting for a manager to decide.
     * @return 
     * @throws java.sql.SQLException
     */
   
    public int countPending() throws SQLException {
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*) FROM `ReturnRequest` WHERE Status = 'ACTIVE'"); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private String bankPayload(String bankName, String bankAccountNumber, String bankAccountHolder) {
        if (isBlank(bankName) && isBlank(bankAccountNumber) && isBlank(bankAccountHolder)) {
            return null;
        }
        String value = BANK_PREFIX + cleanBankPart(bankName) + "|"
                + cleanBankPart(bankAccountNumber) + "|"
                + cleanBankPart(bankAccountHolder);
        return value.length() > 255 ? value.substring(0, 255) : value;
    }

    private void applyBankInfo(RefundModel request) {
        String payload = request.getBackImage();
        if (payload == null || !payload.startsWith(BANK_PREFIX)) {
            return;
        }
        String[] parts = payload.substring(BANK_PREFIX.length()).split("\\|", -1);
        if (parts.length > 0) {
            request.setBankName(parts[0]);
        }
        if (parts.length > 1) {
            request.setBankAccountNumber(parts[1]);
        }
        if (parts.length > 2) {
            request.setBankAccountHolder(parts[2]);
        }
    }

    private String cleanBankPart(String value) {
        return value == null ? "" : value.trim().replace("|", " ");
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
