package controller;

import DAO.PasswordResetDAO;
import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import util.PasswordPolicy;

public class ResetPasswordController extends HttpServlet {

    private final PasswordResetDAO resetDAO = new PasswordResetDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = trim(request.getParameter("token"));
        try {
            if (token.isBlank() || resetDAO.findValidUserId(token) == null) {
                forwardInvalid(request, response);
                return;
            }
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String token = trim(request.getParameter("token"));
        String newPassword = trim(request.getParameter("newPassword"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));
        String error = validate(token, newPassword, confirmPassword);
        if (error != null) {
            forwardForm(request, response, token, error);
            return;
        }

        try {
            Integer userId = resetDAO.findValidUserId(token);
            if (userId == null) {
                forwardInvalid(request, response);
                return;
            }

            userDAO.updatePassword(userId, newPassword);
            resetDAO.markUsed(token);
            response.sendRedirect(request.getContextPath() + "/login?reset=success");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String validate(String token, String newPassword, String confirmPassword) {
        if (token.isBlank()) {
            return "Reset token is missing.";
        }
        if (newPassword.isBlank() || confirmPassword.isBlank()) {
            return "Please fill in both password fields.";
        }
        if (newPassword.length() < PasswordPolicy.MIN_LENGTH
                || newPassword.length() > PasswordPolicy.MAX_LENGTH) {
            return "New password must be 6-20 characters.";
        }
        if (!PasswordPolicy.hasRequiredCharacterTypes(newPassword)) {
            return "New password must include at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Confirm password does not match.";
        }
        return null;
    }

    private void forwardForm(HttpServletRequest request, HttpServletResponse response,
            String token, String error)
            throws ServletException, IOException {
        request.setAttribute("token", token);
        request.setAttribute("error", error);
        request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
    }

    private void forwardInvalid(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("invalidToken", true);
        request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
