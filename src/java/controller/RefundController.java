package controller;

import DAO.OrderDAO;
import DAO.RefundDAO;
import model.OrderModel;
import model.ReturnRequestModel;
import model.UserModel;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

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
                ReturnRequestModel r = returnDAO.findDetail(id);
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
                boolean alreadyRequested = returnDAO.hasActiveForTransaction(user.getId(), orderId);
                request.setAttribute("order", order);
                request.setAttribute("bankRequired", isPaidOrder(order));
                request.setAttribute("alreadyRequested", alreadyRequested);
                request.setAttribute("flash", request.getParameter("flash"));
                if (alreadyRequested) {
                    // load the existing ACTIVE one so we can show its status
                    List<ReturnRequestModel> mine = returnDAO.findByUserId(user.getId());
                    for (ReturnRequestModel rr : mine) {
                        if (rr.getTransactionId() == orderId && rr.isPending()) {
                            request.setAttribute("activeRequest", returnDAO.findDetail(rr.getId()));
                            break;
                        }
                    }
                }
                request.setAttribute("view", "form");
                request.getRequestDispatcher("/views/customer/return-request.jsp").forward(request, response);
                return;
            }

            // no orderId/id: list all refund requests of this user
            List<ReturnRequestModel> mine = returnDAO.findByUserId(user.getId());
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

        try {
            OrderModel order = orderDAO.findOrderDetail(orderId);
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
            boolean bankRequired = isPaidOrder(order);
            String bankName = trimToNull(request.getParameter("bankName"));
            String bankAccountNumber = trimToNull(request.getParameter("bankAccountNumber"));
            String bankAccountHolder = trimToNull(request.getParameter("bankAccountHolder"));
            if (bankRequired && (bankName == null || bankAccountNumber == null || bankAccountHolder == null)) {
                response.sendRedirect(request.getContextPath() + "/return-request?orderId=" + orderId
                        + "&flash=" + encode("Please enter bank information for the refund transfer."));
                return;
            }

            ReturnRequestModel created = returnDAO.createForOrder(
                    user.getId(), orderId, description, savedFileName,
                    bankName, bankAccountNumber, bankAccountHolder);

            response.sendRedirect(request.getContextPath() + "/return-request?id=" + created.getId()
                    + "&flash=" + encode("Your refund request has been submitted. We'll review it shortly."));
        } catch (SQLException ex) {
            throw new ServletException("Cannot submit refund request", ex);
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
            // request entity too large
            throw new ServletException("Upload is too large.", ex);
        }
        if (part == null || part.getSize() == 0) {
            return null;
        }
        String contentType = part.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new ServletException("Only image uploads are allowed.");
        }

        // Folder target
        String webRoot = request.getServletContext().getRealPath("/");
        if (webRoot == null) {
            throw new ServletException("Cannot resolve web root for upload.");
        }
        Path folder = Paths.get(webRoot, "assets", "images", "refund");
        Files.createDirectories(folder);

        String extension = guessExtension(contentType);
        String fileName = UUID.randomUUID().toString().replace("-", "") + extension;
        Path target = folder.resolve(fileName);
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
        return fileName;
    }

    private static String guessExtension(String contentType) {
        switch (contentType.toLowerCase()) {
            case "image/png":
                return ".png";
            case "image/gif":
                return ".gif";
            case "image/webp":
                return ".webp";
            default:
                return ".jpg";
        }
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

    private static boolean isPaidOrder(OrderModel order) {
        BigDecimal paid = order == null ? null : order.getPaidAmount();
        return paid != null && paid.compareTo(BigDecimal.ZERO) > 0;
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, UTF_8);
    }
}
