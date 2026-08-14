package DAO;

import config.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import model.CartItemModel;
import model.CheckoutInfoModel;

public class CheckoutDAO {

    public int createOrder(int userId, List<CartItemModel> items,
            CheckoutInfoModel info, String method, String status,
            boolean paid, boolean reduceStockAndClearCart) throws SQLException {
        if (items == null || items.isEmpty()) {
            throw new SQLException("No products selected for checkout.");
        }

        try (Connection connection = DBContext.getConnection()) {
            boolean autoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                int deliveryInfoId = nextId(connection, "DeliveryInfo");
                int transactionId = nextId(connection, "Transaction");
                int total = total(items);

                insertDeliveryInfo(connection, deliveryInfoId, userId, info);
                insertTransaction(connection, transactionId, userId, total,
                        method, status, paid, deliveryInfoId);
                insertOrderItems(connection, transactionId, items);
                if (reduceStockAndClearCart) {
                    reduceStock(connection, items);
                    removeCartItems(connection, userId, items);
                }

                connection.commit();
                return transactionId;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(autoCommit);
            }
        }
    }

    public void markOnlinePaymentSuccess(int transactionId) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            boolean autoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                String status = paymentStatus(connection, transactionId);
                if ("PAID".equals(status)) {
                    connection.commit();
                    return;
                }
                if (!"PENDING".equals(status)) {
                    throw new SQLException("Order cannot be marked paid.");
                }
                if (!markPaid(connection, transactionId)) {
                    throw new SQLException("Order not found.");
                }
                List<CartItemModel> items = findOrderCartItems(connection, transactionId);
                reduceStock(connection, items);
                removeCartItemsForTransaction(connection, transactionId);
                connection.commit();
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(autoCommit);
            }
        }
    }

    private String paymentStatus(Connection connection, int transactionId)
            throws SQLException {
        String sql = "SELECT Status FROM `Transaction` WHERE ID = ? AND Method = 'VNPAY'";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getString("Status") : "";
            }
        }
    }

    public void markOnlinePaymentFailed(int transactionId) throws SQLException {
        String sql = "UPDATE `Transaction` "
                + "SET Status = 'CANCELLED', Paid_amount = 0, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? AND Method = 'VNPAY' AND Status = 'PENDING'";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.executeUpdate();
        }
    }

    private void insertDeliveryInfo(Connection connection, int id, int userId,
            CheckoutInfoModel info) throws SQLException {
        String sql = "INSERT INTO DeliveryInfo "
                + "(ID, UserID, Recipient_name, Recipient_phone, Delivery_address, Status) "
                + "VALUES (?, ?, ?, ?, ?, 'PENDING')";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.setInt(2, userId);
            statement.setString(3, required(info.getFullName(), "Full name"));
            statement.setString(4, required(info.getPhone(), "Phone"));
            statement.setString(5, required(info.deliveryAddress(), "Delivery address"));
            statement.executeUpdate();
        }
    }

    private void insertTransaction(Connection connection, int id, int userId,
            int total, String method, String status, boolean paid,
            int deliveryInfoId) throws SQLException {
        String sql = "INSERT INTO `Transaction` "
                + "(ID, UserID, Total_price, Type, Status, SupplierID, Paid_amount, "
                + "Change_amount, Method, Updated_by, Reference_transactionID, DeliveryInfoID) "
                + "VALUES (?, ?, ?, 'ORDER', ?, NULL, ?, 0, ?, ?, NULL, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.setInt(2, userId);
            statement.setBigDecimal(3, BigDecimal.valueOf(total));
            statement.setString(4, status);
            statement.setBigDecimal(5, paid ? BigDecimal.valueOf(total) : BigDecimal.ZERO);
            statement.setString(6, method);
            statement.setInt(7, userId);
            statement.setInt(8, deliveryInfoId);
            statement.executeUpdate();
        }
    }

    private void insertOrderItems(Connection connection, int transactionId,
            List<CartItemModel> items) throws SQLException {
        String sql = "INSERT INTO Transaction_ProductVariant "
                + "(TransactionID, ProductVariantID, Amount, UnitPrice, Discount_rate, "
                + "Discount_amount, Total) VALUES (?, ?, ?, ?, 0, 0, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (CartItemModel item : items) {
                int lineTotal = item.getLineTotal();
                statement.setInt(1, transactionId);
                statement.setInt(2, item.getProductVariantId());
                statement.setInt(3, item.getAmount());
                statement.setBigDecimal(4, BigDecimal.valueOf(item.getSellingPrice()));
                statement.setBigDecimal(5, BigDecimal.valueOf(lineTotal));
                statement.addBatch();
            }
            statement.executeBatch();
        }
    }

    private boolean markPaid(Connection connection, int transactionId)
            throws SQLException {
        String sql = "UPDATE `Transaction` "
                + "SET Status = 'PAID', Paid_amount = Total_price, Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ? AND Method = 'VNPAY' AND Status = 'PENDING'";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            return statement.executeUpdate() > 0;
        }
    }

    private List<CartItemModel> findOrderCartItems(Connection connection,
            int transactionId) throws SQLException {
        String sql = "SELECT t.UserID, tp.ProductVariantID, tp.Amount, "
                + "pv.ProductID, pv.RAM_GB, pv.Storage_GB, pv.ColorName, "
                + "pv.Selling_price, pv.Image, p.Name AS ProductName, "
                + "b.Name AS BrandName, COALESCE(i.Amount, 0) AS Stock "
                + "FROM Transaction_ProductVariant tp "
                + "JOIN `Transaction` t ON t.ID = tp.TransactionID "
                + "JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID "
                + "JOIN Brand b ON b.ID = p.BrandID "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
                + "WHERE tp.TransactionID = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            try (ResultSet rs = statement.executeQuery()) {
                java.util.ArrayList<CartItemModel> items = new java.util.ArrayList<>();
                while (rs.next()) {
                    CartItemModel item = new CartItemModel();
                    item.setUserId(rs.getInt("UserID"));
                    item.setProductVariantId(rs.getInt("ProductVariantID"));
                    item.setAmount(rs.getInt("Amount"));
                    item.setProductId(rs.getInt("ProductID"));
                    item.setRamGb(rs.getInt("RAM_GB"));
                    item.setStorageGb(rs.getInt("Storage_GB"));
                    item.setColorName(rs.getString("ColorName"));
                    item.setSellingPrice(rs.getInt("Selling_price"));
                    item.setImage(rs.getString("Image"));
                    item.setProductName(rs.getString("ProductName"));
                    item.setBrandName(rs.getString("BrandName"));
                    item.setStock(rs.getInt("Stock"));
                    items.add(item);
                }
                return items;
            }
        }
    }

    private void reduceStock(Connection connection, List<CartItemModel> items)
            throws SQLException {
        String sql = "UPDATE Inventory SET Amount = Amount - ? "
                + "WHERE ProductVariantID = ? AND Amount >= ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (CartItemModel item : items) {
                statement.setInt(1, item.getAmount());
                statement.setInt(2, item.getProductVariantId());
                statement.setInt(3, item.getAmount());
                if (statement.executeUpdate() == 0) {
                    throw new SQLException("Not enough stock for " + item.getProductName());
                }
            }
        }
    }

    private void removeCartItems(Connection connection, int userId,
            List<CartItemModel> items) throws SQLException {
        String sql = "DELETE FROM Cart WHERE UserID = ? AND ProductVariantID = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (CartItemModel item : items) {
                statement.setInt(1, userId);
                statement.setInt(2, item.getProductVariantId());
                statement.addBatch();
            }
            statement.executeBatch();
        }
    }

    private void removeCartItemsForTransaction(Connection connection,
            int transactionId) throws SQLException {
        String sql = "DELETE c FROM Cart c "
                + "JOIN `Transaction` t ON t.UserID = c.UserID "
                + "JOIN Transaction_ProductVariant tp "
                + "  ON tp.TransactionID = t.ID AND tp.ProductVariantID = c.ProductVariantID "
                + "WHERE t.ID = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.executeUpdate();
        }
    }

    private int nextId(Connection connection, String table) throws SQLException {
        String safeTable = "`" + table.replace("`", "") + "`";
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT COALESCE(MAX(ID), 0) + 1 FROM " + safeTable);
             ResultSet resultSet = statement.executeQuery()) {
            resultSet.next();
            return resultSet.getInt(1);
        }
    }

    private int total(List<CartItemModel> items) {
        int total = 0;
        for (CartItemModel item : items) {
            total += item.getLineTotal();
        }
        return total;
    }

    private String required(String value, String field) throws SQLException {
        if (value == null || value.isBlank()) {
            throw new SQLException(field + " is required.");
        }
        return value.trim();
    }
}
