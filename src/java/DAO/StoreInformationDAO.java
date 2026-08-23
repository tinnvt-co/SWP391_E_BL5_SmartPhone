package DAO;

import config.DBContext;
import model.StoreInformationModel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StoreInformationDAO {

    /**
     * Get store information.Since the system has only one store information
 record, we always use id = 1.
     * @return 
     */
    public StoreInformationModel getStoreInformation() {

        String sql = """
                SELECT id,
                       store_name,
                       address,
                       phone,
                       email,
                       opening_hours,
                       facebook_url,
                       logo_url,
                       updated_at
                FROM StoreInformation
                WHERE id = 1
                """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {

                StoreInformationModel store = new StoreInformationModel();

                store.setStoreName(rs.getString("store_name"));
                store.setAddress(rs.getString("address"));
                store.setPhone(rs.getString("phone"));
                store.setEmail(rs.getString("email"));
                store.setFacebookUrl(rs.getString("facebook_url"));

                return store;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Update store information.
     * @param store
     * @return 
     */
    public boolean updateStoreInformation(StoreInformationModel store) {

        String sql = """
                UPDATE StoreInformation
                SET store_name = ?,
                    address = ?,
                    phone = ?,
                    email = ?,
                    opening_hours = ?,
                    facebook_url = ?,
                    logo_url = ?,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = 1
                """;

        try (
                Connection conn = DBContext.getConnection(); 
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, store.getStoreName());
            ps.setString(2, store.getAddress());
            ps.setString(3, store.getPhone());
            ps.setString(4, store.getEmail());
            ps.setString(6, store.getFacebookUrl());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}
