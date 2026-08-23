package controller;

import DAO.StoreInformationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.StoreInformationModel;

import java.io.IOException;

public class StoreInfoController extends HttpServlet {

    private StoreInformationDAO storeDAO;

    @Override
    public void init() {
        storeDAO = new StoreInformationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        StoreInformationModel store
                = storeDAO.getStoreInformation();

        request.setAttribute("store", store);

        request.getRequestDispatcher(
                "/views/manager/store-info.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String address
                = request.getParameter("address");

        String phone
                = request.getParameter("phone");

        String email
                = request.getParameter("email");

        String facebookUrl
                = request.getParameter("facebookUrl");

        // =========================
        // GET CURRENT DATA
        // =========================
        StoreInformationModel store
                = storeDAO.getStoreInformation();

        if (store == null) {

            request.setAttribute(
                    "error",
                    "Store information not found."
            );

            request.getRequestDispatcher(
                    "/views/manager/store-info.jsp"
            ).forward(request, response);

            return;
        }

        // =========================
        // SET NEW DATA
        // =========================
        store.setAddress(address);
        store.setPhone(phone);
        store.setEmail(email);
        store.setFacebookUrl(facebookUrl);

        // =========================
        // UPDATE DATABASE
        // =========================
        boolean success
                = storeDAO.updateStoreInformation(store);

        if (success) {

            request.getSession().setAttribute(
                    "success",
                    "Store information updated successfully."
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/manager/storeinfo"
            );

        } else {

            request.setAttribute(
                    "error",
                    "Failed to update store information."
            );

            request.setAttribute(
                    "store",
                    store
            );

            request.getRequestDispatcher(
                    "/views/manager/store-info.jsp"
            ).forward(request, response);
        }
    }
}
