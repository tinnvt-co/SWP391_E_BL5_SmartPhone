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

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "StaffCancelRequestController", urlPatterns = {"/staff/cancel-request"})
public class StaffCancelRequestController extends HttpServlet {

    private static final int MAX_NOTE_LENGTH = 500;
    private static final int MAX_SEARCH_LENGTH = 100;

    private final CancelRequestDAO cancelDAO = new CancelRequestDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = request.getParameter("action");
            if ("detail".equals(action)) {
                showDetail(request, response);
                return;
            }
            listRequests(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load cancel requests", exception);
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
        UserModel staff = (UserModel) session.getAttribute("currentUser");

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/staff/cancel-request");
            return;
        }

        try {
            switch (action) {
                case "approve":
                    handleApprove(request, response, staff);
                    return;
                case "reject":
                    handleReject(request, response, staff);
                    return;
                default:
                    redirectBack(request, response, "Invalid action", "/staff/cancel-request");
            }
        } catch (SQLException exception) {
            redirectBack(request, response, "Database error: " + exception.getMessage(),
                    "/staff/cancel-request");
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
        request.getRequestDispatcher("/views/staff/cancel-request.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int requestId = parseInt(request.getParameter("id"), 0);
        CancelRequestModel cancelRequest = findById(requestId);
        if (cancelRequest == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cancel request not found");
            return;
        }
        OrderModel order = orderDAO.findOrderDetail(cancelRequest.getTransactionId());
        request.setAttribute("cancelRequest", cancelRequest);
        request.setAttribute("order", order);
        request.getRequestDispatcher("/views/staff/cancel-request-detail.jsp").forward(request, response);
    }

    private void handleApprove(HttpServletRequest request, HttpServletResponse response, UserModel staff)
            throws SQLException, IOException {
        int requestId = parseInt(request.getParameter("id"), 0);
        String staffNote = normalizeNote(request.getParameter("staffNote"));
        if (requestId <= 0) {
            redirectBack(request, response, "Invalid cancel request", "/staff/cancel-request");
            return;
        }
        CancelRequestModel cancelRequest = findById(requestId);
        if (cancelRequest == null || !cancelRequest.isPending()) {
            redirectBack(request, response, "Cancel request is no longer pending", "/staff/cancel-request");
            return;
        }
        boolean ok = cancelDAO.approveRequest(requestId, cancelRequest.getTransactionId(),
                staff.getId(), staffNote);
        redirectBack(request, response, ok ? "Cancel request approved" : "Cannot approve cancel request",
                "/staff/cancel-request");
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response, UserModel staff)
            throws SQLException, IOException {
        int requestId = parseInt(request.getParameter("id"), 0);
        String staffNote = normalizeNote(request.getParameter("staffNote"));
        if (requestId <= 0) {
            redirectBack(request, response, "Invalid cancel request", "/staff/cancel-request");
            return;
        }
        CancelRequestModel cancelRequest = findById(requestId);
        if (cancelRequest == null || !cancelRequest.isPending()) {
            redirectBack(request, response, "Cancel request is no longer pending", "/staff/cancel-request");
            return;
        }
        boolean ok = cancelDAO.rejectRequest(requestId, staff.getId(), staffNote);
        if (ok) {
            // Reverting the order status back to its previous value isn't
            // tracked here, so we drop the CANCEL_REQUESTED flag back to the
            // original status the order had before the request was raised.
            // Staff can re-evaluate the order from the order list page.
            OrderModel order = orderDAO.findOrderDetail(cancelRequest.getTransactionId());
            if (order != null && "CANCEL_REQUESTED".equalsIgnoreCase(order.getStatus())) {
                orderDAO.updateStatusWithNote(order.getId(), "PENDING", staff.getId(),
                        "Cancel request rejected by staff");
            }
        }
        redirectBack(request, response, ok ? "Cancel request rejected" : "Cannot reject cancel request",
                "/staff/cancel-request");
    }

    private CancelRequestModel findById(int id) throws SQLException {
        return cancelDAO.findById(id);
    }

    private int parseInt(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    private String normalizeKeyword(String input) {
        if (input == null) {
            return "";
        }
        String trimmed = input.trim().replaceAll("\\s+", " ");
        if (trimmed.length() > MAX_SEARCH_LENGTH) {
            trimmed = trimmed.substring(0, MAX_SEARCH_LENGTH);
        }
        return trimmed;
    }

    private String normalizeSort(String input) {
        if (input == null || input.isBlank()) {
            return "newest";
        }
        return "oldest".equalsIgnoreCase(input) ? "oldest" : "newest";
    }

    private String normalizeNote(String input) {
        if (input == null) {
            return null;
        }
        String trimmed = input.trim();
        if (trimmed.length() > MAX_NOTE_LENGTH) {
            trimmed = trimmed.substring(0, MAX_NOTE_LENGTH);
        }
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response,
            String message, String fallbackPath) throws IOException {
        boolean isError = message != null && (
                message.startsWith("Cannot")
                || message.startsWith("Invalid")
                || message.startsWith("no longer")
                || message.startsWith("Database error"));
        String referer = request.getHeader("Referer");
        String base = referer != null && !referer.isBlank() ? referer : request.getContextPath() + fallbackPath;
        int qIndex = base.indexOf('?');
        String path = qIndex >= 0 ? base.substring(0, qIndex) : base;
        String query = qIndex >= 0 ? base.substring(qIndex + 1) : "";
        StringBuilder cleaned = new StringBuilder();
        if (!query.isEmpty()) {
            for (String pair : query.split("&")) {
                int eq = pair.indexOf('=');
                String key = eq >= 0 ? pair.substring(0, eq) : pair;
                if (key.equals("message") || key.equals("error")) {
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
        if (isError) {
            target.append("error=").append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        } else {
            target.append("message=").append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        }
        response.sendRedirect(target.toString());
    }
}
