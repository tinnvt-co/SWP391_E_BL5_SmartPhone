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
            "PENDING", "CONFIRMED", "PROCESSING", "SHIPPING", "DELIVERED",
            "COMPLETED", "CANCEL_REQUESTED", "CANCELLED", "DELIVERY_FAILED");
    private static final Set<String> VALID_TYPES = Set.of("ORDER", "IMPORT");
    private static final Set<String> VALID_SORTS = Set.of("newest", "oldest", "total-desc", "total-asc");
    private static final int MAX_SEARCH_LENGTH = 100;

    public List<OrderModel> findOrders(String keyword, String status, String type,
            String sort, boolean excludeImport, int offset, int limit)
            throws SQLException {

        StringBuilder sql = new StringBuilder()
                .append("SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, ")
                .append("       t.Method, ")
                .append("       t.Updated_by, t.Updated_at, t.Created_at, t.Note, t.Proof_image, ")
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
        
        sql.append("LIMIT ? OFFSET ? ");
        params.add(limit);
        params.add(offset);

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

    public int countOrders(String keyword, String status, String type, boolean excludeImport) throws SQLException {
        StringBuilder sql = new StringBuilder()
                .append("SELECT COUNT(*) ")
                .append("FROM `Transaction` t ")
                .append("JOIN `User` u   ON t.UserID = u.ID ")
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

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<OrderModel> findAvailableShippingOrders() throws SQLException {
        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, t.Proof_image, "
                + "       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, "
                + "       u.Username, u.Name AS UserName, u.Phone, u.Email, "
                + "       upd.Name AS UpdatedByName, "
                + "       d.Recipient_name, d.Recipient_phone, d.Delivery_address, "
                + "       (SELECT COALESCE(SUM(tp.Amount),0) FROM Transaction_ProductVariant tp WHERE tp.TransactionID = t.ID) AS ItemCount "
                + "FROM `Transaction` t "
                + "JOIN `User` u   ON t.UserID = u.ID "
                + "LEFT JOIN `User` upd ON t.Updated_by = upd.ID "
                + "LEFT JOIN DeliveryInfo d ON t.DeliveryInfoID = d.ID "
                + "WHERE t.Status = 'SHIPPING' AND t.Type = 'ORDER' AND (t.ShipperID IS NULL OR t.ShipperID = 0) "
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
                + "       t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, t.Proof_image, "
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

    public List<OrderModel> findDeliveredOrdersByShipper(int shipperId, int offset, int limit) throws SQLException {
        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, t.Proof_image, "
                + "       t.Reference_transactionID, t.DeliveryInfoID, t.ShipperID, "
                + "       u.Username, u.Name AS UserName, u.Phone, u.Email, "
                + "       upd.Name AS UpdatedByName, "
                + "       d.Recipient_name, d.Recipient_phone, d.Delivery_address, "
                + "       (SELECT COALESCE(SUM(tp.Amount),0) FROM Transaction_ProductVariant tp WHERE tp.TransactionID = t.ID) AS ItemCount "
                + "FROM `Transaction` t "
                + "JOIN `User` u   ON t.UserID = u.ID "
                + "LEFT JOIN `User` upd ON t.Updated_by = upd.ID "
                + "LEFT JOIN DeliveryInfo d ON t.DeliveryInfoID = d.ID "
                + "WHERE t.Status IN ('DELIVERED', 'COMPLETED') AND t.Type = 'ORDER' AND t.ShipperID = ? "
                + "ORDER BY t.Updated_at DESC, t.ID DESC "
                + "LIMIT ? OFFSET ?";

        List<OrderModel> orders = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, shipperId);
            statement.setInt(2, limit);
            statement.setInt(3, offset);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrderDetail(rs));
                }
            }
        }
        return orders;
    }

    public int countDeliveredOrdersByShipper(int shipperId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM `Transaction` "
                   + "WHERE Status IN ('DELIVERED', 'COMPLETED') AND Type = 'ORDER' AND ShipperID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, shipperId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public OrderModel findOrderDetail(int id) throws SQLException {
        String sql = "SELECT t.ID, t.UserID, t.Total_price, t.Type, t.Status, "
                + "       t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, t.Proof_image, "
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
                + "WHERE Type = 'ORDER' AND Status IN ('PENDING','CONFIRMED','SHIPPING')";
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

    public int countCompletedOrders(Timestamp from, Timestamp to) throws SQLException {
        String sql = "SELECT COUNT(*) FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND Status = 'COMPLETED' "
                + "AND Created_at BETWEEN ? AND ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public BigDecimal totalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(Total_price), 0) FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND Status IN ('SHIPPING','DELIVERED','COMPLETED')";
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
        // Stamp Delivered_at the first time an order transitions to DELIVERED.
        // We never overwrite an existing value so subsequent edits (note, proof)
        // can't shift the 15-day auto-completion deadline.
        StringBuilder sql = new StringBuilder(
                "UPDATE `Transaction` SET Status = ?, Updated_by = ?, Updated_at = CURRENT_TIMESTAMP");
        if ("DELIVERED".equals(status)) {
            sql.append(", Delivered_at = COALESCE(Delivered_at, CURRENT_TIMESTAMP)");
        }
        sql.append(" WHERE ID = ?");
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
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
                + "       t.Method, "
                + "       t.Updated_by, t.Updated_at, t.Created_at, t.Note, t.Proof_image, "
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
        StringBuilder sql = new StringBuilder(
                "UPDATE `Transaction` SET Status = ?, Note = ?, Updated_by = ?, Updated_at = CURRENT_TIMESTAMP");
        if ("DELIVERED".equals(status)) {
            sql.append(", Delivered_at = COALESCE(Delivered_at, CURRENT_TIMESTAMP)");
        }
        sql.append(" WHERE ID = ?");
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
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

    public boolean updateStatusWithProofAndNote(int orderId, String status, Integer updatedBy, String note, String proofImage)
            throws SQLException {
        if (!VALID_STATUSES.contains(status)) {
            throw new SQLException("Invalid status: " + status);
        }
        StringBuilder sql = new StringBuilder(
                "UPDATE `Transaction` SET Status = ?, Note = ?, Proof_image = ?, Updated_by = ?, Updated_at = CURRENT_TIMESTAMP");
        if ("DELIVERED".equals(status)) {
            sql.append(", Delivered_at = COALESCE(Delivered_at, CURRENT_TIMESTAMP)");
        }
        sql.append(" WHERE ID = ?");
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            statement.setString(1, status);
            statement.setString(2, note);
            statement.setString(3, proofImage);
            if (updatedBy == null) {
                statement.setNull(4, java.sql.Types.INTEGER);
            } else {
                statement.setInt(4, updatedBy);
            }
            statement.setInt(5, orderId);
            return statement.executeUpdate() > 0;
        }
    }

    private OrderModel mapOrderSummary(ResultSet rs) throws SQLException {
        OrderModel order = new OrderModel();

        order.setId(rs.getInt("ID"));
        order.setUserId(rs.getInt("UserID"));
        order.setUserName(rs.getString("UserName"));
        order.setUsername(rs.getString("Username"));
        order.setUserPhone(rs.getString("Phone"));
        order.setUserEmail(rs.getString("Email"));

        order.setTotalPrice(rs.getBigDecimal("Total_price"));
        order.setType(rs.getString("Type"));
        order.setStatus(rs.getString("Status"));
        order.setMethod(rs.getString("Method"));
        
        if ("COD".equalsIgnoreCase(order.getMethod())) {
            order.setPaidAmount(BigDecimal.ZERO);
        } else {
            order.setPaidAmount(order.getTotalPrice());
        }

        // Chưa có trong SELECT hiện tại — cần join/subquery riêng nếu muốn dùng thật
        order.setSupplierId(null);
        order.setSupplierName(null);

        int updatedBy = rs.getInt("Updated_by");
        order.setUpdatedBy(rs.wasNull() ? null : updatedBy);
        order.setUpdatedByName(rs.getString("UpdatedByName"));

        order.setUpdatedAt(rs.getTimestamp("Updated_at"));
        order.setCreatedAt(rs.getTimestamp("Created_at"));

        int refTransId = rs.getInt("Reference_transactionID");
        order.setReferenceTransactionId(rs.wasNull() ? null : refTransId);

        int deliveryInfoId = rs.getInt("DeliveryInfoID");
        order.setDeliveryInfoId(rs.wasNull() ? null : deliveryInfoId);

        // Chưa có trong SELECT hiện tại — thường lấy từ bảng DeliveryInfo qua join riêng
        order.setRecipientName(null);
        order.setRecipientPhone(null);
        order.setDeliveryAddress(null);

        order.setItemCount(rs.getInt("ItemCount"));
        order.setNote(rs.getString("Note"));

        // items để rỗng ở summary, load riêng khi xem chi tiết đơn
        order.setItems(new ArrayList<>());

        // Các cờ trạng thái refund/complaint — chưa có trong query này
        order.setHasOpenRefund(null);
        order.setHasBlockingRefund(null);
        order.setHasCancelPending(null);
        order.setHasOpenComplaint(null);
        order.setHasAnyComplaint(null);

        int shipperId = rs.getInt("ShipperID");
        order.setShipperId(rs.wasNull() ? null : shipperId);

        order.setProofImage(rs.getString("Proof_image"));

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

    /**
     * Returns the IDs of customer orders that have been DELIVERED for at least
     * {@code days} days (using the Delivered_at stamp) and have not yet moved
     * to COMPLETED.Used by the auto-completion scheduler.
     * @param days
     * @return 
     * @throws java.sql.SQLException
     */
    public List<Integer> findStaleDeliveredIds(int days) throws SQLException {
        String sql = "SELECT ID FROM `Transaction` "
                + "WHERE Type = 'ORDER' AND Status = 'DELIVERED' "
                + "AND Delivered_at IS NOT NULL "
                + "AND Delivered_at <= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL ? DAY) "
                + "ORDER BY Delivered_at ASC";
        List<Integer> ids = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, days);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt(1));
                }
            }
        }
        return ids;
    }

    /**
     * Bulk-promotes stale DELIVERED orders to COMPLETED.We don't write a
 special "auto-completed" status because the workflow is identical to a
 customer pressing "Complete" — the only difference is the Updated_by is
 the system user (or whoever resolveFallbackUpdater picks).
     * @param orderIds
     * @param updatedBy
     * @return 
     * @throws java.sql.SQLException
     */
    public int autoCompleteStale(List<Integer> orderIds, Integer updatedBy) throws SQLException {
        if (orderIds == null || orderIds.isEmpty()) {
            return 0;
        }
        if (updatedBy == null) {
            updatedBy = resolveFallbackUpdater();
        }
        String placeholders = String.join(",", java.util.Collections.nCopies(orderIds.size(), "?"));
        String sql = "UPDATE `Transaction` SET Status = 'COMPLETED', "
                + "Updated_by = ?, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID IN (" + placeholders + ") AND Status = 'DELIVERED'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, updatedBy);
            for (int i = 0; i < orderIds.size(); i++) {
                statement.setInt(i + 2, orderIds.get(i));
            }
            return statement.executeUpdate();
        }
    }
}
