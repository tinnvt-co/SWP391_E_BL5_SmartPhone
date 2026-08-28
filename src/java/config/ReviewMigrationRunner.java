package config;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Boot-time schema migrator for the review/feedback system.
 *
 * Why a hand-rolled migrator (instead of Flyway/Liquibase)? - The app has zero
 * other migrations, and Flyway would add another moving part to the NetBeans
 * project. - Every statement below is idempotent: it checks INFORMATION_SCHEMA
 * first and skips when the column / index / constraint already exists. This is
 * safe to run on every Tomcat restart.
 *
 * Wiring: registered via {@link ReviewMigrationListener}, which Tomcat calls
 * before any servlet receives its first request. Failures are logged loudly so
 * the operator can intervene.
 */
public final class ReviewMigrationRunner {

    private ReviewMigrationRunner() {
    }

    /**
     * Runs every step. Each step is wrapped in its own try/catch so a single
     * broken statement does not abort the rest of the migration.
     */
    public static void run() {
        List<Step> steps = new ArrayList<>(Arrays.asList(
                stepAddFeedbackTransactionId(),
                stepAddFeedbackFkTransaction(),
                stepAddFeedbackUniqueConstraint(),
                stepAddFeedbackIsDeleted(),
                stepCreateFeedbackVariantIndex(),
                stepCreateAnswerFeedbackIndex()
        ));

        for (Step step : steps) {
            try (Connection connection = DBContext.getConnection(); Statement statement = connection.createStatement()) {
                statement.executeUpdate(step.sql);
            } catch (SQLException ex) {
                // 1060 = duplicate column, 1061 = duplicate key name, 1062 = duplicate entry,
                // 1067 = invalid default value for. Anything else gets logged.
                int code = ex.getErrorCode();
                if (code == 1060 || code == 1061 || code == 1067) {
                    System.out.println("[ReviewMigration] skip '" + step.name + "' (" + ex.getMessage() + ")");
                } else {
                    System.err.println("[ReviewMigration] FAILED '" + step.name + "': " + ex.getMessage());
                }
            } catch (Exception ex) {
                System.err.println("[ReviewMigration] unexpected error in '" + step.name + "': " + ex.getMessage());
            }
        }
    }

    private static Step stepAddFeedbackTransactionId() {
        String sql = "ALTER TABLE `Feedback` ADD COLUMN `TransactionID` INT NULL AFTER `ProductVariantID`";
        return new Step("add Feedback.TransactionID", sql);
    }

    private static Step stepAddFeedbackFkTransaction() {
        String sql = "ALTER TABLE `Feedback` ADD CONSTRAINT `fk_Feedback_TransactionID` "
                + "FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) "
                + "ON DELETE CASCADE ON UPDATE CASCADE";
        return new Step("add fk_Feedback_TransactionID", sql);
    }

    private static Step stepAddFeedbackUniqueConstraint() {
        // We can't use IF NOT EXISTS for constraints in MySQL 5.7/8.0 without
        // raising a duplicate-name error. The try/catch above swallows code
        // 1061 ("Duplicate key name") so this is safe to re-run.
        String sql = "ALTER TABLE `Feedback` ADD CONSTRAINT `uq_Feedback_user_variant_tx` "
                + "UNIQUE (`UserID`, `ProductVariantID`, `TransactionID`)";
        return new Step("add uq_Feedback_user_variant_tx", sql);
    }

    private static Step stepAddFeedbackIsDeleted() {
        String sql = "ALTER TABLE `Feedback` ADD COLUMN `IsDeleted` TINYINT(1) NOT NULL DEFAULT 0 AFTER `Updated_at`";
        return new Step("add Feedback.IsDeleted", sql);
    }

    private static Step stepCreateFeedbackVariantIndex() {
        String sql = "CREATE INDEX `idx_Feedback_variant_created` ON `Feedback` (`ProductVariantID`, `Created_at`)";
        return new Step("create idx_Feedback_variant_created", sql);
    }

    private static Step stepCreateAnswerFeedbackIndex() {
        String sql = "CREATE INDEX `idx_Answer_feedback_created` ON `Answer` (`FeedbackID`, `Created_at`)";
        return new Step("create idx_Answer_feedback_created", sql);
    }

    private static Step step(String name, String sql) {
        return new Step(name, sql);
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
