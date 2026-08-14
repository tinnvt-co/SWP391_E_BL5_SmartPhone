package controller;

import DAO.CheckoutDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import service.VnpayService;

public class VnpayReturnController extends HttpServlet {

    private final VnpayService vnpayService = new VnpayService();
    private final CheckoutDAO checkoutDAO = new CheckoutDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        boolean validSignature = vnpayService.isValidReturn(request);
        boolean success = validSignature && vnpayService.isSuccess(request);
        int orderId = integer(request.getParameter("vnp_TxnRef"));

        if (validSignature && orderId > 0) {
            try {
                if (success) {
                    checkoutDAO.markOnlinePaymentSuccess(orderId);
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
            return Integer.parseInt(input);
        } catch (Exception exception) {
            return 0;
        }
    }

    private long amount(String input) {
        try {
            return Long.parseLong(input) / 100L;
        } catch (Exception exception) {
            return 0L;
        }
    }
}
