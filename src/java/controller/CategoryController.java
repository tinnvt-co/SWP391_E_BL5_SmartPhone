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
    private final CategoryDAO dao = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            if ("form".equals(req.getParameter("action"))) {
                int id = ProductController.integer(req.getParameter("id"), 0);
                req.setAttribute("category", id > 0 ? dao.findById(id) : new CategoryModel());
                req.getRequestDispatcher("/views/manager/category-form.jsp").forward(req, resp);
                return;
            }
            showList(req, resp);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load categories", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            if ("deactivate".equals(req.getParameter("action"))) {
                dao.deactivate(ProductController.integer(req.getParameter("id"), 0));
            } else {
                CategoryModel category = read(req);
                if (category.getName() == null || category.getName().isBlank()) {
                    req.setAttribute("error", "Category name is required.");
                    req.setAttribute("category", category);
                    req.getRequestDispatcher("/views/manager/category-form.jsp").forward(req, resp);
                    return;
                }
                dao.save(category);
            }
            resp.sendRedirect(req.getContextPath() + "/manager/categories?message=Saved");
        } catch (SQLException ex) {
            req.setAttribute("error", ex.getErrorCode() == 1062 ? "Category name already exists." : ex.getMessage());
            req.setAttribute("category", read(req));
            req.getRequestDispatcher("/views/manager/category-form.jsp").forward(req, resp);
        }
    }

    private CategoryModel read(HttpServletRequest req) {
        CategoryModel category = new CategoryModel();
        category.setId(ProductController.integer(req.getParameter("id"), 0));
        category.setName(req.getParameter("name"));
        category.setDescription(req.getParameter("description"));
        category.setActive("ACTIVE".equals(req.getParameter("status")));
        return category;
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("categories", dao.findAll(false));
        req.getRequestDispatcher("/views/manager/category-list.jsp").forward(req, resp);
    }
}
