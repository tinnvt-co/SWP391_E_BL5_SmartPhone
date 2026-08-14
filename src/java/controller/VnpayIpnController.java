package controller;

import DAO.CheckoutDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import service.VnpayService;

public class VnpayIpnController extends HttpServlet {

    private final VnpayService vnpayService = new VnpayService();
    private final CheckoutDAO checkoutDAO = new CheckoutDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        if (!vnpayService.isValidReturn(request)) {
            response.getWriter().write("{\"RspCode\":\"97\",\"Message\":\"Invalid signature\"}");
            return;
        }

        int orderId = integer(request.getParameter("vnp_TxnRef"));
        if (orderId <= 0) {
            response.getWriter().write("{\"RspCode\":\"01\",\"Message\":\"Order not found\"}");
            return;
        }

        try {
            if (vnpayService.isSuccess(request)) {
                checkoutDAO.markOnlinePaymentSuccess(orderId);
            } else {
                checkoutDAO.markOnlinePaymentFailed(orderId);
            }
        } catch (SQLException exception) {
            response.getWriter().write("{\"RspCode\":\"99\",\"Message\":\"Cannot update order\"}");
            return;
        }

        response.getWriter().write("{\"RspCode\":\"00\",\"Message\":\"Confirm Success\"}");
    }

    private int integer(String input) {
        try {
            return Integer.parseInt(input);
        } catch (Exception exception) {
            return 0;
        }
    }
}
