package controller;

import DAO.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.BrandModel;

@WebServlet(name = "BrandController", urlPatterns = {"/manager/brands"})
public class BrandController extends HttpServlet {
    private final BrandDAO dao = new BrandDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            if ("form".equals(req.getParameter("action"))) {
                int id = ProductController.integer(req.getParameter("id"), 0);
                req.setAttribute("brand", id > 0 ? dao.findById(id) : new BrandModel());
                req.getRequestDispatcher("/views/manager/brand-form.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("brands", dao.findAll(false));
            req.getRequestDispatcher("/views/manager/brand-list.jsp").forward(req, resp);
        } catch (SQLException ex) {
            throw new ServletException("Cannot load brands", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            if ("deactivate".equals(req.getParameter("action"))) {
                dao.deactivate(ProductController.integer(req.getParameter("id"), 0));
            } else {
                BrandModel brand = read(req);
                if (brand.getName() == null || brand.getName().isBlank()) {
                    req.setAttribute("error", "Brand name is required.");
                    req.setAttribute("brand", brand);
                    req.getRequestDispatcher("/views/manager/brand-form.jsp").forward(req, resp);
                    return;
                }
                dao.save(brand);
            }
            resp.sendRedirect(req.getContextPath() + "/manager/brands?message=Saved");
        } catch (SQLException ex) {
            req.setAttribute("error", ex.getErrorCode() == 1062 ? "Brand name already exists." : ex.getMessage());
            req.setAttribute("brand", read(req));
            req.getRequestDispatcher("/views/manager/brand-form.jsp").forward(req, resp);
        }
    }

    private BrandModel read(HttpServletRequest req) {
        BrandModel brand = new BrandModel();
        brand.setId(ProductController.integer(req.getParameter("id"), 0));
        brand.setName(req.getParameter("name"));
        brand.setDescription(req.getParameter("description"));
        brand.setActive("ACTIVE".equals(req.getParameter("status")));
        return brand;
    }
}
