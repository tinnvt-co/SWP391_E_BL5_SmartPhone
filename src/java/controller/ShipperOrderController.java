package controller;

import DAO.OrderDAO;
import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import model.OrderModel;
import model.UserModel;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 5 * 5
)
public class ShipperOrderController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            List<OrderModel> assignedOrders = orderDAO.findShippingOrdersByShipper(currentUser.getId());
            List<OrderModel> availableOrders = orderDAO.findAvailableShippingOrders();

            int page = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            
            int pageSize = 10;
            int totalDelivered = orderDAO.countDeliveredOrdersByShipper(currentUser.getId());
            int totalPages = (int) Math.ceil((double) totalDelivered / pageSize);
            
            if (page > totalPages && totalPages > 0) {
                page = totalPages;
            }
            
            int offset = (page - 1) * pageSize;

            List<OrderModel> deliveredOrders = orderDAO.findDeliveredOrdersByShipper(currentUser.getId(), offset, pageSize);
            hydrateItems(assignedOrders);
            hydrateItems(availableOrders);
            hydrateItems(deliveredOrders);

            request.setAttribute("orders", assignedOrders);
            request.setAttribute("availableOrders", availableOrders);
            request.setAttribute("deliveredOrders", deliveredOrders);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            request.getRequestDispatcher("/views/shipper/delivery-order-list.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void hydrateItems(List<OrderModel> orders) throws SQLException {
        for (OrderModel order : orders) {
            order.setItems(orderDAO.findOrderItems(order.getId()));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("claim".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
                if (currentUser != null) {
                    boolean ok = orderDAO.assignShipper(orderId, currentUser.getId(), currentUser.getId());
                    if (ok) {
                        request.getSession().setAttribute("message", "Order #" + orderId + " claimed successfully.");
                    } else {
                        request.getSession().setAttribute("error", "Failed to claim order. It might have been claimed by someone else.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error claiming order: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            }
        } else if ("updateStatus".equals(action)) {
            // Used for CANCELLED
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String status = request.getParameter("status");

                UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
                Integer updatedBy = (currentUser != null) ? currentUser.getId() : null;

                orderDAO.updateStatus(orderId, status, updatedBy);

                request.getSession().setAttribute("message", "Order #" + orderId + " marked as " + status + ".");
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error updating order status: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            }
        } else if ("deliver".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String note = request.getParameter("note");
                
                String proofImage = saveImageIfAny(request);

                UserModel currentUser = (UserModel) request.getSession().getAttribute("currentUser");
                Integer updatedBy = (currentUser != null) ? currentUser.getId() : null;

                orderDAO.updateStatusWithProofAndNote(orderId, "DELIVERED", updatedBy, note, proofImage);

                request.getSession().setAttribute("message", "Order #" + orderId + " marked as delivered.");
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            } catch (Exception ex) {
                request.getSession().setAttribute("error", "Error completing delivery: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipper/orders");
            }
        }
    }
    
    private String saveImageIfAny(HttpServletRequest request) throws IOException, ServletException {
        Part part;
        try {
            part = request.getPart("proofImage");
        } catch (IllegalStateException ex) {
            throw new ServletException("Upload is too large.");
        }
        if (part == null || part.getSize() == 0) {
            throw new ServletException("Proof of delivery image is required.");
        }

        byte[] data;
        try (InputStream in = part.getInputStream()) {
            data = in.readAllBytes();
        }

        String actualFormat;
        try (InputStream in = new ByteArrayInputStream(data); ImageInputStream iis = ImageIO.createImageInputStream(in)) {
            Iterator<ImageReader> readers = ImageIO.getImageReaders(iis);
            if (!readers.hasNext()) {
                throw new ServletException("Only image uploads are allowed.");
            }
            actualFormat = readers.next().getFormatName().toLowerCase();
        }

        String webRoot = request.getServletContext().getRealPath("/");
        if (webRoot == null) {
            throw new ServletException("Cannot resolve web root for upload.");
        }

        String extension = switch (actualFormat) {
            case "png" -> ".png";
            case "gif" -> ".gif";
            case "webp" -> ".webp";
            case "jpeg", "jpg" -> ".jpg";
            default -> throw new ServletException("Unsupported image format.");
        };

        String fileName = UUID.randomUUID().toString().replace("-", "") + extension;
        
        List<Path> directories = getUploadDirectories(webRoot);
        for (Path directory : directories) {
            Files.createDirectories(directory);
            Path target = directory.resolve(fileName);
            Files.write(target, data, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        }

        return fileName;
    }

    private List<Path> getUploadDirectories(String webRoot) {
        List<Path> directories = new ArrayList<>();
        Path runtimeDirectory = Paths.get(webRoot, "assets", "images").toAbsolutePath().normalize();
        directories.add(runtimeDirectory);

        Path imagesDirectory = runtimeDirectory.getParent();
        Path assetsDirectory = imagesDirectory == null ? null : imagesDirectory.getParent();
        Path webDirectory = assetsDirectory == null ? null : assetsDirectory.getParent();
        
        if (webDirectory != null && "web".equalsIgnoreCase(webDirectory.getFileName().toString())) {
            Path buildDirectory = webDirectory.getParent();
            if (buildDirectory != null && "build".equalsIgnoreCase(buildDirectory.getFileName().toString())) {
                Path sourceDirectory = buildDirectory.getParent().resolve("web/assets/images").toAbsolutePath().normalize();
                if (!sourceDirectory.equals(runtimeDirectory)) {
                    directories.add(sourceDirectory);
                }
            }
        }
        return directories;
    }
}
