package filter;

import DAO.StoreInformationDAO;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;
import model.StoreInformationModel;

@WebFilter("/*")
public class StoreInformationFilter implements Filter {

    private StoreInformationDAO storeDAO;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        storeDAO = new StoreInformationDAO();
    }

    @Override
    public void doFilter(ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        StoreInformationModel store
                = storeDAO.getStoreInformation();
        System.out.println("STORE = " + store);
        request.setAttribute("store", store);

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        storeDAO = null;
    }
}
