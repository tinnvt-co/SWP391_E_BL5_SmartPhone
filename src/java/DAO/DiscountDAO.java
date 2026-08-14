package DAO;

import config.DBContext;
import model.DiscountModel;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class DiscountDAO {

    public List<DiscountModel> findAll(boolean activeOnly) throws SQLException {
        String sql = "SELECT d.ID, d.Name, d.Description, d.Rate, d.Start, d.End, "
                + "d.Updated_at, d.Created_at, "
                + "(SELECT COUNT(*) FROM Discount_Product dp WHERE dp.DiscountID = d.ID) AS ProductCount "
                + "FROM Discount d "
                + "ORDER BY d.Created_at DESC";

        List<DiscountModel> discounts = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                DiscountModel d = mapRow(resultSet);
                if (activeOnly && !d.isLiveNow()) continue;
                discounts.add(d);
            }
        }
        return discounts;
    }

    public DiscountModel findById(int id) throws SQLException {
        String sql = "SELECT d.ID, d.Name, d.Description, d.Rate, d.Start, d.End, "
                + "d.Updated_at, d.Created_at, "
                + "(SELECT COUNT(*) FROM Discount_Product dp WHERE dp.DiscountID = d.ID) AS ProductCount "
                + "FROM Discount d WHERE d.ID = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    DiscountModel d = mapRow(rs);
                    d.setProductIds(loadProductIds(connection, d.getId()));
                    return d;
                }
            }
        }
        return null;
    }

    public List<Integer> loadProductIds(int discountId) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            return loadProductIds(connection, discountId);
        }
    }

    /**
     * Return every ProductID that is already attached to a discount whose
     * time window covers "now" — i.e. active right now OR scheduled in the
     * future and not yet expired. Used by the manager form to hide products
     * that would double-discount.
     */
    public Set<Integer> findLiveOrScheduledProductIds(Integer excludeDiscountId) throws SQLException {
        String sql = "SELECT DISTINCT dp.ProductID FROM Discount_Product dp "
                + "JOIN Discount d ON d.ID = dp.DiscountID "
                + "WHERE d.End >= CURRENT_TIMESTAMP "
                + (excludeDiscountId != null ? "AND d.ID <> ? " : "");
        Set<Integer> ids = new HashSet<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            if (excludeDiscountId != null) ps.setInt(1, excludeDiscountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt(1));
            }
        }
        return ids;
    }

    private List<Integer> loadProductIds(Connection connection, int discountId) throws SQLException {
        String sql = "SELECT ProductID FROM Discount_Product WHERE DiscountID = ? ORDER BY ProductID";
        List<Integer> ids = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, discountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt(1));
            }
        }
        return ids;
    }

    /**
     * Save a discount and sync the Discount_Product relation.
     * Uses a single transaction so the discount and its product list are atomic.
     *
     * Insert path computes the next ID in Java (MAX(ID) + 1) inside a row-level
     * lock, so the table does NOT need AUTO_INCREMENT. Safe even if the column
     * was created without AUTO_INCREMENT.
     */
    public DiscountModel save(DiscountModel d) throws SQLException {
        boolean isNew = d.getId() == 0;
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                int id;
                if (isNew) {
                    id = nextDiscountId(connection);
                    d.setId(id);
                    String insert = "INSERT INTO Discount(ID, Name, Description, Rate, Start, End) "
                            + "VALUES(?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = connection.prepareStatement(insert)) {
                        ps.setInt(1, id);
                        ps.setString(2, d.getName());
                        ps.setString(3, d.getDescription());
                        ps.setDouble(4, d.getRate());
                        ps.setTimestamp(5, d.getStart());
                        ps.setTimestamp(6, d.getEnd());
                        ps.executeUpdate();
                    }
                } else {
                    String update = "UPDATE Discount SET Name = ?, Description = ?, Rate = ?, Start = ?, End = ? WHERE ID = ?";
                    try (PreparedStatement ps = connection.prepareStatement(update)) {
                        ps.setString(1, d.getName());
                        ps.setString(2, d.getDescription());
                        ps.setDouble(3, d.getRate());
                        ps.setTimestamp(4, d.getStart());
                        ps.setTimestamp(5, d.getEnd());
                        ps.setInt(6, d.getId());
                        ps.executeUpdate();
                    }
                    id = d.getId();
                }

                // Sync product list: wipe + reinsert (simpler than diff, fine for small lists)
                try (PreparedStatement del = connection.prepareStatement("DELETE FROM Discount_Product WHERE DiscountID = ?")) {
                    del.setInt(1, id);
                    del.executeUpdate();
                }
                if (d.getProductIds() != null && !d.getProductIds().isEmpty()) {
                    try (PreparedStatement ins = connection.prepareStatement(
                            "INSERT INTO Discount_Product(DiscountID, ProductID) VALUES(?, ?)")) {
                        Set<Integer> seen = new HashSet<>();
                        for (Integer pid : d.getProductIds()) {
                            if (pid == null || !seen.add(pid)) continue;
                            ins.setInt(1, id);
                            ins.setInt(2, pid);
                            ins.addBatch();
                        }
                        if (!seen.isEmpty()) ins.executeBatch();
                    }
                }

                connection.commit();
                d.setId(id);
                return d;
            } catch (SQLException ex) {
                connection.rollback();
                throw ex;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    public void delete(int id) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM Discount_Product WHERE DiscountID = ?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM Discount WHERE ID = ?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            connection.commit();
        }
    }

    /**
     * Compute the next Discount.ID using a table lock so two concurrent inserts
     * cannot pick the same id. Returns 1 when the table is empty.
     */
    private int nextDiscountId(Connection connection) throws SQLException {
        try (Statement lock = connection.createStatement()) {
            lock.executeUpdate("LOCK TABLES `Discount` WRITE");
        }
        try (Statement read = connection.createStatement();
             ResultSet rs = read.executeQuery("SELECT COALESCE(MAX(ID), 0) FROM `Discount`")) {
            int currentMax = rs.next() ? rs.getInt(1) : 0;
            return currentMax + 1;
        } finally {
            try (Statement unlock = connection.createStatement()) {
                unlock.executeUpdate("UNLOCK TABLES");
            }
        }
    }

    private DiscountModel mapRow(ResultSet rs) throws SQLException {
        DiscountModel d = new DiscountModel();
        d.setId(rs.getInt("ID"));
        d.setName(rs.getString("Name"));
        d.setDescription(rs.getString("Description"));
        d.setRate(rs.getDouble("Rate"));
        d.setStart(rs.getTimestamp("Start"));
        d.setEnd(rs.getTimestamp("End"));
        d.setProductCount(rs.getInt("ProductCount"));
        d.setCreatedAt(rs.getTimestamp("Created_at"));
        d.setUpdatedAt(rs.getTimestamp("Updated_at"));
        return d;
    }
}
