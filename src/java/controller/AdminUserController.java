package controller;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.UserModel;

@WebServlet(name = "AdminUserController", urlPatterns = {"/admin/users"})
public class AdminUserController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<UserModel> users = userDAO.findAll();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/views/admin/user-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if (action != null && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                if ("activate".equals(action)) {
                    userDAO.updateStatus(id, "ACTIVE");
                } else if ("deactivate".equals(action)) {
                    userDAO.updateStatus(id, "INACTIVE");
                }
            } catch (Exception ex) {
                // handle parsing or sql exception silently or add error message
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
