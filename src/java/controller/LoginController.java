package controller;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.UserModel;

@WebServlet(name = "LoginController", urlPatterns = {"/login"})
public class LoginController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = trim(request.getParameter("username"));
        String password = trim(request.getParameter("password"));
        String remember = request.getParameter("remember");

        if (username.isEmpty() || password.isEmpty()) {
            forwardWithError(request, response, username, remember, "Please enter both username and password.");
            return;
        }

        try {
            UserModel user = userDAO.findActiveByCredentials(username, password);
            if (user == null) {
                forwardWithError(request, response, username, remember, "Invalid username, password, or inactive account.");
                return;
            }

            List<String> permissions = userDAO.findPermissionNamesByRoleId(user.getRoleId());

            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("currentRole", user.getRoleName());
            session.setAttribute("permissions", permissions);
            session.setMaxInactiveInterval("on".equals(remember) ? 7 * 24 * 60 * 60 : 30 * 60);

            response.sendRedirect(request.getContextPath() + "/home?login=success");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response,
                                  String username, String remember, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("username", username);
        request.setAttribute("rememberChecked", "on".equals(remember));
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
