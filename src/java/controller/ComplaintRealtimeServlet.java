package controller;

import DAO.ComplaintDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ComplaintMessageModel;
import model.ComplaintModel;
import model.UserModel;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;

/**
 * Dedicated realtime channel for the complaint chatbox.
 *
 * <p>
 * Servlet này dùng cho chatbox khiếu nại giữa Customer và Manager.
 * Hiện tại sử dụng polling:
 * frontend gọi endpoint định kỳ để lấy các message mới.
 * </p>
 *
 * <p>
 * Endpoint:
 * GET /complaint-realtime?complaintId=...&since=...
 * </p>
 *
 * <p>
 * Quyền truy cập:
 * - Customer: chỉ được xem complaint do chính mình tạo.
 * - Manager: được xem và trao đổi với Customer.
 * - Staff/Admin: không được truy cập complaint chat.
 * </p>
 */
@WebServlet(
        name = "ComplaintRealtimeServlet",
        urlPatterns = {"/complaint-realtime"}
)
public class ComplaintRealtimeServlet extends HttpServlet {

    /*
     * Chỉ Manager được phép xử lý complaint phía nhân viên.
     *
     * Customer vẫn được phép xem complaint của chính mình
     * thông qua điều kiện complaint.getUserId() == user.getId().
     */
    private static final String MANAGER_ROLE = "MANAGER";

    /*
     * DAO dùng để:
     * - tìm complaint
     * - lấy các message mới
     */
    private final ComplaintDAO complaintDAO = new ComplaintDAO();

    /**
     * METHOD CHÍNH CỦA REALTIME POLLING
     *
     * Frontend gọi method này định kỳ để lấy:
     * - trạng thái complaint hiện tại
     * - các message mới kể từ thời điểm "since"
     */
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        /*
         * Lấy session hiện tại.
         *
         * false = không tạo session mới nếu user chưa đăng nhập.
         */
        HttpSession session = request.getSession(false);

        /*
         * Lấy user hiện tại từ session.
         */
        UserModel user = currentUser(session);

