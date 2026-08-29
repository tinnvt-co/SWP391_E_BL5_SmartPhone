package DAO;

import config.DBContext;
import model.SupplierModel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SupplierDAO {

    private static final String ACTIVE = "ACTIVE";

    /**
     * Get all suppliers.
     *
     * @return
     * @throws java.sql.SQLException
     */
    public List<SupplierModel> findAll() throws SQLException {
        return findAll(null, null, Integer.MAX_VALUE, 0);
    }

    /**
     * Get suppliers with keyword and status filter.
     *
     * @param keyword
     * @param status
     * @param limit
     * @param offset
     * @return
     * @throws java.sql.SQLException
     */
    public List<SupplierModel> findAll(
            String keyword,
            String status,
            int limit,
            int offset)
            throws SQLException {

        StringBuilder sql
                = new StringBuilder(
                        "SELECT s.ID, s.Name, "
                        + "s.Address, s.Phone, "
                        + "s.Description, s.Note, "
                        + "s.Created_at, s.Updated_at, "
                        + "s.Status, "
                        + "(SELECT COUNT(*) "
                        + " FROM Supplier_ProductVariant spv "
                        + " WHERE spv.SupplierID = s.ID) "
                        + "AS ProductVariantCount "
                        + "FROM Supplier s "
                        + "WHERE 1 = 1 ");

        List<Object> parameters = new ArrayList<>();

        if (keyword != null&& !keyword.trim().isEmpty()) {

            sql.append("AND (s.Name LIKE ? "
                    + "OR s.Phone LIKE ? "
                    + "OR s.Address LIKE ?) ");

            String k = "%" + keyword.trim() + "%";

            parameters.add(k);
            parameters.add(k);
            parameters.add(k);
        }

        if (status != null
                && !status.trim().isEmpty()) {

            sql.append(
                    "AND s.Status = ? ");

            parameters.add(status);
        }

        sql.append(
                "ORDER BY s.Created_at DESC, "
                + "s.ID DESC "
                + "LIMIT ? OFFSET ?"); //OFFSET là số dòng cần bỏ qua

        parameters.add(limit);
        parameters.add(Math.max(0, offset));

        List<SupplierModel> suppliers
                = new ArrayList<>();
        
        // Lấy cơ sở dữ liệu thông qua DBContext và lưu kết nối vào connection,
        // tạo preparedStatement để chuẩn bị câu lệnh
        //statement.executeQuery để chạy lệnh query và trả về kết quả
        try (Connection connection
                = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(
                        sql.toString())) {

            for (int i = 0; i < parameters.size(); i++) {
                statement.setObject(i + 1,parameters.get(i));
            }
            
            try (ResultSet rs
                    = statement.executeQuery()) {

                while (rs.next()) {

                    suppliers.add(
                            mapSupplier(rs));
                }
            }
        }

        return suppliers;
    }

    /**
     * Find supplier by ID.
     *
     * @param id
     * @return
     * @throws java.sql.SQLException
     */
    public SupplierModel findById(int id)
            throws SQLException {

        String sql = "SELECT s.ID, s.Name, s.Address, s.Phone, "
                + "s.Description, s.Note, "
                + "s.Created_at, s.Updated_at, s.Status, "
                + "(SELECT COUNT(*) "
                + "FROM Supplier_ProductVariant spv "
                + "WHERE spv.SupplierID = s.ID) AS ProductVariantCount "
                + "FROM Supplier s "
                + "WHERE s.ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                SupplierModel supplier = mapSupplier(rs);
                supplier.setProductVariantIds(findProductVariantIds(id));
                return supplier;
            }
        }
    }

    /**
     * Create supplier.
     *
     * @param supplier
     * @return
     * @throws java.sql.SQLException
     */
    public int create(SupplierModel supplier)
            throws SQLException {

        String sql = "INSERT INTO Supplier "
                + "(Name, Address, Phone, Description, Note, Status) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(
                        sql,
                        Statement.RETURN_GENERATED_KEYS)) {

            statement.setString(
                    1,
                    supplier.getName());

            statement.setString(
                    2,
                    supplier.getAddress());

            statement.setString(
                    3,
                    supplier.getPhone());

            statement.setString(
                    4,
                    supplier.getDescription());

            statement.setString(
                    5,
                    supplier.getNote());

            String status = supplier.getStatus();

            if (status == null
                    || status.trim().isEmpty()) {
                status = ACTIVE;
            }

            statement.setString(6, status);

            statement.executeUpdate();

            try (ResultSet generatedKeys
                    = statement.getGeneratedKeys()) {

                if (!generatedKeys.next()) {
                    throw new SQLException(
                            "Cannot create supplier ID");
                }

                int supplierId
                        = generatedKeys.getInt(1);

                supplier.setId(supplierId);

                return supplierId;
            }
        }
    }

    /**
     * Update supplier information.
     *
     * @param supplier
     * @return
     * @throws java.sql.SQLException
     */
    public boolean update(SupplierModel supplier)
            throws SQLException {

        String sql = "UPDATE Supplier SET "
                + "Name = ?, "
                + "Address = ?, "
                + "Phone = ?, "
                + "Description = ?, "
                + "Note = ?, "
                + "Status = ?, "
                + "Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(
                    1,
                    supplier.getName());

            statement.setString(
                    2,
                    supplier.getAddress());

            statement.setString(
                    3,
                    supplier.getPhone());

            statement.setString(
                    4,
                    supplier.getDescription());

            statement.setString(
                    5,
                    supplier.getNote());

            statement.setString(
                    6,
                    supplier.getStatus());

            statement.setInt(
                    7,
                    supplier.getId());

            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Deactivate supplier.We do not physically delete the supplier because it
     * may already be referenced by import transactions.
     *
     * @param id
     * @return
     * @throws java.sql.SQLException
     */
    public boolean deactivate(int id)
            throws SQLException {

        String sql = "UPDATE Supplier "
                + "SET Status = 'INACTIVE', "
                + "Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, id);

            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Activate supplier.
     *
     * @param id
     * @return
     * @throws java.sql.SQLException
     */
    public boolean activate(int id)
            throws SQLException {

        String sql = "UPDATE Supplier "
                + "SET Status = 'ACTIVE', "
                + "Updated_at = CURRENT_TIMESTAMP "
                + "WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Get all ProductVariant IDs supplied by a supplier.
     *
     * @param supplierId
     * @return
     * @throws java.sql.SQLException
     */
    public List<Integer> findProductVariantIds(int supplierId) throws SQLException {
        String sql = "SELECT ProductVariantID "
                + "FROM Supplier_ProductVariant "
                + "WHERE SupplierID = ? "
                + "ORDER BY ProductVariantID";

        List<Integer> variantIds = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); 
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, supplierId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    variantIds.add(rs.getInt("ProductVariantID"));
                }
            }
        }
        return variantIds;
    }

    /**
     * Get ProductVariants supplied by supplier.
     *
     * @param productVariantId
     * @return
     * @throws java.sql.SQLException
     */
    public List<Integer> findSuppliersByProductVariant(
            int productVariantId) throws SQLException {
        String sql = "SELECT SupplierID "
                + "FROM Supplier_ProductVariant "
                + "WHERE ProductVariantID = ? "
                + "ORDER BY SupplierID";
        List<Integer> supplierIds = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); 
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productVariantId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    supplierIds.add(rs.getInt("SupplierID"));
                }
            }
        }
        return supplierIds;
    }

    /**
     * Add one ProductVariant to a supplier.
     *
     * @param supplierId
     * @param productVariantId
     * @return
     * @throws java.sql.SQLException
     */
    public boolean addProductVariant(
            int supplierId,
            int productVariantId)
            throws SQLException {
        String sql = "INSERT INTO Supplier_ProductVariant "
                + "(SupplierID, ProductVariantID) "
                + "VALUES (?, ?)";

        try (Connection connection = DBContext.getConnection(); 
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, supplierId);
            statement.setInt(2, productVariantId);
            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Remove one ProductVariant from a supplier.
     *
     * @param supplierId
     * @param productVariantId
     * @return
     * @throws java.sql.SQLException
     */
    public boolean removeProductVariant(
            int supplierId,
            int productVariantId)
            throws SQLException {

        String sql = "DELETE FROM Supplier_ProductVariant "
                + "WHERE SupplierID = ? "
                + "AND ProductVariantID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {
            statement.setInt(1, supplierId);
            statement.setInt(2, productVariantId);
            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Replace all ProductVariants of a supplier.This method is useful for an
     * Edit Supplier form.Example: Old: [1, 2, 3]
     *
     * New: [2, 4, 5]
     *
     * Result: [2, 4, 5]
     *
     * @param supplierId
     * @param productVariantIds
     * @return
     * @throws java.sql.SQLException
     */
    public boolean updateProductVariants(
            int supplierId,
            List<Integer> productVariantIds)
            throws SQLException {

        if (productVariantIds == null) {
            productVariantIds = new ArrayList<>();
        }

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                deleteSupplierProductVariants(
                        connection,
                        supplierId);

                insertSupplierProductVariants(
                        connection,
                        supplierId,
                        productVariantIds);

                connection.commit();

                return true;

            } catch (SQLException e) {

                connection.rollback();
                throw e;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }

    /**
     * Delete all ProductVariants of a supplier.
     */
    private void deleteSupplierProductVariants(
            Connection connection,
            int supplierId)
            throws SQLException {

        String sql = "DELETE FROM Supplier_ProductVariant "
                + "WHERE SupplierID = ?";

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, supplierId);

            statement.executeUpdate();
        }
    }

    /**
     * Insert supplier-product relationships.
     */
    private void insertSupplierProductVariants(
            Connection connection,
            int supplierId,
            List<Integer> productVariantIds)
            throws SQLException {

        if (productVariantIds.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO Supplier_ProductVariant "
                + "(SupplierID, ProductVariantID) "
                + "VALUES (?, ?)";

        try (PreparedStatement statement
                = connection.prepareStatement(sql)) {

            for (Integer variantId : productVariantIds) {

                if (variantId == null) {
                    continue;
                }

                statement.setInt(1, supplierId);
                statement.setInt(2, variantId);

                statement.addBatch();
            }

            statement.executeBatch();
        }
    }

    /**
     * Check whether supplier exists.
     *
     * @param supplierId
     * @return
     * @throws java.sql.SQLException
     */
    public boolean exists(int supplierId)
            throws SQLException {

        String sql = "SELECT COUNT(*) "
                + "FROM Supplier "
                + "WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, supplierId);

            try (ResultSet rs = statement.executeQuery()) {

                return rs.next()
                        && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Check whether ProductVariant belongs to a supplier.
     *
     * @param supplierId
     * @param productVariantId
     * @return
     * @throws java.sql.SQLException
     */
    public boolean hasProductVariant(
            int supplierId,
            int productVariantId)
            throws SQLException {

        String sql = "SELECT COUNT(*) "
                + "FROM Supplier_ProductVariant "
                + "WHERE SupplierID = ? "
                + "AND ProductVariantID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, supplierId);
            statement.setInt(2, productVariantId);

            try (ResultSet rs = statement.executeQuery()) {

                return rs.next()
                        && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Map ResultSet to SupplierModel.
     */
    private SupplierModel mapSupplier(
            ResultSet rs) throws SQLException {
        SupplierModel supplier= new SupplierModel();
        supplier.setId(rs.getInt("ID"));
        supplier.setName(rs.getString("Name"));
        supplier.setAddress(rs.getString("Address"));
        supplier.setPhone(rs.getString("Phone"));
        supplier.setDescription(rs.getString("Description"));
        supplier.setNote(rs.getString("Note"));
        supplier.setStatus(rs.getString("Status"));
        Timestamp createdAt = rs.getTimestamp("Created_at");
        Timestamp updatedAt = rs.getTimestamp("Updated_at");
        supplier.setCreatedAt(createdAt);
        supplier.setUpdatedAt(updatedAt);
        try {
            supplier.setProductVariantCount( rs.getInt("ProductVariantCount"));
        } catch (SQLException ignored) {
            // Query does not contain ProductVariantCount.
        }
        return supplier;
    }

    public int countAll(
            String keyword,
            String status)
            throws SQLException {

        StringBuilder sql
                = new StringBuilder(
                        "SELECT COUNT(*) "
                        + "FROM Supplier s "
                        + "WHERE 1 = 1 ");

        List<Object> parameters
                = new ArrayList<>();

        if (keyword != null
                && !keyword.trim().isEmpty()) {

            sql.append(
                    "AND (s.Name LIKE ? "
                    + "OR s.Phone LIKE ? "
                    + "OR s.Address LIKE ?) ");

            String k
                    = "%" + keyword.trim() + "%";

            parameters.add(k);
            parameters.add(k);
            parameters.add(k);
        }

        if (status != null
                && !status.trim().isEmpty()) {

            sql.append(
                    "AND s.Status = ? ");

            parameters.add(status);
        }

        try (Connection connection
                = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(
                        sql.toString())) {

            for (int i = 0;
                    i < parameters.size();
                    i++) {

                statement.setObject(
                        i + 1,
                        parameters.get(i));
            }

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    public boolean isSupplierProvidingVariant(
            int supplierId,
            int productVariantId)
            throws SQLException {

        String sql
                = "SELECT 1 "
                + "FROM Supplier_ProductVariant "
                + "WHERE SupplierID = ? "
                + "AND ProductVariantID = ? "
                + "LIMIT 1";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, supplierId);
            statement.setInt(2, productVariantId);

            try (ResultSet resultSet
                    = statement.executeQuery()) {

                return resultSet.next();
            }

        }
    }
}
