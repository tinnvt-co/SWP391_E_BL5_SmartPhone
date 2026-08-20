package DAO;

import config.DBContext;
import model.OrderItemModel;
import model.OrderModel;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class ImportOrderDAO {

    private static final String TYPE = "IMPORT";

    private static final Set<String> VALID_STATUSES = Set.of(
            "ORDER",
            "COMPLETE"
    );

    /**
     * Get all import invoices.
     * @param keyword
     * @param status
     * @param sort
     * @return 
     * @throws java.sql.SQLException 
     */
    public List<OrderModel> findImportOrders(
            String keyword,
            String status,
            String sort) throws SQLException {

        StringBuilder sql = new StringBuilder()
                .append("SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, ")
                .append("       t.Method, ")
                .append("       t.Updated_by, t.Updated_at, t.Created_at, t.Note, ")
                .append("       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, ")
                .append("       t.SupplierID, ")
                .append("       u.Username, u.Name AS UserName, ")
                .append("       upd.Name AS UpdatedByName, ")
                .append("       s.Name AS SupplierName, ")
                .append("       (SELECT COALESCE(SUM(tp.Amount), 0) ")
                .append("          FROM Transaction_ProductVariant tp ")
                .append("         WHERE tp.TransactionID = t.ID) AS ItemCount ")
                .append("FROM `Transaction` t ")
                .append("JOIN `User` u ON t.UserID = u.ID ")
                .append("LEFT JOIN `User` upd ON t.Updated_by = upd.ID ")
                .append("LEFT JOIN Supplier s ON t.SupplierID = s.ID ")
                .append("WHERE t.Type = 'IMPORT' ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {

            String k = "%" + keyword.trim() + "%";

            sql.append("AND (")
                    .append("CAST(t.ID AS CHAR) LIKE ? ")
                    .append("OR s.Name LIKE ? ")
                    .append("OR u.Name LIKE ?")
                    .append(") ");

            params.add(k);
            params.add(k);
            params.add(k);
        }

        if (status != null
                && !status.isBlank()
                && VALID_STATUSES.contains(status)) {

            sql.append("AND t.Status = ? ");
            params.add(status);
        }

        if (null == sort) {
            
            sql.append("ORDER BY t.Created_at DESC, t.ID DESC");
        } else switch (sort) {
            case "oldest" -> sql.append("ORDER BY t.Created_at ASC, t.ID ASC");
            case "total-desc" -> sql.append("ORDER BY t.Total_price DESC, t.ID DESC");
            case "total-asc" -> sql.append("ORDER BY t.Total_price ASC, t.ID ASC");
            default -> sql.append("ORDER BY t.Created_at DESC, t.ID DESC");
        }

        List<OrderModel> imports = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement
                = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    imports.add(mapImportSummary(rs));
                }
            }
        }

        return imports;
    }

    /**
     * Find import invoice detail.
     * @param transactionId
     * @return 
     * @throws java.sql.SQLException 
     */
    public OrderModel findImportOrderDetail(int transactionId)
            throws SQLException {

        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Change_amount, t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, "
                + "       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, "
                + "       t.SupplierID, "
                + "       u.Username, u.Name AS UserName, "
                + "       u.Phone, u.Email, "
                + "       upd.Name AS UpdatedByName, "
                + "       s.Name AS SupplierName "
                + "FROM `Transaction` t "
                + "JOIN `User` u ON t.UserID = u.ID "
                + "LEFT JOIN `User` upd ON t.Updated_by = upd.ID "
                + "LEFT JOIN Supplier s ON t.SupplierID = s.ID "
                + "WHERE t.ID = ? "
                + "AND t.Type = 'IMPORT'";

        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {

                    OrderModel order = mapImportDetail(rs);

                    order.setItems(findImportItems(
                            connection,
                            transactionId));

                    return order;
                }
            }
        }

        return null;
    }

    /**
     * Find products inside an import invoice.
     * @param transactionId
     * @return 
     * @throws java.sql.SQLException 
     */
    public List<OrderItemModel> findImportItems(int transactionId)
            throws SQLException {

        try (Connection connection = DBContext.getConnection()) {

            return findImportItems(connection, transactionId);
        }
    }

    private List<OrderItemModel> findImportItems(
            Connection connection,
            int transactionId) throws SQLException {

        String sql = "SELECT tp.TransactionID, "
                + "       tp.ProductVariantID, "
                + "       tp.Amount, "
                + "       tp.UnitPrice, "
                + "       tp.Discount_rate, "
                + "       tp.Discount_amount, "
                + "       tp.Total, "
                + "       p.Name AS ProductName, "
                + "       pv.Image AS VariantImage, "
                + "       b.Name AS BrandName, "
                + "       pv.RAM_GB, "
                + "       pv.Storage_GB, "
                + "       pv.ColorName "
                + "FROM Transaction_ProductVariant tp "
                + "JOIN ProductVariant pv "
                + "  ON tp.ProductVariantID = pv.ID "
                + "JOIN Product p "
                + "  ON pv.ProductID = p.ID "
                + "JOIN Brand b "
                + "  ON p.BrandID = b.ID "
                + "WHERE tp.TransactionID = ? "
                + "ORDER BY tp.ProductVariantID";

        List<OrderItemModel> items = new ArrayList<>();

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    items.add(mapImportItem(rs));
                }
            }
        }

        return items;
    }

    /**
     * Create import invoice.Initial status:
 ORDER

 Inventory is NOT updated here.
     *
     * @param userId
     * @param supplierId
     * @param totalPrice
     * @param paidAmount
     * @param changeAmount
     * @param method
     * @param note
     * @param items
     * @return
     * @throws java.sql.SQLException
     */
    public int createImportOrder(
            int userId,
            int supplierId,
            BigDecimal totalPrice,
            BigDecimal paidAmount,
            BigDecimal changeAmount,
            String method,
            String note,
            List<OrderItemModel> items) throws SQLException {

        if (items == null || items.isEmpty()) {
            throw new SQLException(
                    "Import invoice must contain at least one item");
        }

        try (Connection connection = DBContext.getConnection()) {

            connection.setAutoCommit(false);

            try {

                int transactionId = insertTransaction(
                        connection,
                        userId,
                        supplierId,
                        totalPrice,
                        paidAmount,
                        changeAmount,
                        method,
                        note);

                for (OrderItemModel item : items) {

                    insertImportItem(
                            connection,
                            transactionId,
                            item);
                }

                insertStatusHistory(
                        connection,
                        transactionId,
                        userId,
                        "ORDER");

                connection.commit();

                return transactionId;

            } catch (SQLException e) {

                connection.rollback();
                throw e;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }

    /**
     * Insert Transaction with Type = IMPORT
     * and Status = ORDER.
     */
    private int insertTransaction(
            Connection connection,
            int userId,
            int supplierId,
            BigDecimal totalPrice,
            BigDecimal paidAmount,
            BigDecimal changeAmount,
            String method,
            String note) throws SQLException {

        String sql = "INSERT INTO `Transaction` "
                + "(UserID, Total_price, Type, Status, "
                + " SupplierID, "
                + " Method, Note, Updated_by) "
                + "VALUES (?, ?, 'IMPORT', 'ORDER', ?, ?, ?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(
                sql,
                Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, userId);
            statement.setBigDecimal(2, totalPrice);
            statement.setInt(3, supplierId);
            statement.setString(6, method);
            statement.setString(7, note);
            statement.setInt(8, userId);

            statement.executeUpdate();

            try (ResultSet keys = statement.getGeneratedKeys()) {

                if (!keys.next()) {
                    throw new SQLException(
                            "Cannot create import transaction ID");
                }

                return keys.getInt(1);
            }
        }
    }

    /**
     * Insert import invoice item.
     *
     * For import:
     * Discount_rate = 0
     * Discount_amount = 0
     * Total = Amount * UnitPrice
     */
    private void insertImportItem(
            Connection connection,
            int transactionId,
            OrderItemModel item) throws SQLException {

        String sql = "INSERT INTO Transaction_ProductVariant "
                + "(TransactionID, ProductVariantID, Amount, "
                + " UnitPrice, Discount_rate, Discount_amount, Total) "
                + "VALUES (?, ?, ?, ?, 0, 0, ?)";

        BigDecimal total = item.getUnitPrice()
                .multiply(BigDecimal.valueOf(item.getAmount()));

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);
            statement.setInt(2, item.getVariantId());
            statement.setInt(3, item.getAmount());
            statement.setBigDecimal(4, item.getUnitPrice());
            statement.setBigDecimal(5, total);

            statement.executeUpdate();
        }
    }

    /**
     * Change import status.Only:

 ORDER -> COMPLETE

 When COMPLETE:
 1. Insert status history
 2. Increase Inventory

 Both operations are in the same transaction.
     * @param transactionId
     * @param updatedBy
     * @return
     * @throws java.sql.SQLException
     */
    public boolean completeImportOrder(
            int transactionId,
            int updatedBy) throws SQLException {

        try (Connection connection = DBContext.getConnection()) {

            connection.setAutoCommit(false);

            try {

                String currentStatus =
                        getImportStatus(
                                connection,
                                transactionId);

                if (currentStatus == null) {
                    throw new SQLException(
                            "Import order does not exist: "
                            + transactionId);
                }

                if ("COMPLETE".equals(currentStatus)) {
                    throw new SQLException(
                            "Import order is already completed");
                }

                if (!"ORDER".equals(currentStatus)) {
                    throw new SQLException(
                            "Only ORDER import can be completed");
                }

                List<OrderItemModel> items =
                        findImportItems(
                                connection,
                                transactionId);

                if (items.isEmpty()) {
                    throw new SQLException(
                            "Import order has no items");
                }

                updateTransactionStatus(
                        connection,
                        transactionId,
                        "COMPLETE",
                        updatedBy);

                insertStatusHistory(
                        connection,
                        transactionId,
                        updatedBy,
                        "COMPLETE");

                for (OrderItemModel item : items) {

                    increaseInventory(
                            connection,
                            item.getVariantId(),
                            item.getAmount());
                }

                connection.commit();

                return true;

            } catch (SQLException e) {

                connection.rollback();
                throw e;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }

    /**
     * Get current import status.
     */
    private String getImportStatus(
            Connection connection,
            int transactionId) throws SQLException {

        String sql = "SELECT Status "
                + "FROM `Transaction` "
                + "WHERE ID = ? "
                + "AND Type = 'IMPORT'";

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);

            try (ResultSet rs = statement.executeQuery()) {

                return rs.next()
                        ? rs.getString("Status")
                        : null;
            }
        }
    }

    /**
     * Update Transaction.Status.
     */
    private void updateTransactionStatus(
            Connection connection,
            int transactionId,
            String status,
            int updatedBy) throws SQLException {

        if (!VALID_STATUSES.contains(status)) {
            throw new SQLException(
                    "Invalid import status: " + status);
        }

        String sql = "UPDATE `Transaction` "
                + "SET Status = ?, "
                + "    Updated_by = ?, "
                + "    Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? "
                + "AND Type = 'IMPORT'";

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, updatedBy);
            statement.setInt(3, transactionId);

            if (statement.executeUpdate() == 0) {
                throw new SQLException(
                        "Import order does not exist");
            }
        }
    }

    /**
     * Insert status history.
     */
    private void insertStatusHistory(
            Connection connection,
            int transactionId,
            int userId,
            String status) throws SQLException {

        String sql = "INSERT INTO TransactionStatusHistory "
                + "(TransactionID, UserID, Status, Updated_at) "
                + "VALUES (?, ?, ?, CURRENT_TIMESTAMP)";

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);
            statement.setInt(2, userId);
            statement.setString(3, status);

            statement.executeUpdate();
        }
    }

    /**
     * Increase inventory quantity.
     *
     * If inventory does not exist:
     * create it.
     *
     * If inventory exists:
     * Amount = Amount + quantity
     */
    private void increaseInventory(
            Connection connection,
            int variantId,
            int quantity) throws SQLException {

        if (quantity <= 0) {
            throw new SQLException(
                    "Import quantity must be greater than 0");
        }

        String sql = "INSERT INTO Inventory "
                + "(ProductVariantID, Amount, Status, Updated_at) "
                + "VALUES (?, ?, 'ACTIVE', CURRENT_TIMESTAMP) "
                + "ON DUPLICATE KEY UPDATE "
                + "Amount = Amount + VALUES(Amount), "
                + "Status = 'ACTIVE', "
                + "Updated_at = CURRENT_TIMESTAMP";

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, variantId);
            statement.setInt(2, quantity);

            statement.executeUpdate();
        }
    }

    /**
     * Get status history.
     * @param transactionId
     * @return 
     * @throws java.sql.SQLException
     */
    public List<String> findStatusHistory(int transactionId)
            throws SQLException {

        String sql = "SELECT h.Status, "
                + "       h.Updated_at, "
                + "       u.ID AS UserID, "
                + "       u.Name AS UserName "
                + "FROM TransactionStatusHistory h "
                + "JOIN `User` u ON h.UserID = u.ID "
                + "WHERE h.TransactionID = ? "
                + "ORDER BY h.Updated_at ASC, h.ID ASC";

        List<String> history = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, transactionId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {

                    String value =
                            rs.getString("Status")
                            + " | "
                            + rs.getString("UserName")
                            + " | "
                            + rs.getTimestamp("Updated_at");

                    history.add(value);
                }
            }
        }

        return history;
    }

    /**
     * Count import invoices by status.
     * @param status
     * @return 
     * @throws java.sql.SQLException
     */
    public int countByStatus(String status)
            throws SQLException {

        if (!VALID_STATUSES.contains(status)) {
            return 0;
        }

        String sql = "SELECT COUNT(*) "
                + "FROM `Transaction` "
                + "WHERE Type = 'IMPORT' "
                + "AND Status = ?";

        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(1, status);

            try (ResultSet rs = statement.executeQuery()) {

                return rs.next()
                        ? rs.getInt(1)
                        : 0;
            }
        }
    }

    /**
     * Get available import statuses.
     * @return 
     */
    public Set<String> findAllStatuses() {

        return new LinkedHashSet<>(VALID_STATUSES);
    }

    /**
     * Map import summary.
     */
    private OrderModel mapImportSummary(
            ResultSet rs) throws SQLException {

        OrderModel order = new OrderModel();

        order.setId(rs.getInt("ID"));
        order.setUserId(rs.getInt("UserID"));

        order.setUsername(
                rs.getString("Username"));

        order.setUserName(
                rs.getString("UserName"));

        order.setTotalPrice(
                rs.getBigDecimal("Total_price"));
        order.setType(
                rs.getString("Type"));

        order.setStatus(
                rs.getString("Status"));

        order.setMethod(
                rs.getString("Method"));

        int updatedBy = rs.getInt("Updated_by");

        order.setUpdatedBy(
                rs.wasNull()
                        ? null
                        : updatedBy);

        order.setUpdatedByName(
                rs.getString("UpdatedByName"));

        order.setCreatedAt(
                rs.getTimestamp("Created_at"));

        order.setUpdatedAt(
                rs.getTimestamp("Updated_at"));

        order.setNote(
                rs.getString("Note"));

        order.setItemCount(
                rs.getInt("ItemCount"));

        return order;
    }

    /**
     * Map import detail.
     */
    private OrderModel mapImportDetail(
            ResultSet rs) throws SQLException {

        OrderModel order =
                mapImportSummary(rs);

        order.setUserPhone(
                rs.getString("Phone"));

        order.setUserEmail(
                rs.getString("Email"));

        return order;
    }

    /**
     * Map import item.
     */
    private OrderItemModel mapImportItem(
            ResultSet rs) throws SQLException {

        OrderItemModel item =
                new OrderItemModel();

        item.setTransactionId(
                rs.getInt("TransactionID"));

        item.setVariantId(
                rs.getInt("ProductVariantID"));

        item.setAmount(
                rs.getInt("Amount"));

        item.setUnitPrice(
                rs.getBigDecimal("UnitPrice"));

        item.setDiscountRate(
                rs.getBigDecimal("Discount_rate"));

        item.setDiscountAmount(
                rs.getBigDecimal("Discount_amount"));

        item.setTotal(
                rs.getBigDecimal("Total"));

        item.setProductName(
                rs.getString("ProductName"));

        item.setProductImage(
                rs.getString("VariantImage"));

        item.setBrandName(
                rs.getString("BrandName"));

        int ram = rs.getInt("RAM_GB");
        int storage = rs.getInt("Storage_GB");

        item.setMemoryLabel(
                ram + "GB / " + storage + "GB");

        item.setColorName(
                rs.getString("ColorName"));

        return item;
    }
}