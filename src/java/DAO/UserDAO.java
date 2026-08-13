package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.UserModel;

public class UserDAO {

    private static final int CUSTOMER_ROLE_ID = 4;

    public UserModel findActiveByCredentials(String username, String password) throws SQLException {
        String sql = "SELECT u.ID, u.Username, u.Name, u.Phone, u.Address, u.Image, u.Age, "
                + "u.Email, u.RoleID, u.Status, r.Name AS RoleName "
                + "FROM `User` u "
                + "JOIN `Role` r ON u.RoleID = r.ID "
                + "WHERE u.Username = ? AND u.Password = ? "
                + "AND u.Status = 'ACTIVE' AND r.Status = 'ACTIVE'";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    public boolean existsByUsername(String username) throws SQLException {
        return exists("SELECT 1 FROM `User` WHERE Username = ?", username);
    }

    public boolean existsByEmail(String email) throws SQLException {
        return exists("SELECT 1 FROM `User` WHERE Email = ?", email);
    }

    public boolean existsByPhone(String phone) throws SQLException {
        return exists("SELECT 1 FROM `User` WHERE Phone = ?", phone);
    }

    public UserModel createCustomer(UserModel user, String password) throws SQLException {
        String nextIdSql = "SELECT COALESCE(MAX(ID), 0) + 1 FROM `User`";
        String insertSql = "INSERT INTO `User` "
                + "(ID, Username, Password, Name, Phone, Address, Image, Age, Email, RoleID, Status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int nextId;
                try (PreparedStatement ps = conn.prepareStatement(nextIdSql);
                     ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    nextId = rs.getInt(1);
                }

                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, nextId);
                    ps.setString(2, user.getUsername());
                    ps.setString(3, password);
                    ps.setString(4, user.getName());
                    ps.setString(5, user.getPhone());
                    ps.setString(6, user.getAddress());
                    ps.setString(7, user.getImage());
                    if (user.getAge() != null) {
                        ps.setInt(8, user.getAge());
                    } else {
                        ps.setNull(8, java.sql.Types.INTEGER);
                    }
                    ps.setString(9, user.getEmail());
                    ps.setInt(10, CUSTOMER_ROLE_ID);
                    ps.executeUpdate();
                }

                conn.commit();
                return findActiveByCredentials(user.getUsername(), password);
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public List<String> findPermissionNamesByRoleId(int roleId) throws SQLException {
        String sql = "SELECT p.Name "
                + "FROM Permisson_Role pr "
                + "JOIN Permisson p ON pr.PermissonID = p.ID "
                + "WHERE pr.RoleID = ? "
                + "ORDER BY p.ID";

        List<String> permissions = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    permissions.add(rs.getString("Name"));
                }
            }
        }
        return permissions;
    }

    private boolean exists(String sql, String value) throws SQLException {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private UserModel mapUser(ResultSet rs) throws SQLException {
        UserModel user = new UserModel();
        user.setId(rs.getInt("ID"));
        user.setUsername(rs.getString("Username"));
        user.setName(rs.getString("Name"));
        user.setPhone(rs.getString("Phone"));
        user.setAddress(rs.getString("Address"));
        user.setImage(rs.getString("Image"));
        int age = rs.getInt("Age");
        if (!rs.wasNull()) {
            user.setAge(age);
        }
        user.setEmail(rs.getString("Email"));
        user.setRoleId(rs.getInt("RoleID"));
        user.setStatus(rs.getString("Status"));
        user.setRoleName(rs.getString("RoleName"));
        return user;
    }
}
