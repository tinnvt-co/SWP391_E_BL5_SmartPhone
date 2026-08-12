package controller;

import DAO.InventoryDAO;
import model.StockModel;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.annotation.WebServlet;

@WebServlet(name = "InventoryController", urlPatterns = {"/manager/inventory"})
public class InventoryController extends HttpServlet {

    private InventoryDAO dao = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String brand = request.getParameter("brand");
        String status = request.getParameter("status");
        List<StockModel> stocks = dao.getAllStock(keyword, brand, status);
        int[] stats = dao.getStockStats();

        request.setAttribute("stocks", stocks);
        request.setAttribute("stats", stats);
        request.setAttribute("keyword", keyword);
        request.setAttribute("brand", brand);
        request.setAttribute("status", status);
        request.getRequestDispatcher("/views/manager/inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if ("stockIn".equals(action)) {
            try {
                int variantId = Integer.parseInt(request.getParameter("variantId"));
                int qty = Integer.parseInt(request.getParameter("quantity"));
                String note = request.getParameter("note");
                if (qty <= 0) {
                    session.setAttribute("msgErr", "Quantity phải > 0");
                } else {
                    boolean ok = dao.stockIn(variantId, qty, note, userId);
                    session.setAttribute(ok ? "msgOk" : "msgErr", ok ? "Stock In thành công" : "Lỗi khi stock in");
                }
            } catch (Exception e) {
                session.setAttribute("msgErr", "Dữ liệu không hợp lệ");
            }
        } else if ("adjust".equals(action)) {
            try {
                int variantId = Integer.parseInt(request.getParameter("variantId"));
                int newStock = Integer.parseInt(request.getParameter("newStock"));
                String note = request.getParameter("note");
                if (newStock < 0) {
                    session.setAttribute("msgErr", "Stock không thể âm");
                } else {
                    boolean ok = dao.stockAdjust(variantId, newStock, note, userId);
                    session.setAttribute(ok ? "msgOk" : "msgErr", ok ? "Điều chỉnh thành công" : "Lỗi");
                }
            } catch (Exception e) {
                session.setAttribute("msgErr", "Dữ liệu không hợp lệ");
            }
        }
        response.sendRedirect(request.getContextPath() + "/manager/inventory");
    }
}