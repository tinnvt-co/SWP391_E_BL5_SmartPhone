package DAO;

import config.DBContext;
import model.DiscountModel;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class DiscountDAO {

    public List<DiscountModel> findAll(boolean activeOnly) throws SQLException {
        String sql = "SELECT d.ID, d.Name, d.Description, d.Rate, d.Start, d.End, d.Status, d.Updated_at, d.Created_at, "
                + "COUNT(dp.ProductID) AS ProductCount "
                + "FROM Discount d LEFT JOIN Discount_Product dp ON dp.DiscountID = d.ID "
                + (activeOnly ? "WHERE d.Status = 'ACTIVE' " : "")
                + "GROUP BY d.ID, d.Name, d.Description, d.Rate, d.Start, d.End, d.Status, d.Updated_at, d.Created_at "
                + "ORDER BY d.Created_at DESC";

        List<DiscountModel> discounts = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                DiscountModel d = new DiscountModel();
                d.setId(resultSet.getInt("ID"));
                d.setName(resultSet.getString("Name"));
                d.setDescription(resultSet.getString("Description"));
                d.setRate(resultSet.getDouble("Rate"));
                d.setStart(resultSet.getTimestamp("Start"));
                d.setEnd(resultSet.getTimestamp("End"));
                String status = resultSet.getString("Status");
                d.setStatus(status);
                d.setActive("ACTIVE".equals(status));
                d.setProductCount(resultSet.getInt("ProductCount"));
                discounts.add(d);
            }
        }
        return discounts;
    }

    public DiscountModel findById(int id) throws SQLException {
        String sql = "SELECT d.ID, d.Name, d.Description, d.Rate, d.Start, d.End, d.Status, "
                + "COUNT(dp.ProductID) AS ProductCount "
                + "FROM Discount d LEFT JOIN Discount_Product dp ON dp.DiscountID = d.ID "
                + "WHERE d.ID = ? "
                + "GROUP BY d.ID, d.Name, d.Description, d.Rate, d.Start, d.End, d.Status";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    DiscountModel d = new DiscountModel();
                    d.setId(rs.getInt("ID"));
                    d.setName(rs.getString("Name"));
                    d.setDescription(rs.getString("Description"));
                    d.setRate(rs.getDouble("Rate"));
                    d.setStart(rs.getTimestamp("Start"));
                    d.setEnd(rs.getTimestamp("End"));
                    String status = rs.getString("Status");
                    d.setStatus(status);
                    d.setActive("ACTIVE".equals(status));
                    d.setProductCount(rs.getInt("ProductCount"));
                    return d;
                }
            }
        }
        return null;
    }

    public void save(DiscountModel d) throws SQLException {
        boolean isNew = d.getId() == 0;
        String sql = isNew
                ? "INSERT INTO Discount(Name, Description, Rate, Start, End, Status) VALUES(?, ?, ?, ?, ?, ?)"
                : "UPDATE Discount SET Name = ?, Description = ?, Rate = ?, Start = ?, End = ?, Status = ? WHERE ID = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, d.getName());
            statement.setString(2, d.getDescription());
            statement.setDouble(3, d.getRate());
            statement.setTimestamp(4, d.getStart());
            statement.setTimestamp(5, d.getEnd());
            statement.setString(6, d.isActive() ? "ACTIVE" : "INACTIVE");
            if (!isNew) {
                statement.setInt(7, d.getId());
            }
            statement.executeUpdate();
        }
    }

    public void deactivate(int id) throws SQLException {
        String sql = "UPDATE Discount SET Status = 'INACTIVE' WHERE ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.executeUpdate();
        }
    }
}