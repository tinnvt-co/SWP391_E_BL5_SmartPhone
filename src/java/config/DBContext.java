package config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class DBContext {

    private static final Properties FILE_PROPERTIES = loadFileProperties();
    private static final String URL = firstNonBlank(
            System.getProperty("smartphone.db.url"),
            System.getenv("SMARTPHONE_DB_URL"),
            FILE_PROPERTIES.getProperty("smartphone.db.url"),
            "jdbc:mysql://localhost:3306/database_swp391?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Bangkok&characterEncoding=UTF-8");
    private static final String USERNAME = firstNonBlank(
            System.getProperty("smartphone.db.user"),
            System.getenv("SMARTPHONE_DB_USER"),
            FILE_PROPERTIES.getProperty("smartphone.db.user"),
            "root");
    private static final String PASSWORD = firstNonBlank(
            System.getProperty("smartphone.db.password"),
            System.getenv("SMARTPHONE_DB_PASSWORD"),
            FILE_PROPERTIES.getProperty("smartphone.db.password"),
            "");

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

    private static Properties loadFileProperties() {
        Properties properties = new Properties();
        try (InputStream input = DBContext.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (input != null) {
                properties.load(input);
            }
        } catch (IOException ignored) {
        }
        return properties;
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
