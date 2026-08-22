package controller;

import DAO.OrderDAO;
import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.OrderModel;
import model.UserModel;

@WebServlet(name = "ManagerShipperDeliveryController", urlPatterns = {"/manager/shipper-deliveries"})
public class ManagerShipperDeliveryController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<UserModel> shippers = userDAO.findActiveShippers();
            request.setAttribute("shippers", shippers);

            String shipperIdParam = request.getParameter("shipperId");
            if (shipperIdParam != null && !shipperIdParam.isEmpty()) {
                int shipperId = Integer.parseInt(shipperIdParam);
                List<OrderModel> orders = orderDAO.findDeliveredOrdersByShipper(shipperId);
                request.setAttribute("orders", orders);
                request.setAttribute("selectedShipperId", shipperId);
            }

            request.setAttribute("pageName", "Shipper Deliveries");
            request.getRequestDispatcher("/views/manager/shipper-delivery.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load shipper deliveries", ex);
        }
    }
}
