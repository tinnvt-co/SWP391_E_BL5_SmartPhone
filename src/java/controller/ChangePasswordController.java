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
import model.UserModel;

@WebServlet(name = "ChangePasswordController", urlPatterns = {"/change-password"})
public class ChangePasswordController extends HttpServlet {

    private static final int MIN_PASSWORD_LENGTH = 6;
    private static final int MAX_PASSWORD_LENGTH = 20;

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserModel currentUser = session == null ? null : (UserModel) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String currentPassword = trim(request.getParameter("currentPassword"));
        String newPassword = trim(request.getParameter("newPassword"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        String error = validate(currentPassword, newPassword, confirmPassword);
        if (error != null) {
            forward(request, response, error, null);
            return;
        }

        try {
            if (!userDAO.isCurrentPassword(currentUser.getId(), currentPassword)) {
                forward(request, response, "Current password is incorrect.", null);
                return;
            }

            if (!userDAO.updatePassword(currentUser.getId(), newPassword)) {
                forward(request, response, "Cannot update password for this account.", null);
                return;
            }

            forward(request, response, null, "Your password has been changed successfully.");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String validate(String currentPassword, String newPassword, String confirmPassword) {
        if (currentPassword.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            return "Please fill in all password fields.";
        }
        if (newPassword.length() < MIN_PASSWORD_LENGTH || newPassword.length() > MAX_PASSWORD_LENGTH) {
            return "New password must be 6-20 characters.";
        }
        if (newPassword.equals(currentPassword)) {
            return "New password must be different from current password.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Confirm password does not match.";
        }
        return null;
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String error, String success)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("success", success);
        request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
