package controller;

import DAO.OrderDAO;
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

@WebServlet(name = "CustomerOrderDetailController", urlPatterns = {"/customer/order-detail"})
public class CustomerOrderDetailController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception exception) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        UserModel user = (UserModel) session.getAttribute("currentUser");
        try {
            OrderModel order = orderDAO.findOrderDetail(id);
            if (order == null || order.getUserId() != user.getId()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/customer/order-detail.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load order detail", exception);
        }
    }
}
