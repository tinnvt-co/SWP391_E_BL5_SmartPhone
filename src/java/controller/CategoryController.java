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
        try {
            String action = request.getParameter("action");

            if ("form".equals(action)) {
                showForm(request, response);
            } else {
                showList(request, response);
            }
        } catch (SQLException exception) {
            throw new ServletException("Cannot load categories", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            String action = request.getParameter("action");

            if ("deactivate".equals(action)) {
                int categoryId = ProductController.integer(
                        request.getParameter("id"), 0);
                categoryDAO.deactivate(categoryId);
            } else {
                CategoryModel category = readCategory(request);
                String error = validateCategory(category);

                if (error != null) {
                    showFormError(request, response, category, error);
                    return;
                }

                categoryDAO.save(category);
            }

            response.sendRedirect(request.getContextPath()
                    + "/manager/categories?message=Saved");
        } catch (SQLException exception) {
            CategoryModel category = readCategory(request);
            String error = exception.getErrorCode() == 1062
                    ? "Category name already exists."
                    : exception.getMessage();
            showFormError(request, response, category, error);
        }
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
        CategoryModel category = categoryId > 0
                ? categoryDAO.findById(categoryId)
                : new CategoryModel();

        request.setAttribute("category", category);
        request.getRequestDispatcher("/views/manager/category-form.jsp")
                .forward(request, response);
    }

    private CategoryModel readCategory(HttpServletRequest request) {
        CategoryModel category = new CategoryModel();
        category.setId(ProductController.integer(request.getParameter("id"), 0));
        category.setName(request.getParameter("name"));
        category.setDescription(request.getParameter("description"));
        category.setActive("ACTIVE".equals(request.getParameter("status")));
        return category;
    }

    private String validateCategory(CategoryModel category) {
        if (category.getName() == null || category.getName().isBlank()) {
            return "Category name is required.";
        }

        if (category.getName().trim().length() > 25) {
            return "Category name cannot exceed 25 characters.";
        }

        return null;
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
