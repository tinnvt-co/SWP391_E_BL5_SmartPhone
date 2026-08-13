/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CategoryModel;
import model.ProductModel;

/**
 *
 * @author Admin
 */
public class ProductDAO {

    private static final String PRODUCT_SELECT =
            "SELECT p.ID, p.Name, p.Description, p.Release_Year, p.Rating, p.warranty_months, "
            + "p.Barcode, p.SKU, p.Selling_price, p.Latest_cost, p.Image, p.Status, "
            + "c.Name AS CategoryName, b.Name AS BrandName, 0 AS InventoryAmount, "
            + "0 AS SoldAmount "
            + "FROM Product p "
            + "JOIN Category c ON p.CategoryID = c.ID "
            + "JOIN Brand b ON p.BrandID = b.ID ";

    public List<ProductModel> findFeaturedProducts(int limit) throws SQLException {
        String sql = PRODUCT_SELECT
                + "WHERE p.Status = 'ACTIVE' "
                + "ORDER BY p.Rating DESC, p.Created_at DESC, p.ID DESC "
                + "LIMIT ?";

        List<ProductModel> products = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProduct(rs));
                }
            }
        }
        return products;
    }

    public List<ProductModel> findPublicProducts(String keyword, String sort) throws SQLException {
        StringBuilder sql = new StringBuilder(PRODUCT_SELECT)
                .append("WHERE p.Status = 'ACTIVE' ");
        List<String> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (p.Name LIKE ? OR p.Description LIKE ? OR b.Name LIKE ? OR c.Name LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        switch (sort == null ? "" : sort) {
            case "price-asc" -> sql.append("ORDER BY p.Selling_price ASC, p.ID DESC");
            case "price-desc" -> sql.append("ORDER BY p.Selling_price DESC, p.ID DESC");
            default -> sql.append("ORDER BY p.Created_at DESC, p.ID DESC");
        }

        List<ProductModel> products = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProduct(rs));
                }
            }
        }
        return products;
    }

    public ProductModel findById(int id) throws SQLException {
        String sql = PRODUCT_SELECT + "WHERE p.ID = ? AND p.Status = 'ACTIVE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        }
        return null;
    }

    public List<CategoryModel> findActiveCategories() throws SQLException {
        String sql = "SELECT c.ID, c.Name, c.Description, COUNT(p.ID) AS ProductCount "
                + "FROM Category c "
                + "LEFT JOIN Product p ON c.ID = p.CategoryID AND p.Status = 'ACTIVE' "
                + "WHERE c.Status = 'ACTIVE' "
                + "GROUP BY c.ID, c.Name, c.Description "
                + "ORDER BY c.ID";

        List<CategoryModel> categories = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CategoryModel category = new CategoryModel();
                category.setId(rs.getInt("ID"));
                category.setName(rs.getString("Name"));
                category.setDescription(rs.getString("Description"));
                category.setProductCount(rs.getInt("ProductCount"));
                categories.add(category);
            }
        }
        return categories;
    }

    public int countActiveProducts() throws SQLException {
        return count("SELECT COUNT(*) FROM Product WHERE Status = 'ACTIVE'");
    }

    public int countAvailableProducts() throws SQLException {
        return countActiveProducts();
    }

    private int count(String sql) throws SQLException {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private ProductModel mapProduct(ResultSet rs) throws SQLException {
        ProductModel product = new ProductModel();
        product.setId(rs.getInt("ID"));
        product.setName(rs.getString("Name"));
        product.setDescription(rs.getString("Description"));
        int releaseYear = rs.getInt("Release_Year");
        if (!rs.wasNull()) {
            product.setReleaseYear(releaseYear);
        }
        product.setRating(rs.getBigDecimal("Rating"));
        product.setWarrantyMonths(rs.getInt("warranty_months"));
        product.setBarcode(rs.getString("Barcode"));
        product.setSku(rs.getString("SKU"));
        product.setSellingPrice(rs.getBigDecimal("Selling_price"));
        product.setLatestCost(rs.getBigDecimal("Latest_cost"));
        product.setImage(rs.getString("Image"));
        product.setStatus(rs.getString("Status"));
        product.setCategoryName(rs.getString("CategoryName"));
        product.setBrandName(rs.getString("BrandName"));
        product.setInventoryAmount(rs.getInt("InventoryAmount"));
        product.setSoldAmount(rs.getBigDecimal("SoldAmount"));
        return product;
    }
}
