package controller;

import DAO.BrandDAO;
import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashSet;
import java.util.List;
import model.BrandModel;
import model.ProductModel;

@WebServlet(name = "BrandController", urlPatterns = {"/manager/brands"})
public class BrandController extends HttpServlet {

    private final BrandDAO brandDAO = new BrandDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private static final int PRODUCTS_PER_PAGE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = request.getParameter("action");

            if ("form".equals(action)) {
                showForm(request, response);
            } else if ("products".equals(action)) {
                showProducts(request, response);
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
        String action = request.getParameter("action");

        try {
            if ("deactivate".equals(action)) {
                int brandId = ProductController.integer(request.getParameter("id"), 0);
                if (brandId <= 0 || brandDAO.findById(brandId) == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                brandDAO.deactivate(brandId);
            } else if ("move-products".equals(action)) {
                moveProducts(request, response);
                return;
            } else {
                if (!"save".equals(action)) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                BrandModel brand = readBrand(request);
                String error = validateBrand(brand,
                        request.getParameter("status"));

                if (error != null) {
                    showFormError(request, response, brand, error);
                    return;
                }

                if (brandDAO.existsName(brand.getName(), brand.getId())) {
                    showFormError(request, response, brand,
                            "Brand name already exists.");
                    return;
                }

                brandDAO.save(brand);
            }

            response.sendRedirect(request.getContextPath()
                    + "/manager/brands?message=Saved");
        } catch (SQLException exception) {
            if ("move-products".equals(action)) {
                throw new ServletException("Cannot move products to brand",
                        exception);
            }
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
        if (brand == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/views/manager/brand-form.jsp")
                .forward(request, response);
    }

    private BrandModel readBrand(HttpServletRequest request) {
        BrandModel brand = new BrandModel();
        brand.setId(ProductController.integer(request.getParameter("id"), 0));
        brand.setName(normalizeText(request.getParameter("name")));
        brand.setDescription(normalizeText(
                request.getParameter("description")));
        brand.setActive("ACTIVE".equals(request.getParameter("status")));
        return brand;
    }

    private String validateBrand(BrandModel brand, String status) {
        if (brand.getName() == null || brand.getName().isBlank()) {
            return "Brand name is required.";
        }

        if (brand.getName().trim().length() > 50) {
            return "Brand name cannot exceed 50 characters.";
        }

        if (brand.getName().length() < 2) {
            return "Brand name must contain at least 2 characters.";
        }

        if (!isPlainText(brand.getName())) {
            return "Brand name may contain letters, numbers and spaces only.";
        }

        String description = brand.getDescription();
        if (description != null && description.length() > 255) {
            return "Description cannot exceed 255 characters.";
        }

        if (description != null && !description.isBlank()
                && !isPlainText(description)) {
            return "Description may contain letters, numbers and spaces only.";
        }

        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            return "Invalid brand status.";
        }

        return null;
    }

    private void showProducts(HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int brandId = ProductController.integer(request.getParameter("id"), 0);
        BrandModel brand = brandId > 0 ? brandDAO.findById(brandId) : null;
        if (brand == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String keyword = normalizeText(request.getParameter("q"));
        int totalProducts = productDAO.countAll(keyword, brandId, null, false);
        int totalPages = Math.max(1,
                (int) Math.ceil(totalProducts / (double) PRODUCTS_PER_PAGE));
        int currentPage = ProductController.integer(
                request.getParameter("page"), 1);
        currentPage = Math.max(1, Math.min(currentPage, totalPages));

        List<ProductModel> products = productDAO.findAll(keyword, brandId,
                null, "newest", false, PRODUCTS_PER_PAGE,
                (currentPage - 1) * PRODUCTS_PER_PAGE);
        List<ProductModel> otherProducts = productDAO.findAll(
                null, null, null, "newest", false);
        otherProducts.removeIf(product -> product.getBrandId() == brandId);

        request.setAttribute("selectedBrand", brand);
        request.setAttribute("products", products);
        request.setAttribute("movableProducts", otherProducts);
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("pageStart", totalProducts == 0 ? 0
                : (currentPage - 1) * PRODUCTS_PER_PAGE + 1);
        request.setAttribute("pageEnd", Math.min(
                currentPage * PRODUCTS_PER_PAGE, totalProducts));
        request.getRequestDispatcher("/views/manager/brand-product-list.jsp")
                .forward(request, response);
    }

    private void moveProducts(HttpServletRequest request,
            HttpServletResponse response) throws SQLException, IOException {
        int brandId = ProductController.integer(
                request.getParameter("brandId"), 0);
        BrandModel brand = brandId > 0 ? brandDAO.findById(brandId) : null;
        if (brand == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (!brand.isActive()) {
            redirectToProducts(request, response, brandId,
                    "Activate this brand before moving products to it.");
            return;
        }

        LinkedHashSet<Integer> productIds = new LinkedHashSet<>();
        String[] submittedIds = request.getParameterValues("productIds");
        if (submittedIds != null) {
            for (String submittedId : submittedIds) {
                int productId = ProductController.integer(submittedId, 0);
                if (productId > 0) {
                    productIds.add(productId);
                }
            }
        }
        if (productIds.isEmpty()) {
            redirectToProducts(request, response, brandId,
                    "Select at least one product to move.");
            return;
        }

        int movedProducts = productDAO.moveProductsToBrand(brandId, productIds);
        redirectToProducts(request, response, brandId,
                movedProducts + " product(s) moved to " + brand.getName() + ".");
    }

    private void redirectToProducts(HttpServletRequest request,
            HttpServletResponse response, int brandId, String message)
            throws IOException {
        response.sendRedirect(request.getContextPath()
                + "/manager/brands?action=products&id=" + brandId
                + "&message=" + URLEncoder.encode(message,
                        StandardCharsets.UTF_8));
    }

    private boolean isPlainText(String value) {
        return value.matches("^[\\p{L}\\p{N}]+(?: [\\p{L}\\p{N}]+)*$");
    }

    private String normalizeText(String value) {
        if (value == null) {
            return null;
        }
        return value.trim().replaceAll("\\s+", " ");
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
