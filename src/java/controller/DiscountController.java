package controller;

import DAO.DiscountDAO;
import DAO.ProductDAO;
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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.DiscountModel;
import model.ProductModel;

@WebServlet(name = "DiscountController", urlPatterns = {"/manager/discounts"})
public class DiscountController extends HttpServlet {
    private final DiscountDAO dao = new DiscountDAO();
    private final ProductDAO productDao = new ProductDAO();
    private static final SimpleDateFormat DT = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String action = req.getParameter("action");
            if ("form".equals(action)) {
                int id = ProductController.integer(req.getParameter("id"), 0);
                DiscountModel discount = id > 0 ? dao.findById(id) : new DiscountModel();
                req.setAttribute("discount", discount);
                Set<Integer> exclude = dao.findLiveOrScheduledProductIds(id > 0 ? id : null);
                req.setAttribute("products", productDao.findAll(null, null, null, null, false, exclude));
                req.setAttribute("selectedIds", discount == null ? Set.of() : new HashSet<>(discount.getProductIds()));
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
            String action = req.getParameter("action");
            if ("delete".equals(action)) {
                dao.delete(ProductController.integer(req.getParameter("id"), 0));
                resp.sendRedirect(req.getContextPath() + "/manager/discounts?message=Deleted");
                return;
            }
            DiscountModel d = read(req);
            String error = validate(d);
            if (error != null) {
                req.setAttribute("error", error);
                req.setAttribute("discount", d);
                Set<Integer> exclude = dao.findLiveOrScheduledProductIds(d.getId() > 0 ? d.getId() : null);
                req.setAttribute("products", productDao.findAll(null, null, null, null, false, exclude));
                req.setAttribute("selectedIds", new HashSet<>(d.getProductIds()));
                req.getRequestDispatcher("/views/manager/discount-form.jsp").forward(req, resp);
                return;
            }
            dao.save(d);
            resp.sendRedirect(req.getContextPath() + "/manager/discounts?message=Saved");
        } catch (SQLException ex) {
            req.setAttribute("error", ex.getMessage());
            DiscountModel d = read(req);
            req.setAttribute("discount", d);
            try {
                Set<Integer> exclude = dao.findLiveOrScheduledProductIds(d.getId() > 0 ? d.getId() : null);
                req.setAttribute("products", productDao.findAll(null, null, null, null, false, exclude));
            } catch (SQLException ignored) { }
            req.setAttribute("selectedIds", new HashSet<>(d.getProductIds()));
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
        d.setProductIds(parseProductIds(req.getParameterValues("productIds")));
        return d;
    }

    private List<Integer> parseProductIds(String[] raw) {
        List<Integer> ids = new ArrayList<>();
        if (raw == null) return ids;
        Set<Integer> seen = new HashSet<>();
        for (String s : raw) {
            try {
                int id = Integer.parseInt(s);
                if (seen.add(id)) ids.add(id);
            } catch (NumberFormatException ignored) { }
        }
        return ids;
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
