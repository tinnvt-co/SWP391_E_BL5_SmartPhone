package DAO;

import config.DBContext;
import model.FeedbackModel;
import model.FeedbackReplyModel;
import model.FeedbackWithReplies;
import util.SchemaInspector;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Review/Feedback persistence layer.
 *
 * Domain rules encoded here: - One review per (user, variant, transaction).
 * Enforced by UNIQUE constraint uq_Feedback_user_variant_tx (created in
 * review_migration.sql). - Customer can edit up to 15 days after Created_at.
 * Computed via FeedbackModel.isWithinEditWindow(). - Manager/reply history is
 * preserved: every save inserts a new row in Answer so the customer can see the
 * full thread.
 *
 * Self-migrating: the static block below checks for the review columns
 * (TransactionID, IsDeleted) on Feedback and creates them in-place if missing.
 * This keeps the DAO runnable against legacy schemas without any manual SQL
 * step. Errors are logged but do not abort the load, so a missing privilege
 * doesn't break unrelated parts of the app.
 */
public class FeedbackDAO {

    private static final int EDIT_WINDOW_DAYS = 15;

    static {
        ensureSchemaUpToDate();
    }

    private static void ensureSchemaUpToDate() {
        try (Connection c = DBContext.getConnection(); Statement s = c.createStatement()) {

            if (!SchemaInspector.feedbackHasColumn("TransactionID")) {
                try {
                    s.executeUpdate("ALTER TABLE Feedback ADD COLUMN TransactionID INT NULL AFTER ProductVariantID");
                    System.out.println("[FeedbackDAO] Added Feedback.TransactionID");
                } catch (SQLException ex) {
                    // 1060 = duplicate column (race with another node); ignore.
                    if (ex.getErrorCode() != 1060) {
                        System.err.println("[FeedbackDAO] Could not add TransactionID: " + ex.getMessage());
                    }
                }
            }

            if (!SchemaInspector.feedbackHasColumn("IsDeleted")) {
                try {
                    s.executeUpdate("ALTER TABLE Feedback ADD COLUMN IsDeleted TINYINT(1) NOT NULL DEFAULT 0 AFTER Updated_at");
                    System.out.println("[FeedbackDAO] Added Feedback.IsDeleted");
                } catch (SQLException ex) {
                    if (ex.getErrorCode() != 1060) {
                        System.err.println("[FeedbackDAO] Could not add IsDeleted: " + ex.getMessage());
                    }
                }
            }
        } catch (Exception ex) {
            System.err.println("[FeedbackDAO] Schema check failed: " + ex.getMessage());
        }
    }

    /* -------------------------------------------------------------------- */
 /*  Helpers                                                             */
 /* -------------------------------------------------------------------- */
    private int nextFeedbackId(Connection connection) throws SQLException {
        try (Statement lock = connection.createStatement()) {
            lock.executeUpdate("LOCK TABLES `Feedback` WRITE");
        }
        try (Statement read = connection.createStatement(); ResultSet rs = read.executeQuery("SELECT COALESCE(MAX(ID), 0) FROM `Feedback`")) {
            return rs.next() ? rs.getInt(1) + 1 : 1;
        } finally {
            try (Statement unlock = connection.createStatement()) {
                unlock.executeUpdate("UNLOCK TABLES");
            }
        }
    }

    private int nextAnswerId(Connection connection) throws SQLException {
        try (Statement lock = connection.createStatement()) {
            lock.executeUpdate("LOCK TABLES `Answer` WRITE");
        }
        try (Statement read = connection.createStatement(); ResultSet rs = read.executeQuery("SELECT COALESCE(MAX(ID), 0) FROM `Answer`")) {
            return rs.next() ? rs.getInt(1) + 1 : 1;
        } finally {
            try (Statement unlock = connection.createStatement()) {
                unlock.executeUpdate("UNLOCK TABLES");
            }
        }
    }

