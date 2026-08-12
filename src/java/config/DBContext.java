package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBContext {
    private static final String URL = System.getProperty("smartphone.db.url",
            "jdbc:mysql://localhost:3306/database_swp391?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Bangkok&characterEncoding=UTF-8");
    private static final String USERNAME = System.getProperty("smartphone.db.user", "root");
    private static final String PASSWORD = System.getProperty("smartphone.db.password", "Duc@123456");

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

    private DBContext() {}
}
