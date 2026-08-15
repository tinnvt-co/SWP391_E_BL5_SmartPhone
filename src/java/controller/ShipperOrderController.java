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

            List<UserModel> shippers = userDAO.findActiveShippers();
            int totalShippers = shippers.size();
            int shipperIndex = -1;
            for (int i = 0; i < totalShippers; i++) {
                if (shippers.get(i).getId() == currentUser.getId()) {
                    shipperIndex = i;
                    break;
                }
            }

            // Fetch orders that are in SHIPPING status and have delivery info
            List<OrderModel> allShippingOrders = orderDAO.findShippingOrders();
            List<OrderModel> assignedOrders = new ArrayList<>();
            
            if (totalShippers > 0 && shipperIndex != -1) {
                for (OrderModel order : allShippingOrders) {
                    if (order.getId() % totalShippers == shipperIndex) {
                        assignedOrders.add(order);
                    }
                }
            } else {
                assignedOrders = allShippingOrders;
            }

            request.setAttribute("orders", assignedOrders);
            
            request.getRequestDispatcher("/views/shipper/delivery-order-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
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
                
                orderDAO.updateStatusWithNote(orderId, "SHIPPING", updatedBy, note);
                
                request.getSession().setAttribute("message", "Note added to Order #" + orderId + ".");
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error adding note: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            }
        }
    }
}
