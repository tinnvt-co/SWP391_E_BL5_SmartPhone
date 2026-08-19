package controller;

import DAO.OrderDAO;
import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.OrderModel;
import model.UserModel;

public class ShipperOrderController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            List<OrderModel> assignedOrders = orderDAO.findShippingOrdersByShipper(currentUser.getId());
            List<OrderModel> availableOrders = orderDAO.findAvailableShippingOrders();
            List<OrderModel> deliveredOrders = orderDAO.findDeliveredOrdersByShipper(currentUser.getId());
            hydrateItems(assignedOrders);
            hydrateItems(availableOrders);
            hydrateItems(deliveredOrders);

            request.setAttribute("orders", assignedOrders);
            request.setAttribute("availableOrders", availableOrders);
            request.setAttribute("deliveredOrders", deliveredOrders);

            request.getRequestDispatcher("/views/shipper/delivery-order-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void hydrateItems(List<OrderModel> orders) throws SQLException {
        for (OrderModel order : orders) {
            order.setItems(orderDAO.findOrderItems(order.getId()));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("claim".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
                if (currentUser != null) {
                    boolean ok = orderDAO.assignShipper(orderId, currentUser.getId(), currentUser.getId());
                    if (ok) {
                        request.getSession().setAttribute("message", "Order #" + orderId + " claimed successfully.");
                    } else {
                        request.getSession().setAttribute("error", "Failed to claim order. It might have been claimed by someone else.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error claiming order: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            }
        } else if ("updateStatus".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String status = request.getParameter("status"); // Expected: DELIVERED or COMPLETED

                UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
                Integer updatedBy = (currentUser != null) ? currentUser.getId() : null;

                orderDAO.updateStatus(orderId, status, updatedBy);

                request.getSession().setAttribute("message", "Order #" + orderId + " marked as " + status + ".");
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error updating order status: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            }
        } else if ("addNote".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String note = request.getParameter("note");

                UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
                Integer updatedBy = (currentUser != null) ? currentUser.getId() : null;

                orderDAO.updateStatusWithNote(orderId, "DELIVERED", updatedBy, note);

                request.getSession().setAttribute("message", "Note added to Order #" + orderId + " and marked as delivered.");
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error adding note: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            }
        }
    }
}
