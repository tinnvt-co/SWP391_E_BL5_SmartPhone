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
            response.sendRedirect(request.getContextPath()
                    + defaultPage(session.getAttribute("currentRole")));
            return;
        }
        request.setAttribute("redirect", safeRedirect(request.getParameter("redirect")));
        request.setAttribute("requiredRole", request.getParameter("requiredRole"));
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = trim(request.getParameter("username"));
        String password = trim(request.getParameter("password"));
        String remember = request.getParameter("remember");
        String redirect = safeRedirect(request.getParameter("redirect"));
        String requiredRole = trim(request.getParameter("requiredRole"));

        if (username.isEmpty() || password.isEmpty()) {
            forwardWithError(request, response, username, remember, redirect,
                    requiredRole, "Please enter both username and password.");
            return;
        }

        try {
            UserModel user = userDAO.findActiveByCredentials(username, password);
            if (user == null) {
                forwardWithError(request, response, username, remember, redirect,
                        requiredRole, "Invalid username, password, or inactive account.");
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

            String destination = redirect.isEmpty()
                    ? defaultPage(user.getRoleName()) : redirect;
            response.sendRedirect(request.getContextPath() + destination);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response,
                                  String username, String remember, String redirect,
                                  String requiredRole, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("username", username);
        request.setAttribute("rememberChecked", "on".equals(remember));
        request.setAttribute("redirect", redirect);
        request.setAttribute("requiredRole", requiredRole);
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    private String defaultPage(Object role) {
        return "/home?login=success";
    }

    private String safeRedirect(String value) {
        String target = trim(value);
        if (!target.startsWith("/") || target.startsWith("//")
                || target.contains("\\") || target.contains("\r")
                || target.contains("\n")) {
            return "";
        }
        return target;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
