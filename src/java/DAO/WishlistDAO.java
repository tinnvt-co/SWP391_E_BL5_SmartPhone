/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import DTO.WishlistViewDTO;
import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author admin
 */
public class WishlistDAO {

    public List<WishlistViewDTO> findByUserId(int userId) throws SQLException {
        String sql = "SELECT w.UserID, w.ProductVariantID, p.ID AS ProductID,"
                + " p.Name AS ProductName, pv.Image, pv.Selling_price, pv.RAM_GB, pv.Storage_GB"
                + "FROM Wishlist w"
                + "JOIN ProductVariant pv "
                + "ON pv.ID = w.ProductVariantID"
                + "JOIN Product p"
                + "ON p.ID = pv.ProductID"
                + "WHERE UserID = ?"
                + "AND pv.Status = 'ACTIVE'"
                + "AND p.Status = 'ACTIVE'";

        List<WishlistViewDTO> wishlist = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {
                    WishlistViewDTO wishlistDTO = new WishlistViewDTO();

                    wishlistDTO.setUserID(resultSet.getInt("UserID"));
                    wishlistDTO.setProductVariantID(resultSet.getInt("ProductVariantID"));
                    wishlistDTO.setProductID(resultSet.getInt("ProductID"));
                    wishlistDTO.setName(resultSet.getString("Name"));
                    wishlistDTO.setImageName(resultSet.getString("Image"));
                    wishlistDTO.setSellingPrice(resultSet.getBigDecimal("Selling_price"));
                    wishlistDTO.setRam(resultSet.getInt("RAM_GB"));
                    wishlistDTO.setStorage(resultSet.getInt("Storage_GB"));

                    wishlist.add(wishlistDTO);
                }
            }
        }
        return wishlist;
    }

    public boolean exists(int userId, int productVariantId)
            throws SQLException {

        String sql = "SELECT 1 FROM Wishlist "
                + "WHERE UserID = ? "
                + "AND ProductVariantID = ? "
                + "LIMIT 1";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, productVariantId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public void insert(int userId, int productVariantId) throws SQLException {
        String sql = "INSERT INTO Wishlist (UserID, ProductVariantID) "
                + "VALUES (?, ?)";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, productVariantId);

            statement.executeUpdate();
        }
    }

    public void delete(int userId, int productVariantId)
            throws SQLException {

        String sql = "DELETE FROM Wishlist "
                + "WHERE UserID = ? "
                + "AND ProductVariantID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, productVariantId);

            statement.executeUpdate();
        }
    }

}
