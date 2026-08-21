package config;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Boot-time schema migrator for the order completion workflow.
 *
 * Adds a single nullable column {@code Transaction.Delivered_at} that records
 * the moment the order was first marked as DELIVERED. The
 * {@link OrderCompletionScheduler} later uses this column to auto-complete
 * orders that have stayed in DELIVERED more than 15 days without the customer
 * pressing "Complete". The same pattern as ReviewMigrationRunner is followed:
 * each step is idempotent and isolated, so a single failure does not abort
 * the rest of the app boot.
 */
public final class OrderCompletionMigrationRunner {

    private OrderCompletionMigrationRunner() {
    }

    public static void run() {
        List<Step> steps = new ArrayList<>(Arrays.asList(
                stepAddDeliveredAt()
        ));

        for (Step step : steps) {
            try (Connection connection = DBContext.getConnection(); Statement statement = connection.createStatement()) {
                statement.executeUpdate(step.sql);
            } catch (SQLException ex) {
                int code = ex.getErrorCode();
                if (code == 1060 || code == 1061 || code == 1067) {
                    System.out.println("[OrderCompletionMigration] skip '" + step.name + "' (" + ex.getMessage() + ")");
                } else {
                    System.err.println("[OrderCompletionMigration] FAILED '" + step.name + "': " + ex.getMessage());
                }
            } catch (Exception ex) {
                System.err.println("[OrderCompletionMigration] unexpected error in '" + step.name + "': " + ex.getMessage());
            }
        }
    }

    private static Step stepAddDeliveredAt() {
        String sql = "ALTER TABLE `Transaction` ADD COLUMN `Delivered_at` DATETIME NULL AFTER `Updated_at`";
        return new Step("add Transaction.Delivered_at", sql);
    }

    private static final class Step {

        final String name;
        final String sql;

        Step(String name, String sql) {
            this.name = name;
            this.sql = sql;
        }
    }
}
