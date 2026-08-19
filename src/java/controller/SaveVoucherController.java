package controller;

import DAO.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import model.UserModel;


@WebServlet(name = "SaveVoucherController", urlPatterns = {"/voucher/save"})
public class SaveVoucherController extends HttpServlet {

    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            out.print("{\"success\": false, \"message\": \"You must be logged in to save vouchers.\"}");
            return;
        }

        try {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            boolean saved = voucherDAO.saveVoucherForUser(currentUser.getId(), voucherId);
            
            if (saved) {
                out.print("{\"success\": true}");
            } else {
                out.print("{\"success\": false, \"message\": \"Voucher may already be saved or is no longer available.\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"An error occurred while saving the voucher.\"}");
            e.printStackTrace();
        }
    }
}
