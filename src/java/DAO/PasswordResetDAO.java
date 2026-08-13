package DAO;

import config.DBContext;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class PasswordResetDAO {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final char[] HEX = "0123456789abcdef".toCharArray();

    public String createToken(int userId, int validMinutes) throws SQLException {
        ensureTable();
        String token = randomToken();
        String sql = "INSERT INTO PasswordResetToken "
                + "(UserID, Token, Expires_at, Created_at) VALUES (?, ?, ?, NOW())";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, token);
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now().plusMinutes(validMinutes)));
            ps.executeUpdate();
        }
        return token;
    }

    public Integer findValidUserId(String token) throws SQLException {
        ensureTable();
        String sql = "SELECT UserID FROM PasswordResetToken "
                + "WHERE Token = ? AND Used_at IS NULL AND Expires_at > NOW()";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("UserID") : null;
            }
        }
    }

    public void markUsed(String token) throws SQLException {
        ensureTable();
        String sql = "UPDATE PasswordResetToken SET Used_at = NOW() WHERE Token = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }

    private void ensureTable() throws SQLException {
        String sql = "CREATE TABLE IF NOT EXISTS PasswordResetToken ("
                + "ID INT NOT NULL AUTO_INCREMENT,"
                + "UserID INT NOT NULL,"
                + "Token VARCHAR(64) NOT NULL,"
                + "Expires_at DATETIME NOT NULL,"
                + "Used_at DATETIME NULL,"
                + "Created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                + "PRIMARY KEY (ID),"
                + "UNIQUE KEY uq_PasswordResetToken_Token (Token),"
                + "KEY idx_PasswordResetToken_UserID (UserID),"
                + "CONSTRAINT fk_PasswordResetToken_UserID FOREIGN KEY (UserID) "
                + "REFERENCES `User` (ID) ON DELETE CASCADE ON UPDATE CASCADE"
                + ")";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    private String randomToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        char[] token = new char[bytes.length * 2];
        for (int i = 0; i < bytes.length; i++) {
            int value = bytes[i] & 0xff;
            token[i * 2] = HEX[value >>> 4];
            token[i * 2 + 1] = HEX[value & 0x0f];
        }
        return new String(token);
    }
}
