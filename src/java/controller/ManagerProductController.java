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
import model.ProductModel;
import model.ProductVariantModel;

@WebServlet(name = "ManagerProductController", urlPatterns = {"/manager/products"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 60 * 1024 * 1024)
public class ManagerProductController extends HttpServlet {

    private static final String IMAGE_FOLDER = "/assets/images/products";
    private static final int PAGE_SIZE = 10;
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
            String priceRange = ProductController.normalizePriceRange(
                    request.getParameter("priceRange"));

            int filteredTotal = productDAO.countAll(
                    keyword, brandId, categoryId, priceRange, false);
            int totalPages = Math.max(1,
                    (int) Math.ceil((double) filteredTotal / PAGE_SIZE));
            int currentPage = ProductController.integer(
                    request.getParameter("page"), 1);
            currentPage = Math.max(1, Math.min(currentPage, totalPages));

            var products = productDAO.findAll(
                    keyword, brandId, categoryId, priceRange, sort, false,
                    PAGE_SIZE, (currentPage - 1) * PAGE_SIZE);

            request.setAttribute("products", products);
            request.setAttribute("total", productDAO.countAll(
                    null, null, null, false));
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
        List<Path> uploadedFiles = new ArrayList<>();
        ProductModel product = null;

        try {
            if ("deactivate".equals(action)) {
                int productId = ProductController.integer(request.getParameter("id"), 0);
                productDAO.deactivate(productId);
                redirect(response, request, "Product deactivated");
                return;
            }

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

            String uploadError = saveUploadedImages(request, product, uploadedFiles);
            if (uploadError != null) {
                deleteUploadedFiles(uploadedFiles);
                forwardFormWithError(request, response, product, uploadError);
                return;
            }

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

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int productId = ProductController.integer(request.getParameter("id"), 0);
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
        request.setAttribute("maxReleaseYear", Year.now().getValue() + 1);
    }

    private ProductModel read(HttpServletRequest request) {
        ProductModel product = new ProductModel();
        product.setId(ProductController.integer(request.getParameter("id"), 0));
        product.setName(request.getParameter("name"));
        product.setDescription(request.getParameter("description"));

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

        for (int index = 0; index < ramValues.length; index++) {
            ProductVariantModel variant = new ProductVariantModel();
            variant.setId(integerAt(request, "variantId", index));
            variant.setProductId(product.getId());
            variant.setRamGb(integerAt(request, "variantRam", index));
            variant.setStorageGb(integerAt(request, "variantStorage", index));
            variant.setColorName(valueAt(request, "variantColorName", index));
            variant.setSku(valueAt(request, "variantSku", index));
            variant.setSellingPrice(integerAt(request, "variantSellingPrice", index));
            variant.setLatestCost(integerAt(request, "variantLatestCost", index));
            variant.setStock(integerAt(request, "variantStock", index));
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
        if (product.getName() == null || product.getName().isBlank()) {
            return "Product name is required.";
        }
        if (product.getName().trim().length() > 50) {
            return "Product name cannot exceed 50 characters.";
        }
        if (!product.getName().trim().matches(
                "^[\\p{L}\\p{N}]+(?:[ -][\\p{L}\\p{N}]+)*$")) {
            return "Product name may contain letters, numbers, spaces and hyphens only.";
        }
        if (product.getDescription() != null && product.getDescription().length() > 255) {
            return "Description cannot exceed 255 characters.";
        }
        int maxReleaseYear = Year.now().getValue() + 1;
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

        Set<String> options = new HashSet<>();
        Set<String> skus = new HashSet<>();
        Set<String> images = new HashSet<>();

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
            if (variant.getSku() == null || variant.getSku().isBlank()) {
                return row + "SKU is required.";
            }
            if (variant.getSellingPrice() <= 0) {
                return row + "selling price must be greater than 0.";
            }
            if (variant.getLatestCost() < 0) {
                return row + "latest cost cannot be negative.";
            }
            if (variant.getSellingPrice() < variant.getLatestCost()) {
                return row + "selling price cannot be lower than latest cost.";
            }
            if (variant.getStock() < 0) {
                return row + "stock cannot be negative.";
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
        return null;
    }

    private String validateUniqueData(ProductModel product) throws SQLException {
        if (productDAO.existsProductName(product.getName(), product.getId())) {
            return "Product name already exists.";
        }
        if (!categoryDAO.areAllActive(product.getCategoryIds())) {
            return "One or more selected categories are invalid or inactive.";
        }

        for (int index = 0; index < product.getVariants().size(); index++) {
            ProductVariantModel variant = product.getVariants().get(index);
            String row = "Variant " + (index + 1) + ": ";

            if (productDAO.existsVariantSku(variant.getSku(), variant.getId())) {
                return row + "SKU already belongs to another product variant.";
            }
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

    private String saveUploadedImages(HttpServletRequest request,
            ProductModel product, List<Path> uploadedFiles) {
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
        if (!validImageContent(part, fileName)) {
            return label + " must be a real JPG, JPEG, PNG or WEBP image.";
        }

        List<Path> directories = uploadDirectories();
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

    private String friendly(SQLException exception) {
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
}
