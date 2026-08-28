package controller;

import DAO.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.CategoryModel;

@WebServlet(name = "CategoryController", urlPatterns = {"/manager/categories"})
public class CategoryController extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = ProductController.value(
                request.getParameter("action"), "list");

        try {
            switch (action) {
                case "form" -> showForm(request, response);
                default -> showList(request, response);
            }
        } catch (SQLException exception) {
            throw new ServletException("Cannot load categories", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = ProductController.value(
                request.getParameter("action"), "");

        try {
            switch (action) {
                case "deactivate", "set-status" ->
                    handleSetStatus(request, response, action);
                case "save" -> handleSave(request, response);
                default -> response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (SQLException exception) {
            CategoryModel category = readCategory(request);
            String error = exception.getErrorCode() == 1062
                    ? "Category name already exists. Reactivate the existing category if it is inactive."
                    : exception.getMessage();
            showFormError(request, response, category, error);
        }
    }

    private void handleSetStatus(HttpServletRequest request,
            HttpServletResponse response, String action)
            throws SQLException, IOException {
        int categoryId = ProductController.integer(
                request.getParameter("id"), 0);
        if (categoryId <= 0 || categoryDAO.findById(categoryId) == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String requestedStatus = "deactivate".equals(action)
                ? "INACTIVE" : request.getParameter("status");
        if (!"ACTIVE".equals(requestedStatus)
                && !"INACTIVE".equals(requestedStatus)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // Categories are soft-deactivated so historical product relationships remain valid.
        boolean activate = "ACTIVE".equals(requestedStatus);
        categoryDAO.setActive(categoryId, activate);
        redirectToList(request, response);
    }

    private void handleSave(HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        CategoryModel category = readCategory(request);
        if (category.getId() < 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (category.getId() > 0
                && categoryDAO.findById(category.getId()) == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Validate format first, then check database uniqueness before saving.
        String error = validateCategory(category,
                request.getParameter("status"));

        if (error != null) {
            showFormError(request, response, category, error);
            return;
        }

        if (categoryDAO.existsName(category.getName(), category.getId())) {
            showFormError(request, response, category,
                    "Category name already exists. Reactivate the existing category if it is inactive.");
            return;
        }

        categoryDAO.save(category);
        redirectToList(request, response);
    }

    private void redirectToList(HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath()
                + "/manager/categories?message=Saved");
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        request.setAttribute("categories", categoryDAO.findAll(false));
        request.getRequestDispatcher("/views/manager/category-list.jsp")
                .forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int categoryId = ProductController.integer(request.getParameter("id"), 0);
        if (categoryId < 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // The same JSP is reused: ID 0 = Add Category, ID > 0 = Edit Category.
        CategoryModel category = categoryId > 0
                ? categoryDAO.findById(categoryId)
                : new CategoryModel();
        if (category == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // An inactive category must be activated from the list before editing.
        if (categoryId > 0 && !category.isActive()) {
            response.sendRedirect(request.getContextPath()
                    + "/manager/categories");
            return;
        }

        request.setAttribute("category", category);
        request.getRequestDispatcher("/views/manager/category-form.jsp")
                .forward(request, response);
    }

    private CategoryModel readCategory(HttpServletRequest request) {
        CategoryModel category = new CategoryModel();
        category.setId(ProductController.integer(request.getParameter("id"), 0));
        category.setName(normalizeText(request.getParameter("name")));
        category.setDescription(normalizeText(
                request.getParameter("description")));
        category.setActive("ACTIVE".equals(request.getParameter("status")));
        return category;
    }

    private String validateCategory(CategoryModel category, String status) {
        // Controller validation remains authoritative even if the form is bypassed.
        if (category.getName() == null || category.getName().isBlank()) {
            return "Category name is required.";
        }

        if (category.getName().trim().length() > 25) {
            return "Category name cannot exceed 25 characters.";
        }

        if (category.getName().length() < 2) {
            return "Category name must contain at least 2 characters.";
        }

        if (!isPlainText(category.getName())) {
            return "Category name may contain letters, numbers and spaces only.";
        }

        String description = category.getDescription();
        if (description != null && description.length() > 255) {
            return "Description cannot exceed 255 characters.";
        }

        if (description != null && !description.isBlank()
                && !isDescriptionText(description)) {
            return "Description may contain letters, numbers, spaces and hyphens only.";
        }

        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            return "Invalid category status.";
        }

        return null;
    }

    private boolean isPlainText(String value) {
        return value.matches("^[\\p{L}\\p{N}]+(?: [\\p{L}\\p{N}]+)*$");
    }

    private boolean isDescriptionText(String value) {
        return value.matches("^[\\p{L}\\p{N}]+(?:[ -][\\p{L}\\p{N}]+)*$");
    }

    private String normalizeText(String value) {
        if (value == null) {
            return null;
        }
        // Store one clean space between words to avoid visually duplicate names.
        return value.trim().replaceAll("\\s+", " ");
    }

    private void showFormError(HttpServletRequest request,
            HttpServletResponse response, CategoryModel category, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("category", category);
        request.getRequestDispatcher("/views/manager/category-form.jsp")
                .forward(request, response);
    }
}
