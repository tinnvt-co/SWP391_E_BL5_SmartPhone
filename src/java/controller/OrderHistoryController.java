package controller;

import DAO.OrderDAO;
import DAO.RefundDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderModel;
import model.ReturnRequestModel;
import model.UserModel;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "OrderHistoryController", urlPatterns = {"/order-history"})
public class OrderHistoryController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final RefundDAO returnDAO = new RefundDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UserModel user = (UserModel) session.getAttribute("currentUser");
        try {
            List<OrderModel> orders = orderDAO.findByUserId(user.getId());
            // Decorate each order with refund status so the JSP can decide which
            // buttons to show. We don't change OrderDAO.findByUserId (other
            // callers depend on it).
            for (OrderModel order : orders) {
                boolean isReviewable = "COMPLETED".equalsIgnoreCase(order.getStatus())
                        || "DELIVERED".equalsIgnoreCase(order.getStatus());
                if (isReviewable) {
                    order.setHasOpenRefund(returnDAO.hasActiveForTransaction(user.getId(), order.getId()));
                    // For the review button we treat any non-rejected refund as
                    // a hard block (refund pending OR refund approved = no review).
                    order.setHasBlockingRefund(returnDAO.hasBlockingRefundForTransaction(user.getId(), order.getId()));
                } else {
                    order.setHasOpenRefund(Boolean.FALSE);
                    order.setHasBlockingRefund(Boolean.FALSE);
                }
            }
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/views/customer/order-history.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load order history", exception);
        }
    }
}
