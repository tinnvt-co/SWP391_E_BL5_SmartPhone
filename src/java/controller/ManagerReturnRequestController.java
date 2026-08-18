package controller;

import DAO.RefundDAO;
import DAO.OrderDAO;
import model.OrderModel;
import model.RefundModel;
import model.UserModel;
import service.VnpayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

/**
 * Manager-side refund approval queue.
 *
 * GET /manager/return-request -> list pending + filter GET
 * /manager/return-request?action=view&id=N -> detail + thread POST
 * /manager/return-request?action=decide&id=N&... -> approve or reject
 */
@WebServlet(name = "ManagerReturnRequestController", urlPatterns = {"/manager/return-request"})
public class ManagerReturnRequestController extends HttpServlet {

    private final RefundDAO dao = new RefundDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final VnpayService vnpayService = new VnpayService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel manager = requireManager(request, response);
        if (manager == null) {
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("view".equalsIgnoreCase(action)) {
                int id = parseInt(request.getParameter("id"));
                if (id <= 0) {
                    response.sendRedirect(request.getContextPath() + "/manager/return-request");
                    return;
                }
                RefundModel r = dao.findDetail(id);
                if (r == null) {
                    response.sendRedirect(request.getContextPath() + "/manager/return-request");
                    return;
                }
                request.setAttribute("request", r);
                request.setAttribute("view", "detail");
                request.setAttribute("filter", buildFilter(request));
                request.getRequestDispatcher("/views/manager/return-request-list.jsp").forward(request, response);
                return;
            }

            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");
            if (status != null && !dao.findAllStatuses().contains(status)) {
                status = null;
            }
            List<RefundModel> requests = dao.findAllForManager(keyword, status);
            request.setAttribute("requests", requests);
            request.setAttribute("view", "list");
            request.setAttribute("filter", buildFilter(request));
            request.getRequestDispatcher("/views/manager/return-request-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load refund queue", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel manager = requireManager(request, response);
        if (manager == null) {
            return;
        }

        String action = request.getParameter("action");
        if (!"decide".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/manager/return-request");
            return;
        }

        int id = parseInt(request.getParameter("id"));
        String decision = request.getParameter("decision");
        if (id <= 0 || decision == null) {
            response.sendRedirect(request.getContextPath() + "/manager/return-request");
            return;
        }
        boolean approve;
        switch (decision.toLowerCase()) {
            case "approve":
            case "approved":
            case "1":
                approve = true;
                break;
            case "reject":
            case "rejected":
            case "0":
                approve = false;
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/manager/return-request?action=view&id=" + id
                        + "&flash=" + encode("Invalid decision."));
                return;
        }

        try {
            if (approve) {
                RefundModel refund = dao.findDetail(id);
                OrderModel order = refund == null ? null : orderDAO.findOrderDetail(refund.getTransactionId());
                if (order != null && isPaidOrder(order)) {
                    if (!refund.isHasBankInfo()) {
                        response.sendRedirect(request.getContextPath() + "/manager/return-request?action=view&id=" + id
                                + "&flash=" + encode("Customer bank information is required before VNPay refund."));
                        return;
                    }
                    String txnRef = "RF-" + id + "-" + manager.getId() + "-" + System.currentTimeMillis();
                    String paymentUrl = vnpayService.createPaymentUrl(request,
                            order.getPaidAmount().intValue(),
                            "Hoan tien SmartPhone store refund " + id,
                            txnRef);
                    response.sendRedirect(paymentUrl);
                    return;
                }
            }
            boolean ok = dao.decide(id, approve, manager.getId());
            if (!ok) {
                response.sendRedirect(request.getContextPath() + "/manager/return-request?action=view&id=" + id
                        + "&flash=" + encode("This request is no longer pending."));
                return;
            }
            response.sendRedirect(request.getContextPath() + "/manager/return-request?action=view&id=" + id
                    + "&flash=" + encode(approve ? "Refund approved." : "Refund rejected."));
        } catch (SQLException ex) {
            throw new ServletException("Cannot update refund", ex);
        }
    }

    private Object buildFilter(HttpServletRequest request) {
        FilterState f = new FilterState();
        f.keyword = request.getParameter("keyword");
        f.status = request.getParameter("status");
        return f;
    }

    private UserModel requireManager(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        UserModel user = (UserModel) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        String role = (String) session.getAttribute("currentRole");
        if (role == null || !(role.equalsIgnoreCase("MANAGER") || role.equalsIgnoreCase("ADMIN")
                || role.equalsIgnoreCase("STAFF"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    private static int parseInt(String value) {
        if (value == null || value.isBlank()) {
            return 0;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, java.nio.charset.StandardCharsets.UTF_8);
    }

    private static boolean isPaidOrder(OrderModel order) {
        BigDecimal paid = order == null ? null : order.getPaidAmount();
        return paid != null && paid.compareTo(BigDecimal.ZERO) > 0;
    }

    public static class FilterState {

        public String keyword;
        public String status;

        public String getKeyword() {
            return keyword;
        }

        public String getStatus() {
            return status;
        }
    }
}