        /*
         * Nếu chưa đăng nhập → từ chối truy cập.
         */
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(response, "{\"error\":\"unauthorized\"}");
            return;
        }

        /*
         * complaintId:
         * ID của complaint mà chatbox đang mở.
         */
        int complaintId = parseInt(
                request.getParameter("complaintId"),
                0
        );

        /*
         * since:
         * Thời điểm cuối cùng frontend đã nhận message.
         *
         * Servlet chỉ lấy message mới hơn thời điểm này.
         *
         * Đây là phần quan trọng của POLLING REALTIME.
         */
        long sinceMillis = parseLong(
                request.getParameter("since"),
                0L
        );

        /*
         * Kiểm tra complaintId có hợp lệ hay không.
         */
        if (complaintId <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(response, "{\"error\":\"invalid\"}");
            return;
        }

        try {

            /*
             * Lấy thông tin complaint từ Database.
             */
            ComplaintModel complaint =
                    complaintDAO.findById(complaintId);

            /*
             * Complaint không tồn tại.
             */
            if (complaint == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJson(response, "{\"error\":\"not_found\"}");
                return;
            }

            /*
             * KIỂM TRA QUYỀN TRUY CẬP
             *
             * Customer:
             * - Chỉ được xem complaint do chính mình tạo.
             *
             * Manager:
             * - Được xem complaint để xử lý và trả lời Customer.
             *
             * Staff/Admin:
             * - Không được truy cập complaint chat.
             */
            boolean isCustomer =
                    complaint.getUserId() == user.getId();

            boolean isManager =
                    MANAGER_ROLE.equals(
                            normalizeRole(user.getRoleName())
                    );

            boolean allowed = isCustomer || isManager;

            /*
             * Không phải Customer của complaint
             * và cũng không phải Manager → từ chối.
             */
            if (!allowed) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                writeJson(response, "{\"error\":\"forbidden\"}");
                return;
            }

            /*
             * LẤY MESSAGE MỚI
             *
             * Chỉ lấy những message được tạo sau "since".
             *
             * Ví dụ:
             *
             * Lần đầu:
             * since = 10:00:00
             *
             * Manager gửi message lúc:
             * 10:00:05
             *
             * Lần polling tiếp theo:
             * since = 10:00:00
             *
             * → DAO trả về message lúc 10:00:05.
             *
             * Đây là phần cốt lõi của polling realtime.
             */
            List<ComplaintMessageModel> messages =
                    complaintDAO.findMessagesSince(
                            complaintId,
                            new java.sql.Timestamp(sinceMillis)
                    );

            /*
             * Tạo JSON response trả về frontend.
             *
             * Response gồm:
             * - complaintId
             * - status
             * - messages
             */
            StringBuilder sb = new StringBuilder(256);

            sb.append("{\"complaintId\":")
                    .append(complaint.getId());

            /*
             * Trả trạng thái hiện tại của complaint.
             *
             * Frontend có thể dùng status này để cập nhật
             * giao diện chatbox.
             */
            sb.append(",\"status\":\"")
                    .append(escape(complaint.getStatus()))
                    .append("\"");

            sb.append(",\"messages\":[");

            boolean first = true;

            /*
             * Chuyển từng message thành JSON.
             */
            for (ComplaintMessageModel message : messages) {

                if (!first) {
                    sb.append(',');
                }

                first = false;

                appendMessageJson(sb, message);
            }

            sb.append("]}");

            /*
             * Trả JSON về cho JavaScript của chatbox.
             */
            writeJson(response, sb.toString());

        } catch (SQLException exception) {

            /*
             * Nếu xảy ra lỗi Database → HTTP 500.
             */
            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            writeJson(response, "{\"error\":\"database\"}");
        }
    }

    /**
     * Chuyển ComplaintMessageModel thành JSON.
     *
     * Frontend nhận được các thông tin:
     * - id
     * - senderId
     * - senderRole
     * - senderName
     * - content
     * - createdAt
     */
    private void appendMessageJson(
            StringBuilder sb,
            ComplaintMessageModel message) {

        sb.append('{')
                .append("\"id\":")
                .append(message.getId())

                .append(",\"senderId\":")
                .append(message.getSenderId())

                .append(",\"senderRole\":\"")
                .append(escape(message.getSenderRole()))
                .append("\"")

                .append(",\"senderName\":\"")
                .append(escape(message.getSenderName()))
                .append("\"")

                .append(",\"content\":\"")
                .append(escape(message.getContent()))
                .append("\"")

                /*
                 * Chuyển Timestamp thành milliseconds.
                 *
                 * Frontend dùng giá trị này để cập nhật
                 * "since" cho lần polling tiếp theo.
                 */
                .append(",\"createdAt\":\"")
                .append(
                        message.getCreatedAt() == null
                                ? 0L
                                : message.getCreatedAt().getTime()
                )
                .append("\"")

                .append('}');
    }

    /**
     * Gửi JSON response về frontend.
     *
     * Thiết lập:
     * - Content-Type = application/json
     * - Encoding = UTF-8
     */
    private void writeJson(
            HttpServletResponse response,
            String payload) throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter writer = response.getWriter()) {
            writer.write(payload);
        }
    }

    /**
     * Lấy UserModel của user hiện tại từ session.
     *
     * Dùng để xác định:
     * - user đã đăng nhập chưa
     * - user là ai
     * - role của user
     */
    private UserModel currentUser(HttpSession session) {

        if (session == null) {
            return null;
        }

        Object attribute =
                session.getAttribute("currentUser");

        return attribute instanceof UserModel
                ? (UserModel) attribute
                : null;
    }

    /**
     * Chuẩn hóa role về chữ in hoa.
     *
     * Ví dụ:
     * "manager"  → "MANAGER"
     * " Manager " → "MANAGER"
     */
    private String normalizeRole(String role) {

        return role == null
                ? ""
                : role.trim().toUpperCase(Locale.ROOT);
    }

    /**
     * Chuyển String thành int.
     *
     * Dùng để đọc complaintId từ request.
     *
     * Nếu dữ liệu không hợp lệ → trả fallback.
     */
    private int parseInt(
            String input,
            int fallback) {

        try {
            return Integer.parseInt(input);

        } catch (NumberFormatException exception) {

            return fallback;
        }
    }

    /**
     * Chuyển String thành long.
     *
     * Dùng để đọc giá trị "since"
     * từ request của frontend.
     */
    private long parseLong(
            String input,
            long fallback) {

        try {
            return Long.parseLong(input);

        } catch (NumberFormatException exception) {

            return fallback;
        }
    }

    /**
     * Escape dữ liệu trước khi đưa vào JSON.
     *
     * Xử lý các ký tự đặc biệt như:
     * - "
     * - \
     * - xuống dòng
     * - tab
     * - <
     * - >
     *
     * Giúp JSON không bị lỗi khi content chứa
     * ký tự đặc biệt.
     */
    private String escape(String input) {

        if (input == null) {
            return "";
        }

        StringBuilder sb =
                new StringBuilder(input.length() + 16);

        for (int i = 0; i < input.length(); i++) {

            char c = input.charAt(i);

            switch (c) {

                case '"':
                    sb.append("\\\"");
                    break;

                case '\\':
                    sb.append("\\\\");
                    break;

                case '\n':
                    sb.append("\\n");
                    break;

                case '\r':
                    sb.append("\\r");
                    break;

                case '\t':
                    sb.append("\\t");
                    break;

                case '<':
                    sb.append("\\u003c");
                    break;

                case '>':
                    sb.append("\\u003e");
                    break;

                default:

                    if (c < 0x20) {
                        sb.append(
                                String.format(
                                        "\\u%04x",
                                        (int) c
                                )
                        );
                    } else {
                        sb.append(c);
                    }
            }
        }

        return sb.toString();
    }
}