package controller;

import DAO.RoleDAO;
import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            java.util.List<model.UserModel> allUsers = userDAO.findAll();
            int totalUsers = allUsers.size();
            java.util.List<model.Role> allRoles = roleDAO.findAll();
            int totalRoles = allRoles.size();

            java.util.Set<String> activeRoleNames = allRoles.stream()
                    .filter(r -> "ACTIVE".equalsIgnoreCase(r.getStatus()))
                    .map(model.Role::getName)
                    .collect(java.util.stream.Collectors.toSet());

            // Calculate users by role (only for active roles)
            java.util.Map<String, Long> usersByRole = allUsers.stream()
                    .filter(u -> u.getRoleName() != null && activeRoleNames.contains(u.getRoleName()))
                    .collect(java.util.stream.Collectors.groupingBy(
                            u -> u.getRoleName(),
                            java.util.stream.Collectors.counting()
                    ));

            // Calculate users by status
            java.util.Map<String, Long> usersByStatus = allUsers.stream()
                    .collect(java.util.stream.Collectors.groupingBy(
                            u -> u.isActive() ? "Active" : "Inactive",
                            java.util.stream.Collectors.counting()
                    ));

            // Convert to JSON strings manually for JSP
            StringBuilder roleLabels = new StringBuilder("[");
            StringBuilder roleData = new StringBuilder("[");
            usersByRole.forEach((k, v) -> {
                roleLabels.append("'").append(k).append("',");
                roleData.append(v).append(",");
            });
            roleLabels.append("]");
            roleData.append("]");

            StringBuilder statusLabels = new StringBuilder("['Active', 'Inactive']");
            StringBuilder statusData = new StringBuilder("[")
                    .append(usersByStatus.getOrDefault("Active", 0L)).append(",")
                    .append(usersByStatus.getOrDefault("Inactive", 0L)).append("]");

            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalRoles", totalRoles);
            request.setAttribute("roleLabels", roleLabels.toString());
            request.setAttribute("roleData", roleData.toString());
            request.setAttribute("statusLabels", statusLabels.toString());
            request.setAttribute("statusData", statusData.toString());

            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }
}
