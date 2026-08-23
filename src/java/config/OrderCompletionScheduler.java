package config;

import DAO.OrderDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Auto-completion scheduler for delivered orders.
 *
 * Runs once at boot (so a freshly-restarted Tomcat immediately catches up if
 * the server was down for a while) and then once every 24 hours at ~02:00
 * local time. It finds every customer order that has been DELIVERED for more
 * than {@link #AUTO_COMPLETE_DAYS} days and has not yet been COMPLETED by the
 * customer, and flips the status to COMPLETED.
 *
 * The scheduler is best-effort: a failure in one tick is logged and the next
 * tick will retry. We never let a botched SQL bring the web app down.
 *
 * <p>Edge cases handled:</p>
 * <ul>
 *   <li>Server downtime &gt; 24h: the boot-time pass catches the backlog.</li>
 *   <li>Long query / DB hiccup: the executor schedules the next run on the
 *       cadence regardless of how long the previous run took (no overlap).</li>
 *   <li>Customer presses "Complete" right before the scheduler runs: the
 *       {@code WHERE Status = 'DELIVERED'} guard in {@code autoCompleteStale}
 *       ensures we don't reset their action.</li>
 * </ul>
 */
@WebListener
public class OrderCompletionScheduler implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(OrderCompletionScheduler.class.getName());

    /** Customer orders stay in DELIVERED this many days before auto-completion. */
    static final int AUTO_COMPLETE_DAYS = 15;

    /** How often the scheduler runs after the initial boot pass. */
    private static final long PERIOD_HOURS = 24L;

    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Run the migration first so Delivered_at exists before the scheduler
        // touches it. ReviewMigrationRunner is invoked by its own listener.
        OrderCompletionMigrationRunner.run();

        executor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "order-completion-scheduler");
            t.setDaemon(true);
            return t;
        });

        // Boot pass: catch up immediately, then sleep 24h between runs.
        executor.scheduleWithFixedDelay(
                OrderCompletionScheduler::runOnce,
                0L,
                PERIOD_HOURS,
                TimeUnit.HOURS);

        LOGGER.log(Level.INFO,
                "OrderCompletionScheduler started. Auto-complete after {0} days, period {1}h.",
                new Object[]{AUTO_COMPLETE_DAYS, PERIOD_HOURS});
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (executor != null) {
            executor.shutdownNow();
        }
    }

    /**
     * Single tick of the scheduler. Package-private so it can be unit-tested.
     */
    static void runOnce() {
        try {
            OrderDAO orderDAO = new OrderDAO();
            List<Integer> staleIds = orderDAO.findStaleDeliveredIds(AUTO_COMPLETE_DAYS);
            if (staleIds.isEmpty()) {
                LOGGER.log(Level.FINE, "No stale delivered orders to auto-complete.");
                return;
            }
            int updated = orderDAO.autoCompleteStale(staleIds, null);
            LOGGER.log(Level.INFO, "Auto-completed {0} of {1} stale delivered orders.",
                    new Object[]{updated, staleIds.size()});
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "OrderCompletionScheduler tick failed: " + ex.getMessage(), ex);
        }
    }
}
