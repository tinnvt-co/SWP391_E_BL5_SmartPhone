package controller;

import DAO.BrandDAO;
import DAO.ProductDAO;
import DAO.SupplierDAO;
import static controller.ProductController.integer;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.BrandModel;
import model.ProductModel;
import model.SupplierModel;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SupplierController extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private static final int NAME_MAX_LENGTH = 150;
    private static final int ADDRESS_MAX_LENGTH = 255;
    private static final int DESCRIPTION_MAX_LENGTH = 255;
    private static final int NOTE_MAX_LENGTH = 500;

    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String action = request.getParameter("action");
            if ("detail".equals(action)) {
                showDetail(request, response);
            } else {
                listSuppliers(request, response);
            }
        } catch (SQLException e) {
            HttpSession session = request.getSession();
            session.setAttribute("msgErr", "Cannot load suppliers. Please try again.");
            response.sendRedirect(request.getContextPath() + "/manager/supplier/list");
        }
    }

    private void listSuppliers(HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        if (keyword == null) {
            keyword = "";
        }

        keyword = keyword.trim();
        if (keyword.length() > 100) {
            request.setAttribute("msgErr", "Keyword should shorter than 100 character");
            keyword = "";
        }
        //validate page number
        int requestedPage = integer(
                request.getParameter("page"), 1);

        int totalSuppliers = supplierDAO.countAll(
                keyword,
                status
        );

        int totalPages = Math.max(
                1,
                (int) Math.ceil(
                        totalSuppliers / (double) PAGE_SIZE
                )
        );
        
        //tích hợp validate số trang mà người dùng yêu cầu
        int currentPage = Math.min(
                Math.max(1, requestedPage),
                totalPages
        );

        int offset = (currentPage - 1) * PAGE_SIZE;

        List<SupplierModel> suppliers
                = supplierDAO.findAll(
                        keyword,
                        status,
                        PAGE_SIZE,
                        offset
                );

        int startPage = Math.max(
                1,
                currentPage - 2
        );

        int endPage = Math.min(
                totalPages,
                currentPage + 2
        );

        int startItem = totalSuppliers == 0
                ? 0
                : offset + 1;

        int endItem = Math.min(
                offset + PAGE_SIZE,
                totalSuppliers
        );

        request.setAttribute("suppliers", suppliers);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);

        request.setAttribute(
                "currentPage",
                currentPage
        );

        request.setAttribute(
                "totalPages",
                totalPages
        );

        request.setAttribute(
                "startPage",
                startPage
        );

        request.setAttribute(
                "endPage",
                endPage
        );

        request.setAttribute(
                "totalSuppliers",
                totalSuppliers
        );

        request.setAttribute(
                "startItem",
                startItem
        );

        request.setAttribute(
                "endItem",
                endItem
        );

        //Dùng khi đưa keyword vào URL. Nếu keyword có &, ?, khoảng trắng thì nên encode trước khi truyền sang JSP.
        request.setAttribute(
                "urlKeyword",
                java.net.URLEncoder.encode(
                        keyword,
                        java.nio.charset.StandardCharsets.UTF_8
                )
        );

        request.getRequestDispatcher(
                "/views/manager/supplier-list.jsp"
        ).forward(request, response);
    }

    private void showDetail(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int supplierId = parseInt(
                request.getParameter("id"),
                0
        );

        SupplierModel supplier;

        if (supplierId > 0) {

            supplier = supplierDAO.findById(supplierId);

            if (supplier == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Supplier not found."
                );
                return;
            }

        } else {

            supplier = new SupplierModel();

            supplier.setStatus("ACTIVE");

            supplier.setProductVariantIds(new ArrayList<>());
        }

        loadProductVariants(request, supplier);

        List<BrandModel> brands
                = brandDAO.findAll(true);

        request.setAttribute(
                "supplier",
                supplier
        );

        request.setAttribute(
                "brands",
                brands
        );

        request.getRequestDispatcher(
                "/views/manager/supplier-detail.jsp"
        ).forward(request, response);
    }

    private void loadProductVariants(
            HttpServletRequest request,
            SupplierModel supplier)
            throws SQLException {

        String keyword = normalizeKeyword(
                request.getParameter("keyword")
        );

        Integer brandId = parseIntegerOrNull(
                request.getParameter("brand")
        );

        // FIX: dropdown lọc theo tên sản phẩm mới, param "product" = ProductID.
        Integer selectedProductId = parseIntegerOrNull(
                request.getParameter("product")
        );

        String suppliedFilter
                = request.getParameter("supplied");

        int requestedPage = parseInt(
                request.getParameter("page"),
                1
        );

        List<ProductModel> allProducts
                = productDAO.findAll(
                        keyword,
                        brandId,
                        null,
                        "newest",
                        true
                );

        // áp dụng thêm filter theo Product cụ thể (dropdown mới).
        if (selectedProductId != null) {
            allProducts.removeIf(
                    product -> product.getId() != selectedProductId
            );
        }

        Set<Integer> suppliedIds
                = new HashSet<>(
                        supplier.getProductVariantIds()
                );

        // làm phẳng Product + Variant thành 1 list các "dòng variant", mỗi
        // dòng tự mang theo tên product/brand để hiển thị (vì không còn group
        // theo product-card nữa). Dùng Map thay vì tạo model mới cho gọn.
        List<Map<String, Object>> allVariantRows = new ArrayList<>();

        for (ProductModel product : allProducts) {

            if (product.getVariants() == null) {
                continue;
            }

            for (var variant : product.getVariants()) {

                Map<String, Object> row = new LinkedHashMap<>();

                row.put("variantId", variant.getId());
                row.put("productId", product.getId());
                row.put("productName", product.getName());
                row.put("brandName", product.getBrandName());
                row.put("ramGb", variant.getRamGb());
                row.put("storageGb", variant.getStorageGb());
                row.put("colorName", variant.getColorName());
                row.put("sku", variant.getSku());
                row.put("stock", variant.getStock());
                row.put("supplied", suppliedIds.contains(variant.getId()));

                allVariantRows.add(row);
            }
        }

        /*
     * Filter theo checkbox:
     *
     * all      -> tất cả
     * supplied -> chỉ variant supplier cung cấp
     * not      -> variant supplier chưa cung cấp
         */
        if ("supplied".equals(suppliedFilter)) {
            allVariantRows.removeIf(
                    row -> !(Boolean) row.get("supplied")
            );

        } else if ("not".equals(suppliedFilter)) {
            allVariantRows.removeIf(
                    row -> (Boolean) row.get("supplied")
            );
        }

        int totalVariants
                = allVariantRows.size();

        int totalPages = Math.max(
                1,
                (int) Math.ceil(
                        totalVariants / (double) PAGE_SIZE
                )
        );

        int currentPage = Math.min(
                Math.max(1, requestedPage),
                totalPages
        );

        int from
                = (currentPage - 1) * PAGE_SIZE;

        int to
                = Math.min(
                        from + PAGE_SIZE,
                        totalVariants
                );

        List<Map<String, Object>> pageRows
                = from < to
                        ? new ArrayList<>(allVariantRows.subList(from, to))
                        : new ArrayList<>();

        int startItem = totalVariants == 0
                ? 0
                : from + 1;

        int endItem = to;

        // FIX: danh sách sản phẩm để đổ vào dropdown mới, không phụ thuộc
        // keyword/brand đang lọc (luôn hiển thị đầy đủ để user tìm nhanh).
        List<ProductModel> productOptions
                = productDAO.findAll(null, null, null, "newest", true);

        productOptions.sort(
                java.util.Comparator.comparing(
                        ProductModel::getName,
                        String.CASE_INSENSITIVE_ORDER
                )
        );

        request.setAttribute("variantRows", pageRows);
        request.setAttribute("totalVariants", totalVariants);
        request.setAttribute("variantCurrentPage", currentPage);
        request.setAttribute("variantTotalPages", totalPages);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);

        // FIX: danh sách số trang rút gọn kiểu "1 ... 4 5 6 ... 20" tính sẵn ở
        // server, JSP chỉ việc render, không cần tính toán windowing trong EL.
        request.setAttribute("pageItems", buildPageItems(currentPage, totalPages));

        request.setAttribute("productKeyword", keyword);
        request.setAttribute("selectedBrand", brandId);
        request.setAttribute("selectedProduct", selectedProductId);
        request.setAttribute("suppliedFilter", suppliedFilter);
        request.setAttribute("productOptions", productOptions);
    }

    private List<String> buildPageItems(int currentPage, int totalPages) {

        List<String> items = new ArrayList<>();

        if (totalPages <= 7) {
            for (int i = 1; i <= totalPages; i++) {
                items.add(String.valueOf(i));
            }
            return items;
        }

        items.add("1");

        if (currentPage > 3) {
            items.add("...");
        }

        int start = Math.max(2, currentPage - 1);
        int end = Math.min(totalPages - 1, currentPage + 1);

        for (int i = start; i <= end; i++) {
            items.add(String.valueOf(i));
        }

        if (currentPage < totalPages - 2) {
            items.add("...");
        }

        items.add(String.valueOf(totalPages));

        return items;
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        try {
            saveSupplier(request, response);
        } catch (SQLException | ServletException | IOException e) {
            int supplierId = parseInt(request.getParameter("id"), 0);
            HttpSession session = request.getSession();
            session.setAttribute("msgErr", "Cannot save supplier. Please try again.");
            if (!response.isCommitted()) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/manager/supplier/detail"
                        + (supplierId > 0 ? "?id=" + supplierId : "")
                );
            }
        }
    }

    private void saveSupplier(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        int supplierId = parseInt(
                request.getParameter("id"),
                0
        );

        SupplierModel supplier
                = new SupplierModel();

        supplier.setId(supplierId);

        supplier.setName(
                value(request.getParameter("name"))
        );

        supplier.setAddress(
                value(request.getParameter("address"))
        );

        supplier.setPhone(
                value(request.getParameter("phone"))
        );

        supplier.setDescription(
                value(request.getParameter("description"))
        );

        supplier.setNote(
                value(request.getParameter("note"))
        );

        supplier.setStatus(
                value(
                        request.getParameter("status"),
                        "ACTIVE"
                )
        );

        //Các checkbox có: name="productVariantIds" nên request.getParameterValues() sẽ trả về toàn bộ variant được check.
        String rawVariantIds = request.getParameter("productVariantIds");

        List<Integer> productVariantIds = new ArrayList<>();

        if (rawVariantIds != null && !rawVariantIds.isBlank()) {

            for (String rawId : rawVariantIds.split(",")) {

                int variantId = parseInt(rawId.trim(), 0);

                if (variantId > 0
                        && !productVariantIds.contains(variantId)) {

                    productVariantIds.add(variantId);
                }
            }
        }

        supplier.setProductVariantIds(
                productVariantIds
        );

        List<String> errors = validateSupplier(supplier);

        if (!errors.isEmpty()) {
            showSupplierFormWithError(request, response, supplier, errors);
            return;
        }

        HttpSession session
                = request.getSession();

        if (supplierId == 0) {
            int newId
                    = supplierDAO.create(supplier);

            supplierDAO.updateProductVariants(
                    newId,
                    productVariantIds
            );

            session.setAttribute(
                    "msgOk",
                    "Supplier created successfully."
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/manager/supplier/detail?id="
                    + newId
            );

        } else {

            boolean updated
                    = supplierDAO.update(supplier);

            if (!updated) {

                session.setAttribute(
                        "msgErr",
                        "Supplier not found."
                );

            } else {

                supplierDAO.updateProductVariants(
                        supplierId,
                        productVariantIds
                );

                session.setAttribute(
                        "msgOk",
                        "Supplier updated successfully."
                );
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/manager/supplier/detail?id="
                    + supplierId
            );
        }
    }

    private void showSupplierFormWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            SupplierModel supplier,
            List<String> errors)
            throws SQLException, ServletException, IOException {

        loadProductVariants(request, supplier);

        List<BrandModel> brands = brandDAO.findAll(true);

        request.setAttribute("supplier", supplier);
        request.setAttribute("brands", brands);
        request.setAttribute("errors", errors);

        request.getRequestDispatcher(
                "/views/manager/supplier-detail.jsp"
        ).forward(request, response);
    }

    private List<String> validateSupplier(SupplierModel supplier) {

        List<String> errors = new ArrayList<>();

        String name = supplier.getName();
        if (name == null || name.isBlank()) {
            errors.add("Supplier name is required.");
        } else if (name.length() > NAME_MAX_LENGTH) {
            errors.add("Supplier name must be " + NAME_MAX_LENGTH + " characters or fewer.");
        }

        String address = supplier.getAddress();
        if (address == null || address.isBlank()) {
            errors.add("Supplier address is required.");
        } else if (address.length() > ADDRESS_MAX_LENGTH) {
            errors.add("Supplier address must be " + ADDRESS_MAX_LENGTH + " characters or fewer.");
        }

        String phone = supplier.getPhone();
        if (phone == null || phone.isBlank()) {
            errors.add("Supplier phone is required.");
        } else if (!isValidPhone(phone)) {
            errors.add("Supplier phone must be exactly 10 digits (no other characters).");
        }

        String description = supplier.getDescription();
        if (description != null && description.length() > DESCRIPTION_MAX_LENGTH) {
            errors.add("Description must be " + DESCRIPTION_MAX_LENGTH + " characters or fewer.");
        }

        String note = supplier.getNote();
        if (note != null && note.length() > NOTE_MAX_LENGTH) {
            errors.add("Note must be " + NOTE_MAX_LENGTH + " characters or fewer.");
        }

        String status = supplier.getStatus();
        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            errors.add("Invalid supplier status.");
        }

        return errors;
    }

    private boolean isValidPhone(String phone) {
        return phone.matches("0\\d{9}");
    }

    private String normalizeKeyword(
            String value) {

        if (value == null) {
            return "";
        }

        return value.trim()
                .replaceAll("\\s+", " ");
    }

    private String value(
            String value) {

        return value == null
                ? ""
                : value.trim();
    }

    private String value(
            String value,
            String fallback) {

        return value == null
                || value.isBlank()
                ? fallback
                : value.trim();
    }

    private int parseInt(
            String value,
            int fallback) {

        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private Integer parseIntegerOrNull(
            String value) {

        int result
                = parseInt(value, 0);

        return result > 0
                ? result
                : null;
    }
}
