package controller;

import DAO.PasswordResetDAO;
import DAO.UserDAO;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.UserModel;
import service.MailService;

public class ForgotPasswordController extends HttpServlet {

    private static final int RESET_LINK_MINUTES = 30;

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();
    private final MailService mailService = new MailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String email = trim(request.getParameter("email"));
        if (email.isBlank()) {
            forward(request, response, "Please enter your email address.", null, email);
            return;
        }

        try {
            UserModel user = userDAO.findActiveByEmail(email);
            if (user != null) {
                String token = resetDAO.createToken(user.getId(), RESET_LINK_MINUTES);
                mailService.sendPasswordReset(user.getEmail(), user.getName(), resetLink(request, token));
            }

            forward(request, response, null,
                    "If the email exists, a password reset link has been sent.", "");
        } catch (MessagingException e) {
            forward(request, response,
                    "Cannot send reset email. Please check SMTP Gmail configuration.", null, email);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String resetLink(HttpServletRequest request, String token) {
        String base = request.getScheme() + "://"
                + request.getServerName()
                + (isDefaultPort(request) ? "" : ":" + request.getServerPort())
                + request.getContextPath();
        return base + "/reset-password?token=" + token;
    }

    private boolean isDefaultPort(HttpServletRequest request) {
        return ("http".equalsIgnoreCase(request.getScheme()) && request.getServerPort() == 80)
                || ("https".equalsIgnoreCase(request.getScheme()) && request.getServerPort() == 443);
    }

    private void forward(HttpServletRequest request, HttpServletResponse response,
            String error, String success, String email)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("success", success);
        request.setAttribute("email", email);
        request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
