package controller;

import DAO.CartDAO;
import DAO.WishlistDAO;
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

public class WishlistController extends HttpServlet {

    private final WishlistDAO wishlistDAO = new WishlistDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel currentUser = currentUser(request);
        try {
            List<CartItemModel> items = wishlistDAO.findByUserId(currentUser.getId());
            request.setAttribute("wishlistItems", items);
            request.setAttribute("wishlistCount", items.size());
            request.getRequestDispatcher("/views/customer/wishlist.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Không thể tải wishlist.", exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        UserModel currentUser = currentUser(request);
        
        //lấy + kiểm tra action và id
        String action = value(request.getParameter("action"), "add");
        int variantId = integer(request.getParameter("variantId"), 0);

        try {
            if (variantId <= 0) {
                throw new SQLException("Hãy chọn sản phẩm.");
            }

            if ("remove".equals(action)) {
                wishlistDAO.removeItem(currentUser.getId(), variantId);
                redirect(request, response, "removed");
                return;
            }

            if ("moveToCart".equals(action)) {
                cartDAO.addItem(currentUser.getId(), variantId, 1);
                wishlistDAO.removeItem(currentUser.getId(), variantId);
                redirect(request, response, "moved");
                return;
            }

            wishlistDAO.addItem(currentUser.getId(), variantId);
            redirectAfterAdd(request, response);
        } catch (SQLException exception) {
            String redirect = value(request.getParameter("redirect"),
                    request.getContextPath() + "/wishlist");
            response.sendRedirect(redirect + (redirect.contains("?") ? "&" : "?")
                    + "wishlistError=" + URLEncoder.encode("Lỗi không thể lưu",
                            StandardCharsets.UTF_8));
        }
    }

    private UserModel currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (UserModel) session.getAttribute("currentUser");
    }

    private void redirect(HttpServletRequest request, HttpServletResponse response,
            String status) throws IOException {
        response.sendRedirect(request.getContextPath() + "/wishlist?status=" + status);
    }
    
    //quay lại trang sau khi add
    private void redirectAfterAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String redirect = request.getParameter("redirect");
        if (redirect == null || redirect.isBlank()) {
            redirect(request, response, "added");
            return;
        }
        response.sendRedirect(redirect + (redirect.contains("?") ? "&" : "?")
                + "wishlistStatus=added");
    }

    private int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    private String value(String input, String fallback) {
        return input == null || input.isBlank() ? fallback : input;
    }
}
