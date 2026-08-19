package controller;

import DAO.SupplierDAO;
import model.SupplierModel;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "SupplierController", urlPatterns = {"/manager/supplier"})
public class SupplierController extends HttpServlet {

    private final SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {

            // =========================
            // CREATE FORM
            // =========================
            if ("create".equals(action)) {

                request.getRequestDispatcher(
                        "/views/manager/supplier-detail.jsp")
                        .forward(request, response);

                return;
            }

            // =========================
            // EDIT FORM
            // =========================
            if ("edit".equals(action)) {

                int id = parseInt(
                        request.getParameter("id"), 0);

                if (id <= 0) {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }

                SupplierModel supplier
                        = supplierDAO.findById(id);

                if (supplier == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                List<Integer> productVariantIds
                        = supplierDAO.findProductVariantIds(id);

                request.setAttribute(
                        "supplier", supplier);

                request.setAttribute(
                        "productVariantIds",
                        productVariantIds);

                request.getRequestDispatcher(
                        "/views/manager/supplier-detail.jsp")
                        .forward(request, response);

                return;
            }

            // =========================
            // DETAIL
            // =========================
            if ("detail".equals(action)) {

                int id = parseInt(
                        request.getParameter("id"), 0);

                if (id <= 0) {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }

                SupplierModel supplier
                        = supplierDAO.findById(id);

                if (supplier == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                List<Integer> productVariantIds
                        = supplierDAO.findProductVariantIds(id);

                request.setAttribute(
                        "supplier", supplier);

                request.setAttribute(
                        "productVariantIds",
                        productVariantIds);

                request.getRequestDispatcher(
                        "/views/manager/supplier-detail.jsp")
                        .forward(request, response);

                return;
            }

            // =========================
            // LIST + PAGINATION
            // =========================
            final int PAGE_SIZE = 10;

            String keyword
                    = request.getParameter("keyword");

            String status
                    = request.getParameter("status");

            int requestedPage
                    = Math.max(
                            1,
                            parseInt(
                                    request.getParameter("page"),
                                    1));

            /*
         * Get total suppliers first.
             */
            int totalSuppliers
                    = supplierDAO.countAll(
                            keyword,
                            status);

            int totalPages
                    = Math.max(
                            1,
                            (int) Math.ceil(
                                    totalSuppliers
                                    / (double) PAGE_SIZE));

            int currentPage
                    = Math.min(
                            requestedPage,
                            totalPages);

            int offset
                    = (currentPage - 1)
                    * PAGE_SIZE;

            /*
         * Show 5 page buttons around current page.
         *
         * Example:
         *
         * 1 2 3 4 5
         *
         * or
         *
         * 3 4 5 6 7
             */
            int startPage
                    = Math.max(
                            1,
                            currentPage - 2);

            int endPage
                    = Math.min(
                            totalPages,
                            startPage + 4);

            if (endPage - startPage < 4) {

                startPage
                        = Math.max(
                                1,
                                endPage - 4);
            }

            List<SupplierModel> suppliers
                    = supplierDAO.findAll(
                            keyword,
                            status,
                            PAGE_SIZE,
                            offset);

            // =========================
            // FLASH MESSAGE
            // =========================
            HttpSession session
                    = request.getSession();

            Object msgOk
                    = session.getAttribute("msgOk");

            Object msgErr
                    = session.getAttribute("msgErr");

            if (msgOk != null) {

                request.setAttribute(
                        "message",
                        msgOk);

                session.removeAttribute("msgOk");
            }

            if (msgErr != null) {

                request.setAttribute(
                        "error",
                        msgErr);

                session.removeAttribute("msgErr");
            }

            // =========================
            // JSP ATTRIBUTES
            // =========================
            request.setAttribute(
                    "suppliers",
                    suppliers);

            request.setAttribute(
                    "keyword",
                    keyword);

            request.setAttribute(
                    "status",
                    status);

            request.setAttribute(
                    "totalSuppliers",
                    totalSuppliers);

            request.setAttribute(
                    "currentPage",
                    currentPage);

            request.setAttribute(
                    "totalPages",
                    totalPages);

            request.setAttribute(
                    "startPage",
                    startPage);

            request.setAttribute(
                    "endPage",
                    endPage);

            request.setAttribute(
                    "pageSize",
                    PAGE_SIZE);

            request.getRequestDispatcher(
                    "/views/manager/supplier-list.jsp")
                    .forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot load suppliers from database",
                    e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action
                = request.getParameter("action");

        HttpSession session
                = request.getSession();

        try {

            // =========================
            // CREATE
            // =========================
            if ("create".equals(action)) {

                createSupplier(
                        request,
                        session);

            } // =========================
            // UPDATE
            // =========================
            else if ("update".equals(action)) {

                updateSupplier(
                        request,
                        session);

            } // =========================
            // DEACTIVATE
            // =========================
            else if ("deactivate".equals(action)) {

                int id = parseInt(
                        request.getParameter("id"),
                        0);

                if (id <= 0) {

                    session.setAttribute(
                            "msgErr",
                            "Supplier ID không hợp lệ.");

                } else {

                    boolean ok
                            = supplierDAO.deactivate(id);

                    session.setAttribute(
                            ok ? "msgOk" : "msgErr",
                            ok
                                    ? "Đã vô hiệu hóa supplier."
                                    : "Không thể vô hiệu hóa supplier.");
                }
            } // =========================
            // ACTIVATE
            // =========================
            else if ("activate".equals(action)) {

                int id = parseInt(
                        request.getParameter("id"),
                        0);

                if (id <= 0) {

                    session.setAttribute(
                            "msgErr",
                            "Supplier ID không hợp lệ.");

                } else {

                    boolean ok
                            = supplierDAO.activate(id);

                    session.setAttribute(
                            ok ? "msgOk" : "msgErr",
                            ok
                                    ? "Đã kích hoạt supplier."
                                    : "Không thể kích hoạt supplier.");
                }
            } // =========================
            // UPDATE PRODUCT VARIANTS
            // =========================
            else if ("updateProducts".equals(action)) {

                updateProductVariants(
                        request,
                        session);
            } else {

                session.setAttribute(
                        "msgErr",
                        "Action không hợp lệ.");
            }

        } catch (SQLException e) {

            session.setAttribute(
                    "msgErr",
                    "Có lỗi xảy ra khi thao tác với supplier.");

        } catch (Exception e) {

            session.setAttribute(
                    "msgErr",
                    "Dữ liệu không hợp lệ.");
        }

        response.sendRedirect(
                request.getContextPath()
                + "/manager/supplier");
    }

    // =========================================================
    // CREATE SUPPLIER
    // =========================================================
    private void createSupplier(
            HttpServletRequest request,
            HttpSession session)
            throws SQLException {

        String name
                = normalize(request.getParameter("name"));

        String address
                = normalize(request.getParameter("address"));

        String phone
                = normalize(request.getParameter("phone"));

        String description
                = normalize(request.getParameter("description"));

        String note
                = normalize(request.getParameter("note"));

        // -------------------------
        // VALIDATE
        // -------------------------
        String error
                = validateSupplier(
                        name,
                        address,
                        phone,
                        description,
                        note);

        if (error != null) {

            session.setAttribute(
                    "msgErr",
                    error);

            return;
        }

        SupplierModel supplier
                = new SupplierModel();

        supplier.setName(name);
        supplier.setAddress(address);
        supplier.setPhone(phone);
        supplier.setDescription(description);
        supplier.setNote(note);
        supplier.setStatus("ACTIVE");

        int supplierId
                = supplierDAO.create(supplier);

        if (supplierId > 0) {

            session.setAttribute(
                    "msgOk",
                    "Tạo supplier thành công.");

        } else {

            session.setAttribute(
                    "msgErr",
                    "Không thể tạo supplier.");
        }
    }

    // =========================================================
    // UPDATE SUPPLIER
    // =========================================================
    private void updateSupplier(
            HttpServletRequest request,
            HttpSession session)
            throws SQLException {

        int id
                = parseInt(
                        request.getParameter("id"),
                        0);

        if (id <= 0) {

            session.setAttribute(
                    "msgErr",
                    "Supplier ID không hợp lệ.");

            return;
        }

        String name
                = normalize(request.getParameter("name"));

        String address
                = normalize(request.getParameter("address"));

        String phone
                = normalize(request.getParameter("phone"));

        String description
                = normalize(request.getParameter("description"));

        String note
                = normalize(request.getParameter("note"));

        String status
                = normalize(request.getParameter("status"));

        String error
                = validateSupplier(
                        name,
                        address,
                        phone,
                        description,
                        note);

        if (error != null) {

            session.setAttribute(
                    "msgErr",
                    error);

            return;
        }

        if (!"ACTIVE".equals(status)
                && !"INACTIVE".equals(status)) {

            session.setAttribute(
                    "msgErr",
                    "Status không hợp lệ.");

            return;
        }

        SupplierModel supplier
                = new SupplierModel();

        supplier.setId(id);
        supplier.setName(name);
        supplier.setAddress(address);
        supplier.setPhone(phone);
        supplier.setDescription(description);
        supplier.setNote(note);
        supplier.setStatus(status);

        boolean ok
                = supplierDAO.update(supplier);

        session.setAttribute(
                ok ? "msgOk" : "msgErr",
                ok
                        ? "Cập nhật supplier thành công."
                        : "Không thể cập nhật supplier.");
    }

    // =========================================================
    // UPDATE SUPPLIER - PRODUCT VARIANTS
    // =========================================================
    private void updateProductVariants(
            HttpServletRequest request,
            HttpSession session)
            throws SQLException {

        int supplierId
                = parseInt(
                        request.getParameter("supplierId"),
                        0);

        if (supplierId <= 0) {

            session.setAttribute(
                    "msgErr",
                    "Supplier ID không hợp lệ.");

            return;
        }

        /*
         * HTML:
         *
         * <input type="checkbox"
         *        name="productVariantIds"
         *        value="1">
         *
         * <input type="checkbox"
         *        name="productVariantIds"
         *        value="2">
         */
        String[] values
                = request.getParameterValues(
                        "productVariantIds");

        List<Integer> productVariantIds
                = new ArrayList<>();

        if (values != null) {

            for (String value : values) {

                int variantId
                        = parseInt(value, 0);

                if (variantId > 0
                        && !productVariantIds.contains(
                                variantId)) {

                    productVariantIds.add(
                            variantId);
                }
            }
        }

        boolean ok
                = supplierDAO.updateProductVariants(
                        supplierId,
                        productVariantIds);

        session.setAttribute(
                ok ? "msgOk" : "msgErr",
                ok
                        ? "Cập nhật sản phẩm của supplier thành công."
                        : "Không thể cập nhật sản phẩm của supplier.");
    }

    // =========================================================
    // VALIDATION
    // =========================================================
    private String validateSupplier(
            String name,
            String address,
            String phone,
            String description,
            String note) {

        if (name.isEmpty()) {
            return "Supplier name không được để trống.";
        }

        if (name.length() > 50) {
            return "Supplier name không được vượt quá 50 ký tự.";
        }

        if (address.isEmpty()) {
            return "Address không được để trống.";
        }

        if (address.length() > 255) {
            return "Address không được vượt quá 255 ký tự.";
        }

        if (phone.isEmpty()) {
            return "Phone không được để trống.";
        }

        if (phone.length() > 255) {
            return "Phone không được vượt quá 255 ký tự.";
        }

        /*
         * Cho phép:
         * 0123456789
         * +84123456789
         * 012-345-6789
         * (024) 1234 5678
         */
        if (!phone.matches(
                "^[0-9+()\\-\\s]{8,255}$")) {

            return "Phone không đúng định dạng.";
        }

        if (description.length() > 255) {
            return "Description không được vượt quá 255 ký tự.";
        }

        if (note.length() > 255) {
            return "Note không được vượt quá 255 ký tự.";
        }

        return null;
    }

    // =========================================================
    // UTILITY
    // =========================================================
    private String normalize(String input) {
        if (input == null) {
            return "";
        }
        return input.trim()
                .replaceAll("\\s+", " ");
    }

    private int parseInt(
            String input,
            int fallback) {

        try {
            return Integer.parseInt(
                    input);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
