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
import java.util.List;
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
            if (action == null || action.isBlank()
                    || "list".equals(action)) {
                listSuppliers(request, response);
                return;
            }

            if ("detail".equals(action)) {
                showDetail(request, response);
                return;
            }

            listSuppliers(request, response);
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

            supplier.setProductVariantIds(
                    new ArrayList<>()
            );
        }

        loadProducts(request, supplier);

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

    private void loadProducts(
            HttpServletRequest request,
            SupplierModel supplier)
            throws SQLException {

        String keyword = normalizeKeyword(
                request.getParameter("keyword")
        );

        Integer brandId = parseIntegerOrNull(
                request.getParameter("brand")
        );

        String suppliedFilter
                = request.getParameter("supplied");

        int requestedPage = parseInt(
                request.getParameter("page"),
                1
        );

        //tận dụng lại ProductDAO đang trả Product + các ProductVariant
        List<ProductModel> allProducts
                = productDAO.findAll(
                        keyword,
                        brandId,
                        null,
                        "newest",
                        true
                );

        Set<Integer> suppliedIds
                = new HashSet<>(
                        supplier.getProductVariantIds()
                );

        /*
         * Filter theo checkbox:
         *
         * all      -> tất cả
         * supplied -> chỉ variant supplier cung cấp
         * not      -> variant supplier chưa cung cấp
         */
        if ("supplied".equals(suppliedFilter)) {

            filterVariants(
                    allProducts,
                    suppliedIds,
                    true
            );

        } else if ("not".equals(suppliedFilter)) {

            filterVariants(
                    allProducts,
                    suppliedIds,
                    false
            );
        }

        /*
         * Chỉ giữ Product còn variant.
         */
        allProducts.removeIf(
                product -> product.getVariants() == null
                || product.getVariants().isEmpty()
        );

        int totalProducts
                = allProducts.size();

        int totalPages = Math.max(
                1,
                (int) Math.ceil(
                        totalProducts / (double) PAGE_SIZE
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
                        totalProducts
                );

        List<ProductModel> pageProducts
                = from < to
                        ? new ArrayList<>(
                                allProducts.subList(from, to)
                        )
                        : new ArrayList<>();

        int startPage
                = Math.max(1, currentPage - 2);

        int endPage
                = Math.min(totalPages, currentPage + 2);

        request.setAttribute(
                "products",
                pageProducts
        );

        request.setAttribute(
                "productKeyword",
                keyword
        );

        request.setAttribute(
                "selectedBrand",
                brandId
        );

        request.setAttribute(
                "suppliedFilter",
                suppliedFilter
        );

        request.setAttribute(
                "productCurrentPage",
                currentPage
        );

        request.setAttribute(
                "productTotalPages",
                totalPages
        );

        request.setAttribute(
                "productStartPage",
                startPage
        );

        request.setAttribute(
                "productEndPage",
                endPage
        );

        request.setAttribute(
                "suppliedVariantIds",
                suppliedIds
        );
    }

    private void filterVariants(
            List<ProductModel> products,
            Set<Integer> suppliedIds,
            boolean shouldBeSupplied) {

        for (ProductModel product : products) {

            product.getVariants().removeIf(
                    variant -> {

                        boolean supplied
                        = suppliedIds.contains(
                                variant.getId()
                        );

                        return supplied != shouldBeSupplied;
                    }
            );
        }
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

        /*
         * Các checkbox có:
         *
         * name="productVariantIds"
         *
         * nên request.getParameterValues()
         * sẽ trả về toàn bộ variant được check.
         */
        String[] selectedIds
                = request.getParameterValues(
                        "productVariantIds"
                );

        List<Integer> productVariantIds
                = new ArrayList<>();

        if (selectedIds != null) {

            for (String value : selectedIds) {

                int variantId
                        = parseInt(value, 0);

                if (variantId > 0
                        && !productVariantIds.contains(variantId)) {

                    productVariantIds.add(
                            variantId
                    );
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

        loadProducts(request, supplier);

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
            // FIX: siết lại theo yêu cầu - đúng 10 chữ số, không cho phép
            // dấu +, khoảng trắng, gạch ngang hay ký tự nào khác.
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
        return phone.matches("\\d{10}");
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
