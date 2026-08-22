package controller;

import DAO.CartDAO;
import DAO.CheckoutDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.CartItemModel;
import model.CheckoutInfoModel;
import model.UserModel;
import service.VnpayService;

public class CartController extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();
    private final CheckoutDAO checkoutDAO = new CheckoutDAO();
    private final VnpayService vnpayService = new VnpayService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel currentUser = currentUser(request);
        try {
            if ("placeOrder".equals(request.getParameter("checkoutAction"))) {
                placeOrder(request, response, currentUser);
                return;
            }

            List<CartItemModel> items = cartDAO.findByUserId(currentUser.getId());
            request.setAttribute("cartItems", items);
            request.setAttribute("cartTotal", total(items));
            
            // Get user's saved vouchers
            DAO.VoucherDAO voucherDAO = new DAO.VoucherDAO();
            request.setAttribute("savedVouchers", voucherDAO.findSavedVouchersByUser(currentUser.getId()));
            
            request.getRequestDispatcher("/views/customer/cart.jsp")
                    .forward(request, response);
        } catch (SQLException exception) {
            throw new ServletException("Cannot load cart.", exception);
        }
    }

    private void placeOrder(HttpServletRequest request, HttpServletResponse response,
            UserModel currentUser) throws ServletException, IOException, SQLException {
        List<CartItemModel> cartItems = cartDAO.findByUserId(currentUser.getId());
        List<CartItemModel> checkoutItems = selectedItems(
                cartItems, request.getParameterValues("variantId"));

        request.setAttribute("checkoutItems", checkoutItems);
        int checkoutTotal = total(checkoutItems);
        String paymentMethod = normalizePaymentMethod(request.getParameter("paymentMethod"));

        DAO.VoucherDAO voucherDAO = new DAO.VoucherDAO();
        List<model.UserVoucherModel> savedVouchers = voucherDAO.findSavedVouchersByUser(currentUser.getId());
        List<model.UserVoucherModel> applicableVouchers = new ArrayList<>();
        List<model.UserVoucherModel> disabledVouchers = new ArrayList<>();
        for (model.UserVoucherModel uv : savedVouchers) {
            if (uv.getVoucher().getMinOrderValue() == null
                    || java.math.BigDecimal.valueOf(checkoutTotal)
                            .compareTo(uv.getVoucher().getMinOrderValue()) >= 0) {
                applicableVouchers.add(uv);
            } else {
                disabledVouchers.add(uv);
            }
        }
        request.setAttribute("applicableVouchers", applicableVouchers);
        request.setAttribute("disabledVouchers", disabledVouchers);

        int discountAmount = 0;
        model.VoucherModel selectedVoucher = selectedVoucher(request, applicableVouchers);
        if (selectedVoucher != null) {
            if ("PERCENTAGE".equals(selectedVoucher.getDiscountType())) {
                int pctDiscount = (int) (checkoutTotal * selectedVoucher.getValue().doubleValue() / 100);
                if (selectedVoucher.getMaxDiscount() != null) {
                    discountAmount = Math.min(pctDiscount, selectedVoucher.getMaxDiscount().intValue());
                } else {
                    discountAmount = pctDiscount;
                }
            } else {
                discountAmount = selectedVoucher.getValue().intValue();
            }
            discountAmount = Math.min(discountAmount, checkoutTotal);
        }

        request.setAttribute("discountAmount", discountAmount);
        request.setAttribute("finalTotal", checkoutTotal - discountAmount);
        request.setAttribute("selectedVoucher", selectedVoucher);

        if (checkoutItems.isEmpty()) {
            redirectCartError(request, response, "Please select products to checkout.");
            return;
        }

        CheckoutInfoModel checkoutInfo = checkoutInfo(request);
        Integer voucherId = selectedVoucher != null ? selectedVoucher.getId() : null;

        if ("ONLINE".equals(paymentMethod)) {
            int orderId = checkoutDAO.createOrder(currentUser.getId(), checkoutItems,
                    checkoutInfo, "VNPAY", "PENDING", false, false, voucherId, discountAmount);
            String vnpTxnRef = orderId + "-" + System.currentTimeMillis();
            String paymentUrl = vnpayService.createPaymentUrl(request, checkoutTotal - discountAmount,
                    "Thanh toan SmartPhone store don hang " + orderId,
                    vnpTxnRef);
            response.sendRedirect(paymentUrl);
            return;
        }

        int orderId = checkoutDAO.createOrder(currentUser.getId(), checkoutItems,
                checkoutInfo, "COD", "PENDING", false, true, voucherId, discountAmount);
        request.setAttribute("checkoutTotal", checkoutTotal);
        request.setAttribute("paymentMethod", paymentMethod);
        request.setAttribute("orderCreated", true);
        request.setAttribute("orderId", orderId);
        request.getRequestDispatcher("/views/customer/checkout.jsp")
                .forward(request, response);
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

    private model.VoucherModel selectedVoucher(HttpServletRequest request,
            List<model.UserVoucherModel> applicableVouchers) {
        String voucherIdParam = request.getParameter("voucherId");
        if (voucherIdParam == null || voucherIdParam.isEmpty()) {
            return null;
        }

        int selectedVoucherId = integer(voucherIdParam, 0);
        for (model.UserVoucherModel uv : applicableVouchers) {
            if (uv.getVoucherId() == selectedVoucherId) {
                return uv.getVoucher();
            }
        }
        return null;
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
                + URLEncoder.encode(message, StandardCharsets.UTF_8));
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
