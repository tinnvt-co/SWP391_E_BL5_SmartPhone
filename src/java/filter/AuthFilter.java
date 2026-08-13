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
import java.util.List;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    private static final List<String> PUBLIC_PATHS = List.of(
            "",
            "/",
            "/index.html",
            "/home",
            "/login",
            "/register",
            "/logout"
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
            response.sendRedirect(contextPath + "/login");
            return;
        }

        exposeSession(request);
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

}
