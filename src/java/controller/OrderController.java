package controller;

import DAO.ImportOrderDAO;
import DAO.OrderDAO;
import jakarta.mail.Session;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Set;
import model.OrderModel;
import model.UserModel;

@WebServlet(name = "OrderController", urlPatterns = {"/staff/orders"})
/**
 * OrderController - Controller xu ly cac thao tac quan ly don hang cua Staff.
 *
 * Tinh nang chinh:
 * - HIEN THI danh sach don hang (doOrder)
 * - CAP NHAT trang thai don hang (doPost)
 * - Xem CHI TIET don hang (showDetail)
 *
 * Quy tac phan quyen:
 * - Staff chi duoc thay doi cac trang thai: PENDING -> CONFIRMED -> PROCESSING -> SHIPPING
 * - Staff KHONG duoc phep thay doi cac trang thai: COMPLETED, REFUNDED, CANCELLED, DELIVERY_FAILED
 * - Staff KHONG duoc phep danh dau don hang thanh DELIVERED (chi Shipper lam dien)
 * - Staff KHONG duoc phep huy don hang (chi Manager hoac qua yeu cau huy cua KH)
 */
public class OrderController extends HttpServlet {

    private static final int MAX_SEARCH_LENGTH = 100;
    private static final Set<String> VALID_STATUSES = Set.of(
            "PENDING", "CONFIRMED", "PROCESSING", "SHIPPING", "DELIVERED",
            "COMPLETED", "CANCEL_REQUESTED", "CANCELLED");
    private static final Set<String> VALID_TYPES = Set.of("ORDER", "IMPORT", "ALL");

    /**
     * Statuses a staff member may choose when updating an order. -
     * CANCEL_REQUESTED / CANCELLED / DELIVERED are intentionally excluded:
     * staff cannot cancel orders nor mark them as delivered.
     */
    private static final Set<String> STAFF_UPDATABLE_STATUSES = Set.of(
            "PENDING", "CONFIRMED", "PROCESSING", "SHIPPING");

