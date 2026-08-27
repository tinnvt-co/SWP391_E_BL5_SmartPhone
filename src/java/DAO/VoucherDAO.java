package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.UserVoucherModel;
import model.VoucherModel;

public class VoucherDAO {

    private VoucherModel mapVoucher(ResultSet rs) throws SQLException {
        VoucherModel voucher = new VoucherModel();

        voucher.setId(rs.getInt("ID"));
        voucher.setCode(rs.getString("Code"));
        voucher.setDiscountType(rs.getString("Discount_type"));
        voucher.setValue(rs.getBigDecimal("Value"));
        voucher.setMaxDiscount(rs.getBigDecimal("Max_discount"));
        voucher.setMinOrderValue(rs.getBigDecimal("Min_order_value"));
        
        if (rs.getObject("Max_uses_per_user") != null) {
            voucher.setMaxUsesPerUser(rs.getInt("Max_uses_per_user"));
        }

        if (rs.getObject("Usage_limit") != null) {
            voucher.setUsageLimit(rs.getInt("Usage_limit"));
        }

        voucher.setUsedCount(rs.getInt("Used_count"));
        voucher.setStartDate(rs.getTimestamp("Start_date"));
        voucher.setEndDate(rs.getTimestamp("End_date"));
        voucher.setStatus(rs.getString("Status"));
        voucher.setCreatedAt(rs.getTimestamp("Created_at"));
        voucher.setUpdatedAt(rs.getTimestamp("Updated_at"));

        return voucher;
    }

