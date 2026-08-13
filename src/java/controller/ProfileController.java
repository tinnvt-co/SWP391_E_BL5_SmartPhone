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
import java.util.regex.Pattern;
import model.UserModel;

@WebServlet(name = "ProfileController", urlPatterns = {"/profile", "/my-profile"})
public class ProfileController extends HttpServlet {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^$|^[0-9]{9,15}$");

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserModel currentUser = (UserModel) session.getAttribute("currentUser");

        try {
            UserModel freshUser = userDAO.findActiveById(currentUser.getId());
            if (freshUser == null) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            session.setAttribute("currentUser", freshUser);
            request.setAttribute("profile", freshUser);
            request.getRequestDispatcher("/views/customer/profile-dashboard.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserModel currentUser = (UserModel) session.getAttribute("currentUser");
        UserModel form = readForm(request, currentUser);

        String error = validate(form);
        if (error == null) {
            try {
                if (!form.getPhone().isBlank() && userDAO.existsByPhoneForOtherUser(form.getPhone(), form.getId())) {
                    error = "Phone number is already used by another account.";
                }
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("profile", form);
            request.getRequestDispatcher("/views/customer/profile-dashboard.jsp").forward(request, response);
            return;
        }

        try {
            UserModel updatedUser = userDAO.updateProfile(form);
            session.setAttribute("currentUser", updatedUser);
            session.setAttribute("currentRole", updatedUser.getRoleName());

            request.setAttribute("success", "Your profile has been updated.");
            request.setAttribute("profile", updatedUser);
            request.getRequestDispatcher("/views/customer/profile-dashboard.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private UserModel readForm(HttpServletRequest request, UserModel currentUser) {
        UserModel user = new UserModel();
        user.setId(currentUser.getId());
        user.setUsername(currentUser.getUsername());
        user.setEmail(currentUser.getEmail());
        user.setRoleId(currentUser.getRoleId());
        user.setRoleName(currentUser.getRoleName());
        user.setStatus(currentUser.getStatus());
        user.setName(trim(request.getParameter("name")));
        user.setPhone(trim(request.getParameter("phone")));
        user.setAddress(trim(request.getParameter("address")));
        user.setImage(trim(request.getParameter("image")));

        String age = trim(request.getParameter("age"));
        if (!age.isBlank()) {
            try {
                user.setAge(Integer.parseInt(age));
            } catch (NumberFormatException ignored) {
                user.setAge(-1);
            }
        }
        return user;
    }

    private String validate(UserModel user) {
        if (user.getName().isBlank()) {
            return "Full name is required.";
        }
        if (user.getName().length() > 255 || user.getAddress().length() > 255
                || user.getImage().length() > 255) {
            return "Name, address, and image URL must be 255 characters or fewer.";
        }
        if (!PHONE_PATTERN.matcher(user.getPhone()).matches()) {
            return "Phone must be empty or contain 9-15 digits.";
        }
        if (user.getAge() != null && (user.getAge() < 13 || user.getAge() > 100)) {
            return "Age must be between 13 and 100.";
        }
        return null;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
