package controller;

import DAO.UserDAO;
import DAO.RoleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.UserModel;

@WebServlet(name = "AdminUserController", urlPatterns = {"/admin/users"})
public class AdminUserController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            try {
                request.setAttribute("roles", roleDAO.findAll());
                request.getRequestDispatcher("/views/admin/user-create.jsp").forward(request, response);
                return;
            } catch (SQLException ex) {
                throw new ServletException(ex);
            }
        }
        
        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    UserModel user = userDAO.findById(id);
                    if (user != null) {
                        request.setAttribute("user", user);
                        request.setAttribute("roles", roleDAO.findAll());
                        request.getRequestDispatcher("/views/admin/user-edit.jsp").forward(request, response);
                        return;
                    }
                } catch (Exception ex) {
                    // silently fallback to list
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            int page = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            
            int totalItems = userDAO.countAll();
            int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
            
            if (page > totalPages && totalPages > 0) {
                page = totalPages;
            }
            
            int offset = (page - 1) * PAGE_SIZE;
            
            List<UserModel> users = userDAO.findAll(offset, PAGE_SIZE);
            
            request.setAttribute("users", users);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.getRequestDispatcher("/views/admin/user-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            handleCreateUser(request, response);
            return;
        }
        
        if ("update".equals(action)) {
            handleUpdateUser(request, response);
            return;
        }

        String idStr = request.getParameter("id");
        if (action != null && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
                if (currentUser != null && currentUser.getId() == id) {
                    request.getSession().setAttribute("error", "You cannot lock, unlock, or delete your own account.");
                } else {
                    if ("activate".equals(action)) {
                        userDAO.updateStatus(id, "ACTIVE");
                    } else if ("deactivate".equals(action)) {
                        userDAO.updateStatus(id, "INACTIVE");
                    } else if ("delete".equals(action)) {
                        UserModel userToDelete = userDAO.findById(id);
                        if (userToDelete != null && !"ADMIN".equalsIgnoreCase(userToDelete.getRoleName())) {
                            userDAO.delete(id);
                            request.getSession().setAttribute("message", "User deleted successfully.");
                        } else {
                            request.getSession().setAttribute("error", "Cannot delete Admin accounts.");
                        }
                    }
                }
            } catch (Exception ex) {
                // handle parsing or sql exception silently or add error message
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void handleCreateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<String> errors = new ArrayList<>();
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String ageStr = request.getParameter("age");
        String roleIdStr = request.getParameter("roleId");
        String address = request.getParameter("address");

        try {
            if (username == null || !username.matches("^[a-zA-Z0-9]{4,20}$")) {
                errors.add("Username must be alphanumeric and between 4 to 20 characters.");
            } else if (userDAO.existsByUsername(username)) {
                errors.add("Username already exists.");
            }

            if (password == null || !password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$")) {
                errors.add("Password must be at least 8 characters, with 1 uppercase, 1 lowercase, 1 number, and 1 special character.");
            }

            if (name == null || name.trim().isEmpty() || name.length() > 50) {
                errors.add("Name is required and must not exceed 50 characters.");
            }

            if (email == null || !email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
                errors.add("Invalid email format.");
            } else if (userDAO.existsByEmail(email)) {
                errors.add("Email already exists.");
            }

            if (phone == null || !phone.matches("^0\\d{9}$")) {
                errors.add("Phone must start with 0 and have exactly 10 digits.");
            } else if (userDAO.existsByPhone(phone)) {
                errors.add("Phone number already exists.");
            }

            Integer age = null;
            if (ageStr != null && !ageStr.isBlank()) {
                try {
                    age = Integer.parseInt(ageStr);
                    if (age < 10 || age > 100) {
                        errors.add("Age must be between 10 and 100.");
                    }
                } catch (NumberFormatException e) {
                    errors.add("Invalid age format.");
                }
            }

            int roleId = -1;
            if (roleIdStr == null || roleIdStr.isBlank()) {
                errors.add("Role is required.");
            } else {
                try {
                    roleId = Integer.parseInt(roleIdStr);
                } catch (NumberFormatException e) {
                    errors.add("Invalid role format.");
                }
            }

            if (!errors.isEmpty()) {
                request.setAttribute("roles", roleDAO.findAll());
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/views/admin/user-create.jsp").forward(request, response);
                return;
            }

            UserModel user = new UserModel();
            user.setUsername(username);
            user.setName(name);
            user.setEmail(email);
            user.setPhone(phone);
            user.setAge(age);
            user.setAddress(address);

            userDAO.createUser(user, password, roleId);

            response.sendRedirect(request.getContextPath() + "/admin/users");
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void handleUpdateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<String> errors = new ArrayList<>();
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String ageStr = request.getParameter("age");
        String roleIdStr = request.getParameter("roleId");
        String address = request.getParameter("address");

        try {
            int id = Integer.parseInt(idStr);
            UserModel existingUser = userDAO.findById(id);
            if (existingUser == null) {
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            if (name == null || name.trim().isEmpty() || name.length() > 50) {
                errors.add("Name is required and must not exceed 50 characters.");
            }

            if (email == null || !email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
                errors.add("Invalid email format.");
            } else if (userDAO.existsByEmailForOtherUser(email, id)) {
                errors.add("Email already exists for another user.");
            }

            if (phone == null || !phone.matches("^0\\d{9}$")) {
                errors.add("Phone must start with 0 and have exactly 10 digits.");
            } else if (userDAO.existsByPhoneForOtherUser(phone, id)) {
                errors.add("Phone number already exists for another user.");
            }

            Integer age = null;
            if (ageStr != null && !ageStr.isBlank()) {
                try {
                    age = Integer.parseInt(ageStr);
                    if (age < 10 || age > 100) {
                        errors.add("Age must be between 10 and 100.");
                    }
                } catch (NumberFormatException e) {
                    errors.add("Invalid age format.");
                }
            }

            int roleId = -1;
            if (roleIdStr == null || roleIdStr.isBlank()) {
                errors.add("Role is required.");
            } else {
                try {
                    roleId = Integer.parseInt(roleIdStr);
                } catch (NumberFormatException e) {
                    errors.add("Invalid role format.");
                }
            }

            if (!errors.isEmpty()) {
                // To redisplay form with current inputs but original username
                UserModel tempUser = new UserModel();
                tempUser.setId(id);
                tempUser.setUsername(existingUser.getUsername());
                tempUser.setName(name);
                tempUser.setEmail(email);
                tempUser.setPhone(phone);
                tempUser.setAge(age);
                tempUser.setAddress(address);
                tempUser.setRoleId(roleId);

                request.setAttribute("user", tempUser);
                request.setAttribute("roles", roleDAO.findAll());
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/views/admin/user-edit.jsp").forward(request, response);
                return;
            }

            existingUser.setName(name);
            existingUser.setEmail(email);
            existingUser.setPhone(phone);
            existingUser.setAge(age);
            existingUser.setAddress(address);
            existingUser.setRoleId(roleId);

            if (userDAO.updateUserAdmin(existingUser)) {
                request.getSession().setAttribute("message", "User updated successfully.");
            } else {
                request.getSession().setAttribute("error", "Failed to update user.");
            }
            response.sendRedirect(request.getContextPath() + "/admin/users");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
}
