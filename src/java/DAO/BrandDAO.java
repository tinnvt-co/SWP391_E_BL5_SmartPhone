package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.BrandModel;

public class BrandDAO {
    public List<BrandModel> findAll(boolean activeOnly) throws SQLException {
        String sql = "SELECT b.ID, b.Name, b.Description, b.Status, "
                + "COUNT(p.ID) AS ProductCount "
                + "FROM Brand b LEFT JOIN Product p ON p.BrandID = b.ID "
                + (activeOnly ? "WHERE b.Status = 'ACTIVE' " : "")
                + "GROUP BY b.ID, b.Name, b.Description, b.Status ORDER BY b.Name";

        List<BrandModel> brands = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                BrandModel brand = new BrandModel(
                        resultSet.getInt("ID"),
                        resultSet.getString("Name"),
                        resultSet.getString("Description"),
                        "ACTIVE".equals(resultSet.getString("Status")),
                        resultSet.getInt("ProductCount")
                );
                brands.add(brand);
            }
        }
        return brands;
    }

    public BrandModel findById(int id) throws SQLException {
        String sql = "SELECT ID, Name, Description, Status "
                + "FROM Brand WHERE ID = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }

                BrandModel brand = new BrandModel();
                brand.setId(resultSet.getInt("ID"));
                brand.setName(resultSet.getString("Name"));
                brand.setDescription(resultSet.getString("Description"));
                brand.setActive("ACTIVE".equals(resultSet.getString("Status")));
                return brand;
            }
        }
    }

    public void save(BrandModel brand) throws SQLException {
        boolean isNew = brand.getId() == 0;
        String sql = isNew
                ? "INSERT INTO Brand(Name, Description, Status) VALUES(?, ?, ?)"
                : "UPDATE Brand SET Name = ?, Description = ?, Status = ? WHERE ID = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, brand.getName());
            statement.setString(2, brand.getDescription());
            statement.setString(3, brand.isActive() ? "ACTIVE" : "INACTIVE");
            if (!isNew) {
                statement.setInt(4, brand.getId());
            }
            statement.executeUpdate();
        }
    }

    public void deactivate(int id) throws SQLException {
        String sql = "UPDATE Brand SET Status = 'INACTIVE' WHERE ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.executeUpdate();
        }
    }
}
