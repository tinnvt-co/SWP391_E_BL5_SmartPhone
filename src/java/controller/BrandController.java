package controller;

import DAO.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.BrandModel;

@WebServlet(name = "BrandController", urlPatterns = {"/manager/brands"})
public class BrandController extends HttpServlet {

    private final BrandDAO brandDAO = new BrandDAO();

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
            throw new ServletException("Cannot load brands", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            String action = request.getParameter("action");

            if ("deactivate".equals(action)) {
                int brandId = ProductController.integer(request.getParameter("id"), 0);
                brandDAO.deactivate(brandId);
            } else {
                BrandModel brand = readBrand(request);
                String error = validateBrand(brand);

                if (error != null) {
                    showFormError(request, response, brand, error);
                    return;
                }

                brandDAO.save(brand);
            }

            response.sendRedirect(request.getContextPath()
                    + "/manager/brands?message=Saved");
        } catch (SQLException exception) {
            BrandModel brand = readBrand(request);
            String error = exception.getErrorCode() == 1062
                    ? "Brand name already exists."
                    : exception.getMessage();
            showFormError(request, response, brand, error);
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        request.setAttribute("brands", brandDAO.findAll(false));
        request.getRequestDispatcher("/views/manager/brand-list.jsp")
                .forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int brandId = ProductController.integer(request.getParameter("id"), 0);
        BrandModel brand = brandId > 0
                ? brandDAO.findById(brandId)
                : new BrandModel();

        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/views/manager/brand-form.jsp")
                .forward(request, response);
    }

    private BrandModel readBrand(HttpServletRequest request) {
        BrandModel brand = new BrandModel();
        brand.setId(ProductController.integer(request.getParameter("id"), 0));
        brand.setName(request.getParameter("name"));
        brand.setDescription(request.getParameter("description"));
        brand.setActive("ACTIVE".equals(request.getParameter("status")));
        return brand;
    }

    private String validateBrand(BrandModel brand) {
        if (brand.getName() == null || brand.getName().isBlank()) {
            return "Brand name is required.";
        }

        if (brand.getName().trim().length() > 50) {
            return "Brand name cannot exceed 50 characters.";
        }

        return null;
    }

    private void showFormError(HttpServletRequest request,
            HttpServletResponse response, BrandModel brand, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/views/manager/brand-form.jsp")
                .forward(request, response);
    }
}
