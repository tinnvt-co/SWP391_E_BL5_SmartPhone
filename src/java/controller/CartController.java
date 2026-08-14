package controller;

import DAO.CartDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;
import model.CartItemModel;
import model.UserModel;

public class CartController extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel currentUser = currentUser(request);
        try {
            List<CartItemModel> items = cartDAO.findByUserId(currentUser.getId());
            request.setAttribute("cartItems", items);
            request.setAttribute("cartTotal", total(items));
            request.getRequestDispatcher("/views/customer/cart.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load cart.", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        UserModel currentUser = currentUser(request);
        String action = value(request.getParameter("action"), "add");
        int variantId = integer(request.getParameter("variantId"), 0);
        int amount = integer(request.getParameter("amount"), 1);

        try {
            if (variantId <= 0) {
                throw new SQLException("Please select a product option.");
            }

            if ("remove".equals(action)) {
                cartDAO.removeItem(currentUser.getId(), variantId);
                redirectCart(request, response, "removed");
                return;
            }

            if ("update".equals(action)) {
                cartDAO.updateAmount(currentUser.getId(), variantId, amount);
                redirectCart(request, response, "updated");
                return;
            }

            cartDAO.addItem(currentUser.getId(), variantId, amount);
            redirectCart(request, response, "added");
        } catch (SQLException exception) {
            String redirect = value(request.getParameter("redirect"), request.getContextPath() + "/cart");
            response.sendRedirect(redirect + (redirect.contains("?") ? "&" : "?")
                    + "cartError=" + URLEncoder.encode(exception.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private UserModel currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (UserModel) session.getAttribute("currentUser");
    }

    private void redirectCart(HttpServletRequest request, HttpServletResponse response, String status)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/cart?status=" + status);
    }

    private int total(List<CartItemModel> items) {
        int total = 0;
        for (CartItemModel item : items) {
            total += item.getLineTotal();
        }
        return total;
    }

    private int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (Exception exception) {
            return fallback;
        }
    }

    private String value(String input, String fallback) {
        return input == null || input.isBlank() ? fallback : input;
    }
}
