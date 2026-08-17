package controller;

import DAO.CheckoutDAO;
import DAO.OrderDAO;
import DAO.ReturnRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import jakarta.mail.MessagingException;
import model.OrderModel;
import model.ReturnRequestModel;
import service.VnpayService;
import service.MailService;

public class VnpayReturnController extends HttpServlet {

    private final VnpayService vnpayService = new VnpayService();
    private final CheckoutDAO checkoutDAO = new CheckoutDAO();
    private final ReturnRequestDAO returnRequestDAO = new ReturnRequestDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final MailService mailService = new MailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        boolean validSignature = vnpayService.isValidReturn(request);
        boolean success = validSignature && vnpayService.isSuccess(request);
        String txnRef = request.getParameter("vnp_TxnRef");

        if (txnRef != null && txnRef.startsWith("RF-")) {
            handleRefundReturn(request, response, validSignature, success, txnRef);
            return;
        }

        int orderId = integer(txnRef);

        if (validSignature && orderId > 0) {
            try {
                if (success) {
                    checkoutDAO.markOnlinePaymentSuccess(orderId);
                    response.sendRedirect(vnpayService.browserRedirectUrl(request,
                            "/order-history?payment=success&orderId=" + orderId));
                    return;
                } else {
                    checkoutDAO.markOnlinePaymentFailed(orderId);
                }
            } catch (SQLException exception) {
                throw new ServletException("Cannot update VNPay order.", exception);
            }
        }

        request.setAttribute("validSignature", validSignature);
        request.setAttribute("paymentSuccess", success);
        request.setAttribute("responseCode", request.getParameter("vnp_ResponseCode"));
        request.setAttribute("transactionStatus", request.getParameter("vnp_TransactionStatus"));
        request.setAttribute("transactionNo", request.getParameter("vnp_TransactionNo"));
        request.setAttribute("txnRef", request.getParameter("vnp_TxnRef"));
        request.setAttribute("amount", amount(request.getParameter("vnp_Amount")));
        request.getRequestDispatcher("/views/customer/vnpay-return.jsp")
                .forward(request, response);
    }

    private int integer(String input) {
        try {
            if (input != null && input.contains("-")) {
                input = input.substring(0, input.indexOf('-'));
            }
            return Integer.parseInt(input);
        } catch (Exception exception) {
            return 0;
        }
    }

    private void handleRefundReturn(HttpServletRequest request, HttpServletResponse response,
            boolean validSignature, boolean success, String txnRef)
            throws IOException, ServletException {
        RefundRef ref = refundRef(txnRef);
        if (ref.requestId <= 0) {
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/return-request?flash=" + encode("Invalid refund payment reference.")));
            return;
        }

        if (!validSignature || !success) {
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/return-request?action=view&id=" + ref.requestId
                    + "&flash=" + encode("VNPay refund payment was not completed.")));
            return;
        }

        try {
            ReturnRequestModel refund = returnRequestDAO.findDetail(ref.requestId);
            if (refund == null) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/return-request?flash=" + encode("Refund request not found.")));
                return;
            }
            OrderModel order = orderDAO.findOrderDetail(refund.getTransactionId());
            boolean updated = returnRequestDAO.decide(ref.requestId, true, ref.managerId);
            String flash = updated ? "Refund approved and VNPay sandbox payment completed."
                    : "Refund payment completed; request was already processed.";
            if (updated && order != null) {
                sendRefundEmail(refund, order, request.getParameter("vnp_TransactionNo"));
            }
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/return-request?action=view&id=" + ref.requestId
                    + "&flash=" + encode(flash)));
        } catch (SQLException exception) {
            throw new ServletException("Cannot approve refund after VNPay payment.", exception);
        }
    }

    private void sendRefundEmail(ReturnRequestModel refund, OrderModel order,
            String vnpayTransactionNo) {
        if (order.getUserEmail() == null || order.getUserEmail().isBlank()) {
            return;
        }
        try {
            mailService.sendRefundPaymentNotification(order.getUserEmail(), order.getUserName(),
                    refund.getId(), order.getId(), money(order.getPaidAmount()),
                    refund.getBankName(), refund.getBankAccountNumber(),
                    refund.getBankAccountHolder(), vnpayTransactionNo);
        } catch (MessagingException ignored) {
            // The refund is approved even if SMTP is temporarily unavailable.
        }
    }

    private String money(BigDecimal value) {
        if (value == null) {
            return "0 VND";
        }
        return String.format("%,.0f VND", value);
    }

    private RefundRef refundRef(String txnRef) {
        RefundRef ref = new RefundRef();
        try {
            String[] parts = txnRef.split("-");
            ref.requestId = parts.length > 1 ? Integer.parseInt(parts[1]) : 0;
            ref.managerId = parts.length > 2 ? Integer.parseInt(parts[2]) : 0;
        } catch (Exception ignored) {
            ref.requestId = 0;
            ref.managerId = 0;
        }
        return ref;
    }

    private String encode(String value) {
        return java.net.URLEncoder.encode(value, java.nio.charset.StandardCharsets.UTF_8);
    }

    private static class RefundRef {

        int requestId;
        int managerId;
    }

    private long amount(String input) {
        try {
            return Long.parseLong(input) / 100L;
        } catch (Exception exception) {
            return 0L;
        }
    }
}
