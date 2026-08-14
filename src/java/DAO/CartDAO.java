package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CartItemModel;

public class CartDAO {

    public void addItem(int userId, int productVariantId, int amount)
            throws SQLException {
        int requestedAmount = Math.max(1, amount);
        int stock = findStock(productVariantId);
        if (stock <= 0) {
            throw new SQLException("This product variant is out of stock.");
        }

        int finalAmount = Math.min(requestedAmount, stock);
        String sql = "INSERT INTO Cart (UserID, ProductVariantID, Amount) "
                + "VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE Amount = LEAST(Amount + VALUES(Amount), ?)";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setInt(2, productVariantId);
            statement.setInt(3, finalAmount);
            statement.setInt(4, stock);
            statement.executeUpdate();
        }
    }

    public void updateAmount(int userId, int productVariantId, int amount)
            throws SQLException {
        if (amount <= 0) {
            removeItem(userId, productVariantId);
            return;
        }

        int stock = findStock(productVariantId);
        String sql = "UPDATE Cart SET Amount = ? WHERE UserID = ? AND ProductVariantID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, Math.min(amount, Math.max(stock, 1)));
            statement.setInt(2, userId);
            statement.setInt(3, productVariantId);
            statement.executeUpdate();
        }
    }

    public void removeItem(int userId, int productVariantId) throws SQLException {
        String sql = "DELETE FROM Cart WHERE UserID = ? AND ProductVariantID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setInt(2, productVariantId);
            statement.executeUpdate();
        }
    }

    public List<CartItemModel> findByUserId(int userId) throws SQLException {
        String sql = "SELECT c.UserID, c.ProductVariantID, c.Amount, "
                + "pv.ProductID, pv.RAM_GB, pv.Storage_GB, pv.ColorName, "
                + "pv.Selling_price, pv.Image, p.Name AS ProductName, "
                + "b.Name AS BrandName, COALESCE(i.Amount, 0) AS Stock "
                + "FROM Cart c "
                + "JOIN ProductVariant pv ON pv.ID = c.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID "
                + "JOIN Brand b ON b.ID = p.BrandID "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
                + "WHERE c.UserID = ? "
                + "ORDER BY p.Name, pv.Storage_GB, pv.RAM_GB, pv.ColorName";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            List<CartItemModel> items = new ArrayList<>();
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    items.add(mapItem(resultSet));
                }
            }
            return items;
        }
    }

    public int countItems(int userId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(Amount), 0) FROM Cart WHERE UserID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1);
            }
        }
    }

    private int findStock(int productVariantId) throws SQLException {
        String sql = "SELECT COALESCE(i.Amount, 0) AS Stock "
                + "FROM ProductVariant pv "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
                + "WHERE pv.ID = ? AND pv.Status = 'ACTIVE'";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productVariantId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    throw new SQLException("Product variant does not exist.");
                }
                return resultSet.getInt("Stock");
            }
        }
    }

    private CartItemModel mapItem(ResultSet resultSet) throws SQLException {
        CartItemModel item = new CartItemModel();
        item.setUserId(resultSet.getInt("UserID"));
        item.setProductVariantId(resultSet.getInt("ProductVariantID"));
        item.setAmount(resultSet.getInt("Amount"));
        item.setProductId(resultSet.getInt("ProductID"));
        item.setRamGb(resultSet.getInt("RAM_GB"));
        item.setStorageGb(resultSet.getInt("Storage_GB"));
        item.setColorName(resultSet.getString("ColorName"));
        item.setSellingPrice(resultSet.getInt("Selling_price"));
        item.setImage(resultSet.getString("Image"));
        item.setProductName(resultSet.getString("ProductName"));
        item.setBrandName(resultSet.getString("BrandName"));
        item.setStock(resultSet.getInt("Stock"));
        return item;
    }
}
