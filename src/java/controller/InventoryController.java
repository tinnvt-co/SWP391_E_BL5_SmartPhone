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

        HttpSession session = request.getSession();
        Object msgOk = session.getAttribute("msgOk");
        Object msgErr = session.getAttribute("msgErr");
        if (msgOk != null) {
            request.setAttribute("message", msgOk);
            session.removeAttribute("msgOk");
        }
        if (msgErr != null) {
            request.setAttribute("error", msgErr);
            session.removeAttribute("msgErr");
        }

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

        if ("adjust".equals(action)) {
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
                session.setAttribute("msgErr", "Dữ liệu không h�p lệ");
            }
        } else if ("updateLimits".equals(action)) {
            try {
                int variantId = Integer.parseInt(request.getParameter("variantId"));
                int minAmount = Integer.parseInt(request.getParameter("minAmount"));
                int maxAmount = Integer.parseInt(request.getParameter("maxAmount"));
                if (minAmount < 0 || maxAmount < 0) {
                    session.setAttribute("msgErr", "Min / Max không thể âm");
                } else if (maxAmount > 0 && minAmount > maxAmount) {
                    session.setAttribute("msgErr", "Min phải nhỏ hơn hoặc bằng Max");
                } else {
                    boolean ok = dao.updateMinMax(variantId, minAmount, maxAmount, userId);
                    session.setAttribute(ok ? "msgOk" : "msgErr", ok ? "Đã cập nhật ngưỡng Min / Max" : "Lỗi khi cập nhật");
                }
            } catch (Exception e) {
                session.setAttribute("msgErr", "Dữ liệu không hợp lệ");
            }
        }
        response.sendRedirect(request.getContextPath() + "/manager/inventory");
    }
}
