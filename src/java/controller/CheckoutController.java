package controller;

import DAO.CartDAO;
import DAO.CheckoutDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.CartItemModel;
import model.CheckoutInfoModel;
import model.UserModel;
import service.VnpayService;

public class CheckoutController extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();
    private final CheckoutDAO checkoutDAO = new CheckoutDAO();
    private final VnpayService vnpayService = new VnpayService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel currentUser = currentUser(request);
        try {
            List<CartItemModel> cartItems = cartDAO.findByUserId(currentUser.getId());
            List<CartItemModel> checkoutItems = selectedItems(
                    cartItems, request.getParameterValues("variantId"));

            request.setAttribute("checkoutItems", checkoutItems);
            int checkoutTotal = total(checkoutItems);
            String paymentMethod = normalizePaymentMethod(request.getParameter("paymentMethod"));

            if (!"placeOrder".equals(request.getParameter("checkoutAction"))) {
                request.setAttribute("checkoutTotal", checkoutTotal);
                request.setAttribute("paymentMethod", paymentMethod);
                request.getRequestDispatcher("/views/customer/checkout.jsp")
                        .forward(request, response);
                return;
            }

            if (checkoutItems.isEmpty()) {
                redirectCartError(request, response, "Please select products to checkout.");
                return;
            }

            CheckoutInfoModel checkoutInfo = checkoutInfo(request);
            if ("ONLINE".equals(paymentMethod)) {
                int orderId = checkoutDAO.createOrder(currentUser.getId(), checkoutItems,
                        checkoutInfo, "VNPAY", "PENDING", false, false);
                String paymentUrl = vnpayService.createPaymentUrl(request, checkoutTotal,
                        "Thanh toan SmartPhone store don hang " + orderId,
                        String.valueOf(orderId));
                response.sendRedirect(paymentUrl);
                return;
            }

            int orderId = checkoutDAO.createOrder(currentUser.getId(), checkoutItems,
                    checkoutInfo, "COD", "PENDING", false, true);
            request.setAttribute("checkoutTotal", checkoutTotal);
            request.setAttribute("paymentMethod", paymentMethod);
            request.setAttribute("orderCreated", true);
            request.setAttribute("orderId", orderId);
            request.getRequestDispatcher("/views/customer/checkout.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load checkout.", exception);
        }
    }

    private List<CartItemModel> selectedItems(List<CartItemModel> cartItems,
            String[] selectedVariantIds) {
        if (selectedVariantIds == null || selectedVariantIds.length == 0) {
            return cartItems;
        }

        Set<Integer> selectedIds = new HashSet<>();
        for (String value : selectedVariantIds) {
            int id = integer(value, 0);
            if (id > 0) {
                selectedIds.add(id);
            }
        }

        List<CartItemModel> result = new ArrayList<>();
        for (CartItemModel item : cartItems) {
            if (selectedIds.contains(item.getProductVariantId())) {
                result.add(item);
            }
        }
        return result;
    }

    private int total(List<CartItemModel> items) {
        int total = 0;
        for (CartItemModel item : items) {
            total += item.getLineTotal();
        }
        return total;
    }

    private UserModel currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (UserModel) session.getAttribute("currentUser");
    }

    private String normalizePaymentMethod(String input) {
        return "ONLINE".equalsIgnoreCase(input) ? "ONLINE" : "COD";
    }

    private CheckoutInfoModel checkoutInfo(HttpServletRequest request) {
        CheckoutInfoModel info = new CheckoutInfoModel();
        info.setFullName(request.getParameter("fullName"));
        info.setEmail(request.getParameter("email"));
        info.setPhone(request.getParameter("phone"));
        info.setCity(request.getParameter("city"));
        info.setDistrict(request.getParameter("district"));
        info.setWard(request.getParameter("ward"));
        info.setAddress(request.getParameter("address"));
        info.setNotes(request.getParameter("notes"));
        return info;
    }

    private void redirectCartError(HttpServletRequest request,
            HttpServletResponse response, String message) throws IOException {
        response.sendRedirect(request.getContextPath() + "/cart?cartError="
                + java.net.URLEncoder.encode(message,
                        java.nio.charset.StandardCharsets.UTF_8));
    }

    private int integer(String input, int fallback) {
        try {
            return Integer.parseInt(input);
        } catch (Exception exception) {
            return fallback;
        }
    }
}
