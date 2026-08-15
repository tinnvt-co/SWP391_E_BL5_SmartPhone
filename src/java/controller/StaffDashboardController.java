package controller;

import DAO.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import model.OrderModel;

@WebServlet(name = "StaffDashboardController", urlPatterns = {"/staff"})
public class StaffDashboardController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int totalToday = orderDAO.countTodaysOrders();
            int totalProcessing = orderDAO.countProcessing();
            int totalDelivered = orderDAO.countDelivered();
            int totalCancelled = orderDAO.countCancelled();
            BigDecimal totalRevenue = orderDAO.totalRevenue();

            request.setAttribute("totalToday", totalToday);
            request.setAttribute("totalProcessing", totalProcessing);
            request.setAttribute("totalDelivered", totalDelivered);
            request.setAttribute("totalCancelled", totalCancelled);
            request.setAttribute("totalRevenue",
                    totalRevenue != null ? totalRevenue : BigDecimal.ZERO);

            List<OrderModel> recentOrders = orderDAO.findOrders(null, null, "ORDER", "newest", true);
            request.setAttribute("recentOrders",
                    recentOrders.size() > 5 ? recentOrders.subList(0, 5) : recentOrders);

            request.getRequestDispatcher("/views/staff/dashboard.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load staff dashboard", exception);
        }
    }
}
