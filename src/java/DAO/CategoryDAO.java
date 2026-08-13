package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CategoryModel;

public class CategoryDAO {
    public List<CategoryModel> findAll(boolean activeOnly) throws SQLException {
        String sql = "SELECT c.ID, c.Name, c.Description, c.Status, "
                + "COUNT(p.ID) AS ProductCount "
                + "FROM Category c LEFT JOIN Product p ON p.CategoryID = c.ID "
                + (activeOnly ? "WHERE c.Status = 'ACTIVE' " : "")
                + "GROUP BY c.ID, c.Name, c.Description, c.Status ORDER BY c.ID";

        List<CategoryModel> categories = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                CategoryModel category = new CategoryModel(
                        resultSet.getInt("ID"),
                        resultSet.getString("Name"),
                        resultSet.getString("Description"),
                        "ACTIVE".equals(resultSet.getString("Status")),
                        resultSet.getInt("ProductCount")
                );
                categories.add(category);
            }
        }
        return categories;
    }

    public CategoryModel findById(int id) throws SQLException {
        String sql = "SELECT ID, Name, Description, Status "
                + "FROM Category WHERE ID = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }

                CategoryModel category = new CategoryModel();
                category.setId(resultSet.getInt("ID"));
                category.setName(resultSet.getString("Name"));
                category.setDescription(resultSet.getString("Description"));
                category.setActive("ACTIVE".equals(resultSet.getString("Status")));
                return category;
            }
        }
    }

    public void save(CategoryModel category) throws SQLException {
        boolean isNew = category.getId() == 0;
        String sql = isNew
                ? "INSERT INTO Category(Name, Description, Status) VALUES(?, ?, ?)"
                : "UPDATE Category SET Name = ?, Description = ?, Status = ? WHERE ID = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, category.getName());
            statement.setString(2, category.getDescription());
            statement.setString(3, category.isActive() ? "ACTIVE" : "INACTIVE");
            if (!isNew) {
                statement.setInt(4, category.getId());
            }
            statement.executeUpdate();
        }
    }

    public void deactivate(int id) throws SQLException {
        String sql = "UPDATE Category SET Status = 'INACTIVE' WHERE ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.executeUpdate();
        }
    }
}
