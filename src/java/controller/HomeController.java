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

    // Nạp sản phẩm nổi bật, category ACTIVE và số liệu tồn kho cho trang Home public.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Dữ liệu Product/Category này được home.jsp dùng cho product cards và category carousel.
            request.setAttribute("featuredProducts", productDAO.findFeaturedProducts(8));
            request.setAttribute("categories", productDAO.findActiveCategories());
            request.setAttribute("activeProductCount", productDAO.countActiveProducts());
            request.setAttribute("availableProductCount", productDAO.countAvailableProducts());
            
            // Lấy danh sách voucher đang active để hiển thị trên home page
            request.setAttribute("activeVouchers", voucherDAO.findActiveVouchers());
            
            // Nếu user đã đăng nhập, lấy danh sách voucher đã lưu để kiểm tra
            model.UserModel currentUser = (model.UserModel) request.getSession().getAttribute("currentUser");
            if (currentUser != null) {
                java.util.List<model.UserVoucherModel> savedVouchers = voucherDAO.findAllSavedVouchersByUser(currentUser.getId());
                java.util.Map<Integer, model.UserVoucherModel> savedVoucherMap = new java.util.HashMap<>();
                for (model.UserVoucherModel uv : savedVouchers) {
                    savedVoucherMap.put(uv.getVoucherId(), uv);
                }
                request.setAttribute("savedVoucherMap", savedVoucherMap);
            }
            
            request.getRequestDispatcher("/views/home.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
