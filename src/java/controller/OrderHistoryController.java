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
import java.util.List;

@WebServlet(name = "OrderHistoryController", urlPatterns = {"/order-history"})
public class OrderHistoryController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

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
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/views/customer/order-history.jsp").forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load order history", exception);
        }
    }
}
