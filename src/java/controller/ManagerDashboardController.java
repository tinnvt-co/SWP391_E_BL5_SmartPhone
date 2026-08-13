package controller;

import DAO.BrandDAO;
import DAO.CategoryDAO;
import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ManagerDashboardController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("totalProducts",
                    productDAO.findAll(null, null, null, "newest", false).size());
            request.setAttribute("activeProducts", productDAO.countActive());
            request.setAttribute("outOfStockProducts", productDAO.countOutOfStock());
            request.setAttribute("totalCategories", categoryDAO.findAll(false).size());
            request.setAttribute("totalBrands", brandDAO.findAll(false).size());
            request.getRequestDispatcher("/views/manager/dashboard.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load manager dashboard", exception);
        }
    }
}
