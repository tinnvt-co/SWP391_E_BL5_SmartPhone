package controller;

import DAO.BrandDAO;
import DAO.CategoryDAO;
import DAO.FeedbackDAO;
import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;
import java.util.Map;
import model.CategoryModel;
import model.FeedbackWithReplies;
import model.ProductModel;

public class ProductController extends HttpServlet {

    private static final int MAX_SEARCH_LENGTH = 100;
    private static final int PAGE_SIZE = 12;
    private static final Set<String> VALID_SORTS = Set.of(
            "newest", "price-asc", "price-desc");
    private static final Set<String> VALID_PRICE_RANGES = Set.of(
            "under-5m", "5m-10m", "10m-20m", "over-20m");
    private final ProductDAO productDAO = new ProductDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = value(request.getParameter("action"), "list");
            if ("detail".equals(action)) {
                showDetail(request, response);
                return;
            }

            Integer brandId = integerOrNull(request.getParameter("brand"));
            Integer categoryId = integerOrNull(request.getParameter("category"));
            String keyword = normalizeKeyword(request.getParameter("q"));
            String sort = normalizeSort(request.getParameter("sort"));
            String priceRange = normalizePriceRange(
                    request.getParameter("priceRange"));
            int requestedPage = Math.max(1, integer(request.getParameter("page"), 1));

            String validationError = validateSearch(keyword);
            if (validationError != null) {
                request.setAttribute("products", java.util.Collections.emptyList());
                request.setAttribute("validationError", validationError);
                request.setAttribute("totalProducts", 0);
                request.setAttribute("currentPage", 1);
                request.setAttribute("totalPages", 1);
            } else {
                int totalProducts = productDAO.countAll(
                        keyword, brandId, categoryId, priceRange, true);
                int totalPages = Math.max(1,
                        (int) Math.ceil(totalProducts / (double) PAGE_SIZE));
                int currentPage = Math.min(requestedPage, totalPages);
                int offset = (currentPage - 1) * PAGE_SIZE;
                int startPage = Math.max(1, currentPage - 2);
                int endPage = Math.min(totalPages, currentPage + 2);

                request.setAttribute("products",
                        productDAO.findAll(keyword, brandId, categoryId,
                                priceRange, sort, true, PAGE_SIZE, offset));
                request.setAttribute("totalProducts", totalProducts);
                request.setAttribute("currentPage", currentPage);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("startPage", startPage);
                request.setAttribute("endPage", endPage);
            }

            List<CategoryModel> categories = categoryDAO.findAll(true);
            String catalogTitle = "All Smartphones";
            String selectedCategoryName = null;
            if (categoryId != null) {
                for (CategoryModel category : categories) {
                    if (category.getId() == categoryId) {
                        selectedCategoryName = category.getName();
                        catalogTitle = category.getName() + " Collection";
                        break;
                    }
                }
            }

            request.setAttribute("brands", brandDAO.findAll(true));
            request.setAttribute("categories", categories);
            request.setAttribute("selectedBrand", brandId);
            request.setAttribute("selectedCategory", categoryId);
            request.setAttribute("selectedCategoryName", selectedCategoryName);
            request.setAttribute("catalogTitle", catalogTitle);
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedSort", sort);
            request.setAttribute("selectedPriceRange", priceRange);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.getRequestDispatcher("/views/public/product-list.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException(
                    "Cannot load products from database_swp391", exception);
        }
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int productId = integer(request.getParameter("id"), 0);
        ProductModel product = productDAO.findById(productId);

        if (product == null || !product.isActive()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        List<FeedbackWithReplies> reviews = feedbackDAO.loadForProduct(productId);
        Map<String, Double> aggregate = feedbackDAO.aggregateForProduct(productId);
        double avgRating = aggregate.getOrDefault("avg", 0.0);
        int reviewCount = aggregate.getOrDefault("count", 0.0).intValue();

        request.setAttribute("product", product);
        request.setAttribute("reviews", reviews);
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("feedbackCount", reviewCount);
        request.getRequestDispatcher("/views/public/product-detail.jsp")
                .forward(request, response);
    }

    static int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    static double parseDecimal(String input, double fallback) {
        try {
            return Double.parseDouble(input);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    static Integer integerOrNull(String input) {
        int result = integer(input, 0);
        return result > 0 ? result : null;
    }

    static String value(String input, String fallback) {
        return input == null || input.isBlank() ? fallback : input;
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

    static String normalizePriceRange(String input) {
        if (input == null || input.isBlank()) {
            return "";
        }
        return VALID_PRICE_RANGES.contains(input) ? input : "";
    }

    private String validateSearch(String keyword) {
        if (keyword.length() > MAX_SEARCH_LENGTH) {
            return "Search keyword must not exceed 100 characters.";
        }
        for (int index = 0; index < keyword.length(); index++) {
            if (Character.isISOControl(keyword.charAt(index))) {
                return "Search keyword contains invalid characters.";
            }
        }
        return null;
    }
}
