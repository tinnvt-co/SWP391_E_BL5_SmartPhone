package controller;

import DAO.StoreInformationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.StoreInformationModel;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

public class StoreInfoController extends HttpServlet {

    private StoreInformationDAO storeDAO;

    // Regex dùng cho validate
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[\\w]+@[\\w-]+(\\.[\\w-]+)*\\.[a-zA-Z]{2,}$");

    // SĐT Việt Nam: bắt đầu bằng 0, theo sau 9 chữ số (10 số tổng)
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^0\\d{9}$");

    // Facebook URL hợp lệ (không bắt buộc nhập)
    private static final Pattern FACEBOOK_PATTERN =
            Pattern.compile("^(https?://)?(www\\.)?facebook\\.com/.+$");

    @Override
    public void init() {
        storeDAO = new StoreInformationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        StoreInformationModel store = storeDAO.getStoreInformation();
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

        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String facebookUrl = request.getParameter("facebookUrl");

        // =========================
        // VALIDATE INPUT
        // =========================
        Map<String, String> errors = validateInput(address, phone, email, facebookUrl);

        if (!errors.isEmpty()) {
            StoreInformationModel invalidStore = new StoreInformationModel();
            invalidStore.setAddress(address);
            invalidStore.setPhone(phone);
            invalidStore.setEmail(email);
            invalidStore.setFacebookUrl(facebookUrl);

            request.setAttribute("store", invalidStore);
            request.setAttribute("errors", errors);
            request.setAttribute("error", "Vui lòng kiểm tra lại thông tin nhập vào.");
            request.getRequestDispatcher(
                    "/views/manager/store-info.jsp"
            ).forward(request, response);
            return;
        }

        // =========================
        // GET CURRENT DATA
        // =========================
        StoreInformationModel store = storeDAO.getStoreInformation();
        if (store == null) {
            request.setAttribute("error", "Store information not found.");
            request.getRequestDispatcher(
                    "/views/manager/store-info.jsp"
            ).forward(request, response);
            return;
        }

        // =========================
        // SET NEW DATA
        // =========================
        store.setAddress(address.trim());
        store.setPhone(phone.trim());
        store.setEmail(email.trim());
        store.setFacebookUrl(facebookUrl == null ? null : facebookUrl.trim());

        // =========================
        // UPDATE DATABASE
        // =========================
        boolean success = storeDAO.updateStoreInformation(store);

        if (success) {
            request.getSession().setAttribute(
                    "success",
                    "Store information updated successfully."
            );
            response.sendRedirect(
                    request.getContextPath() + "/manager/storeinfo"
            );
        } else {
            request.setAttribute("error", "Failed to update store information.");
            request.setAttribute("store", store);
            request.getRequestDispatcher(
                    "/views/manager/store-info.jsp"
            ).forward(request, response);
        }
    }

    /**
     * Validate dữ liệu nhập vào từ form.
     * @return Map rỗng nếu hợp lệ, ngược lại chứa lỗi theo từng field.
     */
    private Map<String, String> validateInput(
            String address, String phone, String email, String facebookUrl) {

        Map<String, String> errors = new HashMap<>();

        // --- Address ---
        if (address == null || address.trim().isEmpty()) {
            errors.put("address", "Địa chỉ không được để trống.");
        } else if (address.trim().length() > 255) {
            errors.put("address", "Địa chỉ không được vượt quá 255 ký tự.");
        }

        // --- Phone ---
        if (phone == null || phone.trim().isEmpty()) {
            errors.put("phone", "Số điện thoại không được để trống.");
        } else if (!PHONE_PATTERN.matcher(phone.trim()).matches()) {
            errors.put("phone", "Số điện thoại không hợp lệ (phải gồm 10 số, bắt đầu bằng 0).");
        }

        // --- Email ---
        if (email == null || email.trim().isEmpty()) {
            errors.put("email", "Email không được để trống.");
        } else if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            errors.put("email", "Email không đúng định dạng.");
        }

        // --- Facebook URL (không bắt buộc) ---
        if (facebookUrl != null && !facebookUrl.trim().isEmpty()
                && !FACEBOOK_PATTERN.matcher(facebookUrl.trim()).matches()) {
            errors.put("facebookUrl", "Đường dẫn Facebook không hợp lệ.");
        }

        return errors;
    }
}