    private FeedbackModel mapRow(ResultSet rs) throws SQLException {
        FeedbackModel f = new FeedbackModel();
        f.setId(rs.getInt("ID"));
        f.setRating(rs.getInt("Rating"));
        f.setContent(rs.getString("Content"));
        f.setCreatedAt(rs.getTimestamp("Created_at"));
        f.setUpdatedAt(rs.getTimestamp("Updated_at"));
        f.setDeleted(rs.getBoolean("IsDeleted"));
        f.setUserId(rs.getInt("UserID"));
        f.setUserName(rs.getString("UserName"));
        f.setUserImage(rs.getString("UserImage"));
        f.setProductVariantId(rs.getInt("ProductVariantID"));
        f.setTransactionId(rs.getInt("TransactionID"));
        f.setProductId(rs.getInt("ProductID"));
        f.setProductName(rs.getString("ProductName"));
        f.setVariantLabel(rs.getString("VariantLabel"));
        f.setVariantImage(rs.getString("VariantImage"));
        f.setReplyCount(rs.getInt("ReplyCount"));
        f.setLatestReplyAt(rs.getTimestamp("LatestReplyAt"));
        return f;
    }

    private FeedbackReplyModel mapReply(ResultSet rs) throws SQLException {
        FeedbackReplyModel r = new FeedbackReplyModel();
        r.setId(rs.getInt("ID"));
        r.setFeedbackId(rs.getInt("FeedbackID"));
        r.setContent(rs.getString("Content"));
        r.setCreatedAt(rs.getTimestamp("Created_at"));
        r.setUpdatedAt(rs.getTimestamp("Updated_at"));
        r.setUserId(rs.getInt("UserID"));
        r.setUserName(rs.getString("UserName"));
        r.setUserRole(rs.getString("UserRole"));
        r.setUserImage(rs.getString("UserImage"));
        return r;
    }

    private String selectFeedbackBase(String alias) {
        String a = (alias == null || alias.isEmpty()) ? "" : alias + ".";
        return "SELECT " + a + "ID, " + a + "Rating, " + a + "Content, "
                + a + "Created_at, " + a + "Updated_at, " + a + "IsDeleted, "
                + a + "UserID, " + a + "ProductVariantID, " + a + "TransactionID, "
                + "u.Name AS UserName, u.Image AS UserImage, "
                + "pv.ProductID, p.Name AS ProductName, "
                + "CONCAT(pv.RAM_GB, 'GB / ', pv.Storage_GB, 'GB / ', pv.ColorName) AS VariantLabel, "
                + "pv.Image AS VariantImage, "
                + "(SELECT COUNT(*) FROM Answer ans WHERE ans.FeedbackID = " + a + "ID) AS ReplyCount, "
                + "(SELECT MAX(ans.Created_at) FROM Answer ans WHERE ans.FeedbackID = " + a + "ID) AS LatestReplyAt ";
    }

    private String fromFeedbackJoin() {
        return "FROM Feedback f "
                + "JOIN `User` u ON u.ID = f.UserID "
                + "JOIN ProductVariant pv ON pv.ID = f.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID ";
    }

