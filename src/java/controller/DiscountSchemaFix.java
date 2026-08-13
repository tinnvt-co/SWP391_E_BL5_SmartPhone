package controller;

import config.DBContext;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * One-shot self-heal for the Discount table:
 *   - makes Discount.ID auto_increment
 *   - drops the legacy Discount.Status column
 *
 * Idempotent and safe to call repeatedly.
 * Hit once via the browser, then visit /manager/discounts as normal.
 */
@WebServlet(name = "DiscountSchemaFix", urlPatterns = {"/manager/discounts/schema-fix"})
public class DiscountSchemaFix extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html; charset=UTF-8");
        try (PrintWriter out = resp.getWriter(); Connection con = DBContext.getConnection()) {

            boolean wasAutoIncrement = isAutoIncrement(con);
            out.println("<h2>Discount schema fix</h2>");
            out.println("<p><b>Before:</b> ID auto_increment = " + wasAutoIncrement + "</p>");

            try (Statement st = con.createStatement()) {
                if (!wasAutoIncrement) {
                    st.executeUpdate("ALTER TABLE `Discount` MODIFY `ID` INT NOT NULL AUTO_INCREMENT");
                    out.println("<p style='color:green'>[OK] Discount.ID is now AUTO_INCREMENT.</p>");
                } else {
                    out.println("<p>[skip] Discount.ID already AUTO_INCREMENT.</p>");
                }

                if (columnExists(con, "Discount", "Status")) {
                    st.executeUpdate("ALTER TABLE `Discount` DROP COLUMN `Status`");
                    out.println("<p style='color:green'>[OK] Discount.Status column dropped.</p>");
                } else {
                    out.println("<p>[skip] Discount.Status column already removed.</p>");
                }
            }

            out.println("<h3>Final state</h3><pre>");
            try (ResultSet rs = con.getMetaData().getColumns(null, null, "Discount", null)) {
                while (rs.next()) {
                    out.println(rs.getString("COLUMN_NAME") + " | " + rs.getString("TYPE_NAME") + " | "
                            + rs.getString("IS_NULLABLE") + " | default=" + rs.getString("COLUMN_DEF"));
                }
            }
            out.println("</pre>");
            out.println("<p><a href='" + req.getContextPath() + "/manager/discounts'>Go to Discounts</a></p>");

        } catch (SQLException ex) {
            resp.getWriter().println("<pre style='color:red'>SQL error: " + ex.getMessage() + "</pre>");
        }
    }

    private boolean isAutoIncrement(Connection con) throws SQLException {
        try (ResultSet rs = con.getMetaData().getColumns(null, null, "Discount", "ID")) {
            return rs.next() && rs.getString("IS_AUTOINCREMENT") != null
                    && rs.getString("IS_AUTOINCREMENT").equals("YES");
        }
    }

    private boolean columnExists(Connection con, String table, String column) throws SQLException {
        try (ResultSet rs = con.getMetaData().getColumns(null, null, table, column)) {
            return rs.next();
        }
    }
}