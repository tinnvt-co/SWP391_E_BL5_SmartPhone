package controller;

import DAO.CheckoutDAO;
import DAO.CancelRequestDAO;
import DAO.OrderDAO;
import DAO.RefundDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import jakarta.mail.MessagingException;
import model.CancelRequestModel;
import model.OrderModel;
import model.RefundModel;
import service.VnpayService;
import service.MailService;

public class VnpayReturnController extends HttpServlet {

    private final VnpayService vnpayService = new VnpayService();
    private final CheckoutDAO checkoutDAO = new CheckoutDAO();
    private final RefundDAO returnRequestDAO = new RefundDAO();
    private final CancelRequestDAO cancelRequestDAO = new CancelRequestDAO();
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
        if (txnRef != null && txnRef.startsWith("CR-")) {
            handleCancelReturn(request, response, validSignature, success, txnRef);
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
                    response.sendRedirect(vnpayService.browserRedirectUrl(request,
                            "/cart?payment=failed&orderId=" + orderId));
                    return;
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
        } catch (NumberFormatException exception) {
            return 0;
        }
    }

    private void handleRefundReturn(HttpServletRequest request, HttpServletResponse response,
            boolean validSignature, boolean success, String txnRef)
            throws IOException, ServletException {

        RefundRef ref = refundRef(txnRef);

        if (ref.requestId <= 0) {
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/return-request?flash="
                    + encode("Invalid refund payment reference.")));
            return;
        }

        // VNPay payment failed or signature invalid
        if (!validSignature || !success) {
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/return-request?action=view&id=" + ref.requestId
                    + "&flash="
                    + encode("VNPay refund payment was not completed.")));
            return;
        }

        try {
            // 1. Find refund request
            RefundModel refund = returnRequestDAO.findDetail(ref.requestId);
            
            // validate
            if (refund == null) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/return-request?flash="
                        + encode("Refund request not found.")));
                return;
            }

            // 2. Find related order
            OrderModel order = orderDAO.findOrderDetail(refund.getTransactionId());

            if (order == null) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/return-request?action=view&id=" + ref.requestId
                        + "&flash="
                        + encode("Related order not found.")));
                return;
            }

            // 3. Approve refund request
            boolean updated = returnRequestDAO.decide(
                    ref.requestId,
                    true,
                    ref.managerId
            );

            if (!updated) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/return-request?action=view&id=" + ref.requestId
                        + "&flash="
                        + encode("Refund payment completed; request was already processed.")));
                return;
            }

            // 4. IMPORTANT:
            // VNPay refund succeeded -> update order status to REFUNDED
            boolean orderUpdated = orderDAO.updateStatus(
                    order.getId(),
                    "REFUNDED",
                    ref.managerId
            );

            if (!orderUpdated) {
                throw new SQLException(
                        "Refund was approved but order status could not be updated."
                );
            }

            // 5. Send email to customer
            sendRefundEmail(
                    refund,
                    order,
                    request.getParameter("vnp_TransactionNo")
            );

            // 6. Redirect back to manager refund detail
            String flash = "Refund approved, payment completed, and order status changed to REFUNDED.";

            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/return-request?action=view&id=" + ref.requestId
                    + "&flash=" + encode(flash)));

        } catch (SQLException exception) {
            throw new ServletException(
                    "Cannot process refund after VNPay payment.",
                    exception
            );
        }
    }

    private void sendRefundEmail(RefundModel refund, OrderModel order,
            String vnpayTransactionNo) {
        if (order.getUserEmail() == null || order.getUserEmail().isBlank()) {
            return;
        }
        try {
            mailService.sendRefundPaymentNotification(order.getUserEmail(), order.getUserName(),
                    refund.getId(), order.getId(), money(order.getTotalPrice()),
                    refund.getBankName(), refund.getBankAccountNumber(),
                    refund.getBankAccountHolder(), vnpayTransactionNo);
        } catch (MessagingException ignored) {
            // The refund is approved even if SMTP is temporarily unavailable.
        }
    }

    private void handleCancelReturn(HttpServletRequest request, HttpServletResponse response,
            boolean validSignature, boolean success, String txnRef)
            throws IOException, ServletException {

        CancelRef ref = parseCancelRef(txnRef);
        if (ref.requestId <= 0) {
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/cancel-request?flash="
                    + encode("Invalid cancel payment reference.")));
            return;
        }

        // VNPay payment failed or signature invalid
        if (!validSignature || !success) {
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/cancel-request?flash="
                    + encode("VNPay cancel payment was not completed.")));
            return;
        }

        try {
            // 1. Find cancel request
            CancelRequestModel cancelRequest = cancelRequestDAO.findById(ref.requestId);
            if (cancelRequest == null) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/cancel-request?flash="
                        + encode("Cancel request not found.")));
                return;
            }
            if (!cancelRequest.isPending()) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/cancel-request?flash="
                        + encode("Cancel request was already processed.")));
                return;
            }

            // 2. Find related order
            OrderModel order = orderDAO.findOrderDetail(cancelRequest.getTransactionId());
            if (order == null) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/cancel-request?flash="
                        + encode("Related order not found.")));
                return;
            }

            // 3. Mark cancel request as APPROVED
            boolean updated = cancelRequestDAO.markRefundApproved(ref.requestId, ref.managerId);
            if (!updated) {
                response.sendRedirect(vnpayService.browserRedirectUrl(request,
                        "/manager/cancel-request?flash="
                        + encode("Cancel payment completed; request was already processed.")));
                return;
            }

            // 4. Update order status to CANCELLED.
            // Per design decision: keep status as CANCELLED for cancelled orders
            // even when a VNPay refund was issued.
            boolean orderUpdated = orderDAO.updateStatus(
                    order.getId(),
                    "CANCELLED",
                    ref.managerId
            );
            if (!orderUpdated) {
                throw new SQLException(
                        "Cancel was approved but order status could not be updated."
                );
            }

            // 5. Send email to customer
            sendCancelEmail(cancelRequest, order, request.getParameter("vnp_TransactionNo"));

            // 6. Redirect back to manager cancel list
            String flash = "Cancel approved, VNPay refund completed, and order status changed to CANCELLED.";
            response.sendRedirect(vnpayService.browserRedirectUrl(request,
                    "/manager/cancel-request?flash=" + encode(flash)));
        } catch (SQLException exception) {
            throw new ServletException(
                    "Cannot process cancel after VNPay payment.",
                    exception
            );
        }
    }

    private void sendCancelEmail(CancelRequestModel cancelRequest, OrderModel order,
            String vnpayTransactionNo) {
        if (order.getUserEmail() == null || order.getUserEmail().isBlank()) {
            return;
        }
        try {
            mailService.sendRefundPaymentNotification(order.getUserEmail(), order.getUserName(),
                    cancelRequest.getId(), order.getId(), money(order.getTotalPrice()),
                    cancelRequest.getBankName(), cancelRequest.getBankAccountNumber(),
                    cancelRequest.getBankAccountHolder(), vnpayTransactionNo);
        } catch (MessagingException ignored) {
            // Cancellation is approved even if SMTP is temporarily unavailable.
        }
    }

    private CancelRef parseCancelRef(String txnRef) {
        CancelRef ref = new CancelRef();
        try {
            String[] parts = txnRef.split("-");
            ref.requestId = parts.length > 1 ? Integer.parseInt(parts[1]) : 0;
            ref.managerId = parts.length > 2 ? Integer.parseInt(parts[2]) : 0;
        } catch (NumberFormatException ignored) {
            ref.requestId = 0;
            ref.managerId = 0;
        }
        return ref;
    }

    private static class CancelRef {
        int requestId;
        int managerId;
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
        } catch (NumberFormatException ignored) {
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
        } catch (NumberFormatException exception) {
            return 0L;
        }
    }
}