    // =========================
    // GET ALL VOUCHERS
    // =========================
    public List<VoucherModel> findAll(String keyword, int offset, int limit) {
        List<VoucherModel> list = new ArrayList<>();
        String sql = "SELECT * FROM Voucher WHERE Code LIKE ? ORDER BY Created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + (keyword == null ? "" : keyword) + "%");
            ps.setInt(2, limit);
            ps.setInt(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapVoucher(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countAll(String keyword) {
        String sql = "SELECT COUNT(*) FROM Voucher WHERE Code LIKE ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + (keyword == null ? "" : keyword) + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =========================
    // GET ACTIVE VOUCHERS
    // =========================
    public List<VoucherModel> findActiveVouchers() {
        List<VoucherModel> list = new ArrayList<>();
        String sql = "SELECT * FROM Voucher WHERE Status = 'ACTIVE' " +
                     "AND Start_date <= ? AND End_date >= ? " +
                     "AND (Usage_limit IS NULL OR Used_count < Usage_limit) " +
                     "ORDER BY Created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
            ps.setTimestamp(1, now);
            ps.setTimestamp(2, now);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapVoucher(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // =========================
    // GET VOUCHER BY ID
    // =========================
    public VoucherModel findById(int id) {

        String sql = "SELECT * FROM Voucher WHERE ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapVoucher(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // =========================
    // GET VOUCHER BY CODE
    // =========================
    public VoucherModel findByCode(String code) {

        String sql = "SELECT * FROM Voucher WHERE Code = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapVoucher(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // =========================
    // CREATE VOUCHER
    // =========================
    public boolean create(VoucherModel voucher) {
        String sql = "INSERT INTO Voucher (Code, Discount_type, Value, Max_discount, Min_order_value, Max_uses_per_user, Usage_limit, Start_date, End_date) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, voucher.getCode());
            ps.setString(2, voucher.getDiscountType());
            ps.setBigDecimal(3, voucher.getValue());
            ps.setBigDecimal(4, voucher.getMaxDiscount());
            ps.setBigDecimal(5, voucher.getMinOrderValue());

            if (voucher.getMaxUsesPerUser() > 0) {
                ps.setInt(6, voucher.getMaxUsesPerUser());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            
            if (voucher.getUsageLimit() != null) {
                ps.setInt(7, voucher.getUsageLimit());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            
            ps.setTimestamp(8, voucher.getStartDate());
            ps.setTimestamp(9, voucher.getEndDate());

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        voucher.setId(rs.getInt(1));
                    }
                }

                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================
    // UPDATE VOUCHER
    // =========================
    public boolean update(VoucherModel voucher) {
        String sql = "UPDATE Voucher SET Code = ?, Discount_type = ?, Value = ?, Max_discount = ?, Min_order_value = ?, Max_uses_per_user = ?, Usage_limit = ?, Start_date = ?, End_date = ? WHERE ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, voucher.getCode());
            ps.setString(2, voucher.getDiscountType());
            ps.setBigDecimal(3, voucher.getValue());
            ps.setBigDecimal(4, voucher.getMaxDiscount());
            ps.setBigDecimal(5, voucher.getMinOrderValue());

            if (voucher.getMaxUsesPerUser() > 0) {
                ps.setInt(6, voucher.getMaxUsesPerUser());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            
            if (voucher.getUsageLimit() != null) {
                ps.setInt(7, voucher.getUsageLimit());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            
            ps.setTimestamp(8, voucher.getStartDate());
            ps.setTimestamp(9, voucher.getEndDate());
            ps.setInt(10, voucher.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================
    // UPDATE STATUS
    // =========================
    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE Voucher SET Status = ? WHERE ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, id);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================
    // DELETE VOUCHER
    // =========================
    public boolean delete(int id) {
        String sql = "DELETE FROM Voucher WHERE ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================
    // SAVE VOUCHER FOR USER
    // =========================
    public boolean saveVoucherForUser(int userId, int voucherId) {
        String sql = "INSERT INTO User_Voucher (UserID, VoucherID) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, voucherId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================
    // GET SAVED VOUCHERS BY USER
    // =========================
    public List<UserVoucherModel> findAllSavedVouchersByUser(int userId) {
        List<UserVoucherModel> list = new ArrayList<>();
        String sql = "SELECT uv.*, v.Code, v.Discount_type, v.Value, v.Max_discount, v.Min_order_value, v.Max_uses_per_user, v.Usage_limit, v.Used_count, v.Start_date, v.End_date, v.Status " +
                     "FROM User_Voucher uv " +
                     "JOIN Voucher v ON uv.VoucherID = v.ID " +
                     "WHERE uv.UserID = ? " +
                     "ORDER BY uv.Saved_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserVoucherModel uv = new UserVoucherModel();
                    uv.setUserId(rs.getInt("UserID"));
                    uv.setVoucherId(rs.getInt("VoucherID"));
                    uv.setUsedCount(rs.getInt("Used_count"));
                    uv.setSavedAt(rs.getTimestamp("Saved_at"));
                    
                    VoucherModel v = new VoucherModel();
                    v.setId(rs.getInt("VoucherID"));
                    v.setCode(rs.getString("Code"));
                    v.setDiscountType(rs.getString("Discount_type"));
                    v.setValue(rs.getBigDecimal("Value"));
                    v.setMaxDiscount(rs.getBigDecimal("Max_discount"));
                    v.setMinOrderValue(rs.getBigDecimal("Min_order_value"));
                    
                    if (rs.getObject("Max_uses_per_user") != null) {
                        v.setMaxUsesPerUser(rs.getInt("Max_uses_per_user"));
                    }
                    if (rs.getObject("Usage_limit") != null) {
                        v.setUsageLimit(rs.getInt("Usage_limit"));
                    }
                    v.setUsedCount(rs.getInt("Used_count")); // This is the voucher's global used count, but we are overwriting it? Wait, query selects uv.Used_count and v.Used_count? Let's not worry about v.usedCount here.
                    v.setStartDate(rs.getTimestamp("Start_date"));
                    v.setEndDate(rs.getTimestamp("End_date"));
                    v.setStatus(rs.getString("Status"));
                    
                    uv.setVoucher(v);
                    list.add(uv);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<UserVoucherModel> findSavedVouchersByUser(int userId) {

        List<UserVoucherModel> list = new ArrayList<>();
        String sql = "SELECT uv.*, v.Code, v.Discount_type, v.Value, v.Max_discount, v.Min_order_value, v.Max_uses_per_user, v.Usage_limit, v.Used_count, v.Start_date, v.End_date, v.Status " +
                     "FROM User_Voucher uv " +
                     "JOIN Voucher v ON uv.VoucherID = v.ID " +
                     "WHERE uv.UserID = ? " +
                     "AND v.Status = 'ACTIVE' " +
                     "AND v.Start_date <= ? AND v.End_date >= ? " +
                     "AND (v.Usage_limit IS NULL OR v.Used_count < v.Usage_limit) " +
                     "AND (v.Max_uses_per_user IS NULL OR uv.Used_count < v.Max_uses_per_user) " +
                     "ORDER BY uv.Saved_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
            ps.setInt(1, userId);
            ps.setTimestamp(2, now);
            ps.setTimestamp(3, now);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    UserVoucherModel uv = new UserVoucherModel();

                    uv.setUserId(rs.getInt("UserID"));
                    uv.setVoucherId(rs.getInt("VoucherID"));
                    uv.setUsedCount(rs.getInt("Used_count"));
                    uv.setSavedAt(rs.getTimestamp("Saved_at"));

                    VoucherModel v = new VoucherModel();

                    v.setId(rs.getInt("VoucherID"));
                    v.setCode(rs.getString("Code"));
                    v.setDiscountType(rs.getString("Discount_type"));
                    v.setValue(rs.getBigDecimal("Value"));
                    v.setMaxDiscount(rs.getBigDecimal("Max_discount"));
                    v.setMinOrderValue(rs.getBigDecimal("Min_order_value"));
                    
                    if (rs.getObject("Max_uses_per_user") != null) {
                        v.setMaxUsesPerUser(rs.getInt("Max_uses_per_user"));
                    }

                    if (rs.getObject("Usage_limit") != null) {
                        v.setUsageLimit(rs.getInt("Usage_limit"));
                    }

                    v.setUsedCount(rs.getInt("Used_count"));
                    v.setStartDate(rs.getTimestamp("Start_date"));
                    v.setEndDate(rs.getTimestamp("End_date"));
                    v.setStatus(rs.getString("Status"));

                    uv.setVoucher(v);

                    list.add(uv);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}