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

    // Lấy danh sách brand kèm số sản phẩm; activeOnly=true thì chỉ lấy brand ACTIVE.
    public List<BrandModel> findAll(boolean activeOnly) throws SQLException {
        // LEFT JOIN vẫn lấy brand chưa có product; COUNT dùng để hiển thị số lượng trên card.
        String sql = "SELECT b.ID, b.Name, b.Description, b.Status, "
                + "COUNT(p.ID) AS ProductCount "
                + "FROM Brand b LEFT JOIN Product p ON p.BrandID = b.ID "
                + (activeOnly ? "WHERE b.Status = 'ACTIVE' " : "")
                + "GROUP BY b.ID, b.Name, b.Description, b.Status ORDER BY b.Name";

        List<BrandModel> brands = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {

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

    // Tìm một brand theo ID để kiểm tra tồn tại hoặc nạp dữ liệu cho trang Edit/Products.
    public BrandModel findById(int id) throws SQLException {
        String sql = "SELECT ID, Name, Description, Status "
                + "FROM Brand WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
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

    // Kiểm tra trùng tên brand; bỏ qua brand hiện tại khi Edit.
    public boolean existsName(String name, int excludedBrandId)
            throws SQLException {
        // Loại brand hiện tại để giữ nguyên tên cũ vẫn hợp lệ khi Edit.
        String sql = "SELECT 1 FROM Brand "
                + "WHERE LOWER(TRIM(Name)) = LOWER(?) AND ID <> ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name.trim());
            statement.setInt(2, excludedBrandId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // Kiểm tra brand theo ID có đang ở trạng thái ACTIVE hay không.
    public boolean isActive(int id) throws SQLException {
        String sql = "SELECT 1 FROM Brand WHERE ID = ? AND Status = 'ACTIVE'";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // Lưu Brand: ID = 0 thì INSERT mới, ID > 0 thì UPDATE brand hiện có.
    public void save(BrandModel brand) throws SQLException {
        // ID bằng 0 là Add; ID dương là Edit brand đang tồn tại.
        boolean isNew = brand.getId() == 0;
        String sql = isNew
                ? "INSERT INTO Brand(Name, Description, Status) VALUES(?, ?, ?)"
                : "UPDATE Brand SET Name = ?, Description = ?, Status = ? WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, brand.getName());
            statement.setString(2, brand.getDescription());
            statement.setString(3, brand.isActive() ? "ACTIVE" : "INACTIVE");
            if (!isNew) {
                statement.setInt(4, brand.getId());
            }
            statement.executeUpdate();
        }
    }

    // Đưa brand về trạng thái INACTIVE bằng cách gọi chung hàm setActive().
    public void deactivate(int id) throws SQLException {
        setActive(id, false);
    }

    // Đổi trạng thái brand thành ACTIVE hoặc INACTIVE mà không xóa dữ liệu liên quan.
    public void setActive(int id, boolean active) throws SQLException {
        // Đổi trạng thái mềm giúp giữ product và dữ liệu lịch sử liên kết với brand.
        String sql = "UPDATE Brand SET Status = ? WHERE ID = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, active ? "ACTIVE" : "INACTIVE");
            statement.setInt(2, id);
            statement.executeUpdate();
        }
    }
}
