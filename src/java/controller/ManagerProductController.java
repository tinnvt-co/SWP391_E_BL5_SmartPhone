package controller;

import DAO.BrandDAO;
import DAO.CategoryDAO;
import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.Year;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.CategoryModel;
import model.BrandModel;
import model.ProductModel;
import model.ProductVariantModel;
import validation.ProductBrandValidator;

@WebServlet(name = "ManagerProductController", urlPatterns = {"/manager/products"})
// Multipart limits protect the server: 5 MB per image and 60 MB per form request.
@MultipartConfig(fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 60 * 1024 * 1024)
public class ManagerProductController extends HttpServlet {

    private static final String IMAGE_FOLDER = "/assets/images/products";
    private static final int PAGE_SIZE = 10;
    private static final int MAX_PRICE = 500_000_000;
    private static final List<Integer> RAM_OPTIONS = List.of(
            2, 3, 4, 6, 8, 12, 16, 18, 24);
    private static final List<Integer> STORAGE_OPTIONS = List.of(
            32, 64, 128, 256, 512, 1024, 2048);

    private final ProductDAO productDAO = new ProductDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // One servlet handles the list, Add/Edit form, and category picker by action.
        String action = ProductController.value(
                request.getParameter("action"), "list");

        try {
            switch (action) {
                case "form" -> handleForm(request, response);
                case "category-picker" -> showCategoryPicker(request, response);
                default -> handleList(request, response);
            }
        } catch (SQLException exception) {
            throw new ServletException("Cannot load product management", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // POST actions change data; an unknown action falls back to saving the form.
        String action = ProductController.value(
                request.getParameter("action"), "save");

        try {
            switch (action) {
                case "add-category-products" ->
                    addProductsToCategory(request, response);
                case "remove-category-product" ->
                    removeProductFromCategory(request, response);
                case "deactivate" -> handleDeactivate(request, response);
                case "save" -> handleSave(request, response);
                default -> handleSave(request, response);
            }
        } catch (SQLException exception) {
            throw new ServletException("Cannot process product management",
                    exception);
        }
    }

    private void handleForm(HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        Integer categoryId = ProductController.integerOrNull(
                request.getParameter("category"));
        int productId = ProductController.integer(
                request.getParameter("id"), 0);

        // category + no product ID means "select existing products for a category",
        // while a product ID (or no category) means the normal Add/Edit form.
        if (categoryId != null && productId == 0) {
            showCategoryPicker(request, response);
            return;
        }

        showForm(request, response);
    }

    private void handleList(HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        // Read optional filters first; null values mean that filter is not applied.
        Integer brandId = ProductController.integerOrNull(
                request.getParameter("brand"));
        Integer categoryId = ProductController.integerOrNull(
                request.getParameter("category"));
        boolean fromCategory = categoryId != null
                && "category".equals(request.getParameter("from"));
        String keyword = request.getParameter("q");
        String sort = request.getParameter("sort");
        String priceRange = ProductController.normalizePriceRange(
                request.getParameter("priceRange"));

        // Count and data queries use the same filters so pagination stays correct.
        int filteredTotal = productDAO.countAll(
                keyword, brandId, categoryId, priceRange, false);
        int totalPages = Math.max(1,
                (int) Math.ceil((double) filteredTotal / PAGE_SIZE));
        int currentPage = ProductController.integer(
                request.getParameter("page"), 1);
        currentPage = Math.max(1, Math.min(currentPage, totalPages));

        // OFFSET skips previous pages; PAGE_SIZE limits this page to 10 products.
        List<ProductModel> products = productDAO.findAll(
                keyword, brandId, categoryId, priceRange, sort, false,
                PAGE_SIZE, (currentPage - 1) * PAGE_SIZE);
        List<CategoryModel> categories = categoryDAO.findAll(true);

        request.setAttribute("products", products);
        request.setAttribute("filteredTotal", filteredTotal);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageStart", filteredTotal == 0 ? 0
                : (currentPage - 1) * PAGE_SIZE + 1);
        request.setAttribute("pageEnd", Math.min(
                currentPage * PAGE_SIZE, filteredTotal));
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("selectedPriceRange", priceRange);
        request.setAttribute("brands", brandDAO.findAll(true));
        request.setAttribute("categories", categories);
        request.setAttribute("selectedBrand", brandId);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("fromCategory", fromCategory);

        loadSelectedCategory(request, categoryId, fromCategory);

        request.getRequestDispatcher("/views/manager/product-list.jsp")
                .forward(request, response);
    }

