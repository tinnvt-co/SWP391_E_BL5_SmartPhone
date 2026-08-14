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
import java.util.HashSet;
import java.util.Set;
import model.ProductModel;
import model.ProductVariantModel;

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
        readVariants(request, product);
        return product;
    }

    private void readVariants(HttpServletRequest request, ProductModel product) {
        String[] ramValues = request.getParameterValues("variantRam");
        if (ramValues == null) {
            return;
        }

        for (int index = 0; index < ramValues.length; index++) {
            ProductVariantModel variant = new ProductVariantModel();
            variant.setId(integerAt(request, "variantId", index));
            variant.setProductId(product.getId());
            variant.setRamGb(integerAt(request, "variantRam", index));
            variant.setStorageGb(integerAt(request, "variantStorage", index));
            variant.setColorName(valueAt(request, "variantColorName", index));
            variant.setSku(valueAt(request, "variantSku", index));
            variant.setBarcode(valueAt(request, "variantBarcode", index));
            variant.setSellingPrice(integerAt(request, "variantSellingPrice", index));
            variant.setLatestCost(integerAt(request, "variantLatestCost", index));
            variant.setStock(integerAt(request, "variantStock", index));
            variant.setImage(valueAt(request, "variantImage", index));
            variant.setBackImage(valueAt(request, "variantBackImage", index));
            product.getVariants().add(variant);
        }
    }

    private int integerAt(HttpServletRequest request, String name, int index) {
        return ProductController.integer(valueAt(request, name, index), 0);
    }

    private String valueAt(HttpServletRequest request, String name, int index) {
        String[] values = request.getParameterValues(name);
        return values != null && index < values.length ? values[index] : "";
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
        if (product.getReleaseYear() != null
                && (product.getReleaseYear() < 2000 || product.getReleaseYear() > 2100)) {
            return "Release year must be from 2000 to 2100.";
        }
        if (product.getWarrantyMonths() < 0) {
            return "Warranty period cannot be negative.";
        }
        if (product.getRating() < 0 || product.getRating() > 5) {
            return "Rating must be from 0 to 5.";
        }
        if (!"ACTIVE".equals(product.getStatus())
                && !"INACTIVE".equals(product.getStatus())) {
            return "Invalid product status.";
        }
        if (product.getBrandId() == 0 || product.getCategoryId() == 0) {
            return "Brand and category are required.";
        }
        if (product.getVariants().isEmpty()) {
            return "Add at least one product variant.";
        }

        Set<String> options = new HashSet<>();
        Set<String> skus = new HashSet<>();
        Set<String> barcodes = new HashSet<>();
        Set<String> images = new HashSet<>();

        for (int index = 0; index < product.getVariants().size(); index++) {
            ProductVariantModel variant = product.getVariants().get(index);
            String row = "Variant " + (index + 1) + ": ";
            if (variant.getRamGb() <= 0 || variant.getStorageGb() <= 0) {
                return row + "RAM and storage must be greater than zero.";
            }
            if (variant.getColorName() == null || variant.getColorName().isBlank()) {
                return row + "color name is required.";
            }
            if (variant.getColorName().trim().length() > 50) {
                return row + "color name cannot exceed 50 characters.";
            }
            if (variant.getSku() == null || variant.getSku().isBlank()
                    || variant.getBarcode() == null || variant.getBarcode().isBlank()) {
                return row + "SKU and barcode are required.";
            }
            if (variant.getSellingPrice() < 0 || variant.getLatestCost() < 0
                    || variant.getStock() < 0) {
                return row + "price, cost and stock cannot be negative.";
            }

            String imageError = validateImage(row, variant.getImage(), "front");
            if (imageError != null) {
                return imageError;
            }
            imageError = validateImage(row, variant.getBackImage(), "back");
            if (imageError != null) {
                return imageError;
            }

            String optionKey = variant.getRamGb() + "|" + variant.getStorageGb()
                    + "|" + variant.getColorName().trim().toLowerCase();
            if (!options.add(optionKey)) {
                return row + "RAM, storage and color duplicate another variant.";
            }
            if (!skus.add(variant.getSku().trim().toLowerCase())) {
                return row + "SKU duplicates another variant.";
            }
            if (!barcodes.add(variant.getBarcode().trim().toLowerCase())) {
                return row + "barcode duplicates another variant.";
            }
            if (!images.add(variant.getImage().trim().toLowerCase())) {
                return row + "front image name duplicates another variant.";
            }
        }
        return null;
    }

    private String validateImage(String row, String imageName, String view) {
        if (imageName == null || imageName.isBlank()) {
            return row + view + " image file name is required.";
        }
        String name = imageName.trim();
        if (!name.matches("(?i)^[a-z0-9][a-z0-9._-]*\\.(webp|png|jpg|jpeg)$")) {
            return row + view + " image must be a file name ending in webp, png, jpg or jpeg.";
        }
        try {
            if (getServletContext().getResource(
                    "/assets/images/products/" + name) == null) {
                return row + view + " image does not exist in assets/images/products.";
            }
        } catch (java.net.MalformedURLException exception) {
            return row + "invalid " + view + " image file name.";
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
            return "Product name, variant option, SKU, barcode or front image name already exists.";
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
