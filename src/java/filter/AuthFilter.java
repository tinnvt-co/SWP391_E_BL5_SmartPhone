package filter;

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
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

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
            "/brands",
            "/brand"
    );

    private static final List<AccessRule> ACCESS_RULES = List.of(
            rule("/admin/users", roles("ADMIN")),
            rule("/admin/roles", roles("ADMIN")),
            rule("/manager/products", roles("MANAGER")),
            rule("/manager/categories", roles("MANAGER")),
            rule("/manager/brands", roles("MANAGER")),
            rule("/manager/inventory", roles("MANAGER")),
            rule("/manager/discounts", roles("MANAGER")),
            rule("/manager/sales", roles("MANAGER")),
            rule("/manager/sales-stats", roles("MANAGER")),
            rule("/manager/revenue", roles("MANAGER")),
            rule("/manager/order-statistics", roles("MANAGER")),
            rule("/manager/statistics", roles("MANAGER")),
            rule("/manager/suppliers", roles("MANAGER")),
            rule("/manager/refunds", roles("MANAGER")),
            rule("/manager/feedback", roles("MANAGER")),
            rule("/manager/orders", roles("MANAGER", "STAFF")),
            rule("/staff/orders", roles("STAFF", "MANAGER")),
            rule("/orders/manage", roles("STAFF", "MANAGER")),
            rule("/shipper/orders", roles("SHIPPER")),
            rule("/shipper/deliveries", roles("SHIPPER")),
            rule("/wishlist", roles("CUSTOMER")),
            rule("/feedback", roles("CUSTOMER", "MANAGER")),
            rule("/checkout", roles("CUSTOMER")),
            rule("/order-history", roles("CUSTOMER")),
            rule("/customer/orders", roles("CUSTOMER")),
            rule("/customer/delivery-status", roles("CUSTOMER")),
            rule("/delivery-status", roles("CUSTOMER")),
            rule("/profile", roles("ADMIN", "MANAGER", "STAFF", "CUSTOMER", "SHIPPER")),
            rule("/my-profile", roles("ADMIN", "MANAGER", "STAFF", "CUSTOMER", "SHIPPER")),
            rule("/change-password", roles("ADMIN", "MANAGER", "STAFF", "CUSTOMER", "SHIPPER")),
            rule("/admin", roles("ADMIN")),
            rule("/manager", roles("MANAGER")),
            rule("/staff", roles("STAFF", "MANAGER")),
            rule("/shipper", roles("SHIPPER")),
            rule("/customer", roles("CUSTOMER"))
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

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
            response.sendRedirect(contextPath + "/login?redirect=" + response.encodeURL(path));
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
    public void destroy() {}

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

        String role = normalizeRole(session.getAttribute("currentRole"));
        return rule.roles.contains(role);
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
    }

    private void applyNoCacheHeaders(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }

    private static AccessRule rule(String pathPrefix, List<String> roles) {
        return new AccessRule(pathPrefix, roles);
    }

    private static List<String> roles(String... roles) {
        List<String> normalized = new ArrayList<>();
        for (String role : roles) {
            normalized.add(role.toUpperCase(Locale.ROOT));
        }
        return normalized;
    }

    private static final class AccessRule {
        private final String pathPrefix;
        private final List<String> roles;

        private AccessRule(String pathPrefix, List<String> roles) {
            this.pathPrefix = pathPrefix;
            this.roles = roles;
        }
    }
}
