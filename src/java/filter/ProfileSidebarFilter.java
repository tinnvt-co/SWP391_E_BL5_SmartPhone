package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.UserModel;

/**
 * Populates the "profile" request attribute that
 * /views/common/profile-sidebar.jsp relies on, so any
 * controller forwarding to a page that includes the
 * sidebar automatically gets it — without each controller
 * having to remember to set it manually.
 *
 * Individual controllers (e.g. ProfileController) may still
 * overwrite "profile" afterwards with fresher/edited data —
 * this filter only provides a safe default.
 */
@WebFilter("/*")
public class ProfileSidebarFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);

        if (session != null) {
            UserModel currentUser = (UserModel) session.getAttribute("currentUser");
            if (currentUser != null) {
                request.setAttribute("profile", currentUser);
            }
        }

        chain.doFilter(request, response);
    }
}