    /**
     * Cac trang thai don hang ma Staff KHONG the thay doi.
     * Khi don hang da COMPLETED, REFUNDED hoac CANCELLED thi khong duoc phep sua trang thai nua.
     * Vi: don hang da hoan thanh => khong the quay lai trang thai truoc.
     */
    private static final Set<String> STAFF_IMMUTABLE_STATUSES = Set.of(
            "COMPLETED", "REFUNDED", "CANCELLED", "DELIVERY_FAILED");
    private final OrderDAO orderDAO = new OrderDAO();
    private final ImportOrderDAO importOrderDAO = new ImportOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = value(request.getParameter("action"), "list");
            if ("detail".equals(action)) {
                showDetail(request, response);
                return;
            }
            listOrders(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load orders from database", exception);
        }
    }

    /**
     * XU LY YEU CAU CAP NHAT TRANG THAI DON HANG (doPost).
     *
     * Cac buoc thuc hien:
     * 1. Kiem tra nguoi dung da dang nhap chua
     * 2. Kiem tra don hang co ton tai khong
     * 3. Kiem tra don hang co o trang thai IMMUTABLE khong (COMPLETED, REFUNDED, CANCELLED, DELIVERY_FAILED)
     *    -> Neu la IMMUTABLE thi tra ve loi, khong cho cap nhat
     * 4. Kiem tra don hang IMPORT chi duoc cap nhat thanh COMPLETED
     * 5. Kiem tra don hang ORDER khong duoc danh dau thanh DELIVERED
     * 6. Neu tat ca kiem tra deu qua -> goi DAO de cap nhat trang thai
     *
     * @param request  HttpServletRequest chua orderId va status moi
     * @param response HttpServletResponse de redirect ve trang danh sach
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = value(request.getParameter("action"), "update-status");

        try {
            HttpSession session = request.getSession();
            if ("update-status".equals(action)) {
                int orderId = integer(request.getParameter("id"), 0);

                String status = request.getParameter("status");
                UserModel currentUser
                        = (UserModel) session.getAttribute(
                                "currentUser");

                if (currentUser == null) {
                    response.sendRedirect(
                            request.getContextPath()
                            + "/login");
                    return;
                }
                if (orderId <= 0 || status == null || !VALID_STATUSES.contains(status)) {
                    redirectBack(request, response, "Invalid request");
                    return;
                }
                OrderModel existing = orderDAO.findOrderDetail(orderId);
                if (existing == null) {
                    redirectBack(request, response, "Order not found");
                    return;
                }
                // Neu don hang da o trang thai IMMUTABLE (COMPLETED, REFUNDED, CANCELLED, DELIVERY_FAILED) thi khong cho phep thay doi
                if (STAFF_IMMUTABLE_STATUSES.contains(existing.getStatus())) {
                    redirectBack(request, response, "Orders with status '" + existing.getStatus() + "' cannot be updated");
                    return;
                }
                boolean isImport = "IMPORT".equalsIgnoreCase(existing.getType());
                if (isImport && !"COMPLETED".equals(status)) {
                    redirectBack(request, response, "Import orders can only be updated to COMPLETED");
                    return;
                }
                if (!isImport && "DELIVERED".equals(status)) {
                    redirectBack(request, response, "Staff cannot mark orders as DELIVERED");
                    return;
                }
                if (!isImport && !STAFF_UPDATABLE_STATUSES.contains(status)) {
                    redirectBack(request, response, "Invalid status for this order");
                    return;
                }

                boolean ok;
                if (isImport) {
                    ok = importOrderDAO.completeImportOrder(
                            orderId,
                            currentUser.getId());
                } else {
                    ok = orderDAO.updateStatus(orderId, status, currentUser.getId());
                }
                redirectBack(request, response, ok ? "Order status updated" : "Cannot update order");
            }
        } catch (SQLException exception) {
            redirectBack(request, response, "Database error: " + exception.getMessage());
        }
    }

    /**
     * HIEN THI DANH SACH DON HANG (doGet).
     *
     * Lay cac tham so loc tu request:
     * - q: tu khoa tim kiem (theo ma don, ten KH, sdt)
     * - status: loc theo trang thai don hang
     * - type: loc theo loai (ORDER hoac IMPORT)
     * - sort: sap xep (newest, oldest, total-desc, total-asc)
     *
     * Tra ve:
     * - Danh sach don hang phan trang (10 don/trang)
     * - Tong so trang, trang hien tai
     * - Cac bo loc de hien thi tren giao dien
     *
     * @param request  HttpServletRequest
     * @param response HttpServletResponse
     */
    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = normalizeKeyword(request.getParameter("q"));
        String status = normalizeStatus(request.getParameter("status"));
        String type = normalizeType(request.getParameter("type"));
        String sort = normalizeSort(request.getParameter("sort"));

        String validationError = validateSearch(keyword);

        if (validationError != null) {
            request.setAttribute("orders", java.util.Collections.emptyList());
            request.setAttribute("validationError", validationError);
        } else {
            boolean excludeImport = "ORDER".equals(type);
            request.setAttribute("orders",
                    orderDAO.findOrders(keyword, status, type, sort, excludeImport));
        }

        request.setAttribute("statuses", orderDAO.findAllStatuses());
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedType", "ALL".equals(type) ? "ALL" : type);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("totalToday", orderDAO.countTodaysOrders());
        request.setAttribute("totalProcessing", orderDAO.countProcessing());
        request.setAttribute("totalDelivered", orderDAO.countDelivered());
        request.setAttribute("totalCancelled", orderDAO.countCancelled());

        request.getRequestDispatcher("/views/staff/order-list.jsp").forward(request, response);
    }

    /**
     * HIEN THI CHI TIET MOT DON HANG (doGet - action=detail).
     *
     * Lay thong tin chi tiet don hang theo orderId.
     * Dong thoi truyen danh sach trang thai co the chon:
     * - Neu la IMPORT: chi co the chon COMPLETED
     * - Neu la ORDER: chi co the chon PENDING, CONFIRMED, PROCESSING, SHIPPING
     *
     * @param request  HttpServletRequest chua id cua don hang
     * @param response HttpServletResponse de forward sang trang chi tiet
     */
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int orderId = integer(request.getParameter("id"), 0);
        OrderModel order = orderDAO.findOrderDetail(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }
        request.setAttribute("order", order);
        boolean isImportOrder = "IMPORT".equalsIgnoreCase(order.getType());
        request.setAttribute("statuses", isImportOrder ? Set.of("COMPLETED") : STAFF_UPDATABLE_STATUSES);
        request.getRequestDispatcher("/views/staff/order-detail.jsp").forward(request, response);
    }

    /**
     * CHUYEN HUONG VE TRANG TRUOC (redirect back).
     *
     * Muc dich: Sau khi xu ly xong (thanh cong hoac that bai), quay ve trang ma nguoi dung
     * da dang xem truoc do (su dung Referer header).
     *
     * Logic:
     * - Neu co Referer -> su dung lai URL do (nhom cac tham so status/message cu)
     * - Neu khong co Referer -> chuyen ve /staff/orders
     * - Loai bo tham so 'status' va 'message' cu khoi URL de tranh loi
     * - Them tham so 'message' chua thong bao ket qua thao tac
     *
     * @param request  HttpServletRequest de lay Referer
     * @param response HttpServletResponse de sendRedirect
     * @param message  Thong bao hien thi sau khi chuyen huong (thanh cong/that bai)
     */
    private void redirectBack(HttpServletRequest request, HttpServletResponse response,
            String message) throws IOException {
        String referer = request.getHeader("Referer");
        String base = referer != null && !referer.isBlank()
                ? referer
                : request.getContextPath() + "/staff/orders";
        int qIndex = base.indexOf('?');
        String path = qIndex >= 0 ? base.substring(0, qIndex) : base;
        String query = qIndex >= 0 ? base.substring(qIndex + 1) : "";
        StringBuilder cleaned = new StringBuilder();
        if (!query.isEmpty()) {
            for (String pair : query.split("&")) {
                int eq = pair.indexOf('=');
                String key = eq >= 0 ? pair.substring(0, eq) : pair;
                if (key.equals("status") || key.equals("message")) {
                    continue;
                }
                if (cleaned.length() > 0) {
                    cleaned.append('&');
                }
                cleaned.append(pair);
            }
        }
        StringBuilder target = new StringBuilder(path);
        target.append("?");
        if (cleaned.length() > 0) {
            target.append(cleaned).append('&');
        }
        target.append("message=").append(java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
        response.sendRedirect(target.toString());
    }

    static int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
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

    private String normalizeStatus(String input) {
        if (input == null || input.isBlank()) {
            return "";
        }
        return VALID_STATUSES.contains(input) ? input : "";
    }

    private String normalizeType(String input) {
        if (input == null || input.isBlank()) {
            return "ALL";
        }
        return VALID_TYPES.contains(input) ? input : "ALL";
    }

    private String normalizeSort(String input) {
        if (input == null || input.isBlank()) {
            return "newest";
        }
        return Set.of("newest", "oldest", "total-desc", "total-asc").contains(input) ? input : "newest";
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