    private void loadSelectedCategory(HttpServletRequest request,
            Integer categoryId, boolean fromCategory) throws SQLException {
        if (categoryId == null) {
            return;
        }

        CategoryModel selectedCategory = categoryDAO.findById(categoryId);
        if (selectedCategory != null) {
            request.setAttribute("selectedCategoryName",
                    selectedCategory.getName());
        }

        if (fromCategory) {
            Set<Integer> assignedIds = categoryDAO.findProductIds(categoryId);
            List<ProductModel> availableProducts = productDAO.findAll(
                    null, null, null, "newest", false, assignedIds);
            request.setAttribute("availableCategoryProducts",
                    availableProducts);
        }
    }

    private void handleDeactivate(HttpServletRequest request,
            HttpServletResponse response) throws SQLException, IOException {
        int productId = ProductController.integer(
                request.getParameter("id"), 0);
        productDAO.deactivate(productId);
        redirect(response, request, "Product deactivated");
    }

    private void handleSave(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        List<Path> uploadedFiles = new ArrayList<>();
        ProductModel product = null;

        try {
            // Validation order: map form -> business rules -> database uniqueness
            // -> brand warning -> image files -> database transaction.
            product = read(request);
            String validationError = validate(product);
            if (validationError != null) {
                forwardFormWithError(request, response, product, validationError);
                return;
            }

            String duplicateError = validateUniqueData(product);
            if (duplicateError != null) {
                forwardFormWithError(request, response, product, duplicateError);
                return;
            }

            // A suspicious brand is a warning, not a hard error, because model names
            // are not always sufficient to determine the real manufacturer.
            String brandWarning = brandMismatchWarning(product);
            if (brandWarning != null
                    && !"true".equals(request.getParameter(
                            "confirmBrandMismatch"))) {
                forwardFormWithBrandWarning(request, response, product,
                        brandWarning);
                return;
            }

            String uploadError = saveUploadedImages(request, product, uploadedFiles);
            if (uploadError != null) {
                deleteUploadedFiles(uploadedFiles);
                forwardFormWithError(request, response, product, uploadError);
                return;
            }

            // DAO.save inserts/updates the product, categories and variants atomically.
            productDAO.save(product);
            redirect(response, request, "Product saved");
        } catch (IllegalStateException exception) {
            deleteUploadedFiles(uploadedFiles);
            if (product == null) {
                product = new ProductModel();
            }
            forwardFormWithError(request, response, product,
                    "Each image must be 5 MB or smaller.");
        } catch (SQLException exception) {
            deleteUploadedFiles(uploadedFiles);
            if (product == null) {
                product = read(request);
            }
            forwardFormWithError(request, response, product, friendly(exception));
        }
    }

