package controller;

import DAO.RoleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.Role;

public class AdminRoleController extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();
    private final DAO.UserDAO userDAO = new DAO.UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Role> roles = roleDAO.findAll();
            for (Role role : roles) {
                role.setPermissions(userDAO.findPermissionNamesByRoleId(role.getId()));
            }
            request.setAttribute("roles", roles);

            request.getRequestDispatcher("/views/admin/role-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("toggleStatus".equals(action)) {
            try {
                int roleId = Integer.parseInt(request.getParameter("roleId"));

                model.UserModel currentUser = (model.UserModel) request.getSession().getAttribute("currentUser");
                if (currentUser != null && currentUser.getRoleId() == roleId) {
                    throw new Exception("You cannot deactivate your own role.");
                }

                Role targetRole = roleDAO.findById(roleId);
                if (targetRole != null && "ADMIN".equalsIgnoreCase(targetRole.getName())) {
                    throw new Exception("You cannot deactivate the Admin role.");
                }

                String currentStatus = request.getParameter("currentStatus");
                String newStatus = "ACTIVE".equals(currentStatus) ? "INACTIVE" : "ACTIVE";

                roleDAO.updateStatus(roleId, newStatus);
                request.getSession().setAttribute("message", "Role status changed to " + newStatus + ".");
                response.sendRedirect(request.getContextPath() + "/admin/roles");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error updating role status: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/roles");
            }
        }
    }
}
