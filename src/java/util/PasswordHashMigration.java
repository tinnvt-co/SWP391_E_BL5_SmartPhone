package util;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public final class PasswordHashMigration {

    public static void main(String[] args) throws Exception {
        List<LegacyPassword> legacyPasswords = new ArrayList<>();
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (Statement statement = connection.createStatement()) {
                    statement.executeUpdate(
                            "ALTER TABLE `User` MODIFY COLUMN `Password` VARCHAR(255) NOT NULL");
                }

                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT ID, Password FROM `User`");
                        ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        String storedPassword = resultSet.getString("Password");
                        if (PasswordHasher.needsRehash(storedPassword)) {
                            legacyPasswords.add(new LegacyPassword(
                                    resultSet.getInt("ID"), storedPassword));
                        }
                    }
                }

                try (PreparedStatement statement = connection.prepareStatement(
                        "UPDATE `User` SET Password = ? WHERE ID = ?")) {
                    for (LegacyPassword legacy : legacyPasswords) {
                        statement.setString(1, PasswordHasher.hash(legacy.password));
                        statement.setInt(2, legacy.userId);
                        statement.addBatch();
                    }
                    statement.executeBatch();
                }

                connection.commit();
                System.out.println("Migrated password hashes: " + legacyPasswords.size());
            } catch (Exception exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    private static final class LegacyPassword {

        private final int userId;
        private final String password;

        private LegacyPassword(int userId, String password) {
            this.userId = userId;
            this.password = password;
        }
    }

    private PasswordHashMigration() {
    }
}
