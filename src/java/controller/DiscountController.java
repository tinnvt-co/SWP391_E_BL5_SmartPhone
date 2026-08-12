package controller;

import DAO.DiscountDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import model.DiscountModel;

@WebServlet(name = "DiscountController", urlPatterns = {"/manager/discounts"})
public class DiscountController extends HttpServlet {
    private final DiscountDAO dao = new DiscountDAO();
    private static final SimpleDateFormat DT = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            if ("form".equals(req.getParameter("action"))) {
                int id = ProductController.integer(req.getParameter("id"), 0);
                req.setAttribute("discount", id > 0 ? dao.findById(id) : new DiscountModel());
                req.getRequestDispatcher("/views/manager/discount-form.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("discounts", dao.findAll(false));
            req.getRequestDispatcher("/views/manager/discount-list.jsp").forward(req, resp);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load discounts", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            if ("deactivate".equals(req.getParameter("action"))) {
                dao.deactivate(ProductController.integer(req.getParameter("id"), 0));
                resp.sendRedirect(req.getContextPath() + "/manager/discounts?message=Saved");
                return;
            }
            DiscountModel d = read(req);
            String error = validate(d);
            if (error != null) {
                req.setAttribute("error", error);
                req.setAttribute("discount", d);
                req.getRequestDispatcher("/views/manager/discount-form.jsp").forward(req, resp);
                return;
            }
            dao.save(d);
            resp.sendRedirect(req.getContextPath() + "/manager/discounts?message=Saved");
        } catch (SQLException ex) {
            req.setAttribute("error", ex.getMessage());
            req.setAttribute("discount", read(req));
            req.getRequestDispatcher("/views/manager/discount-form.jsp").forward(req, resp);
        }
    }

    private DiscountModel read(HttpServletRequest req) {
        DiscountModel d = new DiscountModel();
        d.setId(ProductController.integer(req.getParameter("id"), 0));
        d.setName(req.getParameter("name"));
        d.setDescription(req.getParameter("description"));
        d.setRate(ProductController.parseDecimal(req.getParameter("rate"), 0));
        d.setStart(parseDate(req.getParameter("start")));
        d.setEnd(parseDate(req.getParameter("end")));
        d.setActive("ACTIVE".equals(req.getParameter("status")));
        return d;
    }

    private Timestamp parseDate(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            return new Timestamp(DT.parse(s).getTime());
        } catch (ParseException e) {
            return null;
        }
    }

    private String validate(DiscountModel d) {
        if (d.getName() == null || d.getName().isBlank()) return "Discount name is required.";
        if (d.getName().length() > 255) return "Discount name cannot exceed 255 characters.";
        if (d.getRate() <= 0 || d.getRate() > 100) return "Rate must be between 0 and 100.";
        if (d.getStart() == null) return "Start date is required.";
        if (d.getEnd() == null) return "End date is required.";
        if (d.getEnd().before(d.getStart())) return "End date must be after start date.";
        return null;
    }
}