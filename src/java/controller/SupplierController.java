package controller;

import DAO.BrandDAO;
import DAO.ProductDAO;
import DAO.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
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

@WebServlet(
        name = "SupplierController",
        urlPatterns = {
            "/manager/suppliers",
            "/manager/suppliers/detail"
        }
)
public class SupplierController extends HttpServlet {

    private static final int PAGE_SIZE = 12;

    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!isManager(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Manager access required."
            );
            return;
        }

        String path = request.getServletPath();

        try {

            if ("/manager/suppliers/detail".equals(path)) {
                showDetail(request, response);
            } else {
                showList(request, response);
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Cannot load supplier data.",
                    e
            );
        }
    }

    private void showList(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String keyword = normalizeKeyword(
                request.getParameter("keyword")
        );

        String status = request.getParameter("status");

        int requestedPage = parseInt(
                request.getParameter("page"),
                1
        );

        int totalSuppliers =
                supplierDAO.countAll(keyword, status);

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

        int offset =
                (currentPage - 1) * PAGE_SIZE;

        List<SupplierModel> suppliers =
                supplierDAO.findAll(
                        keyword,
                        status,
                        PAGE_SIZE,
                        offset
                );

        int startPage =
                Math.max(1, currentPage - 2);

        int endPage =
                Math.min(totalPages, currentPage + 2);

        request.setAttribute(
                "suppliers",
                suppliers
        );

        request.setAttribute(
                "keyword",
                keyword
        );

        request.setAttribute(
                "status",
                status
        );

        request.setAttribute(
                "totalSuppliers",
                totalSuppliers
        );

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

        List<BrandModel> brands =
                brandDAO.findAll(true);

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

        String suppliedFilter =
                request.getParameter("supplied");

        int requestedPage = parseInt(
                request.getParameter("page"),
                1
        );

        /*
         * ProductDAO đang trả Product + các ProductVariant
         * nên chúng ta tận dụng lại luôn.
         */
        List<ProductModel> allProducts =
                productDAO.findAll(
                        keyword,
                        brandId,
                        null,
                        "newest",
                        true
                );

        Set<Integer> suppliedIds =
                new HashSet<>(
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

        int totalProducts =
                allProducts.size();

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

        int from =
                (currentPage - 1) * PAGE_SIZE;

        int to =
                Math.min(
                        from + PAGE_SIZE,
                        totalProducts
                );

        List<ProductModel> pageProducts =
                from < to
                        ? new ArrayList<>(
                                allProducts.subList(from, to)
                        )
                        : new ArrayList<>();

        int startPage =
                Math.max(1, currentPage - 2);

        int endPage =
                Math.min(totalPages, currentPage + 2);

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

                        boolean supplied =
                                suppliedIds.contains(
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

        if (!isManager(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Manager access required."
            );
            return;
        }

        String path = request.getServletPath();

        if (!"/manager/suppliers/detail".equals(path)) {
            response.sendError(
                    HttpServletResponse.SC_METHOD_NOT_ALLOWED
            );
            return;
        }

        try {

            saveSupplier(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot save supplier.",
                    e
            );
        }
    }

    private void saveSupplier(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {

        int supplierId = parseInt(
                request.getParameter("id"),
                0
        );

        SupplierModel supplier =
                new SupplierModel();

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
        String[] selectedIds =
                request.getParameterValues(
                        "productVariantIds"
                );

        List<Integer> productVariantIds =
                new ArrayList<>();

        if (selectedIds != null) {

            for (String value : selectedIds) {

                int variantId =
                        parseInt(value, 0);

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

        validateSupplier(supplier);

        HttpSession session =
                request.getSession();

        if (supplierId == 0) {

            int newId =
                    supplierDAO.create(supplier);

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
                    + "/manager/suppliers/detail?id="
                    + newId
            );

        } else {

            boolean updated =
                    supplierDAO.update(supplier);

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
                    + "/manager/suppliers/detail?id="
                    + supplierId
            );
        }
    }

    private void validateSupplier(
            SupplierModel supplier) {

        if (supplier.getName() == null
                || supplier.getName().isBlank()) {

            throw new IllegalArgumentException(
                    "Supplier name is required."
            );
        }

        if (supplier.getAddress() == null
                || supplier.getAddress().isBlank()) {

            throw new IllegalArgumentException(
                    "Supplier address is required."
            );
        }

        if (supplier.getPhone() == null
                || supplier.getPhone().isBlank()) {

            throw new IllegalArgumentException(
                    "Supplier phone is required."
            );
        }
    }

    private boolean isManager(
            HttpServletRequest request) {

        HttpSession session =
                request.getSession(false);

        if (session == null) {
            return false;
        }

        Object role =
                session.getAttribute("role");

        return role != null
                && "MANAGER".equalsIgnoreCase(
                        role.toString()
                );
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

        int result =
                parseInt(value, 0);

        return result > 0
                ? result
                : null;
    }
}