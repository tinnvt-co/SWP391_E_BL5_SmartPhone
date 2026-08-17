package controller;

import DAO.FeedbackDAO;
import model.FeedbackModel;
import model.FeedbackReplyModel;
import model.FeedbackWithReplies;
import model.UserModel;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Manager-side review queue.
 *
 * GET /manager/feedback -> list of all reviews (filter, search) GET
 * /manager/feedback?action=view&id=N -> show one review + its thread POST
 * /manager/feedback?action=reply&id=N -> post a reply (insert new Answer row)
 *
 * Why a unique thread URL per review: keeps the JSP bookmarkable and lets the
 * manager hand a permalink to a colleague.
 */
@WebServlet(name = "ManagerFeedbackController", urlPatterns = {"/manager/feedback"})
public class ManagerFeedbackController extends HttpServlet {

    private final FeedbackDAO dao = new FeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel user = requireManager(request, response);
        if (user == null) {
            return;
        }

        String action = request.getParameter("action");
        if ("view".equalsIgnoreCase(action)) {
            int id = parseInt(request.getParameter("id"));
            if (id <= 0) {
                response.sendRedirect(request.getContextPath() + "/manager/feedback");
                return;
            }
            try {
                FeedbackWithReplies item = dao.loadFeedbackWithReplies(id);
                if (item == null) {
                    response.sendRedirect(request.getContextPath() + "/manager/feedback");
                    return;
                }
                request.setAttribute("item", item);
                request.setAttribute("reviews", null);
                request.setAttribute("filter", buildFilter(request));
                request.getRequestDispatcher("/views/manager/feedback-list.jsp").forward(request, response);
            } catch (SQLException ex) {
                throw new ServletException("Cannot load feedback", ex);
            }
            return;
        }

        try {
            String keyword = request.getParameter("keyword");
            Integer rating = parseNullableInt(request.getParameter("rating"));
            boolean onlyUnanswered = "1".equals(request.getParameter("onlyUnanswered"))
                    || "true".equalsIgnoreCase(request.getParameter("onlyUnanswered"));
            List<FeedbackModel> reviews = dao.findAllForManager(keyword, rating, onlyUnanswered);
            request.setAttribute("reviews", reviews);
            request.setAttribute("filter", buildFilter(request));
            request.getRequestDispatcher("/views/manager/feedback-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("Cannot list feedback", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserModel user = requireManager(request, response);
        if (user == null) {
            return;
        }

        String action = request.getParameter("action");
        if (!"reply".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/manager/feedback");
            return;
        }

        int feedbackId = parseInt(request.getParameter("id"));
        String content = request.getParameter("content");
        if (feedbackId <= 0) {
            response.sendRedirect(request.getContextPath() + "/manager/feedback");
            return;
        }
        if (content == null) {
            content = "";
        }
        content = content.trim();
        if (content.length() < 3) {
            response.sendRedirect(request.getContextPath() + "/manager/feedback?action=view&id=" + feedbackId
                    + "&flash=" + encode("Reply must be at least 3 characters."));
            return;
        }
        if (content.length() > 255) {
            response.sendRedirect(request.getContextPath() + "/manager/feedback?action=view&id=" + feedbackId
                    + "&flash=" + encode("Reply must be 255 characters or fewer."));
            return;
        }

        try {
            FeedbackModel existing = dao.findById(feedbackId);
            if (existing == null || existing.isDeleted()) {
                response.sendRedirect(request.getContextPath() + "/manager/feedback");
                return;
            }
            if (!existing.isManagerReplyAllowed()) {
                response.sendRedirect(request.getContextPath() + "/manager/feedback?action=view&id=" + feedbackId
                        + "&flash=" + encode("Manager can reply only after the customer updates this review."));
                return;
            }
            dao.reply(feedbackId, user.getId(), content);
            response.sendRedirect(request.getContextPath() + "/manager/feedback?action=view&id=" + feedbackId
                    + "&flash=" + encode("Reply posted."));
        } catch (SQLException ex) {
            throw new ServletException("Cannot post reply", ex);
        }
    }

    private Object buildFilter(HttpServletRequest request) {
        FilterState f = new FilterState();
        f.keyword = request.getParameter("keyword");
        f.rating = request.getParameter("rating");
        f.onlyUnanswered = request.getParameter("onlyUnanswered");
        return f;
    }

    private UserModel requireManager(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
        if (role == null || !(role.equalsIgnoreCase("MANAGER") || role.equalsIgnoreCase("ADMIN"))) {
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

    private static Integer parseNullableInt(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private static String encode(String value) {
        return java.net.URLEncoder.encode(value, java.nio.charset.StandardCharsets.UTF_8);
    }

    public static class FilterState {

        public String keyword;
        public String rating;
        public String onlyUnanswered;

        public String getKeyword() {
            return keyword;
        }

        public String getRating() {
            return rating;
        }

        public String getOnlyUnanswered() {
            return onlyUnanswered;
        }
    }
}
