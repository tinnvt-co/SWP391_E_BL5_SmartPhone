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
     */
    public DiscountModel save(DiscountModel d) throws SQLException {
        boolean isNew = d.getId() == 0;
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                int id;
                if (isNew) {
                    String insert = "INSERT INTO Discount(Name, Description, Rate, Start, End) VALUES(?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = connection.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setString(1, d.getName());
                        ps.setString(2, d.getDescription());
                        ps.setDouble(3, d.getRate());
                        ps.setTimestamp(4, d.getStart());
                        ps.setTimestamp(5, d.getEnd());
                        ps.executeUpdate();
                        try (ResultSet keys = ps.getGeneratedKeys()) {
                            if (keys.next()) id = keys.getInt(1);
                            else throw new SQLException("Failed to obtain new discount id");
                        }
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
