/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import DAO.ImportOrderDAO;
import DAO.ProductDAO;
import DAO.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.OrderItemModel;
import model.OrderModel;
import model.ProductModel;
import model.ProductVariantModel;
import model.SupplierModel;
import model.UserModel;

/**
 *
 * @author admin
 */
public class ImportOrderController extends HttpServlet {

    private final ImportOrderDAO importOrderDAO
            = new ImportOrderDAO();

    private final SupplierDAO supplierDAO
            = new SupplierDAO();

    private final ProductDAO productDAO
            = new ProductDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String action = value(
                    request.getParameter("action"),
                    "list");

            switch (action) {
                case "create" ->
                    showCreate(request, response);
                case "detail" ->
                    showDetail(request, response);
                case "history" ->
                    showHistory(request, response);
                default ->
                    listImportOrders(request, response);
            }

        } catch (SQLException exception) {
            throw new ServletException(
                    "Cannot load import orders",
                    exception);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = value(
                request.getParameter("action"),
                "");

        try {
            switch (action) {
                case "create" ->
                    createImportOrder(request, response);
                case "complete" ->
                    completeImportOrder(request, response);
                default ->
                    redirect(
                            request,
                            response,
                            "Invalid action.",
                            false);
            }

        } catch (SQLException exception) {
            redirect(
                    request,
                    response,
                    "Database error: "
                    + exception.getMessage(),
                    false);
        }
    }

    /* =========================================================
       LIST
       ========================================================= */
    private void listImportOrders(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String keyword = trim(
                request.getParameter("keyword"));

        String status = trim(
                request.getParameter("status"));

        String sort = trim(
                request.getParameter("sort"));

        if (keyword.length() > 100) {
            keyword = "";
            request.setAttribute(
                    "error",
                    "Search keyword cannot exceed 100 characters.");
        }

        request.setAttribute(
                "importOrders",
                importOrderDAO.findImportOrders(
                        keyword,
                        status,
                        sort));

        request.setAttribute(
                "keyword",
                keyword);

        request.setAttribute(
                "selectedStatus",
                status);

        request.setAttribute(
                "selectedSort",
                sort);

        request.getRequestDispatcher(
                "/views/manager/import-list.jsp")
                .forward(request, response);
    }

    /* =========================================================
       CREATE FORM
       ========================================================= */
    private void showCreate(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int supplierId = integer(
                request.getParameter("supplierId"),
                0);

        int variantId = integer(
                request.getParameter("variantId"),
                0);

        /*
         * -----------------------------------------------------
         * CASE 1:
         * Không chọn gì -> hiển thị toàn bộ
         * -----------------------------------------------------
         */
        List<SupplierModel> suppliers
                = supplierDAO.findAll();

        List<ProductModel> products
                = productDAO.findAll(
                        null,
                        null,
                        null,
                        "newest",
                        false);

        /*
         * -----------------------------------------------------
         * CASE 2:
         * Đã chọn Supplier
         *
         * Chỉ hiển thị ProductVariant mà Supplier cung cấp.
         * -----------------------------------------------------
         */
        if (supplierId > 0) {

            List<Integer> suppliedVariantIds
                    = supplierDAO.findProductVariantIds(
                            supplierId);

            products = filterProductsByVariants(
                    products,
                    suppliedVariantIds);
        }

        /*
         * -----------------------------------------------------
         * CASE 3:
         * Đã chọn ProductVariant
         *
         * Chỉ hiển thị Supplier cung cấp variant đó.
         * -----------------------------------------------------
         */
        if (variantId > 0) {

            List<Integer> supplierIds
                    = supplierDAO.findSuppliersByProductVariant(
                            variantId);

            suppliers = filterSuppliersByIds(
                    suppliers,
                    supplierIds);
        }

        request.setAttribute(
                "suppliers",
                suppliers);

        request.setAttribute(
                "products",
                products);

        request.setAttribute(
                "selectedSupplierId",
                supplierId);

        request.setAttribute(
                "selectedVariantId",
                variantId);

        request.getRequestDispatcher(
                "/views/manager/import-detail.jsp")
                .forward(request, response);
    }

    /* =========================================================
       DETAIL
       ========================================================= */
    private void showDetail(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int id = integer(
                request.getParameter("id"),
                0);

        if (id <= 0) {
            redirect(
                    request,
                    response,
                    "Invalid import order.",
                    false);
            return;
        }

        OrderModel order
                = importOrderDAO.findImportOrderDetail(id);

        if (order == null) {
            redirect(
                    request,
                    response,
                    "Import order not found.",
                    false);
            return;
        }

        request.setAttribute(
                "order",
                order);

        request.getRequestDispatcher(
                "/views/manager/import-detail.jsp")
                .forward(request, response);
    }

    /* =========================================================
       HISTORY
       ========================================================= */
    private void showHistory(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        int id = integer(
                request.getParameter("id"),
                0);

        if (id <= 0) {
            redirect(
                    request,
                    response,
                    "Invalid import order.",
                    false);
            return;
        }

        OrderModel order
                = importOrderDAO.findImportOrderDetail(id);

        if (order == null) {
            redirect(
                    request,
                    response,
                    "Import order not found.",
                    false);
            return;
        }

        request.setAttribute(
                "order",
                order);

        request.setAttribute(
                "history",
                importOrderDAO.findStatusHistory(id));

        request.getRequestDispatcher(
                "/views/manager/import-history.jsp")
                .forward(request, response);
    }

    /* =========================================================
       CREATE
       ========================================================= */
    private void createImportOrder(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {

        HttpSession session
                = request.getSession();

        UserModel currentUser
                = (UserModel) session.getAttribute(
                        "currentUser");

        if (currentUser == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/login");
            return;
        }

        int supplierId = integer(
                request.getParameter("supplierId"),
                0);

        String[] variantIds
                = request.getParameterValues(
                        "variantId");

        String[] quantities
                = request.getParameterValues(
                        "quantity");

        String[] unitPrices
                = request.getParameterValues(
                        "unitPrice");

        String method = trim(
                request.getParameter("method"));

        String note = trim(
                request.getParameter("note"));

        if (supplierId <= 0) {
            redirect(
                    request,
                    response,
                    "Please select a supplier.",
                    false);
            return;
        }

        if (variantIds == null
                || quantities == null
                || unitPrices == null
                || variantIds.length == 0) {

            redirect(
                    request,
                    response,
                    "Please add at least one product.",
                    false);
            return;
        }

        if (variantIds.length
                != quantities.length
                || variantIds.length
                != unitPrices.length) {

            redirect(
                    request,
                    response,
                    "Invalid product data.",
                    false);
            return;
        }

        /*
         * -----------------------------------------------------
         * BACKEND VALIDATION
         *
         * Không tin dữ liệu từ JSP.
         *
         * Supplier phải thực sự cung cấp tất cả variants.
         * -----------------------------------------------------
         */
        Set<Integer> suppliedVariantIds
                = new HashSet<>(
                        supplierDAO.findProductVariantIds(
                                supplierId));

        List<OrderItemModel> items
                = new ArrayList<>();

        BigDecimal totalPrice
                = BigDecimal.ZERO;

        for (int i = 0;
                i < variantIds.length;
                i++) {

            int variantId = integer(
                    variantIds[i],
                    0);

            int quantity = integer(
                    quantities[i],
                    0);

            BigDecimal unitPrice;

            try {
                unitPrice
                        = new BigDecimal(
                                unitPrices[i]);
            } catch (NumberFormatException e) {
                redirect(
                        request,
                        response,
                        "Invalid unit price.",
                        false);
                return;
            }

            if (variantId <= 0
                    || !supplierDAO.isSupplierProvidingVariant(
                            supplierId,
                            variantId)) {

                redirect(
                        request,
                        response,
                        "Selected product is not supplied "
                        + "by this supplier.",
                        false);
                return;
            }

            if (quantity <= 0) {
                redirect(
                        request,
                        response,
                        "Quantity must be greater than 0.",
                        false);
                return;
            }

            if (unitPrice.compareTo(
                    BigDecimal.ZERO) <= 0) {

                redirect(
                        request,
                        response,
                        "Unit price must be greater than 0.",
                        false);
                return;
            }

            OrderItemModel item
                    = new OrderItemModel();

            item.setVariantId(variantId);
            item.setAmount(quantity);
            item.setUnitPrice(unitPrice);

            items.add(item);

            totalPrice = totalPrice.add(
                    unitPrice.multiply(
                            BigDecimal.valueOf(
                                    quantity)));
        }

        /*
         * ImportOrderDAO đã xử lý transaction:
         *
         * Transaction
         * Transaction_ProductVariant
         * TransactionStatusHistory = ORDER
         */
        int transactionId
                = importOrderDAO.createImportOrder(
                        currentUser.getId(),
                        supplierId,
                        totalPrice,
                        totalPrice,
                        BigDecimal.ZERO,
                        method,
                        note,
                        items);

        session.setAttribute(
                "message",
                "Import order #"
                + transactionId
                + " created successfully.");

        response.sendRedirect(
                request.getContextPath()
                + "/manager/import-list");
    }

    /* =========================================================
       COMPLETE
       ========================================================= */
    private void completeImportOrder(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {

        HttpSession session
                = request.getSession();

        UserModel currentUser
                = (UserModel) session.getAttribute(
                        "currentUser");

        if (currentUser == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/login");
            return;
        }

        int id = integer(
                request.getParameter("id"),
                0);

        if (id <= 0) {
            redirect(
                    request,
                    response,
                    "Invalid import order.",
                    false);
            return;
        }

        OrderModel order
                = importOrderDAO.findImportOrderDetail(id);

        if (order == null) {
            redirect(
                    request,
                    response,
                    "Import order not found.",
                    false);
            return;
        }

        if (!"ORDER".equalsIgnoreCase(
                order.getStatus())) {

            redirect(
                    request,
                    response,
                    "Only ORDER import orders "
                    + "can be completed.",
                    false);
            return;
        }

        /*
         * DAO:
         *
         * 1. UPDATE Transaction.Status
         * 2. INSERT TransactionStatusHistory
         * 3. UPDATE Inventory
         *
         * tất cả trong cùng transaction.
         */
        importOrderDAO.completeImportOrder(
                id,
                currentUser.getId());

        session.setAttribute(
                "message",
                "Import order #"
                + id
                + " completed successfully.");

        response.sendRedirect(
                request.getContextPath()
                + "/manager/import-list");
    }

    /* =========================================================
       FILTER HELPERS
       ========================================================= */
    private List<SupplierModel> filterSuppliersByIds(
            List<SupplierModel> suppliers,
            List<Integer> supplierIds) {

        Set<Integer> ids
                = new HashSet<>(supplierIds);

        List<SupplierModel> result
                = new ArrayList<>();

        for (SupplierModel supplier : suppliers) {
            if (ids.contains(supplier.getId())) {
                result.add(supplier);
            }
        }

        return result;
    }

    private List<ProductModel> filterProductsByVariants(
            List<ProductModel> products,
            List<Integer> variantIds) {

        Set<Integer> ids
                = new HashSet<>(variantIds);

        List<ProductModel> result
                = new ArrayList<>();

        for (ProductModel product : products) {

            List<ProductVariantModel> variants
                    = product.getVariants();

            if (variants == null) {
                continue;
            }

            List<ProductVariantModel> filteredVariants
                    = new ArrayList<>();

            for (ProductVariantModel variant
                    : variants) {

                if (ids.contains(variant.getId())) {
                    filteredVariants.add(variant);
                }
            }

            if (!filteredVariants.isEmpty()) {

                /*
                 * Không làm mất ProductModel.
                 * Chỉ giữ lại variant mà supplier cung cấp.
                 */
                product.setVariants(
                        filteredVariants);

                result.add(product);
            }
        }

        return result;
    }

    /* =========================================================
       COMMON
       ========================================================= */
    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response,
            String message,
            boolean success)
            throws IOException {

        if (success) {
            request.getSession().setAttribute(
                    "message",
                    message);
        } else {
            request.getSession().setAttribute(
                    "error",
                    message);
        }

        response.sendRedirect(
                request.getContextPath()
                + "/manager/import-list");
    }

    private static String value(
            String value,
            String defaultValue) {

        if (value == null
                || value.isBlank()) {
            return defaultValue;
        }

        return value.trim();
    }

    private static String trim(String value) {
        return value == null
                ? ""
                : value.trim();
    }

    private static int integer(
            String value,
            int defaultValue) {

        try {
            return Integer.parseInt(
                    value == null
                            ? ""
                            : value.trim());

        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
