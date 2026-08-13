package controller;

import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Set;
import model.ProductModel;

@WebServlet(name = "ProductControllerRoute", urlPatterns = {"/products"})
public class ProductController extends HttpServlet {

    private static final int MAX_SEARCH_LENGTH = 100;
    private static final Set<String> VALID_SORTS = Set.of("newest", "price-asc", "price-desc");

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = value(request.getParameter("action"), "list");
        try {
            if ("detail".equals(action)) {
                showDetail(request, response);
                return;
            }
            showList(request, response);
        } catch (SQLException e) {
            throw new ServletException("Cannot load product route.", e);
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = normalizeKeyword(request.getParameter("q"));
        String sort = normalizeSort(request.getParameter("sort"));

        String validationError = validateSearch(keyword);
        if (validationError != null) {
            request.setAttribute("products", java.util.Collections.emptyList());
            request.setAttribute("validationError", validationError);
        } else {
            request.setAttribute("products", productDAO.findPublicProducts(keyword, sort));
        }

        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSort", sort);
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int productId = integer(request.getParameter("id"), 0);
        ProductModel product = productDAO.findById(productId);

        if (product == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("product", product);
        request.getRequestDispatcher("/views/product/product-detail.jsp").forward(request, response);
    }

    private String normalizeKeyword(String input) {
        if (input == null) {
            return "";
        }
        return input.trim().replaceAll("\\s+", " ");
    }

    private String normalizeSort(String input) {
        if (input == null || input.isBlank()) {
            return "newest";
        }
        return VALID_SORTS.contains(input) ? input : "newest";
    }

    private String validateSearch(String keyword) {
        if (keyword.length() > MAX_SEARCH_LENGTH) {
            return "Search keyword must not exceed 100 characters.";
        }
        for (int i = 0; i < keyword.length(); i++) {
            if (Character.isISOControl(keyword.charAt(i))) {
                return "Search keyword contains invalid characters.";
            }
        }
        return null;
    }

    static int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (Exception e) {
            return fallback;
        }
    }

    static String value(String input, String fallback) {
        return input == null || input.isBlank() ? fallback : input;
    }
}
