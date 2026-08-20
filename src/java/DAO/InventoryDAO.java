package DAO;

import model.StockModel;
import model.InventoryLogModel;
import config.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {

    public List<StockModel> getAllStock(String keyword, String brand, String status) {
        List<StockModel> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT v.ID AS variant_id, v.ProductID, v.RAM_GB, v.Storage_GB, v.ColorName, "
                + "v.Selling_price, v.Image AS product_image, v.Status AS variant_status, "
                + "p.Name AS product_name, p.Status AS product_status, "
                + "v.Latest_cost, b.Name AS brand_name, "
                + "COALESCE((SELECT GROUP_CONCAT(c.Name ORDER BY c.Name SEPARATOR ', ') "
                + "FROM Product_Category pc JOIN Category c ON c.ID = pc.CategoryID "
                + "WHERE pc.ProductID = p.ID AND c.Status = 'ACTIVE'), 'Uncategorized') AS category_name, "
                + "i.ID AS inventory_id, COALESCE(i.Amount, 0) AS stock, i.Min_amount, i.Max_amount, i.Status AS inventory_status "
                + "FROM ProductVariant v "
                + "JOIN Product p ON p.ID = v.ProductID "
                + "LEFT JOIN Brand b ON b.ID = p.BrandID "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = v.ID "
                + "WHERE 1=1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.Name LIKE ? OR v.ColorName LIKE ? OR b.Name LIKE ?) ");
        }
        if (brand != null && !brand.trim().isEmpty()) {
            sql.append("AND b.ID = ? ");
        }
        sql.append("ORDER BY p.Name ASC, v.RAM_GB DESC, v.Storage_GB DESC");

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String k = "%" + keyword.trim() + "%";
                ps.setString(idx++, k);
                ps.setString(idx++, k);
                ps.setString(idx++, k);
            }
            if (brand != null && !brand.trim().isEmpty()) {
                ps.setInt(idx++, Integer.parseInt(brand));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StockModel s = new StockModel();
                    s.setVariantId(rs.getInt("variant_id"));
                    s.setProductId(rs.getInt("ProductID"));
                    s.setProductName(rs.getString("product_name"));
                    s.setBrandName(rs.getString("brand_name"));
                    s.setCategoryName(rs.getString("category_name"));
                    int ram = rs.getInt("RAM_GB"), storage = rs.getInt("Storage_GB");
                    s.setMemoryLabel(ram + "GB - " + (storage == 1024 ? "1TB" : storage + "GB"));
                    s.setColorName(rs.getString("ColorName"));
                    s.setProductImage(rs.getString("product_image"));
                    s.setStock(rs.getInt("stock"));
                    s.setSellingPrice(rs.getInt("Selling_price"));
                    s.setImportPrice(rs.getInt("Latest_cost"));
                    int min = rs.getInt("Min_amount");
                    if (!rs.wasNull() && min > 0) {
                        s.setLowStockThreshold(min);
                    }
                    int max = rs.getInt("Max_amount");
                    if (!rs.wasNull() && max > 0) {
                        s.setMaxAmount(max);
                    }
                    s.setActive("ACTIVE".equals(rs.getString("product_status")));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (status != null && !status.trim().isEmpty()) {
            list.removeIf(s -> {
                switch (status) {
                    case "LOW":
                        return !s.isLowStock() || s.isOutOfStock();
                    case "OUT":
                        return !s.isOutOfStock();
                    case "EXCESS":
                        return !"EXCESS".equals(s.getStockStatus());
                    case "OK":
                        return s.isLowStock() || s.isOutOfStock() || "EXCESS".equals(s.getStockStatus());
                    default:
                        return false;
                }
            });
        }
        return list;
    }

    public int[] getStockStats() {
        int total = 0, inStock = 0, lowStock = 0, outOfStock = 0, excess = 0;
        String sql = "SELECT v.ID, COALESCE(i.Amount, 0) AS stock, COALESCE(i.Min_amount, 5) AS min_amount, "
                + "COALESCE(i.Max_amount, 0) AS max_amount, v.Status, p.Status AS pstatus "
                + "FROM ProductVariant v "
                + "JOIN Product p ON p.ID = v.ProductID "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = v.ID";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                if (!"ACTIVE".equals(rs.getString("pstatus"))) {
                    continue;
                }
                if (!"ACTIVE".equals(rs.getString("Status"))) {
                    continue;
                }
                int stock = rs.getInt("stock");
                int min = rs.getInt("min_amount");
                int max = rs.getInt("max_amount");
                total++;
                if (stock <= 0) {
                    outOfStock++;
                } else if (stock <= min) {
                    lowStock++;
                } else if (max > 0 && stock > max) {
                    excess++;
                } else {
                    inStock++;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new int[]{total, inStock, lowStock, outOfStock, excess};
    }

    public boolean stockIn(int variantId, int qty, String note, Integer createdBy) {
        String checkSql = "SELECT COUNT(*) FROM Inventory WHERE ProductVariantID = ?";
        String insertSql = "INSERT INTO Inventory(ProductVariantID, Amount, Status, Updated_at) VALUES(?, ?, 'ACTIVE', CURRENT_TIMESTAMP)";
        String updateSql = "UPDATE Inventory SET Amount = Amount + ?, Updated_at = CURRENT_TIMESTAMP WHERE ProductVariantID = ?";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean exists = false;
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setInt(1, variantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            exists = true;
                        }
                    }
                }
                if (!exists) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setInt(1, variantId);
                        ps.setInt(2, qty);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                        ps.setInt(1, qty);
                        ps.setInt(2, variantId);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean stockAdjust(int variantId, int newStock, String note, Integer createdBy) {
        String insertSql = "INSERT INTO Inventory(ProductVariantID, Amount, Status, Updated_at) VALUES(?, ?, 'ACTIVE', CURRENT_TIMESTAMP)";
        String updateSql = "UPDATE Inventory SET Amount = ?, Updated_at = CURRENT_TIMESTAMP WHERE ProductVariantID = ?";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO Inventory(ProductVariantID, Amount, Status, Updated_at) VALUES(?, ?, 'ACTIVE', CURRENT_TIMESTAMP) "
                        + "ON DUPLICATE KEY UPDATE Amount = VALUES(Amount), Updated_at = CURRENT_TIMESTAMP")) {
                    ps.setInt(1, variantId);
                    ps.setInt(2, newStock);
                    ps.executeUpdate();
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateMinMax(int variantId, int minAmount, int maxAmount, Integer createdBy) {
        String checkSql = "SELECT COUNT(*) FROM Inventory WHERE ProductVariantID = ?";
        String insertSql = "INSERT INTO Inventory(ProductVariantID, Amount, Min_amount, Max_amount, Status, Updated_at) "
                + "VALUES(?, 0, ?, ?, 'ACTIVE', CURRENT_TIMESTAMP)";
        String updateSql = "UPDATE Inventory SET Min_amount = ?, Max_amount = ?, Updated_at = CURRENT_TIMESTAMP WHERE ProductVariantID = ?";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean exists = false;
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setInt(1, variantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            exists = true;
                        }
                    }
                }
                if (!exists) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setInt(1, variantId);
                        ps.setInt(2, minAmount);
                        ps.setInt(3, maxAmount);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                        ps.setInt(1, minAmount);
                        ps.setInt(2, maxAmount);
                        ps.setInt(3, variantId);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
