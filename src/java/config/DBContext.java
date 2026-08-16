package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBContext {

    private static final String URL = firstNonBlank(
            System.getProperty("smartphone.db.url"),
            System.getenv("SMARTPHONE_DB_URL"),
            "jdbc:mysql://localhost:3306/database_swp391"
            + "?useSSL=false"
            + "&allowPublicKeyRetrieval=true"
            + "&serverTimezone=Asia/Bangkok"
            + "&characterEncoding=UTF-8");
    private static final String USERNAME = firstNonBlank(
            System.getProperty("smartphone.db.user"),
            System.getenv("SMARTPHONE_DB_USER"),
            "root");
    private static final String PASSWORD = firstNonBlank(
            System.getProperty("smartphone.db.password"),
            System.getenv("SMARTPHONE_DB_PASSWORD"),
            "040805");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new ExceptionInInitializerError("MySQL JDBC driver is missing: " + ex.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    private static String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.trim();
            }
        }
        return "";
    }

    private DBContext() {}
}
