package controller;

import DAO.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import model.VoucherModel;

@WebServlet(name = "ManagerVoucherController", urlPatterns = {"/manager/vouchers"})
public class ManagerVoucherController extends HttpServlet {

    private final VoucherDAO voucherDAO = new VoucherDAO();

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("search");
        
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        int offset = (page - 1) * PAGE_SIZE;
        int totalItems = voucherDAO.countAll(keyword);
        int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
        
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
            offset = (page - 1) * PAGE_SIZE;
        }

        List<VoucherModel> vouchers = voucherDAO.findAll(keyword, offset, PAGE_SIZE);
        
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.getRequestDispatcher("/views/manager/voucher-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/manager/vouchers");
            return;
        }

        try {
            switch (action) {
                case "create":
                    createVoucher(request, response);
                    break;
                case "update":
                    updateVoucher(request, response);
                    break;
                case "toggleStatus":
                    toggleStatus(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/manager/vouchers");
            }
        } catch (Exception ex) {
            request.getSession().setAttribute("error", "Error: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/manager/vouchers");
        }
    }

    private void createVoucher(HttpServletRequest request, HttpServletResponse response) throws Exception {
        VoucherModel v = new VoucherModel();
        populateVoucherFromRequest(request, v);
        
        if (voucherDAO.findByCode(v.getCode()) != null) {
            request.getSession().setAttribute("error", "Voucher code already exists!");
        } else if (voucherDAO.create(v)) {
            request.getSession().setAttribute("message", "Voucher created successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to create voucher.");
        }
        response.sendRedirect(request.getContextPath() + "/manager/vouchers");
    }

    private void updateVoucher(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int id = Integer.parseInt(request.getParameter("id"));
        VoucherModel v = voucherDAO.findById(id);
        if (v == null) {
            request.getSession().setAttribute("error", "Voucher not found.");
            response.sendRedirect(request.getContextPath() + "/manager/vouchers");
            return;
        }

        String oldCode = v.getCode();
        populateVoucherFromRequest(request, v);
        
        VoucherModel existing = voucherDAO.findByCode(v.getCode());
        if (existing != null && existing.getId() != id) {
            request.getSession().setAttribute("error", "Voucher code already exists!");
        } else if (voucherDAO.update(v)) {
            request.getSession().setAttribute("message", "Voucher updated successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to update voucher.");
        }
        response.sendRedirect(request.getContextPath() + "/manager/vouchers");
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int id = Integer.parseInt(request.getParameter("id"));
        String status = request.getParameter("status");
        if (voucherDAO.updateStatus(id, status)) {
            request.getSession().setAttribute("message", "Voucher status updated.");
        } else {
            request.getSession().setAttribute("error", "Failed to update status.");
        }
        response.sendRedirect(request.getContextPath() + "/manager/vouchers");
    }

    private void populateVoucherFromRequest(HttpServletRequest request, VoucherModel v) throws Exception {
        v.setCode(request.getParameter("code").toUpperCase().trim());
        v.setDiscountType(request.getParameter("discountType"));
        v.setValue(new BigDecimal(request.getParameter("value")));
        
        String maxDiscountStr = request.getParameter("maxDiscount");
        if (maxDiscountStr != null && !maxDiscountStr.isBlank()) {
            v.setMaxDiscount(new BigDecimal(maxDiscountStr));
        } else {
            v.setMaxDiscount(null);
        }

        String minOrderStr = request.getParameter("minOrderValue");
        if (minOrderStr != null && !minOrderStr.isBlank()) {
            v.setMinOrderValue(new BigDecimal(minOrderStr));
        } else {
            v.setMinOrderValue(null);
        }

        String limitStr = request.getParameter("usageLimit");
        if (limitStr != null && !limitStr.isBlank()) {
            v.setUsageLimit(Integer.parseInt(limitStr));
        } else {
            v.setUsageLimit(null);
        }

        String maxUsesStr = request.getParameter("maxUsesPerUser");
        if (maxUsesStr != null && !maxUsesStr.isBlank()) {
            v.setMaxUsesPerUser(Integer.parseInt(maxUsesStr));
        } else {
            v.setMaxUsesPerUser(1); // default
        }

        DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
        LocalDateTime start = LocalDateTime.parse(request.getParameter("startDate"), formatter);
        LocalDateTime end = LocalDateTime.parse(request.getParameter("endDate"), formatter);
        
        v.setStartDate(Timestamp.valueOf(start));
        v.setEndDate(Timestamp.valueOf(end));
    }
}
