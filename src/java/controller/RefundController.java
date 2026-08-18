package controller;

import DAO.OrderDAO;
import DAO.RefundDAO;
import model.OrderModel;
import model.RefundModel;
import model.UserModel;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.ByteArrayInputStream;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

/**
 * Customer-facing refund/return request flow.
 *
 * GET /return-request?orderId=N -> open the form (or list existing refund
 * requests for this user) GET /return-request?id=N -> detail of one of the
 * user's previous requests POST /return-request -> submit a new request
 * (multipart: reason text + image)
 *
 * Image uploads land in {@code <webroot>/assets/images/refund/}. File names are
 * randomised so we don't expose the customer's original filename.
 */
@WebServlet(name = "ReturnRequestController", urlPatterns = {"/return-request"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB spill to disk
        maxFileSize = 5L * 1024 * 1024, // 5MB per file
        maxRequestSize = 10L * 1024 * 1024 // 10MB total
)
public class RefundController extends HttpServlet {

    private static final java.nio.charset.Charset UTF_8 = java.nio.charset.StandardCharsets.UTF_8;

    private final RefundDAO returnDAO = new RefundDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UserModel user = requireCustomer(request, response);
        if (user == null) {
            return;
        }

        try {
            int id = parseInt(request.getParameter("id"));
            if (id > 0) {
                RefundModel r = returnDAO.findDetail(id);
                if (r == null || r.getUserId() != user.getId()) {
                    response.sendRedirect(request.getContextPath() + "/order-history");
                    return;
                }
                request.setAttribute("request", r);
                request.setAttribute("view", "detail");
                request.getRequestDispatcher("/views/customer/return-request.jsp").forward(request, response);
                return;
            }

            int orderId = parseInt(request.getParameter("orderId"));
            if (orderId > 0) {
                OrderModel order = orderDAO.findOrderDetail(orderId);
                if (order == null || order.getUserId() != user.getId()) {
                    response.sendRedirect(request.getContextPath() + "/order-history");
                    return;
                }
                if (!"COMPLETED".equals(order.getStatus()) && !"DELIVERED".equals(order.getStatus())) {
                    request.setAttribute("error",
                            "You can only request a refund for orders that have been completed or delivered.");
                    request.setAttribute("order", order);
                    request.getRequestDispatcher("/views/customer/return-request.jsp").forward(request, response);
                    return;
                }
                prepareRefundForm(request, user, order);
                request.getRequestDispatcher("/views/customer/return-request.jsp").forward(request, response);
                return;
            }

            // no orderId/id: list all refund requests of this user
            List<RefundModel> mine = returnDAO.findByUserId(user.getId());
            request.setAttribute("myRequests", mine);
            request.setAttribute("view", "list");
            request.getRequestDispatcher("/views/customer/return-request.jsp").forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException("Cannot load refund request", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        //Validate
        UserModel user = requireCustomer(request, response);
        if (user == null) {
            return;
        }

        int orderId = parseInt(request.getParameter("orderId"));
        if (orderId <= 0) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        String description = trimToNull(request.getParameter("description"));
        if (description == null || description.length() < 5) {
            response.sendRedirect(request.getContextPath() + "/return-request?orderId=" + orderId
                    + "&flash=" + encode("Please describe the reason (at least 5 characters)."));
            return;
        }
        if (description.length() > 255) {
            response.sendRedirect(request.getContextPath() + "/return-request?orderId=" + orderId
                    + "&flash=" + encode("Reason must be 255 characters or fewer."));
            return;
        }

        String bankName = trimToNull(request.getParameter("bankName"));
        String bankAccountNumber = trimToNull(request.getParameter("bankAccountNumber"));
        String bankAccountHolder = trimToNull(request.getParameter("bankAccountHolder"));
        if (bankName == null || bankAccountNumber == null || bankAccountHolder == null) {
            response.sendRedirect(request.getContextPath() + "/return-request?orderId=" + orderId
                    + "&flash=" + encode("Please enter bank information for the refund transfer."));
            return;
        }
        OrderModel order = null;

        try {
            order = orderDAO.findOrderDetail(orderId);
            if (order == null || order.getUserId() != user.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Order is not yours.");
                return;
            }
            if (!"COMPLETED".equals(order.getStatus()) && !"DELIVERED".equals(order.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/return-request?orderId=" + orderId
                        + "&flash=" + encode("Order is not eligible for refund yet."));
                return;
            }
            if (returnDAO.hasActiveForTransaction(user.getId(), orderId)) {
                response.sendRedirect(request.getContextPath() + "/return-request?orderId=" + orderId
                        + "&flash=" + encode("You already have a pending refund request for this order."));
                return;
            }

            String savedFileName = saveImageIfAny(request);

            RefundModel created = returnDAO.createForOrder(
                    user.getId(), orderId, description, savedFileName,
                    bankName, bankAccountNumber, bankAccountHolder);

            response.sendRedirect(request.getContextPath() + "/return-request?id=" + created.getId()
                    + "&flash=" + encode("Your refund request has been submitted. We'll review it shortly."));
        } catch (SQLException ex) {
            showRefundFormWithError(
                    request,
                    response,
                    user,
                    order,
                    description,
                    bankName,
                    bankAccountNumber,
                    bankAccountHolder,
                    "Cannot submit refund request. Please try again."
            );

        } catch (ServletException ex) {

            showRefundFormWithError(
                    request,
                    response,
                    user,
                    order,
                    description,
                    bankName,
                    bankAccountNumber,
                    bankAccountHolder,
                    ex.getMessage()
            );
        }
    }

    private void showRefundFormWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            UserModel user,
            OrderModel order,
            String description,
            String bankName,
            String bankAccountNumber,
            String bankAccountHolder,
            String error
    ) throws ServletException, IOException {

        request.setAttribute("description", description);
        request.setAttribute("bankName", bankName);
        request.setAttribute("bankAccountNumber", bankAccountNumber);
        request.setAttribute("bankAccountHolder", bankAccountHolder);
        request.setAttribute("error", error);

        try {
            if (order != null) {
                prepareRefundForm(request, user, order);
            }
        } catch (SQLException ex) {
            throw new ServletException(
                    "Cannot prepare refund form",
                    ex
            );
        }

        request.getRequestDispatcher(
                "/views/customer/return-request.jsp"
        ).forward(request, response);
    }

    private void prepareRefundForm(
            HttpServletRequest request,
            UserModel user,
            OrderModel order
    ) throws SQLException {

        int orderId = order.getId();

        boolean alreadyRequested
                = returnDAO.hasActiveForTransaction(
                        user.getId(),
                        orderId
                );

        request.setAttribute("order", order);
        request.setAttribute("alreadyRequested", alreadyRequested);
        request.setAttribute("view", "form");

        if (alreadyRequested) {
            List<RefundModel> mine
                    = returnDAO.findByUserId(user.getId());

            for (RefundModel rr : mine) {
                if (rr.getTransactionId() == orderId
                        && rr.isPending()) {

                    request.setAttribute(
                            "activeRequest",
                            returnDAO.findDetail(rr.getId())
                    );

                    break;
                }
            }
        }
    }

    /**
     * Saves the {@code image} part of the form (if any) to
     * {@code assets/images/refund/} under the web root and returns the new file
     * name. Returns {@code null} when no file was uploaded.
     */
    private String saveImageIfAny(HttpServletRequest request) throws IOException, ServletException {
        Part part;
        try {
            part = request.getPart("image");
        } catch (IllegalStateException ex) {
            throw new ServletException("Upload is too large.");
        }
        if (part == null || part.getSize() == 0) {
            throw new ServletException("Image is required.");
        }

        // Đọc toàn bộ file vào bộ nhớ trước để vừa validate, vừa ghi file
        byte[] data;
        try (InputStream in = part.getInputStream()) {
            data = in.readAllBytes();
        }

        // Xác thực thật sự đây là ảnh bằng cách thử decode nó,
        // thay vì chỉ tin vào Content-Type do client gửi lên
        String actualFormat;
        try (InputStream in = new ByteArrayInputStream(data); ImageInputStream iis = ImageIO.createImageInputStream(in)) {
            Iterator<ImageReader> readers = ImageIO.getImageReaders(iis);
            if (!readers.hasNext()) {
                throw new ServletException("Only image uploads are allowed.");
            }
            actualFormat = readers.next().getFormatName().toLowerCase(); // "jpeg", "png", "gif", "webp"...
        }

        String webRoot = request.getServletContext().getRealPath("/");
        if (webRoot == null) {
            throw new ServletException("Cannot resolve web root for upload.");
        }
        Path folder = Paths.get(webRoot, "assets", "images", "refund");
        Files.createDirectories(folder);

        // Suy ra extension từ format ĐÃ ĐƯỢC XÁC THỰC, không dùng contentType của client nữa
        String extension = switch (actualFormat) {
            case "png" ->
                ".png";
            case "gif" ->
                ".gif";
            case "webp" ->
                ".webp";
            case "jpeg", "jpg" ->
                ".jpg";
            default ->
                throw new ServletException("Unsupported image format.");
        };

        String fileName = UUID.randomUUID().toString().replace("-", "") + extension;
        Path target = folder.resolve(fileName);
        Files.write(target, data, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

        return fileName;
    }

    //  Filters / helpers                                                 
    private UserModel requireCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        UserModel user = (UserModel) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        String role = (String) session.getAttribute("currentRole");
        if (role != null && !"CUSTOMER".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    private static int parseInt(String value) {
        if (value == null || value.isBlank()) {
            return 0;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String t = value.trim();
        return t.isEmpty() ? null : t;
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, UTF_8);
    }
}
