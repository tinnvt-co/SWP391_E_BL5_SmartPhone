package DAO;

import config.DBContext;
import model.OrderItemModel;
import model.OrderModel;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class OrderDAO {

    private static final Set<String> VALID_STATUSES = Set.of(
            "PENDING", "CONFIRMED", "PROCESSING", "PAID", "SHIPPING", "DELIVERED",
            "COMPLETED", "CANCEL_REQUESTED", "CANCELLED");
    private static final Set<String> VALID_TYPES = Set.of("ORDER", "IMPORT");
    private static final Set<String> VALID_SORTS = Set.of("newest", "oldest", "total-desc", "total-asc");
    private static final int MAX_SEARCH_LENGTH = 100;

    public List<OrderModel> findOrders(String keyword, String status, String type,
            String sort, boolean excludeImport)
            throws SQLException {

        StringBuilder sql = new StringBuilder()
                .append("SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, ")
                .append("       t.Paid_amount, t.Change_amount, t.Method, ")
                .append("       t.Updated_by, t.Updated_at, t.Created_at, t.Note, ")
                .append("       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, ")
                .append("       u.Username, u.Name AS UserName, u.Phone, u.Email, ")
                .append("       upd.Name AS UpdatedByName, ")
                .append("       (SELECT COUNT(*) FROM Transaction_ProductVariant tp ")
                .append("          WHERE tp.TransactionID = t.ID) AS ItemCount ")
                .append("FROM `Transaction` t ")
                .append("JOIN `User` u   ON t.UserID = u.ID ")
                .append("LEFT JOIN `User` upd ON t.Updated_by = upd.ID ")
                .append("WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        String normalized = normalizeKeyword(keyword);
        if (!normalized.isEmpty()) {
            sql.append("AND (u.Name LIKE ? OR u.Username LIKE ? OR CAST(t.ID AS CHAR) LIKE ?) ");
            String like = "%" + normalized + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.isBlank() && VALID_STATUSES.contains(status)) {
            sql.append("AND t.Status = ? ");
            params.add(status);
        }
        if (type != null && !type.isBlank() && VALID_TYPES.contains(type)) {
            sql.append("AND t.Type = ? ");
            params.add(type);
        } else if (excludeImport) {
            sql.append("AND t.Type = 'ORDER' ");
        }

        String order = normalizeSort(sort);
        switch (order) {
            case "oldest":
                sql.append("ORDER BY t.Created_at ASC, t.ID ASC ");
                break;
            case "total-desc":
                sql.append("ORDER BY t.Total_price DESC, t.ID DESC ");
                break;
            case "total-asc":
                sql.append("ORDER BY t.Total_price ASC, t.ID ASC ");
                break;
            default:
                sql.append("ORDER BY t.Created_at DESC, t.ID DESC ");
        }

        List<OrderModel> orders = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrderSummary(rs));
                }
            }
        }
        return orders;
    }

    public List<OrderModel> findAvailableShippingOrders() throws SQLException {
        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Paid_amount, t.Change_amount, t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, "
                + "       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, "
                + "       u.Username, u.Name AS UserName, u.Phone, u.Email, "
                + "       upd.Name AS UpdatedByName, "
                + "       d.Recipient_name, d.Recipient_phone, d.Delivery_address, "
                + "       (SELECT COALESCE(SUM(tp.Amount),0) FROM Transaction_ProductVariant tp WHERE tp.TransactionID = t.ID) AS ItemCount "
                + "FROM `Transaction` t "
                + "JOIN `User` u   ON t.UserID = u.ID "
                + "LEFT JOIN `User` upd ON t.Updated_by = upd.ID "
                + "LEFT JOIN DeliveryInfo d ON t.DeliveryInfoID = d.ID "
                + "WHERE t.Status = 'SHIPPING' AND t.Type = 'ORDER' AND t.ShipperID IS NULL "
                + "ORDER BY t.Created_at DESC, t.ID DESC";

        List<OrderModel> orders = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrderDetail(rs));
                }
            }
        }
        return orders;
    }

    public List<OrderModel> findShippingOrdersByShipper(int shipperId) throws SQLException {
        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Paid_amount, t.Change_amount, t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, "
                + "       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, "
                + "       u.Username, u.Name AS UserName, u.Phone, u.Email, "
                + "       upd.Name AS UpdatedByName, "
                + "       d.Recipient_name, d.Recipient_phone, d.Delivery_address, "
                + "       (SELECT COALESCE(SUM(tp.Amount),0) FROM Transaction_ProductVariant tp WHERE tp.TransactionID = t.ID) AS ItemCount "
                + "FROM `Transaction` t "
                + "JOIN `User` u   ON t.UserID = u.ID "
                + "LEFT JOIN `User` upd ON t.Updated_by = upd.ID "
                + "LEFT JOIN DeliveryInfo d ON t.DeliveryInfoID = d.ID "
                + "WHERE t.Status = 'SHIPPING' AND t.Type = 'ORDER' AND t.ShipperID = ? "
                + "ORDER BY t.Created_at DESC, t.ID DESC";

        List<OrderModel> orders = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, shipperId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrderDetail(rs));
                }
            }
        }
        return orders;
    }

    public OrderModel findOrderDetail(int id) throws SQLException {
        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Paid_amount, t.Change_amount, t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, "
                + "       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, "
                + "       u.Username, u.Name AS UserName, u.Phone, u.Email, "
                + "       upd.Name AS UpdatedByName, "
                + "       d.Recipient_name, d.Recipient_phone, d.Delivery_address, "
                + "       (SELECT COALESCE(SUM(tp.Amount),0) FROM Transaction_ProductVariant tp WHERE tp.TransactionID = t.ID) AS ItemCount "
                + "FROM `Transaction` t "
                + "JOIN `User` u   ON t.UserID = u.ID "
                + "LEFT JOIN `User` upd ON t.Updated_by = upd.ID "
                + "LEFT JOIN DeliveryInfo d ON t.DeliveryInfoID = d.ID "
                + "WHERE t.ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    OrderModel order = mapOrderDetail(rs);
                    order.setItems(findOrderItems(id));
                    return order;
                }
            }
        }
        return null;
    }

    public List<OrderItemModel> findOrderItems(int transactionId) throws SQLException {
        String sql = "SELECT tp.TransactionID, tp.ProductVariantID, tp.Amount, tp.UnitPrice, "
                + "       tp.Discount_rate, tp.Discount_amount, tp.Total, "
                + "       p.Name AS ProductName, pv.Image AS VariantImage, "
                + "       b.Name AS BrandName, "
                + "       pv.RAM_GB, pv.Storage_GB, pv.ColorName "
                + "FROM Transaction_ProductVariant tp "
                + "JOIN ProductVariant pv ON tp.ProductVariantID = pv.ID "
                + "JOIN Product p ON pv.ProductID = p.ID "
                + "JOIN Brand b ON p.BrandID = b.ID "
                + "WHERE tp.TransactionID = ? "
                + "ORDER BY tp.ProductVariantID";

        List<OrderItemModel> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    items.add(mapOrderItem(rs));
                }
            }
        }
        return items;
    }

    public Set<String> findAllStatuses() {
        Set<String> result = new LinkedHashSet<>(VALID_STATUSES);
        return result;
    }

    public int countByStatus(String status) throws SQLException {
        if (status == null || status.isBlank() || !VALID_STATUSES.contains(status)) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM `Transaction` WHERE Status = ? AND Type = 'ORDER'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countTodaysOrders() throws SQLException {
        String sql = "SELECT COUNT(*) FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND DATE(Created_at) = CURDATE()";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countProcessing() throws SQLException {
        String sql = "SELECT COUNT(*) FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND Status IN ('PENDING','CONFIRMED','PAID','SHIPPING')";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countDelivered() throws SQLException {
        String sql = "SELECT COUNT(*) FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND Status IN ('DELIVERED','COMPLETED')";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countCancelled() throws SQLException {
        String sql = "SELECT COUNT(*) FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND Status IN ('CANCEL_REQUESTED','CANCELLED')";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public BigDecimal totalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(Total_price), 0) FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND Status IN ('PAID','SHIPPING','DELIVERED','COMPLETED')";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }

    public boolean updateStatus(int orderId, String status, Integer updatedBy)
            throws SQLException {
        if (!VALID_STATUSES.contains(status)) {
            throw new SQLException("Invalid status: " + status);
        }
        if (updatedBy == null) {
            updatedBy = resolveFallbackUpdater();
        }
        String sql = "UPDATE `Transaction` SET Status = ?, Updated_by = ?, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, updatedBy);
            statement.setInt(3, orderId);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean assignShipper(int orderId, int shipperId, Integer updatedBy) throws SQLException {
        if (updatedBy == null) {
            updatedBy = resolveFallbackUpdater();
        }
        String sql = "UPDATE `Transaction` SET Status = 'SHIPPING', ShipperID = ?, Updated_by = ?, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, shipperId);
            statement.setInt(2, updatedBy);
            statement.setInt(3, orderId);
            return statement.executeUpdate() > 0;
        }
    }

    private Integer resolveFallbackUpdater() throws SQLException {
        String sql = "SELECT u.ID FROM `User` u JOIN `Role` r ON u.RoleID = r.ID WHERE r.Name IN ('STAFF','ADMIN') AND u.Status='ACTIVE' ORDER BY (r.Name='ADMIN') DESC, u.ID ASC LIMIT 1";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        throw new SQLException("No active STAFF/ADMIN account available to set Updated_by");
    }

    public List<OrderModel> findByUserId(int userId) throws SQLException {
        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Paid_amount, t.Change_amount, t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, "
                + "       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, "
                + "       u.Username, u.Name AS UserName, u.Phone, u.Email, "
                + "       upd.Name AS UpdatedByName, "
                + "       (SELECT COUNT(*) FROM Transaction_ProductVariant tp "
                + "          WHERE tp.TransactionID = t.ID) AS ItemCount "
                + "FROM `Transaction` t "
                + "JOIN `User` u   ON t.UserID = u.ID "
                + "LEFT JOIN `User` upd ON t.Updated_by = upd.ID "
                + "WHERE t.UserID = ? AND t.Type = 'ORDER' "
                + "ORDER BY t.Created_at DESC, t.ID DESC";

        List<OrderModel> orders = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrderSummary(rs));
                }
            }
        }
        return orders;
    }

    public boolean updateStatusWithNote(int orderId, String status, Integer updatedBy, String note)
            throws SQLException {
        if (!VALID_STATUSES.contains(status)) {
            throw new SQLException("Invalid status: " + status);
        }
        String sql = "UPDATE `Transaction` SET Status = ?, Note = ?, Updated_by = ?, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setString(2, note);
            if (updatedBy == null) {
                statement.setNull(3, java.sql.Types.INTEGER);
            } else {
                statement.setInt(3, updatedBy);
            }
            statement.setInt(4, orderId);
            return statement.executeUpdate() > 0;
        }
    }

    private OrderModel mapOrderSummary(ResultSet rs) throws SQLException {
        OrderModel order = new OrderModel();
        order.setId(rs.getInt("ID"));
        order.setUserId(rs.getInt("UserID"));
        order.setUsername(rs.getString("Username"));
        order.setUserName(rs.getString("UserName"));
        order.setTotalPrice(rs.getBigDecimal("Total_price"));
        order.setPaidAmount(rs.getBigDecimal("Paid_amount"));
        order.setChangeAmount(rs.getBigDecimal("Change_amount"));
        order.setType(rs.getString("Type"));
        order.setStatus(rs.getString("Status"));
        order.setMethod(rs.getString("Method"));
        int updatedBy = rs.getInt("Updated_by");
        order.setUpdatedBy(rs.wasNull() ? null : updatedBy);
        order.setUpdatedByName(rs.getString("UpdatedByName"));
        Timestamp updatedAt = rs.getTimestamp("Updated_at");
        Timestamp createdAt = rs.getTimestamp("Created_at");
        order.setUpdatedAt(updatedAt);
        order.setCreatedAt(createdAt);
        int referenceId = rs.getInt("Reference_transactionID");
        order.setReferenceTransactionId(rs.wasNull() ? null : referenceId);
        order.setNote(rs.getString("Note"));
        int deliveryId = rs.getInt("DeliveryInfoID");
        order.setDeliveryInfoId(rs.wasNull() ? null : deliveryId);
        int shipperId = rs.getInt("ShipperID");
        order.setShipperId(rs.wasNull() ? null : shipperId);
        order.setItemCount(rs.getInt("ItemCount"));
        return order;
    }

    private OrderModel mapOrderDetail(ResultSet rs) throws SQLException {
        OrderModel order = mapOrderSummary(rs);
        order.setUserPhone(rs.getString("Phone"));
        order.setUserEmail(rs.getString("Email"));
        order.setRecipientName(rs.getString("Recipient_name"));
        order.setRecipientPhone(rs.getString("Recipient_phone"));
        order.setDeliveryAddress(rs.getString("Delivery_address"));
        return order;
    }

    private OrderItemModel mapOrderItem(ResultSet rs) throws SQLException {
        OrderItemModel item = new OrderItemModel();
        item.setTransactionId(rs.getInt("TransactionID"));
        item.setVariantId(rs.getInt("ProductVariantID"));
        item.setAmount(rs.getInt("Amount"));
        item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
        item.setDiscountRate(rs.getBigDecimal("Discount_rate"));
        item.setDiscountAmount(rs.getBigDecimal("Discount_amount"));
        item.setTotal(rs.getBigDecimal("Total"));
        item.setProductName(rs.getString("ProductName"));
        item.setProductImage(rs.getString("VariantImage"));
        item.setBrandName(rs.getString("BrandName"));
        int ram = rs.getInt("RAM_GB");
        int storage = rs.getInt("Storage_GB");
        item.setMemoryLabel(ram + "GB / " + storage + "GB");
        item.setColorName(rs.getString("ColorName"));
        return item;
    }

    private String normalizeKeyword(String input) {
        if (input == null) {
            return "";
        }
        String trimmed = input.trim().replaceAll("\\s+", " ");
        if (trimmed.length() > MAX_SEARCH_LENGTH) {
            trimmed = trimmed.substring(0, MAX_SEARCH_LENGTH);
        }
        return trimmed;
    }

    private String normalizeSort(String input) {
        if (input == null || input.isBlank()) {
            return "newest";
        }
        return VALID_SORTS.contains(input) ? input : "newest";
    }
}
