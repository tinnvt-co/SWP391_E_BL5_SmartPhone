package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import model.CategoryModel;

public class CategoryDAO {

    // Lấy danh sách category kèm số sản phẩm; activeOnly=true thì chỉ lấy category ACTIVE.
    public List<CategoryModel> findAll(boolean activeOnly) throws SQLException {
        // LEFT JOIN vẫn lấy category rỗng; COUNT đếm số product thuộc từng category.
        String sql = "SELECT c.ID, c.Name, c.Description, c.Status, "
                + "COUNT(DISTINCT p.ID) AS ProductCount "
                + "FROM Category c "
                + "LEFT JOIN Product_Category pc ON pc.CategoryID = c.ID "
                + "LEFT JOIN Product p ON p.ID = pc.ProductID "
                + (activeOnly ? "WHERE c.Status = 'ACTIVE' " : "")
                + "GROUP BY c.ID, c.Name, c.Description, c.Status ORDER BY c.ID";

        List<CategoryModel> categories = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {

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

    // Tìm một category theo ID để kiểm tra tồn tại hoặc nạp dữ liệu cho trang Edit/Products.
    public CategoryModel findById(int id) throws SQLException {
        String sql = "SELECT ID, Name, Description, Status "
                + "FROM Category WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
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

    // Tìm category ACTIVE theo đúng tên, dùng khi cần xác định category từ tên public.
    public CategoryModel findActiveByName(String name) throws SQLException {
        String sql = "SELECT ID, Name, Description, Status "
                + "FROM Category WHERE LOWER(Name) = LOWER(?) "
                + "AND Status = 'ACTIVE'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }

                CategoryModel category = new CategoryModel();
                category.setId(resultSet.getInt("ID"));
                category.setName(resultSet.getString("Name"));
                category.setDescription(resultSet.getString("Description"));
                category.setActive(true);
                return category;
            }
        }
    }

    // Kiểm tra tất cả category được chọn trong Product Form có tồn tại và đều ACTIVE hay không.
    public boolean areAllActive(List<Integer> categoryIds) throws SQLException {
        if (categoryIds == null || categoryIds.isEmpty()) {
            return false;
        }
        // Tạo một dấu ? cho mỗi ID và yêu cầu mọi category được chọn đều ACTIVE.
        String placeholders = String.join(",",
                java.util.Collections.nCopies(categoryIds.size(), "?"));
        String sql = "SELECT COUNT(*) FROM Category WHERE Status = 'ACTIVE' "
                + "AND ID IN (" + placeholders + ")";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < categoryIds.size(); index++) {
                statement.setInt(index + 1, categoryIds.get(index));
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1) == categoryIds.size();
            }
        }
    }

    // Lưu Category: ID = 0 thì INSERT mới, ID > 0 thì UPDATE category hiện có.
    public void save(CategoryModel category) throws SQLException {
        // ID bằng 0 là Add; ID dương là Edit category đang tồn tại.
        boolean isNew = category.getId() == 0;
        String sql = isNew
                ? "INSERT INTO Category(Name, Description, Status) VALUES(?, ?, ?)"
                : "UPDATE Category SET Name = ?, Description = ?, Status = ? WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, category.getName());
            statement.setString(2, category.getDescription());
            statement.setString(3, category.isActive() ? "ACTIVE" : "INACTIVE");
            if (!isNew) {
                statement.setInt(4, category.getId());
            }
            statement.executeUpdate();
        }
    }

    // Đưa category về trạng thái INACTIVE bằng cách gọi chung hàm setActive().
    public void deactivate(int id) throws SQLException {
        setActive(id, false);
    }

    // Đổi trạng thái category thành ACTIVE hoặc INACTIVE mà không xóa dữ liệu.
    public void setActive(int id, boolean active) throws SQLException {
        // Chỉ đổi trạng thái, không xóa category hoặc các quan hệ product của nó.
        String sql = "UPDATE Category SET Status = ? WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, active ? "ACTIVE" : "INACTIVE");
            statement.setInt(2, id);
            statement.executeUpdate();
        }
    }

    // Kiểm tra trùng tên category; bỏ qua category hiện tại khi Edit.
    public boolean existsName(String name, int excludedCategoryId)
            throws SQLException {
        // Không phân biệt hoa thường/khoảng trắng và loại dòng hiện tại khi Edit.
        String sql = "SELECT 1 FROM Category "
                + "WHERE LOWER(TRIM(Name)) = LOWER(?) AND ID <> ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name.trim());
            statement.setInt(2, excludedCategoryId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // Lấy ID các sản phẩm đã thuộc category; dùng để loại chúng khỏi popup Add Products.
    public Set<Integer> findProductIds(int categoryId) throws SQLException {
        String sql = "SELECT ProductID FROM Product_Category WHERE CategoryID = ?";
        Set<Integer> productIds = new LinkedHashSet<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, categoryId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    productIds.add(resultSet.getInt("ProductID"));
                }
            }
        }
        return productIds;
    }

    // Thêm nhiều quan hệ Product-Category vào bảng trung gian Product_Category bằng batch.
    public void addProducts(int categoryId, List<Integer> productIds)
            throws SQLException {
        // Product_Category là bảng liên kết nhiều-nhiều; INSERT IGNORE ngăn liên kết trùng.
        String sql = "INSERT IGNORE INTO Product_Category(ProductID, CategoryID) "
                + "VALUES(?, ?)";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            for (Integer productId : new LinkedHashSet<>(productIds)) {
                statement.setInt(1, productId);
                statement.setInt(2, categoryId);
                statement.addBatch();
            }
            statement.executeBatch();
        }
    }

    // Gỡ một sản phẩm khỏi category; chỉ xóa quan hệ, không xóa Product hay Category.
    public boolean removeProduct(int categoryId, int productId)
            throws SQLException {
        // Chỉ gỡ quan hệ category, không xóa bản ghi Product hoặc Category.
        String sql = "DELETE FROM Product_Category "
                + "WHERE CategoryID = ? AND ProductID = ?";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, categoryId);
            statement.setInt(2, productId);
            return statement.executeUpdate() > 0;
        }
    }
}
