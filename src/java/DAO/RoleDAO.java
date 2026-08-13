package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Role;

public class RoleDAO {
    public List<Role> findAll() throws SQLException {
        String sql = "SELECT * FROM `Role` ORDER BY ID ASC";
        List<Role> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role role = new Role();
                role.setId(rs.getInt("ID"));
                role.setName(rs.getString("Name"));
                role.setStatus(rs.getString("Status"));
                role.setCreatedAt(rs.getTimestamp("Created_at"));
                role.setUpdatedAt(rs.getTimestamp("Updated_at"));
                list.add(role);
            }
        }
        return list;
    }
}
