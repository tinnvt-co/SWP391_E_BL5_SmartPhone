package config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Boot-time migrator. Runs once when Tomcat finishes initialising the web
 * context and again when it shuts down (where it is a no-op). Failures in
 * ReviewMigrationRunner are isolated per step so a missing column does not
 * prevent the rest of the app from starting.
 */
@WebListener
public class ReviewMigrationListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[ReviewMigration] Boot-time schema check starting...");
        try {
            ReviewMigrationRunner.run();
            System.out.println("[ReviewMigration] Boot-time schema check done.");
        } catch (Exception ex) {
            System.err.println("[ReviewMigration] Boot-time schema check aborted: " + ex.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // No-op: schema migrations are permanent.
    }
}