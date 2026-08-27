package controller;

import DAO.CancelRequestDAO;
import DAO.OrderDAO;
import DAO.RefundDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderModel;
import model.UserModel;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;

@WebServlet(name = "OrderHistoryController", urlPatterns = {"/order-history"})
public class OrderHistoryController extends HttpServlet {

    private static final Set<String> NON_CANCELABLE_STATUSES = Set.of(
            "DELIVERED", "COMPLETED", "CANCELLED", "CANCEL_REQUESTED", "REFUND");

    private final OrderDAO orderDAO = new OrderDAO();
    private final RefundDAO returnDAO = new RefundDAO();
    private final CancelRequestDAO cancelDAO = new CancelRequestDAO();

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
            for (OrderModel order : orders) {
                boolean isAfterDelivery = "COMPLETED".equalsIgnoreCase(order.getStatus())
                        || "DELIVERED".equalsIgnoreCase(order.getStatus());
                if (isAfterDelivery) {
                    order.setHasOpenRefund(returnDAO.hasActiveForTransaction(user.getId(), order.getId()));
                    order.setHasBlockingRefund(returnDAO.hasBlockingRefundForTransaction(user.getId(), order.getId()));
                } else {
                    order.setHasOpenRefund(Boolean.FALSE);
                    order.setHasBlockingRefund(Boolean.FALSE);
                }

                boolean cancelPending = cancelDAO.hasActiveRequest(order.getId());
                order.setHasCancelPending(cancelPending);

                order.setHasOpenComplaint(Boolean.FALSE);
                order.setHasAnyComplaint(Boolean.FALSE);
            }
            request.setAttribute("orders", orders);
            request.setAttribute("cancelReasons", cancelDAO.findValidReasons());
            request.getRequestDispatcher("/views/customer/order-history.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load order history", exception);
        }
    }

    public static boolean isCancelable(String status) {
        if (status == null) {
            return false;
        }
        return !NON_CANCELABLE_STATUSES.contains(status.toUpperCase());
    }
}
