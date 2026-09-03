package controller;

import DAO.FeedbackDAO;
import DAO.FeedbackDAO.OrderSummary;
import DAO.RefundDAO;
import model.FeedbackModel;
import model.UserModel;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Customer-facing review flow.
 *
 * GET /feedback?orderId=N -> list of variants in the order, each in "create" or
 * "edit" mode GET /feedback?orderId=N&variantId=V -> jump straight to that
 * variant's form POST /feedback -> save (insert or update) one review POST
 * /feedback?action=delete -> soft-delete (within 15-day window)
 */
public class FeedbackController extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final RefundDAO returnRequestDAO = new RefundDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UserModel user = requireCustomer(request, response);
        if (user == null) {
            return;
        }

        String orderIdRaw = request.getParameter("orderId");

        if (orderIdRaw == null || orderIdRaw.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        int orderId;

        try {
            orderId = Integer.parseInt(orderIdRaw);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        try {
            OrderSummary order = feedbackDAO.findOrderSummary(orderId, user.getId());

            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/order-history");
                return;
            }

            if (!"DELIVERED".equals(order.status)
                    && !"COMPLETED".equals(order.status)) {

                request.setAttribute(
                        "error",
                        "Cần nhận hàng mới có thể gửi đánh giá."
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/order-detail?id="
                        + orderId
                );

                return;
            }

            if (returnRequestDAO.hasBlockingRefundForTransaction(user.getId(), orderId)) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/return-request?orderId="
                        + orderId
                        + "&flash="
                        + encode(
                                "Bạn đã trả hàng nên không được đánh giá."
                        )
                );
                return;
            }

            List<Map<String, Object>> items = feedbackDAO.findReviewableItems(user.getId(), orderId);

            request.setAttribute("order", order);
            request.setAttribute("items", items);
            request.setAttribute("lineItemCount",feedbackDAO.countTransactionItems(orderId)
            );
            request.setAttribute(
                    "focusVariantId",
                    parseInt(request.getParameter("variantId"))
            );
            request.setAttribute(
                    "flash",
                    request.getParameter("flash")
            );

            request.getRequestDispatcher(
                    "/views/customer/feedback.jsp"
            ).forward(request, response);

        } catch (SQLException ex) {
            response.sendRedirect(request.getContextPath() + "/order-history?flash="
                    + encode("Cannot load feedback form. Please try again."));
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
        int variantId = parseInt(request.getParameter("variantId"));
        int rating = parseInt(request.getParameter("rating"));

        //Validate
        String content = trimToNull(request.getParameter("content")
        );

        if (orderId <= 0 || variantId <= 0) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/order-history"
            );
            return;
        }

        if (rating < 1 || rating > 5) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/feedback?orderId="
                    + orderId
                    + "&variantId="
                    + variantId
                    + "&flash="
                    + encode(
                            "Please pick a rating from 1 to 5 stars."
                    )
            );
            return;
        }

        if (content == null || content.length() < 5) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/feedback?orderId="
                    + orderId
                    + "&variantId="
                    + variantId
                    + "&flash="
                    + encode(
                            "Please write at least 5 characters."
                    )
            );
            return;
        }

        if (content.length() > 255) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/feedback?orderId="
                    + orderId
                    + "&variantId="
                    + variantId
                    + "&flash="
                    + encode(
                            "Review must be 255 characters or fewer."
                    )
            );
            return;
        }

        try {
            if (returnRequestDAO.hasBlockingRefundForTransaction(user.getId(), orderId)) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/return-request?orderId="
                        + orderId
                        + "&flash="
                        + encode(
                                "This order is being refunded, so reviews are disabled."
                        )
                );
                return;
            }

            if (!feedbackDAO.canReview(
                    user.getId(),
                    orderId,
                    variantId)) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Order is not eligible for review"
                );

                return;
            }

            FeedbackModel existing
                    = feedbackDAO.findByUserVariantOrder(
                            user.getId(),
                            variantId,
                            orderId
                    );

            OrderSummary order = feedbackDAO.findOrderSummary(orderId, user.getId());
            boolean orderTooOld = order != null
                    && order.createdAt != null
                    && (System.currentTimeMillis() - order.createdAt.getTime()) > 2L * 365 * 24 * 60 * 60 * 1000;

            FeedbackModel toSave = new FeedbackModel();

            toSave.setRating(rating);
            toSave.setContent(content);
            toSave.setUserId(user.getId());
            toSave.setProductVariantId(variantId);
            toSave.setTransactionId(orderId);

            String flash;

            if (existing == null) {

                if (orderTooOld) {
                    response.sendRedirect(
                            request.getContextPath()
                            + "/feedback?orderId="
                            + orderId
                            + "&flash="
                            + encode(
                                    "Cần review trong vòng 2 năm"
                            )
                    );
                    return;
                }

                feedbackDAO.saveCustomerFeedback(toSave);

                flash = "Thanks for your review!";

            } else {

                if (!existing.isWithinEditWindow()) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/feedback?orderId="
                            + orderId
                            + "&variantId="
                            + variantId
                            + "&flash="
                            + encode(
                                    "Cần review trong vòng 2 năm"
                            )
                    );

                    return;
                }

                toSave.setId(existing.getId());
                feedbackDAO.saveCustomerFeedback(toSave);

                long remaining
                        = existing.getEditWindowRemainingDays();

                flash
                        = "Review updated. You can still edit it for about "
                        + remaining
                        + " more day(s).";
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/feedback?orderId="
                    + orderId
                    + "&variantId="
                    + variantId
                    + "&flash="
                    + encode(flash)
            );

        } catch (SQLException ex) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/feedback?orderId="
                    + orderId
                    + "&variantId="
                    + variantId
                    + "&rating="
                    + rating
                    + "&content="
                    + encode(content)
                    + "&flash="
                    + encode("Cannot save review. Please try again.")
            );
        }
    }

    private UserModel requireCustomer(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return null;
        }

        UserModel user
                = (UserModel) session.getAttribute(
                        "currentUser"
                );

        if (user == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return null;
        }

        String role
                = (String) session.getAttribute(
                        "currentRole"
                );

        if (role != null
                && !"CUSTOMER".equalsIgnoreCase(role)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
            );

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

        String trimmed = value.trim();

        return trimmed.isEmpty()
                ? null
                : trimmed;
    }

    private static String encode(String value) {

        return java.net.URLEncoder.encode(
                value,
                java.nio.charset.StandardCharsets.UTF_8
        );
    }
}
