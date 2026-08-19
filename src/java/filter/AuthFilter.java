package filter;

import DAO.CartDAO;
import DAO.WishlistDAO;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import model.UserModel;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    private final CartDAO cartDAO = new CartDAO();
    private final WishlistDAO wishlistDAO = new WishlistDAO();

    private static final List<String> PUBLIC_PATHS = List.of(
            "",
            "/",
            "/index.html",
            "/index.jsp",
            "/home",
            "/products",
            "/ProductController",
            "/login",
            "/register",
            "/logout",
            "/forgot-password",
            "/reset-password",
            "/login-google",
            "/google-login",
            "/oauth2callback",
            "/vnpay-return",
            "/vnpay-ipn",
            "/brands",
            "/brand"
    );

    private static final List<AccessRule> ACCESS_RULES = List.of(
            rule("/admin/users", perms("USER_VIEW_LIST", "USER_TOGGLE_STATUS")),
            rule("/admin/roles", perms("ROLE_VIEW_LIST", "ROLE_VIEW_PERMISSIONS", "ROLE_UPDATE", "ROLE_TOGGLE_STATUS", "ROLE_EDIT_PERMISSIONS")),
            rule("/manager/products", perms("PRODUCT_MANAGE")),
            rule("/manager/categories", perms("CATEGORY_MANAGE")),
            rule("/manager/brands", perms("BRAND_MANAGE")),
            rule("/manager/supplier", perms("SUPPLIER_MANAGE")),
            rule("/manager/inventory", perms("INVENTORY_MANAGE")),
            rule("/manager/discounts", perms("DISCOUNT_MANAGE")),
            rule("/manager/sales", perms("SALES_STATS_VIEW")),
            rule("/manager/sales-stats", perms("SALES_STATS_VIEW")),
            rule("/manager/revenue", perms("REVENUE_VIEW")),
            rule("/manager/order-statistics", perms("ORDER_STATS_VIEW")),
            rule("/manager/statistics", perms("SALES_STATS_VIEW", "REVENUE_VIEW", "ORDER_STATS_VIEW")),
            rule("/manager/suppliers", perms("SUPPLIER_MANAGE")),
            rule("/manager/refunds", perms("REFUND_MANAGE")),
            rule("/manager/feedback", perms("FEEDBACK_VIEW", "FEEDBACK_REPLY")),
            rule("/manager/orders", perms("ORDER_VIEW", "ORDER_UPDATE_STATUS")),
            rule("/staff/orders", perms("ORDER_VIEW", "ORDER_UPDATE_STATUS")),
            rule("/orders/manage", perms("ORDER_VIEW", "ORDER_UPDATE_STATUS")),
            rule("/shipper/orders", perms("DELIVERY_ORDER_VIEW", "DELIVERY_STATUS_UPDATE")),
            rule("/shipper/deliveries", perms("DELIVERY_ORDER_VIEW")),
            rule("/wishlist", perms("WISHLIST_MANAGE")),
            rule("/cart", perms("CHECKOUT")),
            rule("/feedback", perms("FEEDBACK_SEND", "FEEDBACK_VIEW", "FEEDBACK_REPLY")),
            rule("/checkout", perms("CHECKOUT")),
            rule("/order-history", perms("ORDER_HISTORY_VIEW")),
            rule("/customer/orders", perms("ORDER_HISTORY_VIEW")),
            rule("/customer/order-detail", perms("ORDER_HISTORY_VIEW")),
            rule("/order-detail", perms("ORDER_HISTORY_VIEW")),
            rule("/customer/delivery-status", perms("DELIVERY_STATUS_VIEW")),
            rule("/delivery-status", perms("DELIVERY_STATUS_VIEW")),
            rule("/profile", perms()),
            rule("/my-profile", perms()),
            rule("/change-password", perms()),
            rule("/admin", perms("USER_VIEW_LIST", "ROLE_VIEW_LIST")),
            rule("/manager", perms("PRODUCT_MANAGE", "CATEGORY_MANAGE", "BRAND_MANAGE", "INVENTORY_MANAGE", "DISCOUNT_MANAGE", "SALES_STATS_VIEW", "REVENUE_VIEW", "ORDER_STATS_VIEW", "SUPPLIER_MANAGE", "REFUND_MANAGE", "FEEDBACK_VIEW")),
            rule("/staff", perms("ORDER_VIEW")),
            rule("/shipper", perms("DELIVERY_ORDER_VIEW")),
            rule("/customer", perms("ORDER_HISTORY_VIEW", "WISHLIST_MANAGE", "CHECKOUT"))
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        applyNoCacheHeaders(response);

        String contextPath = request.getContextPath();
        String path = request.getRequestURI().substring(contextPath.length());
        if (isPublic(path)) {
            exposeSession(request);
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            String target = path;
            if (request.getQueryString() != null) {
                target += "?" + request.getQueryString();
            }
            String redirect = URLEncoder.encode(target, StandardCharsets.UTF_8);
            String managerRequired = matches(path, "/manager")
                    ? "&requiredRole=manager" : "";
            response.sendRedirect(contextPath + "/login?redirect="
                    + redirect + managerRequired);
            return;
        }

        exposeSession(request);
        if (!isAllowed(path, session)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.getRequestDispatcher("/views/error/403.jsp").forward(request, response);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }

    private boolean isPublic(String path) {
        if (path == null) {
            return true;
        }
        if (PUBLIC_PATHS.contains(path)) {
            return true;
        }
        return path.startsWith("/assets/")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/")
                || path.startsWith("/favicon");
    }

    private boolean isAllowed(String path, HttpSession session) {
        AccessRule rule = findRule(path);
        if (rule == null) {
            return true;
        }

        if (rule.permissions.isEmpty()) {
            return true;
        }

        List<String> userPerms = (List<String>) session.getAttribute("permissions");
        if (userPerms == null || userPerms.isEmpty()) {
            return false;
        }

        for (String requiredPerm : rule.permissions) {
            if (userPerms.contains(requiredPerm)) {
                return true;
            }
        }
        return false;
    }

    private AccessRule findRule(String path) {
        AccessRule bestMatch = null;
        for (AccessRule rule : ACCESS_RULES) {
            if (matches(path, rule.pathPrefix)
                    && (bestMatch == null || rule.pathPrefix.length() > bestMatch.pathPrefix.length())) {
                bestMatch = rule;
            }
        }
        return bestMatch;
    }

    private boolean matches(String path, String prefix) {
        return path.equals(prefix) || path.startsWith(prefix + "/");
    }

    private String normalizeRole(Object value) {
        return value == null ? "" : value.toString().trim().toUpperCase(Locale.ROOT);
    }

    private void exposeSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object currentUser = session.getAttribute("currentUser");
        Object currentRole = session.getAttribute("currentRole");
        Object permissions = session.getAttribute("permissions");
        if (currentUser != null) {
            request.setAttribute("currentUser", currentUser);
        }
        if (currentRole != null) {
            request.setAttribute("currentRole", currentRole);
        }
        if (permissions != null) {
            request.setAttribute("permissions", permissions);
        }
        if (currentUser instanceof UserModel
                && "CUSTOMER".equals(normalizeRole(currentRole))) {
            UserModel user = (UserModel) currentUser;
            try {
                request.setAttribute("cartCount", cartDAO.countItems(user.getId()));
                request.setAttribute("wishlistCount", wishlistDAO.countItems(user.getId()));
            } catch (Exception ex) {
                request.setAttribute("cartCount", 0);
                request.setAttribute("wishlistCount", 0);
            }
        }
    }

    private void applyNoCacheHeaders(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }

    private static AccessRule rule(String pathPrefix, List<String> permissions) {
        return new AccessRule(pathPrefix, permissions);
    }

    private static List<String> perms(String... permissions) {
        List<String> normalized = new ArrayList<>();
        for (String perm : permissions) {
            normalized.add(perm.toUpperCase(Locale.ROOT));
        }
        return normalized;
    }

    private static final class AccessRule {

        private final String pathPrefix;
        private final List<String> permissions;

        private AccessRule(String pathPrefix, List<String> permissions) {
            this.pathPrefix = pathPrefix;
            this.permissions = permissions;
        }
    }
}
