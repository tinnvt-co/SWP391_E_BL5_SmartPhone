package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import config.DBContext;

/**
 * Discovers which columns exist on a given table and caches the result for the
 * lifetime of the JVM. Lets the app run against a legacy schema that doesn't
 * yet have the review columns (TransactionID, IsDeleted) without crashing, by
 * letting callers build SQL that omits references to missing columns.
 *
 * Cache invalidation: in-process only. Schema migrations done while Tomcat is
 * running won't be picked up until the next restart, which is acceptable for
 * this project.
 */
public final class SchemaInspector {

    private static final Set<String> feedbackColumns = Collections.synchronizedSet(new HashSet<>());
    private static volatile boolean feedbackColumnsLoaded = false;

    private SchemaInspector() {
    }

    /**
     * True if the given column exists on the Feedback table. Loads the full
     * column list on first call; subsequent calls are an in-memory lookup.
     */
    public static boolean feedbackHasColumn(String columnName) {
        ensureFeedbackColumnsLoaded();
        synchronized (feedbackColumns) {
            return feedbackColumns.contains(columnName.toLowerCase());
        }
    }

    private static void ensureFeedbackColumnsLoaded() {
        if (feedbackColumnsLoaded) {
            return;
        }
        synchronized (feedbackColumns) {
            if (feedbackColumnsLoaded) {
                return;
            }
            feedbackColumns.clear();
            String sql = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS "
                    + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Feedback'";
            try (Connection c = DBContext.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    feedbackColumns.add(rs.getString(1).toLowerCase());
                }
                feedbackColumnsLoaded = true;
            } catch (SQLException ex) {
                // Leave the set empty; callers will treat missing columns as
                // absent and continue with the legacy query path.
                System.err.println("[SchemaInspector] Failed to read Feedback columns: " + ex.getMessage());
            }
        }
    }
}