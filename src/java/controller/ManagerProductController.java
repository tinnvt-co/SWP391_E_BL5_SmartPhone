package controller;

import DAO.BrandDAO;
import DAO.CategoryDAO;
import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import model.ProductModel;


@WebServlet(name = "ManagerProductController", urlPatterns = {"/manager/products"})
public class ManagerProductController extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = ProductController.value(request.getParameter("action"), "list");
            if ("form".equals(action)) {
                showForm(request, response);
                return;
            }

            Integer brandId = ProductController.integerOrNull(request.getParameter("brand"));
            Integer categoryId = ProductController.integerOrNull(request.getParameter("category"));
            String keyword = request.getParameter("q");
            String sort = request.getParameter("sort");

            var products = productDAO.findAll(
                    keyword, brandId, categoryId, sort, false);

            request.setAttribute("products", products);
            request.setAttribute("total", products.size());
            request.setAttribute("active", productDAO.countActive());
            request.setAttribute("outOfStock", productDAO.countOutOfStock());
            request.setAttribute("brands", brandDAO.findAll(true));
            request.setAttribute("categories", categoryDAO.findAll(true));
            request.setAttribute("selectedBrand", brandId);
            request.setAttribute("selectedCategory", categoryId);
            request.getRequestDispatcher("/views/manager/product-list.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load product management", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = ProductController.value(request.getParameter("action"), "save");

        try {
            if ("deactivate".equals(action)) {
                int productId = ProductController.integer(request.getParameter("id"), 0);
                productDAO.deactivate(productId);
                redirect(response, request, "Product deactivated");
                return;
            }

            ProductModel product = read(request);
            String validationError = validate(product);
            if (validationError != null) {
                forwardFormWithError(request, response, product, validationError);
                return;
            }

            productDAO.save(product);
            redirect(response, request, "Product saved");
        } catch (SQLException exception) {
            ProductModel product = read(request);
            forwardFormWithError(request, response, product, friendly(exception));
        }
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int productId = ProductController.integer(request.getParameter("id"), 0);
        ProductModel product = productId > 0
                ? productDAO.findById(productId)
                : new ProductModel();

        request.setAttribute("product", product);
        loadChoices(request);
        request.getRequestDispatcher("/views/manager/product-form.jsp")
                .forward(request, response);
    }

    private void loadChoices(HttpServletRequest request) throws SQLException {
        request.setAttribute("brands", brandDAO.findAll(true));
        request.setAttribute("categories", categoryDAO.findAll(true));
    }

    private ProductModel read(HttpServletRequest request) {
        ProductModel product = new ProductModel();
        product.setId(ProductController.integer(request.getParameter("id"), 0));
        product.setName(request.getParameter("name"));
        product.setDescription(request.getParameter("description"));

        int releaseYear = ProductController.integer(
                request.getParameter("releaseYear"), 0);
        product.setReleaseYear(releaseYear == 0 ? null : releaseYear);

        product.setRating(ProductController.integer(request.getParameter("rating"), 0));
        product.setWarrantyMonths(ProductController.integer(
                request.getParameter("warrantyMonths"), 12));
        product.setBarcode(request.getParameter("barcode"));
        product.setSku(request.getParameter("sku"));
        product.setSellingPrice(ProductController.integer(
                request.getParameter("sellingPrice"), 0));
        product.setLatestCost(ProductController.integer(
                request.getParameter("latestCost"), 0));
        product.setImage(request.getParameter("image"));
        product.setCategoryId(ProductController.integer(
                request.getParameter("categoryId"), 0));
        product.setBrandId(ProductController.integer(
                request.getParameter("brandId"), 0));
        product.setStock(ProductController.integer(request.getParameter("stock"), 0));
        product.setStatus(ProductController.value(
                request.getParameter("status"), "ACTIVE"));
        return product;
    }

    private String validate(ProductModel product) {
        if (product.getName() == null || product.getName().isBlank()) {
            return "Product name is required.";
        }
        if (product.getName().trim().length() > 50) {
            return "Product name cannot exceed 50 characters.";
        }
        if (product.getDescription() != null && product.getDescription().length() > 255) {
            return "Description cannot exceed 255 characters.";
        }
        if (product.getBarcode() == null || product.getBarcode().isBlank()) {
            return "Barcode is required.";
        }
        if (product.getSku() == null || product.getSku().isBlank()) {
            return "SKU is required.";
        }
        if (product.getBrandId() == 0 || product.getCategoryId() == 0) {
            return "Brand and category are required.";
        }
        if (product.getSellingPrice() < 0
                || product.getLatestCost() < 0
                || product.getStock() < 0) {
            return "Price, cost and stock cannot be negative.";
        }
        return null;
    }

    private void forwardFormWithError(HttpServletRequest request,
            HttpServletResponse response, ProductModel product, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("product", product);
        try {
            loadChoices(request);
        } catch (SQLException ignored) {
        }
        request.getRequestDispatcher("/views/manager/product-form.jsp")
                .forward(request, response);
    }

    private String friendly(SQLException exception) {
        if (exception.getErrorCode() == 1062) {
            return "Product name, SKU or barcode already exists.";
        }
        return "Database error: " + exception.getMessage();
    }

    private void redirect(HttpServletResponse response, HttpServletRequest request,
            String message) throws IOException {
        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath()
                + "/manager/products?message=" + encodedMessage);
    }
}
