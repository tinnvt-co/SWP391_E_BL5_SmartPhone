package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CartItemModel;

public class WishlistDAO {

    public void addItem(int userId, int productVariantId) throws SQLException {
        ensureVariantExists(productVariantId);
        String sql = "INSERT IGNORE INTO Wishlist (UserID, ProductVariantID) VALUES (?, ?)";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setInt(2, productVariantId);
            statement.executeUpdate();
        }
    }

    public void removeItem(int userId, int productVariantId) throws SQLException {
        String sql = "DELETE FROM Wishlist WHERE UserID = ? AND ProductVariantID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setInt(2, productVariantId);
            statement.executeUpdate();
        }
    }

    public List<CartItemModel> findByUserId(int userId) throws SQLException {
        String sql = "SELECT w.UserID, w.ProductVariantID, "
                + "pv.ProductID, pv.RAM_GB, pv.Storage_GB, pv.ColorName, "
                + "pv.Selling_price, pv.Image, p.Name AS ProductName, "
                + "b.Name AS BrandName, COALESCE(i.Amount, 0) AS Stock "
                + "FROM Wishlist w "
                + "JOIN ProductVariant pv ON pv.ID = w.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID "
                + "JOIN Brand b ON b.ID = p.BrandID "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
                + "WHERE w.UserID = ? "
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
        String sql = "SELECT COUNT(*) FROM Wishlist WHERE UserID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1);
            }
        }
    }

    private void ensureVariantExists(int productVariantId) throws SQLException {
        String sql = "SELECT ID FROM ProductVariant WHERE ID = ? AND Status = 'ACTIVE'";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productVariantId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    throw new SQLException("Product variant does not exist.");
                }
            }
        }
    }

    private CartItemModel mapItem(ResultSet resultSet) throws SQLException {
        CartItemModel item = new CartItemModel();
        item.setUserId(resultSet.getInt("UserID"));
        item.setProductVariantId(resultSet.getInt("ProductVariantID"));
        item.setAmount(1);
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
