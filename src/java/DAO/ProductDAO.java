package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.ProductModel;

public class ProductDAO {
    private static final String SELECT = "SELECT p.ID,p.Name,p.Description,p.Release_Year,p.Rating,"
            + "p.warranty_months,p.Barcode,p.SKU,p.Selling_price,p.Latest_cost,p.Image,p.Discount,"
            + "p.CategoryID,c.Name CategoryName,p.BrandID,b.Name BrandName,p.Status,p.Created_at,"
            + "COALESCE(i.Amount,0) Stock,COUNT(DISTINCT f.ID) ReviewCount "
            + "FROM Product p JOIN Category c ON c.ID=p.CategoryID JOIN Brand b ON b.ID=p.BrandID "
            + "LEFT JOIN Inventory i ON i.ProductID=p.ID LEFT JOIN Feedback f ON f.ProductID=p.ID AND f.Status='VISIBLE' ";
    private static final String GROUP = " GROUP BY p.ID,p.Name,p.Description,p.Release_Year,p.Rating,p.warranty_months,"
            + "p.Barcode,p.SKU,p.Selling_price,p.Latest_cost,p.Image,p.Discount,p.CategoryID,c.Name,p.BrandID,b.Name,p.Status,p.Created_at,i.Amount ";




    public List<ProductModel> findAll(String keyword, Integer brandId, Integer categoryId,
            String sort, boolean publicOnly) throws SQLException {
        StringBuilder sql = new StringBuilder(SELECT).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (publicOnly) sql.append("AND p.Status='ACTIVE' AND c.Status='ACTIVE' AND b.Status='ACTIVE' ");
        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND p.Name LIKE ? ESCAPE '\\\\' ");
            params.add("%" + escapeLike(keyword.trim()) + "%");
        }
        if (brandId != null) { sql.append("AND p.BrandID=? "); params.add(brandId); }
        if (categoryId != null) { sql.append("AND p.CategoryID=? "); params.add(categoryId); }
        sql.append(GROUP).append(orderBy(sort));
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                List<ProductModel> list = new ArrayList<>();
                while (rs.next()) list.add(map(rs));
                return list;
            }
        }
    }

    public ProductModel findById(int id) throws SQLException {
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT + "WHERE p.ID=?" + GROUP)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
        }
    }

    public void save(ProductModel p) throws SQLException {
        if (p.getId() == 0) insert(p); else update(p);
    }




    private void insert(ProductModel p) throws SQLException {
        String productSql = "INSERT INTO Product(Name,Description,Release_Year,Rating,warranty_months,Barcode,SKU,Selling_price,Latest_cost,Image,Discount,CategoryID,BrandID,Status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(productSql, Statement.RETURN_GENERATED_KEYS)) {
                bindProduct(ps, p);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new SQLException("Cannot create product ID");
                    p.setId(keys.getInt(1));
                }
                try (PreparedStatement inventory = con.prepareStatement("INSERT INTO Inventory(ProductID,Amount,Min_amount,Status) VALUES(?,?,0,'ACTIVE')")) {
                    inventory.setInt(1, p.getId()); inventory.setInt(2, p.getStock()); inventory.executeUpdate();
                }
                con.commit();
            } catch (SQLException ex) { con.rollback(); throw ex; }
            finally { con.setAutoCommit(true); }
        }
    }

    private void update(ProductModel p) throws SQLException {
        String sql = "UPDATE Product SET Name=?,Description=?,Release_Year=?,Rating=?,warranty_months=?,Barcode=?,SKU=?,Selling_price=?,Latest_cost=?,Image=?,Discount=?,CategoryID=?,BrandID=?,Status=? WHERE ID=?";
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                bindProduct(ps, p); ps.setInt(15, p.getId()); ps.executeUpdate();
                try (PreparedStatement inv = con.prepareStatement("INSERT INTO Inventory(ProductID,Amount,Min_amount,Status) VALUES(?,?,0,'ACTIVE') ON DUPLICATE KEY UPDATE Amount=VALUES(Amount)")) {
                    inv.setInt(1, p.getId()); inv.setInt(2, p.getStock()); inv.executeUpdate();
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

    public int countActive() throws SQLException { return count("p.Status='ACTIVE'"); }

    public int countOutOfStock() throws SQLException { return count("COALESCE(i.Amount,0)=0"); }

    private int count(String condition) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Product p LEFT JOIN Inventory i ON i.ProductID=p.ID WHERE " + condition;
        try (Connection con=DBContext.getConnection(); PreparedStatement ps=con.prepareStatement(sql); ResultSet rs=ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private void bindProduct(PreparedStatement ps, ProductModel p) throws SQLException {
        ps.setString(1,p.getName()); ps.setString(2,p.getDescription());
        if (p.getReleaseYear()==null) ps.setNull(3,java.sql.Types.INTEGER); else ps.setInt(3,p.getReleaseYear());
        ps.setInt(4,p.getRating()); ps.setInt(5,p.getWarrantyMonths()); ps.setString(6,p.getBarcode());
        ps.setString(7,p.getSku()); ps.setInt(8,p.getSellingPrice()); ps.setInt(9,p.getLatestCost());
        ps.setString(10,p.getImage()); ps.setInt(11,p.getDiscount()); ps.setInt(12,p.getCategoryId());
        ps.setInt(13,p.getBrandId()); ps.setString(14,p.getStatus());
    }

    private String orderBy(String sort) {
        if ("price-asc".equals(sort)) {
            return "ORDER BY (p.Selling_price * (100 - COALESCE(p.Discount,0)) / 100) ASC, p.ID DESC";
        }
        if ("price-desc".equals(sort)) {
            return "ORDER BY (p.Selling_price * (100 - COALESCE(p.Discount,0)) / 100) DESC, p.ID DESC";
        }
        return "ORDER BY p.Created_at DESC, p.ID DESC";
    }

    private String escapeLike(String value) {
        return value.replace("\\", "\\\\")
                .replace("%", "\\%")
                .replace("_", "\\_");
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
