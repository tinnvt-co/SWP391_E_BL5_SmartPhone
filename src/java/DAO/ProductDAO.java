package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.CategoryModel;
import model.ProductModel;
import model.ProductVariantModel;

public class ProductDAO {
    public List<ProductModel> findAll(String keyword, Integer brandId, Integer categoryId,
            String sort, boolean publicOnly) throws SQLException {
        try (Connection con = DBContext.getConnection()) {
            StringBuilder sql = new StringBuilder(selectSql(con)).append("WHERE 1=1 ");
            List<Object> params = new ArrayList<>();
            if (publicOnly) sql.append("AND p.Status='ACTIVE' AND c.Status='ACTIVE' AND b.Status='ACTIVE' ");
            if (keyword != null && !keyword.isBlank()) {
                sql.append("AND p.Name LIKE ? ESCAPE '\\\\' ");
                params.add("%" + escapeLike(keyword.trim()) + "%");
            }
            if (brandId != null) { sql.append("AND p.BrandID=? "); params.add(brandId); }
            if (categoryId != null) { sql.append("AND p.CategoryID=? "); params.add(categoryId); }
            sql.append(orderBy(sort));
            try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                List<ProductModel> list = new ArrayList<>();
                while (rs.next()) list.add(map(rs));
                if (tableExists(con, "ProductVariant")) loadVariants(con, list);
                return list;
            }
            }
        }
    }

    public ProductModel findById(int id) throws SQLException {
        try (Connection con = DBContext.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(selectSql(con) + "WHERE p.ID=?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return null;
                    ProductModel product = map(rs);
                    if (tableExists(con, "ProductVariant")) loadVariants(con, List.of(product));
                    return product;
                }
            }
        }
    }

    public void save(ProductModel p) throws SQLException {
        if (p.getId() == 0) insert(p); else update(p);
    }




    private void insert(ProductModel p) throws SQLException {
        try (Connection con = DBContext.getConnection()) {
            boolean legacyDiscount = columnExists(con, "Product", "Discount");
            String columns = "Name,Description,Release_Year,Rating,warranty_months,Barcode,SKU,Selling_price,Latest_cost,Image"
                    + (legacyDiscount ? ",Discount" : "")
                    + ",CategoryID,BrandID,Status";
            int parameterCount = 13 + (legacyDiscount ? 1 : 0);
            String productSql = "INSERT INTO Product(" + columns + ") VALUES("
                    + "?,".repeat(parameterCount - 1) + "?)";
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(productSql, Statement.RETURN_GENERATED_KEYS)) {
                bindProduct(ps, p, legacyDiscount);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new SQLException("Cannot create product ID");
                    p.setId(keys.getInt(1));
                }
                if (tableExists(con, "ProductVariant")) {
                    createDefaultVariants(con, p);
                } else {
                    try (PreparedStatement inventory = con.prepareStatement("INSERT INTO Inventory(ProductID,Amount,Min_amount,Status) VALUES(?,?,0,'ACTIVE')")) {
                        inventory.setInt(1, p.getId()); inventory.setInt(2, p.getStock()); inventory.executeUpdate();
                    }
                }
                con.commit();
            } catch (SQLException ex) { con.rollback(); throw ex; }
            finally { con.setAutoCommit(true); }
        }
    }

    private void update(ProductModel p) throws SQLException {
        try (Connection con = DBContext.getConnection()) {
            boolean legacyDiscount = columnExists(con, "Product", "Discount");
            String sql = "UPDATE Product SET Name=?,Description=?,Release_Year=?,Rating=?,warranty_months=?,Barcode=?,SKU=?,Selling_price=?,Latest_cost=?,Image=?"
                    + (legacyDiscount ? ",Discount=?" : "")
                    + ",CategoryID=?,BrandID=?,Status=? WHERE ID=?";
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                int lastIndex = bindProduct(ps, p, legacyDiscount);
                ps.setInt(lastIndex + 1, p.getId());
                ps.executeUpdate();
                if (tableExists(con, "ProductVariant")) {
                    try (PreparedStatement inv = con.prepareStatement("UPDATE Inventory i JOIN ProductVariant pv ON pv.ID=i.VariantID SET i.Amount=? WHERE pv.ProductID=?")) {
                        inv.setInt(1, p.getStock()); inv.setInt(2, p.getId()); inv.executeUpdate();
                    }
                } else {
                    try (PreparedStatement inv = con.prepareStatement("INSERT INTO Inventory(ProductID,Amount,Min_amount,Status) VALUES(?,?,0,'ACTIVE') ON DUPLICATE KEY UPDATE Amount=VALUES(Amount)")) {
                        inv.setInt(1, p.getId()); inv.setInt(2, p.getStock()); inv.executeUpdate();
                    }
                }
                con.commit();
            } catch (SQLException ex) { con.rollback(); throw ex; }
            finally { con.setAutoCommit(true); }
        }
    }

    public void deactivate(int id) throws SQLException {
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement("UPDATE Product SET Status='INACTIVE' WHERE ID=?")) {
            ps.setInt(1, id); ps.executeUpdate();
        }
    }

    public List<ProductModel> findFeaturedProducts(int limit) throws SQLException {
        List<ProductModel> products = findAll(null, null, null, "newest", true);
        return products.size() <= limit ? products : new ArrayList<>(products.subList(0, limit));
    }

    public List<ProductModel> findPublicProducts(String keyword, String sort) throws SQLException {
        return findAll(keyword, null, null, sort, true);
    }

    public List<CategoryModel> findActiveCategories() throws SQLException {
        String sql = "SELECT c.ID, c.Name, c.Description, c.Status, COUNT(p.ID) ProductCount "
                + "FROM Category c "
                + "LEFT JOIN Product p ON p.CategoryID=c.ID AND p.Status='ACTIVE' "
                + "WHERE c.Status='ACTIVE' "
                + "GROUP BY c.ID,c.Name,c.Description,c.Status "
                + "ORDER BY c.ID";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<CategoryModel> categories = new ArrayList<>();
            while (rs.next()) {
                CategoryModel category = new CategoryModel();
                category.setId(rs.getInt("ID"));
                category.setName(rs.getString("Name"));
                category.setDescription(rs.getString("Description"));
                category.setActive("ACTIVE".equalsIgnoreCase(rs.getString("Status")));
                category.setProductCount(rs.getInt("ProductCount"));
                categories.add(category);
            }
            return categories;
        }
    }

    public int countActiveProducts() throws SQLException {
        return countActive();
    }

    public int countAvailableProducts() throws SQLException {
        return countActive();
    }

    public int countActive() throws SQLException {
        try (Connection con=DBContext.getConnection();
             PreparedStatement ps=con.prepareStatement("SELECT COUNT(*) FROM Product WHERE Status='ACTIVE'");
             ResultSet rs=ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int countOutOfStock() throws SQLException {
        try (Connection con = DBContext.getConnection()) {
            String sql = tableExists(con, "ProductVariant")
                    ? "SELECT COUNT(*) FROM Product p WHERE COALESCE((SELECT SUM(i.Amount) FROM ProductVariant pv LEFT JOIN Inventory i ON i.VariantID=pv.ID WHERE pv.ProductID=p.ID AND pv.Status='ACTIVE'),0)=0"
                    : columnExists(con, "Inventory", "ProductID")
                    ? "SELECT COUNT(*) FROM Product p LEFT JOIN Inventory i ON i.ProductID=p.ID WHERE COALESCE(i.Amount,0)=0"
                    : "SELECT 0";
            try (PreparedStatement ps=con.prepareStatement(sql); ResultSet rs=ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private int bindProduct(PreparedStatement ps, ProductModel p,
            boolean legacyDiscount) throws SQLException {
        ps.setString(1,p.getName()); ps.setString(2,p.getDescription());
        if (p.getReleaseYear()==null) ps.setNull(3,java.sql.Types.INTEGER); else ps.setInt(3,p.getReleaseYear());
        ps.setInt(4,p.getRating()); ps.setInt(5,p.getWarrantyMonths()); ps.setString(6,p.getBarcode());
        ps.setString(7,p.getSku()); ps.setInt(8,p.getSellingPrice()); ps.setInt(9,p.getLatestCost());
        ps.setString(10,p.getImage());
        int index = 11;
        if (legacyDiscount) ps.setInt(index++, p.getDiscount());
        ps.setInt(index++,p.getCategoryId()); ps.setInt(index++,p.getBrandId());
        ps.setString(index,p.getStatus());
        return index;
    }

    private String orderBy(String sort) {
        if ("price-asc".equals(sort)) {
            return "ORDER BY (p.Selling_price * (100 - Discount) / 100) ASC, p.ID DESC";
        }
        if ("price-desc".equals(sort)) {
            return "ORDER BY (p.Selling_price * (100 - Discount) / 100) DESC, p.ID DESC";
        }
        return "ORDER BY p.Created_at DESC, p.ID DESC";
    }

    private String escapeLike(String value) {
        return value.replace("\\", "\\\\")
                .replace("%", "\\%")
                .replace("_", "\\_");
    }

    private String selectSql(Connection con) throws SQLException {
        String discount = tableExists(con, "Discount_Product") && tableExists(con, "Discount")
                ? "COALESCE((SELECT MAX(d.Rate) FROM Discount_Product dp JOIN Discount d ON d.ID=dp.DiscountID WHERE dp.ProductID=p.ID AND d.Status='ACTIVE' AND CURRENT_TIMESTAMP BETWEEN d.Start AND d.End),0)"
                : columnExists(con, "Product", "Discount") ? "COALESCE(p.Discount,0)" : "0";
        String visibleFeedback = columnExists(con, "Feedback", "Status")
                ? " AND f.Status='VISIBLE'" : "";
        String stock = tableExists(con, "ProductVariant")
                ? "COALESCE((SELECT SUM(i.Amount) FROM ProductVariant pv LEFT JOIN Inventory i ON i.VariantID=pv.ID WHERE pv.ProductID=p.ID AND pv.Status='ACTIVE'),0)"
                : columnExists(con, "Inventory", "ProductID") ? "COALESCE(i.Amount,0)" : "0";
        return "SELECT p.ID,p.Name,p.Description,p.Release_Year,p.Rating,"
                + "p.warranty_months,p.Barcode,p.SKU,p.Selling_price,p.Latest_cost,p.Image,"
                + discount + " Discount,p.CategoryID,c.Name CategoryName,p.BrandID,b.Name BrandName,"
                + "p.Status,p.Created_at," + stock + " Stock,"
                + "(SELECT COUNT(*) FROM Feedback f WHERE f.ProductID=p.ID" + visibleFeedback + ") ReviewCount "
                + "FROM Product p JOIN Category c ON c.ID=p.CategoryID JOIN Brand b ON b.ID=p.BrandID "
                + (tableExists(con, "ProductVariant") || !columnExists(con, "Inventory", "ProductID")
                ? "" : "LEFT JOIN Inventory i ON i.ProductID=p.ID ");
    }

    private boolean tableExists(Connection con, String table) throws SQLException {
        String sql = "SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND LOWER(TABLE_NAME)=LOWER(?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, table);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private boolean columnExists(Connection con, String table, String column) throws SQLException {
        String sql = "SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND LOWER(TABLE_NAME)=LOWER(?) AND LOWER(COLUMN_NAME)=LOWER(?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, table); ps.setString(2, column);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private void loadVariants(Connection con, List<ProductModel> products) throws SQLException {
        if (products.isEmpty()) return;
        String placeholders = String.join(",", java.util.Collections.nCopies(products.size(), "?"));
        String sql = "SELECT pv.ID,pv.ProductID,pv.RAM_GB,pv.Storage_GB,pv.ColorName,pv.ColorHex,pv.Selling_price,pv.Image,COALESCE(i.Amount,0) Stock "
                + "FROM ProductVariant pv LEFT JOIN Inventory i ON i.VariantID=pv.ID "
                + "WHERE pv.Status='ACTIVE' AND pv.ProductID IN (" + placeholders + ") "
                + "ORDER BY pv.ProductID,pv.Storage_GB,pv.RAM_GB,pv.ID";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int index = 0; index < products.size(); index++) ps.setInt(index + 1, products.get(index).getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariantModel variant = new ProductVariantModel();
                    variant.setId(rs.getInt("ID")); variant.setProductId(rs.getInt("ProductID"));
                    variant.setRamGb(rs.getInt("RAM_GB")); variant.setStorageGb(rs.getInt("Storage_GB"));
                    variant.setColorName(rs.getString("ColorName")); variant.setColorHex(rs.getString("ColorHex"));
                    variant.setSellingPrice(rs.getInt("Selling_price")); variant.setImage(rs.getString("Image"));
                    variant.setStock(rs.getInt("Stock"));
                    products.stream().filter(product -> product.getId() == variant.getProductId())
                            .findFirst().ifPresent(product -> product.getVariants().add(variant));
                }
            }
        }
    }

    private void createDefaultVariants(Connection con, ProductModel product) throws SQLException {
        int[][] memories = {{8, 128, 0}, {12, 256, 2500000}, {12, 512, 5000000}};
        String[][] colors = {{"Black", "#24262B"}, {"Silver", "#D7D8DA"}, {"Blue", "#6F89A8"}, {"Pink", "#D8A7B1"}};
        String sql = "INSERT INTO ProductVariant(ProductID,RAM_GB,Storage_GB,ColorName,ColorHex,Selling_price,Image,Status) VALUES(?,?,?,?,?,?,?, 'ACTIVE')";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
             PreparedStatement inventory = con.prepareStatement("INSERT INTO Inventory(VariantID,Amount,Min_amount,Max_amount,Status) VALUES(?,?,0,100,'ACTIVE')")) {
            for (int[] memory : memories) {
                for (String[] color : colors) {
                    ps.setInt(1, product.getId()); ps.setInt(2, memory[0]); ps.setInt(3, memory[1]);
                    ps.setString(4, color[0]); ps.setString(5, color[1]);
                    ps.setInt(6, product.getSellingPrice() + memory[2]); ps.setString(7, product.getImage());
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) throw new SQLException("Cannot create product variant ID");
                        inventory.setInt(1, keys.getInt(1)); inventory.setInt(2, product.getStock());
                        inventory.executeUpdate();
                    }
                }
            }
        }
    }

    private ProductModel map(ResultSet rs) throws SQLException {
        ProductModel p = new ProductModel();
        p.setId(rs.getInt("ID")); p.setName(rs.getString("Name")); p.setDescription(rs.getString("Description"));
        int year=rs.getInt("Release_Year"); p.setReleaseYear(rs.wasNull()?null:year);
        p.setRating(rs.getInt("Rating")); p.setWarrantyMonths(rs.getInt("warranty_months"));
        p.setBarcode(rs.getString("Barcode")); p.setSku(rs.getString("SKU")); p.setSellingPrice(rs.getInt("Selling_price"));
        p.setLatestCost(rs.getInt("Latest_cost")); p.setImage(rs.getString("Image")); p.setDiscount(rs.getInt("Discount"));
        p.setCategoryId(rs.getInt("CategoryID")); p.setCategoryName(rs.getString("CategoryName"));
        p.setBrandId(rs.getInt("BrandID")); p.setBrandName(rs.getString("BrandName")); p.setStatus(rs.getString("Status"));
        p.setStock(rs.getInt("Stock")); p.setReviewCount(rs.getInt("ReviewCount")); return p;
    }
}
