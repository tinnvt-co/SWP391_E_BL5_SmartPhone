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
import java.util.regex.Pattern;
import model.UserModel;
import util.PasswordPolicy;

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    private static final Pattern FULL_NAME_PATTERN = Pattern.compile(
            "^(?=.{2,100}$)\\p{L}+(?:[ '\\-]\\p{L}+)*$");
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_]{4,50}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9]+@[A-Za-z0-9]+(?:\\.[A-Za-z]{2,})+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9]{9,15}$");
    private static final Pattern AGE_PATTERN = Pattern.compile("^(?:1[3-9]|[2-9][0-9]|100)$");
    private static final Pattern ADDRESS_PATTERN = Pattern.compile(
            "^(?=.{5,255}$)(?=.*[\\p{L}\\p{N}])[\\p{L}\\p{N}\\s,.'/#()&\\-]+$");

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        UserModel form = readForm(request);
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));
        String age = trim(request.getParameter("age"));

        String error = validate(form, password, confirmPassword, age);
        if (error != null) {
            forwardWithError(request, response, form, error);
            return;
        }

        try {
            error = validateUnique(form);
            if (error != null) {
                forwardWithError(request, response, form, error);
                return;
            }

            UserModel user = userDAO.createCustomer(form, password);
            List<String> permissions = userDAO.findPermissionNamesByRoleId(user.getRoleId());

            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("currentRole", user.getRoleName());
            session.setAttribute("permissions", permissions);
            session.setMaxInactiveInterval(30 * 60);

            response.sendRedirect(request.getContextPath() + "/home?register=success");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private UserModel readForm(HttpServletRequest request) {
        UserModel user = new UserModel();
        user.setUsername(trim(request.getParameter("username")));
        user.setName(trim(request.getParameter("name")));
        user.setPhone(trim(request.getParameter("phone")));
        user.setAddress(trim(request.getParameter("address")));
        user.setEmail(trim(request.getParameter("email")));

        String age = trim(request.getParameter("age"));
        if (!age.isEmpty()) {
            try {
                user.setAge(Integer.parseInt(age));
            } catch (NumberFormatException ignored) {
                user.setAge(-1);
            }
        }
        return user;
    }

    private String validate(UserModel user, String password, String confirmPassword, String age) {
        if (user.getName().isEmpty() || user.getUsername().isEmpty() || password.isEmpty()
                || confirmPassword.isEmpty() || user.getPhone().isEmpty()
                || user.getAddress().isEmpty() || user.getEmail().isEmpty()) {
            return "Please fill in all required fields.";
        }
        if (!FULL_NAME_PATTERN.matcher(user.getName()).matches()) {
            return "Full name must be 2-100 characters and contain only letters, spaces, apostrophes, or hyphens.";
        }
        if (!USERNAME_PATTERN.matcher(user.getUsername()).matches()) {
            return "Username must be 4-50 characters and contain only letters, numbers, or underscore.";
        }
        if (password.length() < PasswordPolicy.MIN_LENGTH
                || password.length() > PasswordPolicy.MAX_LENGTH) {
            return "Password must be 6-20 characters.";
        }
        if (!PasswordPolicy.hasRequiredCharacterTypes(password)) {
            return "Password must include at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character.";
        }
        if (!password.equals(confirmPassword)) {
            return "Password confirmation does not match.";
        }
        if (!EMAIL_PATTERN.matcher(user.getEmail()).matches()) {
            return "Email must use only letters and numbers before @ and have a valid domain.";
        }
        if (!PHONE_PATTERN.matcher(user.getPhone()).matches()) {
            return "Phone must contain 9-15 digits.";
        }
        if (!age.isEmpty() && !AGE_PATTERN.matcher(age).matches()) {
            return "Age must be between 13 and 100.";
        }
        if (!ADDRESS_PATTERN.matcher(user.getAddress()).matches()) {
            return "Address must be 5-255 characters and contain only valid address characters.";
        }
        return null;
    }

    private String validateUnique(UserModel user) throws SQLException {
        if (userDAO.existsByUsername(user.getUsername())) {
            return "Username is already taken.";
        }
        if (userDAO.existsByEmail(user.getEmail())) {
            return "Email is already registered.";
        }
        if (userDAO.existsByPhone(user.getPhone())) {
            return "Phone number is already registered.";
        }
        return null;
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response,
            UserModel form, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("form", form);
        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
