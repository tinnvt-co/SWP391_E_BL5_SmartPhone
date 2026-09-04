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
// Giới hạn multipart bảo vệ server: tối đa 5 MB mỗi ảnh và 60 MB mỗi request form.
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

    // Nhận GET và điều hướng đến danh sách hoặc form Add/Edit product.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Một servlet xử lý danh sách và form Add/Edit dựa trên action.
        String action = ProductController.value(
                request.getParameter("action"), "list");

        try {
            switch (action) {
                case "form" -> showForm(request, response);
                default -> handleList(request, response);
            }
        } catch (SQLException exception) {
            throw new ServletException("Cannot load product management", exception);
        }
    }

    // Nhận POST thay đổi dữ liệu: Save, Deactivate và thêm/gỡ product khỏi category.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // Action POST làm thay đổi dữ liệu; action không xác định sẽ mặc định Save form.
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

    // Đọc bộ lọc, tính phân trang, lấy product và chuẩn bị dữ liệu popup Category Products.
    private void handleList(HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        // Đọc các bộ lọc tùy chọn; giá trị null nghĩa là không áp dụng bộ lọc đó.
        Integer brandId = ProductController.integerOrNull(
                request.getParameter("brand"));
        Integer categoryId = ProductController.integerOrNull(
                request.getParameter("category"));
        boolean fromCategory = categoryId != null
                && "category".equals(request.getParameter("from"));

        // Chỉ category ACTIVE mới được phép quản lý danh sách product.
        if (fromCategory) {
            CategoryModel selectedCategory = categoryDAO.findById(categoryId);
            if (selectedCategory == null || !selectedCategory.isActive()) {
                response.sendRedirect(request.getContextPath()
                        + "/manager/categories");
                return;
            }
        }

        String keyword = request.getParameter("q");
        String sort = request.getParameter("sort");
        String priceRange = ProductController.normalizePriceRange(
                request.getParameter("priceRange"));

        // Câu đếm và câu lấy dữ liệu dùng cùng bộ lọc để phân trang luôn chính xác.
        int filteredTotal = productDAO.countAll(
                keyword, brandId, categoryId, priceRange, false);
        int totalPages = Math.max(1,
                (int) Math.ceil((double) filteredTotal / PAGE_SIZE));
        int currentPage = ProductController.integer(
                request.getParameter("page"), 1);
        currentPage = Math.max(1, Math.min(currentPage, totalPages));

        // OFFSET bỏ qua các trang trước; PAGE_SIZE giới hạn trang hiện tại còn 10 product.
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

    // Nạp tên category và các product chưa thuộc category để hiển thị trong popup.
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

    // Xóa mềm product bằng cách chuyển trạng thái sang INACTIVE.
    private void handleDeactivate(HttpServletRequest request,
            HttpServletResponse response) throws SQLException, IOException {
        int productId = ProductController.integer(
                request.getParameter("id"), 0);
        productDAO.deactivate(productId);
        redirect(response, request, "Product deactivated");
    }

    // Điều phối luồng Save: đọc form, validate, kiểm tra trùng, lưu ảnh rồi gọi DAO.
    private void handleSave(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        List<Path> uploadedFiles = new ArrayList<>();
        ProductModel product = null;

        try {
            // Thứ tự kiểm tra: đọc form -> luật nghiệp vụ -> dữ liệu duy nhất trong database
            // -> cảnh báo brand -> file ảnh -> transaction database.
            product = read(request);
            if (product.getId() < 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            if (product.getId() > 0
                    && productDAO.findById(product.getId()) == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

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

            // DAO.save thêm/cập nhật product, category và variant trong một transaction.
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

    // Đọc các product được chọn, loại ID sai/trùng rồi thêm quan hệ Product-Category.
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
            redirectToCategoryProductsWithError(response, request, categoryId,
                    "Please select at least one product.");
            return;
        }

        categoryDAO.addProducts(categoryId, productIds);
        redirectToCategoryProducts(response, request, categoryId,
                productIds.size() + " product(s) added to category.");
    }

    // Gỡ một product khỏi category nhưng không xóa bản ghi Product.
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

    // Tạo model rỗng khi Add hoặc tải product cũ khi Edit rồi forward sang Product Form.
    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int productId = ProductController.integer(request.getParameter("id"), 0);
        if (productId < 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // ID bằng 0 tạo model rỗng cho Add; ID lớn hơn 0 tải model cũ cho Edit.
        ProductModel product = productId > 0
                ? productDAO.findById(productId)
                : new ProductModel();
        if (product == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("product", product);
        request.setAttribute("selectedCategoryIds",
                new HashSet<>(product.getCategoryIds()));
        loadChoices(request);
        request.getRequestDispatcher("/views/manager/product-form.jsp")
                .forward(request, response);
    }

    // Nạp danh sách brand và category ACTIVE cho các ô lựa chọn trong Product Form.
    private void loadChoices(HttpServletRequest request) throws SQLException {
        request.setAttribute("brands", brandDAO.findAll(true));
        request.setAttribute("categories", categoryDAO.findAll(true));
        request.setAttribute("ramOptions", RAM_OPTIONS);
        request.setAttribute("storageOptions", STORAGE_OPTIONS);
        request.setAttribute("maxReleaseYear", Year.now().getValue());
    }

    // Chuyển toàn bộ tham số request thành ProductModel trước khi validate và lưu.
    private ProductModel read(HttpServletRequest request) {
        // Chuyển toàn bộ tham số form thành một ProductModel trước khi validate.
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

    // Đọc mảng categoryIds từ form và gắn các ID hợp lệ vào product.
    private void readCategories(HttpServletRequest request, ProductModel product) {
        String[] values = request.getParameterValues("categoryIds");
        if (values == null) {
            return;
        }

        // Một product có thể có nhiều category; Set ngăn category ID bị trùng.
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

    // Ghép các mảng variant cùng index thành từng ProductVariantModel.
    private void readVariants(HttpServletRequest request, ProductModel product) {
        String[] ramValues = request.getParameterValues("variantRam");
        if (ramValues == null) {
            return;
        }

        // Các trường variant được gửi thành những mảng song song; cùng một index đại diện
        // cho một tổ hợp RAM/bộ nhớ/màu/giá/ảnh.
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

    // Lấy tên file upload ở một dòng; nếu chưa chọn file mới thì giữ tên ảnh hiện tại.
    private String uploadedNameAt(HttpServletRequest request, String partName,
            String existingName, int index) {
        List<Part> parts = partsByName(request, partName);
        if (index < parts.size() && parts.get(index).getSize() > 0) {
            return safeFileName(parts.get(index).getSubmittedFileName());
        }
        // Khi Edit, không chọn ảnh mới nghĩa là giữ lại tên ảnh hiện tại.
        return valueAt(request, existingName, index);
    }

    // Gom tất cả multipart Part có cùng name để xử lý ảnh theo từng dòng variant.
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

    // Lấy phần tử tại index trong mảng request và chuyển thành int, sai định dạng thì trả 0.
    private int integerAt(HttpServletRequest request, String name, int index) {
        return ProductController.integer(valueAt(request, name, index), 0);
    }

    // Lấy an toàn một giá trị theo index trong mảng tham số request.
    private String valueAt(HttpServletRequest request, String name, int index) {
        String[] values = request.getParameterValues(name);
        return values != null && index < values.length ? values[index] : "";
    }

    // Kiểm tra toàn bộ dữ liệu Product và từng variant; trả lỗi đầu tiên hoặc null nếu hợp lệ.
    private String validate(ProductModel product) {
        // Validation phía server là bắt buộc vì validation trình duyệt có thể bị vượt qua.
        // Trả về lỗi đầu tiên giúp luồng form đơn giản và dễ giải thích.
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

        // Các Set phát hiện dữ liệu trùng ngay trong form trước khi chạy SQL.
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

    // Kiểm tra tên ảnh bắt buộc và phần mở rộng JPG, JPEG, PNG hoặc WEBP.
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

    // Hỏi DAO để kiểm tra tên product, SKU, ảnh trước và tổ hợp variant có bị trùng trong DB không.
    private String validateUniqueData(ProductModel product) throws SQLException {
        // Các quy tắc này cần dữ liệu hiện tại trong database nên JSP không thể tự kiểm tra chính xác.
        // Khi Edit phải loại ID hiện tại để bản ghi không bị coi là trùng với chính nó.
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

    // Ghép các file front/back theo từng variant và lưu chúng; trả lỗi nếu một ảnh không hợp lệ.
    private String saveUploadedImages(HttpServletRequest request,
            ProductModel product, List<Path> uploadedFiles) {
        // Ảnh trước và ảnh sau được ghép với variant dựa trên index của dòng.
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

    // Lấy Part theo index; trả null nếu dòng hiện tại không có file tương ứng.
    private Part partAt(List<Part> parts, int index) {
        return index < parts.size() ? parts.get(index) : null;
    }

    // Validate dung lượng/nội dung/trùng tên rồi sao chép một ảnh vào các thư mục chạy ứng dụng.
    private String saveImagePart(Part part, String fileName, String label,
            List<Path> uploadedFiles) throws IOException {
        if (part == null || part.getSize() == 0) {
            return imageExists(fileName) ? null
                    : label + " is required. Please choose an image file.";
        }
        if (part.getSize() > 5L * 1024 * 1024) {
            return label + " must be 5 MB or smaller.";
        }
        // Kiểm tra chữ ký file, không chỉ đuôi file, để loại file giả ảnh do đổi tên.
        if (!validImageContent(part, fileName)) {
            return label + " must be a real JPG, JPEG, PNG or WEBP image.";
        }

        List<Path> directories = uploadDirectories();
        // Kiểm tra mọi đường dẫn đích trước khi sao chép để hạn chế upload dở dang.
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

    // Đọc magic bytes của file để xác nhận nội dung thật đúng định dạng, không chỉ dựa vào đuôi tên.
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

    // Xác định các thư mục ảnh cần đồng bộ giữa source và thư mục ứng dụng đang deploy.
    private List<Path> uploadDirectories() throws IOException {
        String realPath = getServletContext().getRealPath(IMAGE_FOLDER);
        if (realPath == null) {
            throw new IOException("The image upload folder is unavailable.");
        }

        List<Path> directories = new ArrayList<>();
        // Lưu vào thư mục deploy để hiển thị ngay và thư mục source để ảnh vẫn còn
        // sau lần clean/deploy tiếp theo.
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

    // Kiểm tra ảnh cũ còn tồn tại trong tài nguyên của ứng dụng hay không.
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

    // Loại phần đường dẫn khỏi tên file upload để ngăn ghi file ra ngoài thư mục cho phép.
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

    // Xóa các ảnh vừa lưu nếu bước Save sau đó thất bại để tránh file rác.
    private void deleteUploadedFiles(List<Path> files) {
        // Xóa hoàn tác các file đã ghi nếu validation sau đó hoặc database bị lỗi.
        for (Path file : files) {
            try {
                Files.deleteIfExists(file);
            } catch (IOException ignored) {
            }
        }
    }

    // Khôi phục dữ liệu form, đánh dấu vị trí lỗi và forward lại Product Form.
    private void forwardFormWithError(HttpServletRequest request,
            HttpServletResponse response, ProductModel product, String error)
            throws ServletException, IOException {
        // Dùng forward thay vì redirect để giữ dữ liệu đã nhập và lỗi cho JSP.
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

    // Chuyển nội dung lỗi thành tên field/index variant để JSP tô đỏ đúng ô.
    private void exposeErrorLocation(HttpServletRequest request, String error) {
        // Chuyển lỗi thành tên field để JSP tô viền đỏ đúng ô nhập sai
        // mà không phải lặp lại validation nghiệp vụ trong JavaScript.
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

    // Khôi phục tên ảnh cũ vào model vì trình duyệt không gửi lại nội dung file input.
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

    // Chuyển lỗi ràng buộc SQL thành thông báo an toàn và dễ hiểu cho người dùng.
    private String friendly(SQLException exception) {
        // Chuyển thông báo ràng buộc database thành lỗi form an toàn và dễ hiểu.
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

    // Redirect về Product Management và gắn thông báo thành công trên URL.
    private void redirect(HttpServletResponse response, HttpServletRequest request,
            String message) throws IOException {
        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath()
                + "/manager/products?message=" + encodedMessage);
    }

    // Cắt khoảng trắng hai đầu và gộp nhiều khoảng trắng liên tiếp thành một.
    private String normalizeText(String value) {
        if (value == null) {
            return null;
        }
        // Cắt khoảng trắng hai đầu và gộp khoảng trắng lặp trước khi validate và lưu.
        return value.trim().replaceAll("\\s+", " ");
    }

    // Cắt khoảng trắng hai đầu nhưng vẫn giữ null nếu đầu vào là null.
    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    // Redirect về danh sách product của category sau khi thêm hoặc gỡ quan hệ thành công.
    private void redirectToCategoryProducts(HttpServletResponse response,
            HttpServletRequest request, int categoryId, String message)
            throws IOException {
        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath()
                + "/manager/products?category=" + categoryId
                + "&from=category&message=" + encodedMessage);
    }

    // Redirect về danh sách product của category và mang theo thông báo lỗi.
    private void redirectToCategoryProductsWithError(HttpServletResponse response,
            HttpServletRequest request, int categoryId, String error)
            throws IOException {
        String encodedError = URLEncoder.encode(error, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath()
                + "/manager/products?category=" + categoryId
                + "&from=category&error=" + encodedError);
    }
}
