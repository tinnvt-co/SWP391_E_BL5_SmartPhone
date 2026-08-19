package controller;

import DAO.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "HomeController", urlPatterns = {"/home"})
public class HomeController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final DAO.VoucherDAO voucherDAO = new DAO.VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("featuredProducts", productDAO.findFeaturedProducts(8));
            request.setAttribute("categories", productDAO.findActiveCategories());
            request.setAttribute("activeProductCount", productDAO.countActiveProducts());
            request.setAttribute("availableProductCount", productDAO.countAvailableProducts());
            
            // Lấy danh sách voucher đang active để hiển thị trên home page
            request.setAttribute("activeVouchers", voucherDAO.findActiveVouchers());
            
            // Nếu user đã đăng nhập, lấy danh sách voucher đã lưu để kiểm tra
            model.UserModel currentUser = (model.UserModel) request.getSession().getAttribute("currentUser");
            if (currentUser != null) {
                java.util.List<model.UserVoucherModel> savedVouchers = voucherDAO.findSavedVouchersByUser(currentUser.getId());
                java.util.Set<Integer> savedVoucherIds = new java.util.HashSet<>();
                for (model.UserVoucherModel uv : savedVouchers) {
                    savedVoucherIds.add(uv.getVoucherId());
                }
                request.setAttribute("savedVoucherIds", savedVoucherIds);
            }
            
            request.getRequestDispatcher("/views/home.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
