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
            
            // Fetch all permissions for the edit modal
            java.util.List<model.Permission> allPermissions = userDAO.findAllPermissions();
            request.setAttribute("allPermissions", allPermissions);
            
            request.getRequestDispatcher("/views/admin/role-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("updatePermissions".equals(action)) {
            try {
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                String[] permStrs = request.getParameterValues("permissions");
                java.util.List<Integer> permissionIds = new java.util.ArrayList<>();
                if (permStrs != null) {
                    for (String p : permStrs) {
                        permissionIds.add(Integer.parseInt(p));
                    }
                }
                userDAO.updateRolePermissions(roleId, permissionIds);
                request.getSession().setAttribute("message", "Role permissions updated successfully.");
                response.sendRedirect(request.getContextPath() + "/admin/roles");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error updating permissions: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/roles");
            }
        }
    }
}