    /* -------------------------------------------------------------------- */
 /*  Reads                                                               */
 /* -------------------------------------------------------------------- */
    public FeedbackModel findById(int id) throws SQLException {
        String sql = selectFeedbackBase("f") + fromFeedbackJoin() + "WHERE f.IsDeleted = 0 AND f.ID = ?";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    /**
     * Looks up the buyer's existing review for a specific line of an order (one
     * variant inside one transaction). Used by the review form to decide
     * whether to show "create" or "edit" mode.
     */
    public FeedbackModel findByUserVariantOrder(int userId, int productVariantId, int transactionId) throws SQLException {
        String sql = selectFeedbackBase("f") + fromFeedbackJoin()
                + "WHERE f.IsDeleted = 0 AND f.UserID = ? AND f.ProductVariantID = ? AND f.TransactionID = ?";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productVariantId);
            ps.setInt(3, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    /**
     * All variants inside a transaction that the buyer is allowed to review
     * (DELIVERED or COMPLETED). For each variant we also return the existing
     * feedback (if any) so the JSP can split the list into "to review" vs
     * "already reviewed".
     */
    public List<Map<String, Object>> findReviewableItems(int userId, int transactionId) throws SQLException {
        // Relaxed filter: order ownership + status eligibility. We don't
        // require Type='ORDER' here because some legacy rows use other type
        // codes; the controller already verified the user owns the order and
        // that it's eligible for review.
        String sql = "SELECT tpv.ProductVariantID, tpv.Amount, "
                + "pv.ProductID, p.Name AS ProductName, "
                + "pv.RAM_GB, pv.Storage_GB, pv.ColorName, pv.Image AS VariantImage, "
                + "f.ID AS FeedbackID, f.Rating, f.Content, f.Created_at, f.Updated_at, f.UserID, f.TransactionID "
                + "FROM Transaction_ProductVariant tpv "
                + "JOIN `Transaction` t ON t.ID = tpv.TransactionID "
                + "JOIN ProductVariant pv ON pv.ID = tpv.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID "
                + "LEFT JOIN Feedback f ON f.UserID = ? AND f.ProductVariantID = tpv.ProductVariantID "
                + "                         AND f.TransactionID = tpv.TransactionID "
                + (SchemaInspector.feedbackHasColumn("IsDeleted") ? "AND f.IsDeleted = 0 " : "")
                + "WHERE tpv.TransactionID = ? AND t.UserID = ? "
                + "  AND t.Status IN ('DELIVERED','COMPLETED') "
                + "ORDER BY tpv.ProductVariantID";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, transactionId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("variantId", rs.getInt("ProductVariantID"));
                    row.put("productId", rs.getInt("ProductID"));
                    row.put("productName", rs.getString("ProductName"));
                    row.put("productImage", null);
                    row.put("amount", rs.getInt("Amount"));
                    int ram = rs.getInt("RAM_GB");
                    int storage = rs.getInt("Storage_GB");
                    row.put("memoryLabel", ram + "GB / " + storage + "GB");
                    row.put("colorName", rs.getString("ColorName"));
                    row.put("variantImage", rs.getString("VariantImage"));
                    int feedbackId = rs.getInt("FeedbackID");
                    row.put("feedbackId", rs.wasNull() ? null : feedbackId);
                    int rating = rs.getInt("Rating");
                    row.put("rating", rs.wasNull() ? null : rating);
                    row.put("content", rs.getString("Content"));
                    row.put("createdAt", rs.getTimestamp("Created_at"));
                    row.put("updatedAt", rs.getTimestamp("Updated_at"));
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    public List<FeedbackModel> findForVariant(int productVariantId, boolean includeDeleted) throws SQLException {
        String sql = selectFeedbackBase("f") + fromFeedbackJoin()
                + "WHERE f.ProductVariantID = ? " + (includeDeleted ? "" : "AND f.IsDeleted = 0 ")
                + "ORDER BY f.Created_at DESC";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, productVariantId);
            try (ResultSet rs = ps.executeQuery()) {
                List<FeedbackModel> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                return list;
            }
        }
    }

    public List<FeedbackModel> findForProduct(int productId, boolean includeDeleted) throws SQLException {
        String sql = selectFeedbackBase("f") + fromFeedbackJoin()
                + "WHERE pv.ProductID = ? " + (includeDeleted ? "" : "AND f.IsDeleted = 0 ")
                + "ORDER BY f.Created_at DESC";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                List<FeedbackModel> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                return list;
            }
        }
    }

    public List<FeedbackModel> findAllForManager(String keyword, Integer rating, boolean onlyUnanswered) throws SQLException {
        StringBuilder sql = new StringBuilder(selectFeedbackBase("f")).append(fromFeedbackJoin())
                .append("WHERE f.IsDeleted = 0 ");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (p.Name LIKE ? OR u.Name LIKE ? OR f.Content LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (rating != null) {
            sql.append("AND f.Rating = ? ");
            params.add(rating);
        }
        if (onlyUnanswered) {
            sql.append("AND NOT EXISTS (SELECT 1 FROM Answer a WHERE a.FeedbackID = f.ID) ");
        }
        sql.append("ORDER BY f.Created_at DESC");
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<FeedbackModel> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                return list;
            }
        }
    }

    public List<FeedbackReplyModel> findRepliesByFeedback(int feedbackId) throws SQLException {
        String sql = "SELECT a.ID, a.FeedbackID, a.Content, a.Created_at, a.Updated_at, "
                + "a.UserID, u.Name AS UserName, r.Name AS UserRole, u.Image AS UserImage "
                + "FROM Answer a "
                + "JOIN `User` u ON u.ID = a.UserID "
                + "LEFT JOIN `Role` r ON r.ID = u.RoleID "
                + "WHERE a.FeedbackID = ? "
                + "ORDER BY a.Created_at ASC, a.ID ASC";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            try (ResultSet rs = ps.executeQuery()) {
                List<FeedbackReplyModel> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapReply(rs));
                }
                return list;
            }
        }
    }

    /**
     * Hydrates a (feedback, replies) pair for a single review. Used by the
     * product-detail page so the JSP can render each review + its thread in one
     * block.
     */
    public FeedbackWithReplies loadFeedbackWithReplies(int feedbackId) throws SQLException {
        FeedbackModel f = findById(feedbackId);
        if (f == null) {
            return null;
        }
        FeedbackWithReplies fwr = new FeedbackWithReplies();
        fwr.setFeedback(f);
        fwr.setReplies(findRepliesByFeedback(feedbackId));
        return fwr;
    }

    public List<FeedbackWithReplies> loadForVariant(int productVariantId) throws SQLException {
        List<FeedbackModel> feedbacks = findForVariant(productVariantId, false);
        List<FeedbackWithReplies> result = new ArrayList<>();
        for (FeedbackModel f : feedbacks) {
            FeedbackWithReplies fwr = new FeedbackWithReplies();
            fwr.setFeedback(f);
            fwr.setReplies(findRepliesByFeedback(f.getId()));
            result.add(fwr);
        }
        return result;
    }

    public List<FeedbackWithReplies> loadForProduct(int productId) throws SQLException {
        List<FeedbackModel> feedbacks = findForProduct(productId, false);
        List<FeedbackWithReplies> result = new ArrayList<>();
        // Batch-load replies to avoid N+1
        Map<Integer, List<FeedbackReplyModel>> repliesByFeedback = new HashMap<>();
        if (!feedbacks.isEmpty()) {
            StringBuilder sql = new StringBuilder(
                    "SELECT a.ID, a.FeedbackID, a.Content, a.Created_at, a.Updated_at, "
                    + "a.UserID, u.Name AS UserName, r.Name AS UserRole, u.Image AS UserImage "
                    + "FROM Answer a "
                    + "JOIN `User` u ON u.ID = a.UserID "
                    + "LEFT JOIN `Role` r ON r.ID = u.RoleID "
                    + "WHERE a.FeedbackID IN (");
            for (int i = 0; i < feedbacks.size(); i++) {
                sql.append(i == 0 ? "?" : ",?");
            }
            sql.append(") ORDER BY a.FeedbackID, a.Created_at ASC, a.ID ASC");
            try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
                for (int i = 0; i < feedbacks.size(); i++) {
                    ps.setInt(i + 1, feedbacks.get(i).getId());
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        FeedbackReplyModel r = mapReply(rs);
                        repliesByFeedback.computeIfAbsent(r.getFeedbackId(), k -> new ArrayList<>()).add(r);
                    }
                }
            }
        }
        for (FeedbackModel f : feedbacks) {
            FeedbackWithReplies fwr = new FeedbackWithReplies();
            fwr.setFeedback(f);
            fwr.setReplies(repliesByFeedback.getOrDefault(f.getId(), new ArrayList<>()));
            result.add(fwr);
        }
        return result;
    }

    /* -------------------------------------------------------------------- */
 /*  Aggregation                                                         */
 /* -------------------------------------------------------------------- */
    public Map<String, Double> aggregateForProduct(int productId) throws SQLException {
        String sql = "SELECT COUNT(*) AS total, AVG(f.Rating) AS avgRating "
                + "FROM Feedback f "
                + "JOIN ProductVariant pv ON pv.ID = f.ProductVariantID "
                + "WHERE pv.ProductID = ? AND f.IsDeleted = 0";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                Map<String, Double> out = new HashMap<>();
                if (rs.next()) {
                    out.put("count", rs.getDouble("total"));
                    out.put("avg", rs.getObject("avgRating") == null ? 0.0 : rs.getDouble("avgRating"));
                } else {
                    out.put("count", 0.0);
                    out.put("avg", 0.0);
                }
                return out;
            }
        }
    }

    /* -------------------------------------------------------------------- */
 /*  Writes                                                              */
 /* -------------------------------------------------------------------- */
    /**
     * Saves a customer review. Pass feedback.getId() == 0 to create, otherwise
     * updates (still subject to the 15-day window enforced by the caller).
     */
    public FeedbackModel saveCustomerFeedback(FeedbackModel feedback) throws SQLException {
        boolean isNew = feedback.getId() == 0;
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                if (isNew) {
                    int id = nextFeedbackId(c);
                    feedback.setId(id);
                    String sql = "INSERT INTO Feedback(ID, Rating, Content, UserID, ProductVariantID, TransactionID) "
                            + "VALUES(?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = c.prepareStatement(sql)) {
                        ps.setInt(1, id);
                        ps.setInt(2, feedback.getRating());
                        ps.setString(3, feedback.getContent());
                        ps.setInt(4, feedback.getUserId());
                        ps.setInt(5, feedback.getProductVariantId());
                        if (feedback.getTransactionId() > 0) {
                            ps.setInt(6, feedback.getTransactionId());
                        } else {
                            ps.setNull(6, Types.INTEGER);
                        }
                        ps.executeUpdate();
                    }
                } else {
                    String sql = "UPDATE Feedback SET Rating = ?, Content = ?, Updated_at = CURRENT_TIMESTAMP "
                            + "WHERE ID = ? AND UserID = ? AND IsDeleted = 0";
                    try (PreparedStatement ps = c.prepareStatement(sql)) {
                        ps.setInt(1, feedback.getRating());
                        ps.setString(2, feedback.getContent());
                        ps.setInt(3, feedback.getId());
                        ps.setInt(4, feedback.getUserId());
                        if (ps.executeUpdate() == 0) {
                            throw new SQLException("Feedback not found or not owned by user");
                        }
                    }
                }
                c.commit();
                return feedback;
            } catch (SQLException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public void softDelete(int feedbackId, int userId) throws SQLException {
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE Feedback SET IsDeleted = 1, Updated_at = CURRENT_TIMESTAMP "
                        + "WHERE ID = ? AND UserID = ?")) {
                    ps.setInt(1, feedbackId);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }
                c.commit();
            } catch (SQLException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    /**
     * Manager-side reply. Always inserts a new row so the customer can see the
     * full history, even when the manager replies again after a customer edit.
     * Returns the new row id.
     */
    public int reply(int feedbackId, int userId, String content) throws SQLException {
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                int id = nextAnswerId(c);
                String sql = "INSERT INTO Answer(ID, FeedbackID, Content, UserID) VALUES(?, ?, ?, ?)";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.setInt(2, feedbackId);
                    ps.setString(3, content);
                    ps.setInt(4, userId);
                    ps.executeUpdate();
                }
                // Touch the parent so the latest-reply timestamp stays accurate
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE Feedback SET Updated_at = CURRENT_TIMESTAMP WHERE ID = ?")) {
                    ps.setInt(1, feedbackId);
                    ps.executeUpdate();
                }
                c.commit();
                return id;
            } catch (SQLException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    /* -------------------------------------------------------------------- */
 /*  Order-authorization helpers                                         */
 /* -------------------------------------------------------------------- */
    /**
     * True when (a) the order belongs to the user, (b) it's an ORDER (not
     * IMPORT), (c) it's in DELIVERED or COMPLETED, and (d) the variant is
     * actually one of the line items of that order.
     */
    public boolean canReview(int userId, int transactionId, int productVariantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM `Transaction` t "
                + "JOIN Transaction_ProductVariant tpv ON tpv.TransactionID = t.ID "
                + "WHERE t.ID = ? AND t.UserID = ? AND t.Type = 'ORDER' "
                + "  AND t.Status IN ('DELIVERED','COMPLETED') "
                + "  AND tpv.ProductVariantID = ?";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, transactionId);
            ps.setInt(2, userId);
            ps.setInt(3, productVariantId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    public OrderSummary findOrderSummary(int transactionId, int userId) throws SQLException {
        String sql = "SELECT t.ID, t.Status, t.Type, t.Created_at FROM `Transaction` t "
                + "WHERE t.ID = ? AND t.UserID = ?";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, transactionId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                OrderSummary s = new OrderSummary();
                s.id = rs.getInt("ID");
                s.status = rs.getString("Status");
                s.type = rs.getString("Type");
                s.createdAt = rs.getTimestamp("Created_at");
                return s;
            }
        }
    }

    /**
     * Returns how many line items this transaction has (for debugging the
     * "empty review" case).
     */
    public int countTransactionItems(int transactionId) throws SQLException {
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*) FROM Transaction_ProductVariant WHERE TransactionID = ?")) {
            ps.setInt(1, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public static final class OrderSummary {

        public int id;
        public String status;
        public String type;
        public java.sql.Timestamp createdAt;

        // Explicit getters so JSP EL can read fields even when the bean is
        // loaded by a stale classloader that predates a recompile.
        public int getId() {
            return id;
        }

        public String getStatus() {
            return status;
        }

        public String getType() {
            return type;
        }

        public java.sql.Timestamp getCreatedAt() {
            return createdAt;
        }
    }
}
