package controller;

import DAO.CancelRequestDAO;
import DAO.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CancelRequestModel;
import model.OrderModel;
import model.UserModel;
import service.VnpayService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ManagerCancelRequestController", urlPatterns = {"/manager/cancel-request"})
public class ManagerCancelRequestController extends HttpServlet {

    private static final int MAX_NOTE_LENGTH = 500;
    private static final int MAX_SEARCH_LENGTH = 100;

    private final CancelRequestDAO cancelDAO = new CancelRequestDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final VnpayService vnpayService = new VnpayService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        UserModel manager = (UserModel) session.getAttribute("currentUser");

        try {
            listRequests(request, response);
        } catch (SQLException exception) {
            throw new ServletException(exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        UserModel manager = (UserModel) session.getAttribute("currentUser");

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/manager/cancel-request");
            return;
        }

        try {
            switch (action) {
                case "approve":
                    handleApprove(request, response, manager);
                    return;
                case "reject":
                    handleReject(request, response, manager);
                    return;
                default:
                    redirectBack(request, response, "Invalid action", "/manager/cancel-request");
            }
        } catch (SQLException exception) {
            redirectBack(request, response, "Database error: " + exception.getMessage(),
                    "/manager/cancel-request");
        }
    }

    private void listRequests(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = normalizeKeyword(request.getParameter("q"));
        String sort = normalizeSort(request.getParameter("sort"));
        String view = request.getParameter("view");
        if (view == null || (!"history".equalsIgnoreCase(view) && !"pending".equalsIgnoreCase(view))) {
            view = "pending";
        }

        List<CancelRequestModel> requests = "history".equalsIgnoreCase(view)
                ? cancelDAO.findHistoryRequests(keyword, sort)
                : cancelDAO.findPendingRequests(keyword, sort);
        request.setAttribute("requests", requests);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("selectedView", view);
        request.setAttribute("totalPending", cancelDAO.countPending());
        request.setAttribute("totalApproved", cancelDAO.countApproved());
        request.setAttribute("totalRejected", cancelDAO.countRejected());
        request.getRequestDispatcher("/views/manager/cancel-request.jsp").forward(request, response);
    }

    private void handleApprove(HttpServletRequest request, HttpServletResponse response, UserModel manager)
            throws SQLException, IOException {
        int requestId = parseInt(request.getParameter("id"), 0);
        String managerNote = normalizeNote(request.getParameter("staffNote"));
        if (requestId <= 0) {
            redirectBack(request, response, "Invalid cancel request", "/manager/cancel-request");
            return;
        }
        CancelRequestModel cancelRequest = findById(requestId);
        if (cancelRequest == null || !cancelRequest.isPending()) {
            redirectBack(request, response, "Cancel request is no longer pending", "/manager/cancel-request");
            return;
        }
        OrderModel order = orderDAO.findOrderDetail(cancelRequest.getTransactionId());
        if (order == null) {
            redirectBack(request, response, "Related order not found", "/manager/cancel-request");
            return;
        }

       // Các đơn hàng đã thanh toán (qua VNPay) cần có giao dịch hoàn tiền qua VNPay
       // trước khi đánh dấu yêu cầu là đã được phê duyệt. Các đơn hàng COD có thể bị hủy
       // trực tiếp mà không cần hoàn tiền.
        if (isPaidOrder(order)) {
            if (!cancelRequest.isHasBankInfo()) {
                redirectBack(request, response,
                        "Customer bank information is required before VNPay refund for paid orders",
                        "/manager/cancel-request");
                return;
            }
            try {
                String txnRef = "CR-" + requestId + "-" + manager.getId() + "-" + System.currentTimeMillis();
                String paymentUrl = vnpayService.createPaymentUrl(
                        request,
                        order.getTotalPrice().intValue(),
                        "Hoan tien SmartPhone store cancel order " + cancelRequest.getTransactionId(),
                        txnRef);
                response.sendRedirect(paymentUrl);
                return;
            } catch (Exception ex) {
                redirectBack(request, response,
                        "Cannot start VNPay refund: " + ex.getMessage(),
                        "/manager/cancel-request");
                return;
            }
        }

        boolean ok = cancelDAO.approveRequest(requestId, cancelRequest.getTransactionId(),
                manager.getId(), managerNote);
        redirectBack(request, response, ok ? "Cancel request approved" : "Cannot approve cancel request",
                "/manager/cancel-request");
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response, UserModel manager)
            throws SQLException, IOException {
        int requestId = parseInt(request.getParameter("id"), 0);
        String managerNote = normalizeNote(request.getParameter("staffNote"));
        if (requestId <= 0) {
            redirectBack(request, response, "Invalid cancel request", "/manager/cancel-request");
            return;
        }
        CancelRequestModel cancelRequest = findById(requestId);
        if (cancelRequest == null || !cancelRequest.isPending()) {
            redirectBack(request, response, "Cancel request is no longer pending", "/manager/cancel-request");
            return;
        }
        boolean ok = cancelDAO.rejectRequest(requestId, manager.getId(), managerNote);
        if (ok) {
            OrderModel order = orderDAO.findOrderDetail(cancelRequest.getTransactionId());
            if (order != null && "CANCEL_REQUESTED".equalsIgnoreCase(order.getStatus())) {
                orderDAO.updateStatusWithNote(order.getId(), "PENDING", manager.getId(),
                        "Cancel request rejected by manager");
            }
        }
        redirectBack(request, response, ok ? "Cancel request rejected" : "Cannot reject cancel request",
                "/manager/cancel-request");
    }

    private CancelRequestModel findById(int id) throws SQLException {
        return cancelDAO.findById(id);
    }

    private boolean isPaidOrder(OrderModel order) {
        return order != null && order.getMethod() != null && "VNPAY".equalsIgnoreCase(order.getMethod());
    }

    private int parseInt(String input, int fallback) {
        try {
            if (input == null || input.isBlank()) {
                return fallback;
            }
            return Integer.parseInt(input.trim());
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }

    private String normalizeKeyword(String input) {
        if (input == null) {
            return "";
        }
        String trimmed = input.trim();
        if (trimmed.length() > MAX_SEARCH_LENGTH) {
            trimmed = trimmed.substring(0, MAX_SEARCH_LENGTH);
        }
        return trimmed;
    }

    private String normalizeSort(String input) {
        if (input == null) {
            return "newest";
        }
        return switch (input.toLowerCase()) {
            case "oldest" -> "oldest";
            default -> "newest";
        };
    }

    private String normalizeNote(String input) {
        if (input == null) {
            return "";
        }
        String trimmed = input.trim();
        if (trimmed.length() > MAX_NOTE_LENGTH) {
            trimmed = trimmed.substring(0, MAX_NOTE_LENGTH);
        }
        return trimmed;
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response,
                              String message, String basePath) throws IOException {
        String query = request.getParameter("view");
        StringBuilder target = new StringBuilder(request.getContextPath()).append(basePath);
        if (query != null && !query.isBlank()) {
            target.append("?view=").append(URLEncoder.encode(query, StandardCharsets.UTF_8));
        }
        if (message != null) {
            String key = message.toLowerCase().contains("error") || message.toLowerCase().contains("invalid")
                    || message.toLowerCase().contains("cannot")
                    ? "error" : "message";
            target.append(target.toString().contains("?") ? "&" : "?");
            target.append(key).append("=").append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        }
        response.sendRedirect(target.toString());
    }
}