    private void showCategoryPicker(HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int categoryId = ProductController.integer(
                request.getParameter("category"), 0);
        CategoryModel category = categoryId > 0
                ? categoryDAO.findById(categoryId) : null;
        if (category == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String keyword = request.getParameter("q");
        Set<Integer> assignedIds = categoryDAO.findProductIds(categoryId);
        List<ProductModel> allAvailableProducts = productDAO.findAll(
                keyword, null, null, "newest", false, assignedIds);

        int filteredTotal = allAvailableProducts.size();
        int totalPages = Math.max(1,
                (int) Math.ceil((double) filteredTotal / PAGE_SIZE));
        int currentPage = ProductController.integer(
                request.getParameter("page"), 1);
        currentPage = Math.max(1, Math.min(currentPage, totalPages));
        int fromIndex = (currentPage - 1) * PAGE_SIZE;
        int toIndex = Math.min(fromIndex + PAGE_SIZE, filteredTotal);
        List<ProductModel> availableProducts = new ArrayList<>(
                allAvailableProducts.subList(fromIndex, toIndex));

        request.setAttribute("category", category);
        request.setAttribute("keyword", keyword);
        request.setAttribute("availableProducts", availableProducts);
        request.setAttribute("filteredTotal", filteredTotal);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageStart", filteredTotal == 0 ? 0 : fromIndex + 1);
        request.setAttribute("pageEnd", toIndex);
        request.getRequestDispatcher(
                "/views/manager/category-product-picker.jsp")
                .forward(request, response);
    }

    private void addProductsToCategory(HttpServletRequest request,
            HttpServletResponse response) throws SQLException, IOException {
        int categoryId = ProductController.integer(
                request.getParameter("categoryId"), 0);
        if (categoryDAO.findById(categoryId) == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String[] values = request.getParameterValues("productIds");
        List<Integer> productIds = new ArrayList<>();
        Set<Integer> uniqueIds = new HashSet<>();
        if (values != null) {
            for (String value : values) {
                int productId = ProductController.integer(value, 0);
                if (productId > 0 && uniqueIds.add(productId)) {
                    productIds.add(productId);
                }
            }
        }

        if (productIds.isEmpty()) {
            redirectToCategoryPicker(response, request, categoryId,
                    "Please select at least one product.");
            return;
        }

        categoryDAO.addProducts(categoryId, productIds);
        redirectToCategoryProducts(response, request, categoryId,
                productIds.size() + " product(s) added to category.");
    }

    private void removeProductFromCategory(HttpServletRequest request,
            HttpServletResponse response) throws SQLException, IOException {
        int categoryId = ProductController.integer(
                request.getParameter("categoryId"), 0);
        int productId = ProductController.integer(
                request.getParameter("productId"), 0);
        if (categoryId <= 0 || productId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        boolean removed = categoryDAO.removeProduct(categoryId, productId);
        redirectToCategoryProducts(response, request, categoryId,
                removed ? "Product removed from category."
                        : "Product was not in this category.");
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int productId = ProductController.integer(request.getParameter("id"), 0);
        // ID 0 creates an empty model for Add; ID > 0 loads the model for Edit.
        ProductModel product = productId > 0
                ? productDAO.findById(productId)
                : new ProductModel();
        if (product == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (productId == 0) {
            int categoryId = ProductController.integer(
                    request.getParameter("category"), 0);
            CategoryModel category = categoryId > 0
                    ? categoryDAO.findById(categoryId) : null;
            if (category != null && category.isActive()) {
                product.getCategories().add(category);
            }
        }

        request.setAttribute("product", product);
        request.setAttribute("selectedCategoryIds",
                new HashSet<>(product.getCategoryIds()));
        loadChoices(request);
        request.getRequestDispatcher("/views/manager/product-form.jsp")
                .forward(request, response);
    }

    private void loadChoices(HttpServletRequest request) throws SQLException {
        request.setAttribute("brands", brandDAO.findAll(true));
        request.setAttribute("categories", categoryDAO.findAll(true));
        request.setAttribute("ramOptions", RAM_OPTIONS);
        request.setAttribute("storageOptions", STORAGE_OPTIONS);
        request.setAttribute("maxReleaseYear", Year.now().getValue());
    }

    private ProductModel read(HttpServletRequest request) {
        // Convert all submitted form parameters into one ProductModel before validation.
        ProductModel product = new ProductModel();
        product.setId(ProductController.integer(request.getParameter("id"), 0));
        product.setName(normalizeText(request.getParameter("name")));
        product.setDescription(normalizeText(request.getParameter("description")));

        int releaseYear = ProductController.integer(
                request.getParameter("releaseYear"), 0);
        product.setReleaseYear(releaseYear == 0 ? null : releaseYear);

        product.setRating(0);
        product.setWarrantyMonths(ProductController.integer(
                request.getParameter("warrantyMonths"), 12));
        product.setSku(request.getParameter("sku"));
        product.setSellingPrice(ProductController.integer(
                request.getParameter("sellingPrice"), 0));
        product.setLatestCost(ProductController.integer(
                request.getParameter("latestCost"), 0));
        product.setImage(request.getParameter("image"));
        product.setBrandId(ProductController.integer(
                request.getParameter("brandId"), 0));
        readCategories(request, product);
        product.setStock(ProductController.integer(request.getParameter("stock"), 0));
        product.setStatus(ProductController.value(
                request.getParameter("status"), "ACTIVE"));
        readVariants(request, product);
        return product;
    }

    private void readCategories(HttpServletRequest request, ProductModel product) {
        String[] values = request.getParameterValues("categoryIds");
        if (values == null) {
            return;
        }

        // A product may have many categories; Set prevents duplicate category IDs.
        Set<Integer> uniqueIds = new HashSet<>();
        for (String value : values) {
            int categoryId = ProductController.integer(value, 0);
            if (categoryId > 0 && uniqueIds.add(categoryId)) {
                CategoryModel category = new CategoryModel();
                category.setId(categoryId);
                product.getCategories().add(category);
            }
        }
    }

    private void readVariants(HttpServletRequest request, ProductModel product) {
        String[] ramValues = request.getParameterValues("variantRam");
        if (ramValues == null) {
            return;
        }

        // Variant fields are submitted as parallel arrays; the same index represents
        // one RAM/storage/color/price/images combination.
        for (int index = 0; index < ramValues.length; index++) {
            ProductVariantModel variant = new ProductVariantModel();
            variant.setId(integerAt(request, "variantId", index));
            variant.setProductId(product.getId());
            variant.setRamGb(integerAt(request, "variantRam", index));
            variant.setStorageGb(integerAt(request, "variantStorage", index));
            variant.setColorName(normalizeText(
                    valueAt(request, "variantColorName", index)));
            variant.setSellingPrice(integerAt(request, "variantSellingPrice", index));
            variant.setImage(uploadedNameAt(request, "variantImageFile",
                    "existingVariantImage", index));
            variant.setBackImage(uploadedNameAt(request, "variantBackImageFile",
                    "existingVariantBackImage", index));
            product.getVariants().add(variant);
        }
    }

    private String uploadedNameAt(HttpServletRequest request, String partName,
            String existingName, int index) {
        List<Part> parts = partsByName(request, partName);
        if (index < parts.size() && parts.get(index).getSize() > 0) {
            return safeFileName(parts.get(index).getSubmittedFileName());
        }
        // During Edit, no new upload means the current image name is kept.
        return valueAt(request, existingName, index);
    }

    private List<Part> partsByName(HttpServletRequest request, String name) {
        List<Part> result = new ArrayList<>();
        try {
            for (Part part : request.getParts()) {
                if (name.equals(part.getName())) {
                    result.add(part);
                }
            }
        } catch (IOException | ServletException exception) {
            throw new IllegalStateException(exception);
        }
        return result;
    }

    private int integerAt(HttpServletRequest request, String name, int index) {
        return ProductController.integer(valueAt(request, name, index), 0);
    }

    private String valueAt(HttpServletRequest request, String name, int index) {
        String[] values = request.getParameterValues(name);
        return values != null && index < values.length ? values[index] : "";
    }

    private String validate(ProductModel product) {
        // Server-side validation is mandatory because browser validation can be bypassed.
        // Returning the first error keeps the form flow simple and easy to explain.
        if (product.getName() == null || product.getName().isBlank()) {
            return "Product name is required.";
        }
        if (product.getName().trim().length() > 50) {
            return "Product name cannot exceed 50 characters.";
        }
        if (product.getName().length() < 2) {
            return "Product name must contain at least 2 characters.";
        }
        if (!product.getName().trim().matches(
                "^[\\p{L}\\p{N}]+(?:[ -][\\p{L}\\p{N}]+)*$")) {
            return "Product name may contain letters, numbers, spaces and hyphens only.";
        }
        if (product.getDescription() != null && product.getDescription().length() > 255) {
            return "Description cannot exceed 255 characters.";
        }
        if (product.getDescription() != null
                && (product.getDescription().contains("<")
                || product.getDescription().contains(">"))) {
            return "Description cannot contain angle brackets.";
        }
        int maxReleaseYear = Year.now().getValue();
        if (product.getReleaseYear() != null
                && (product.getReleaseYear() < 2007
                || product.getReleaseYear() > maxReleaseYear)) {
            return "Release year must be from 2007 to " + maxReleaseYear + ".";
        }
        if (product.getWarrantyMonths() < 0 || product.getWarrantyMonths() > 36) {
            return "Warranty period must be from 0 to 36 months.";
        }
        if (!"ACTIVE".equals(product.getStatus())
                && !"INACTIVE".equals(product.getStatus())) {
            return "Invalid product status.";
        }
        if (product.getBrandId() == 0) {
            return "Brand is required.";
        }
        if (product.getCategories().isEmpty()) {
            return "Select at least one category.";
        }
        if (product.getVariants().isEmpty()) {
            return "Add at least one product variant.";
        }

        // These sets detect duplicates inside the same submitted form before SQL runs.
        Set<String> options = new HashSet<>();
        Set<String> frontImages = new HashSet<>();

        for (int index = 0; index < product.getVariants().size(); index++) {
            ProductVariantModel variant = product.getVariants().get(index);
            String row = "Variant " + (index + 1) + ": ";
            if (!RAM_OPTIONS.contains(variant.getRamGb())) {
                return row + "RAM must be one of these values: "
                        + "2, 3, 4, 6, 8, 12, 16, 18 or 24 GB.";
            }
            if (!STORAGE_OPTIONS.contains(variant.getStorageGb())) {
                return row + "storage must be one of these values: "
                        + "32, 64, 128, 256, 512, 1024 or 2048 GB.";
            }
            if (variant.getColorName() == null || variant.getColorName().isBlank()) {
                return row + "color name is required.";
            }
            if (variant.getColorName().trim().length() > 50) {
                return row + "color name cannot exceed 50 characters.";
            }
            if (!variant.getColorName().trim().matches(
                    "^[\\p{L}]+(?:[ -][\\p{L}]+)*$")) {
                return row + "color name may contain letters, spaces and hyphens only.";
            }
            if (variant.getSellingPrice() <= 0) {
                return row + "selling price must be greater than 0.";
            }
            if (variant.getSellingPrice() > MAX_PRICE) {
                return row + "selling price cannot exceed 500,000,000 VND.";
            }
            String imageError = validateImage(row, variant.getImage(), "front");
            if (imageError != null) {
                return imageError;
            }
            imageError = validateImage(row, variant.getBackImage(), "back");
            if (imageError != null) {
                return imageError;
            }
            if (variant.getImage().trim().equalsIgnoreCase(
                    variant.getBackImage().trim())) {
                return row + "front image and back image must be different files.";
            }

            String optionKey = variant.getRamGb() + "|" + variant.getStorageGb()
                    + "|" + variant.getColorName().trim().toLowerCase();
            if (!options.add(optionKey)) {
                return row + "RAM, storage and color duplicate another variant.";
            }
            if (!frontImages.add(variant.getImage().trim().toLowerCase())) {
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
        return null;
    }

    private String validateUniqueData(ProductModel product) throws SQLException {
        // These rules require current database data, so they cannot be checked reliably
        // by the JSP alone. The current ID is excluded when editing the same record.
        if (productDAO.existsProductName(product.getName(), product.getId())) {
            return "Product name already exists.";
        }
        if (!brandDAO.isActive(product.getBrandId())) {
            return "Selected brand is invalid or inactive.";
        }
        if (!categoryDAO.areAllActive(product.getCategoryIds())) {
            return "One or more selected categories are invalid or inactive.";
        }

        for (int index = 0; index < product.getVariants().size(); index++) {
            ProductVariantModel variant = product.getVariants().get(index);
            String row = "Variant " + (index + 1) + ": ";

            if (productDAO.existsFrontImage(variant.getImage(), variant.getId())) {
                return row + "front image name already belongs to another product variant.";
            }
            if (product.getId() > 0 && productDAO.existsVariantOption(
                    product.getId(), variant.getRamGb(), variant.getStorageGb(),
                    variant.getColorName(), variant.getId())) {
                return row + "RAM, storage and color already exist for this product.";
            }
        }
        return null;
    }

    private String brandMismatchWarning(ProductModel product)
            throws SQLException {
        BrandModel selectedBrand = brandDAO.findById(product.getBrandId());
        if (selectedBrand == null) {
            return null;
        }

        List<String> detectedBrands = ProductBrandValidator.detectBrands(
                product.getName());
        if (detectedBrands.size() > 1) {
            return "The product name contains keywords from multiple brands: "
                    + String.join(", ", detectedBrands)
                    + ". Check the product name or choose Save anyway.";
        }
        if (!ProductBrandValidator.isMismatch(product.getName(),
                selectedBrand.getName())) {
            return null;
        }
        String detectedBrand = ProductBrandValidator.detectBrand(
                product.getName());
        return "The product name appears to belong to " + detectedBrand
                + ", but the selected brand is " + selectedBrand.getName()
                + ". Check the information or choose Save anyway.";
    }

    private String saveUploadedImages(HttpServletRequest request,
            ProductModel product, List<Path> uploadedFiles) {
        // Front and back uploads are matched to variants by their row index.
        try {
            List<Part> frontParts = partsByName(request, "variantImageFile");
            List<Part> backParts = partsByName(request, "variantBackImageFile");

            for (int index = 0; index < product.getVariants().size(); index++) {
                ProductVariantModel variant = product.getVariants().get(index);
                String row = "Variant " + (index + 1) + ": ";

                String error = saveImagePart(partAt(frontParts, index),
                        variant.getImage(), row + "front image", uploadedFiles);
                if (error != null) {
                    return error;
                }
                error = saveImagePart(partAt(backParts, index),
                        variant.getBackImage(), row + "back image", uploadedFiles);
                if (error != null) {
                    return error;
                }
            }
            return null;
        } catch (IOException exception) {
            return "Cannot save image files: " + exception.getMessage();
        }
    }

    private Part partAt(List<Part> parts, int index) {
        return index < parts.size() ? parts.get(index) : null;
    }

    private String saveImagePart(Part part, String fileName, String label,
            List<Path> uploadedFiles) throws IOException {
        if (part == null || part.getSize() == 0) {
            return imageExists(fileName) ? null
                    : label + " is required. Please choose an image file.";
        }
        if (part.getSize() > 5L * 1024 * 1024) {
            return label + " must be 5 MB or smaller.";
        }
        // Check file signatures, not only extensions, to reject renamed non-images.
        if (!validImageContent(part, fileName)) {
            return label + " must be a real JPG, JPEG, PNG or WEBP image.";
        }

        List<Path> directories = uploadDirectories();
        // Validate every target before copying so a partial upload is less likely.
        for (Path directory : directories) {
            Files.createDirectories(directory);
            Path target = directory.resolve(fileName).normalize();
            if (!target.getParent().equals(directory.normalize())) {
                return label + " has an invalid file name.";
            }
            if (Files.exists(target)) {
                return label + " file name already exists. Rename the file and try again.";
            }
        }

        for (Path directory : directories) {
            Path target = directory.resolve(fileName);
            try (InputStream input = part.getInputStream()) {
                Files.copy(input, target);
            }
            uploadedFiles.add(target);
        }
        return null;
    }

    private boolean validImageContent(Part part, String fileName) throws IOException {
        String lowerName = fileName.toLowerCase();
        byte[] header = new byte[12];
        int length;
        try (InputStream input = part.getInputStream()) {
            length = input.read(header);
        }
        if ((lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg"))) {
            return length >= 3 && (header[0] & 255) == 255
                    && (header[1] & 255) == 216 && (header[2] & 255) == 255;
        }
        if (lowerName.endsWith(".png")) {
            return length >= 8 && (header[0] & 255) == 137
                    && header[1] == 80 && header[2] == 78 && header[3] == 71
                    && header[4] == 13 && header[5] == 10
                    && header[6] == 26 && header[7] == 10;
        }
        return length >= 12 && header[0] == 'R' && header[1] == 'I'
                && header[2] == 'F' && header[3] == 'F'
                && header[8] == 'W' && header[9] == 'E'
                && header[10] == 'B' && header[11] == 'P';
    }

    private List<Path> uploadDirectories() throws IOException {
        String realPath = getServletContext().getRealPath(IMAGE_FOLDER);
        if (realPath == null) {
            throw new IOException("The image upload folder is unavailable.");
        }

        List<Path> directories = new ArrayList<>();
        // Save to the deployed folder for immediate display and to the source folder
        // so the image remains available after the next clean/redeploy.
        Path runtimeDirectory = Paths.get(realPath).toAbsolutePath().normalize();
        directories.add(runtimeDirectory);

        Path imagesDirectory = runtimeDirectory.getParent();
        Path assetsDirectory = imagesDirectory == null ? null : imagesDirectory.getParent();
        Path webDirectory = assetsDirectory == null ? null : assetsDirectory.getParent();
        if (webDirectory != null && "web".equalsIgnoreCase(
                webDirectory.getFileName().toString())) {
            Path buildDirectory = webDirectory.getParent();
            if (buildDirectory != null && "build".equalsIgnoreCase(
                    buildDirectory.getFileName().toString())) {
                Path sourceDirectory = buildDirectory.getParent().resolve(
                        "web/assets/images/products").toAbsolutePath().normalize();
                if (!sourceDirectory.equals(runtimeDirectory)) {
                    directories.add(sourceDirectory);
                }
            }
        }
        return directories;
    }

    private boolean imageExists(String fileName) {
        if (fileName == null || fileName.isBlank()) {
            return false;
        }
        try {
            return getServletContext().getResource(
                    IMAGE_FOLDER + "/" + fileName) != null;
        } catch (java.net.MalformedURLException exception) {
            return false;
        }
    }

    private String safeFileName(String submittedName) {
        if (submittedName == null || submittedName.isBlank()) {
            return "";
        }
        try {
            return Paths.get(submittedName).getFileName().toString();
        } catch (RuntimeException exception) {
            return "";
        }
    }

    private void deleteUploadedFiles(List<Path> files) {
        // Roll back files written before a later validation or database failure.
        for (Path file : files) {
            try {
                Files.deleteIfExists(file);
            } catch (IOException ignored) {
            }
        }
    }

    private void forwardFormWithError(HttpServletRequest request,
            HttpServletResponse response, ProductModel product, String error)
            throws ServletException, IOException {
        // Forward (not redirect) preserves submitted values and the error for the JSP.
        restoreExistingImageNames(request, product);
        exposeErrorLocation(request, error);
        request.setAttribute("error", error);
        request.setAttribute("product", product);
        request.setAttribute("selectedCategoryIds",
                new HashSet<>(product.getCategoryIds()));
        try {
            loadChoices(request);
        } catch (SQLException ignored) {
        }
        request.getRequestDispatcher("/views/manager/product-form.jsp")
                .forward(request, response);
    }

    private void exposeErrorLocation(HttpServletRequest request, String error) {
        // Translate the returned error into field names so the JSP can draw red borders
        // on the exact invalid input without duplicating business validation in JavaScript.
        Set<String> errorFields = new HashSet<>();
        int errorVariantIndex = -1;
        boolean errorAllVariants = false;
        String detail = error == null ? "" : error.toLowerCase();

        if (detail.startsWith("variant ")) {
            int colonIndex = detail.indexOf(':');
            if (colonIndex > 8) {
                errorVariantIndex = ProductController.integer(
                        detail.substring(8, colonIndex).trim(), 1) - 1;
                detail = detail.substring(colonIndex + 1).trim();
            }
        }

        if (detail.contains("front image and back image")) {
            errorFields.add("variantImageFile");
            errorFields.add("variantBackImageFile");
        } else if (detail.contains("ram, storage and color")) {
            errorFields.add("variantRam");
            errorFields.add("variantStorage");
            errorFields.add("variantColorName");
        } else if (detail.contains("front image")) {
            errorFields.add("variantImageFile");
        } else if (detail.contains("back image")) {
            errorFields.add("variantBackImageFile");
        } else if (detail.contains("each image")) {
            errorFields.add("variantImageFile");
            errorFields.add("variantBackImageFile");
            errorAllVariants = true;
        } else if (detail.contains("selling price")) {
            errorFields.add("variantSellingPrice");
        } else if (detail.contains("color name")) {
            errorFields.add("variantColorName");
        } else if (detail.contains("storage")) {
            errorFields.add("variantStorage");
        } else if (detail.contains("ram")) {
            errorFields.add("variantRam");
        } else if (detail.contains("product name")) {
            errorFields.add("name");
        } else if (detail.contains("description")) {
            errorFields.add("description");
        } else if (detail.contains("release year")) {
            errorFields.add("releaseYear");
        } else if (detail.contains("warranty")) {
            errorFields.add("warrantyMonths");
        } else if (detail.contains("brand")) {
            errorFields.add("brandId");
        } else if (detail.contains("categor")) {
            errorFields.add("categoryIds");
        } else if (detail.contains("product status")) {
            errorFields.add("status");
        } else if (detail.contains("product variant")) {
            errorFields.add("variants");
        }

        request.setAttribute("errorFields", errorFields);
        request.setAttribute("errorVariantIndex", errorVariantIndex);
        request.setAttribute("errorAllVariants", errorAllVariants);
    }

    private void forwardFormWithBrandWarning(HttpServletRequest request,
            HttpServletResponse response, ProductModel product, String warning)
            throws ServletException, IOException {
        restoreExistingImageNames(request, product);
        request.setAttribute("brandWarning", warning);
        request.setAttribute("confirmBrandMismatch", true);
        request.setAttribute("product", product);
        request.setAttribute("selectedCategoryIds",
                new HashSet<>(product.getCategoryIds()));
        try {
            loadChoices(request);
        } catch (SQLException ignored) {
        }
        request.getRequestDispatcher("/views/manager/product-form.jsp")
                .forward(request, response);
    }

    private void restoreExistingImageNames(HttpServletRequest request,
            ProductModel product) {
        try {
            for (int index = 0; index < product.getVariants().size(); index++) {
                ProductVariantModel variant = product.getVariants().get(index);
                variant.setImage(valueAt(request, "existingVariantImage", index));
                variant.setBackImage(valueAt(
                        request, "existingVariantBackImage", index));
            }
        } catch (IllegalStateException ignored) {
        }
    }

    private String friendly(SQLException exception) {
        // Convert database constraint messages into safe, understandable form errors.
        if (exception.getErrorCode() == 1062) {
            String detail = exception.getMessage() == null
                    ? "" : exception.getMessage().toLowerCase();
            if (detail.contains("uk_productvariant_sku")) {
                return "SKU already belongs to another product variant.";
            }
            if (detail.contains("uk_productvariant_image")) {
                return "Front image name already belongs to another product variant.";
            }
            if (detail.contains("uk_productvariant_option")) {
                return "This RAM, storage and color variant already exists.";
            }
            if (detail.contains("product.name")
                    || detail.contains("key 'name'")
                    || detail.contains("key `name`")) {
                return "Product name already exists.";
            }
            return "A unique value already exists. Please reload the form and try again.";
        }
        return "Database error: " + exception.getMessage();
    }

    private void redirect(HttpServletResponse response, HttpServletRequest request,
            String message) throws IOException {
        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath()
                + "/manager/products?message=" + encodedMessage);
    }

    private String normalizeText(String value) {
        if (value == null) {
            return null;
        }
        // Trim edges and collapse repeated spaces before validation and persistence.
        return value.trim().replaceAll("\\s+", " ");
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private void redirectToCategoryProducts(HttpServletResponse response,
            HttpServletRequest request, int categoryId, String message)
            throws IOException {
        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath()
                + "/manager/products?category=" + categoryId
                + "&from=category&message=" + encodedMessage);
    }

    private void redirectToCategoryPicker(HttpServletResponse response,
            HttpServletRequest request, int categoryId, String error)
            throws IOException {
        String encodedError = URLEncoder.encode(error, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath()
                + "/manager/products?action=category-picker&category="
                + categoryId + "&error=" + encodedError);
    }
}
