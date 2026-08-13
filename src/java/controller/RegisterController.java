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

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_]{4,50}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9]{9,15}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

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

        String error = validate(form, password, confirmPassword);
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

    private String validate(UserModel user, String password, String confirmPassword) {
        if (user.getName().isEmpty() || user.getUsername().isEmpty() || password.isEmpty()
                || confirmPassword.isEmpty() || user.getPhone().isEmpty()
                || user.getAddress().isEmpty() || user.getEmail().isEmpty()) {
            return "Please fill in all required fields.";
        }
        if (!USERNAME_PATTERN.matcher(user.getUsername()).matches()) {
            return "Username must be 4-50 characters and contain only letters, numbers, or underscore.";
        }
        if (password.length() < 6 || password.length() > 20) {
            return "Password must be 6-20 characters.";
        }
        if (!password.equals(confirmPassword)) {
            return "Password confirmation does not match.";
        }
        if (!PHONE_PATTERN.matcher(user.getPhone()).matches()) {
            return "Phone must contain 9-15 digits.";
        }
        if (!EMAIL_PATTERN.matcher(user.getEmail()).matches()) {
            return "Email format is invalid.";
        }
        if (user.getAge() != null && (user.getAge() < 13 || user.getAge() > 100)) {
            return "Age must be between 13 and 100.";
        }
        if (user.getName().length() > 255 || user.getAddress().length() > 255 || user.getEmail().length() > 255) {
            return "Name, address, and email must be 255 characters or fewer.";
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
