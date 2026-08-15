package controller;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.Duration;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import model.UserModel;

@WebServlet(name = "GoogleLoginController", urlPatterns = {"/login-google", "/oauth2callback"})
public class GoogleLoginController extends HttpServlet {

    private static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo";
    private static final String GOOGLE_STATE_SESSION_KEY = "googleOAuthState";
    private static final Pattern JSON_STRING_PATTERN = Pattern.compile("\"%s\"\\s*:\\s*\"((?:\\\\.|[^\"])*)\"");

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        if ("/login-google".equals(path)) {
            startGoogleLogin(request, response);
            return;
        }
        handleGoogleCallback(request, response);
    }

    private void startGoogleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        GoogleConfig config = readConfig();
        if (!config.isReady()) {
            forwardLoginError(request, response, "Google login is not configured. Please set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.");
            return;
        }

        HttpSession session = request.getSession(true);
        String state = UUID.randomUUID().toString();
        session.setAttribute(GOOGLE_STATE_SESSION_KEY, state);

        String authUrl = GOOGLE_AUTH_URL
                + "?client_id=" + encode(config.clientId)
                + "&redirect_uri=" + encode(redirectUri(request))
                + "&response_type=code"
                + "&scope=" + encode("openid email profile")
                + "&state=" + encode(state)
                + "&prompt=select_account";
        response.sendRedirect(authUrl);
    }

    private void handleGoogleCallback(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String error = request.getParameter("error");
        if (error != null && !error.isBlank()) {
            forwardLoginError(request, response, "Google login was cancelled or denied.");
            return;
        }

        HttpSession session = request.getSession(false);
        String expectedState = session == null ? null : (String) session.getAttribute(GOOGLE_STATE_SESSION_KEY);
        String actualState = request.getParameter("state");
        if (expectedState == null || !expectedState.equals(actualState)) {
            forwardLoginError(request, response, "Google login session is invalid. Please try again.");
            return;
        }
        session.removeAttribute(GOOGLE_STATE_SESSION_KEY);

        String code = request.getParameter("code");
        if (code == null || code.isBlank()) {
            forwardLoginError(request, response, "Google did not return an authorization code.");
            return;
        }

        GoogleConfig config = readConfig();
        if (!config.isReady()) {
            forwardLoginError(request, response, "Google login is not configured. Please set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.");
            return;
        }

        try {
            String accessToken = exchangeCodeForAccessToken(config, request, code);
            GoogleProfile profile = fetchGoogleProfile(accessToken);
            if (profile.email == null || profile.email.isBlank()) {
                forwardLoginError(request, response, "Google account email is unavailable.");
                return;
            }

            UserModel user = userDAO.findOrCreateGoogleCustomer(profile.email, profile.name, profile.picture);
            List<String> permissions = userDAO.findPermissionNamesByRoleId(user.getRoleId());

            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("currentUser", user);
            newSession.setAttribute("currentRole", user.getRoleName());
            newSession.setAttribute("permissions", permissions);
            newSession.setMaxInactiveInterval(30 * 60);

            String destination = "/home?login=google";
            if (user.getRoleName() != null) {
                String roleStr = user.getRoleName().toUpperCase();
                if (roleStr.equals("ADMIN")) {
                    destination = "/admin/dashboard";
                } else if (roleStr.equals("MANAGER")) {
                    destination = "/manager";
                } else if (roleStr.equals("STAFF")) {
                    destination = "/staff";
                }
            }
            response.sendRedirect(request.getContextPath() + destination);
        } catch (SQLException e) {
            throw new ServletException(e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ServletException(e);
        }
    }

    private String exchangeCodeForAccessToken(GoogleConfig config, HttpServletRequest request, String code)
            throws IOException, InterruptedException, ServletException {
        String body = "code=" + encode(code)
                + "&client_id=" + encode(config.clientId)
                + "&client_secret=" + encode(config.clientSecret)
                + "&redirect_uri=" + encode(redirectUri(request))
                + "&grant_type=authorization_code";

        HttpRequest tokenRequest = HttpRequest.newBuilder()
                .uri(URI.create(GOOGLE_TOKEN_URL))
                .timeout(Duration.ofSeconds(15))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        HttpResponse<String> tokenResponse = httpClient.send(tokenRequest, HttpResponse.BodyHandlers.ofString());
        if (tokenResponse.statusCode() < 200 || tokenResponse.statusCode() >= 300) {
            throw new ServletException("Google token request failed with status " + tokenResponse.statusCode());
        }

        String accessToken = jsonString(tokenResponse.body(), "access_token");
        if (accessToken == null || accessToken.isBlank()) {
            throw new ServletException("Google token response did not include an access token.");
        }
        return accessToken;
    }

    private GoogleProfile fetchGoogleProfile(String accessToken)
            throws IOException, InterruptedException, ServletException {
        HttpRequest profileRequest = HttpRequest.newBuilder()
                .uri(URI.create(GOOGLE_USERINFO_URL))
                .timeout(Duration.ofSeconds(15))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();

        HttpResponse<String> profileResponse = httpClient.send(profileRequest, HttpResponse.BodyHandlers.ofString());
        if (profileResponse.statusCode() < 200 || profileResponse.statusCode() >= 300) {
            throw new ServletException("Google profile request failed with status " + profileResponse.statusCode());
        }

        return new GoogleProfile(
                jsonString(profileResponse.body(), "email"),
                jsonString(profileResponse.body(), "name"),
                jsonString(profileResponse.body(), "picture")
        );
    }

    private String jsonString(String json, String key) {
        Matcher matcher = Pattern.compile(String.format(JSON_STRING_PATTERN.pattern(), Pattern.quote(key))).matcher(json);
        if (!matcher.find()) {
            return null;
        }
        return unescapeJson(matcher.group(1));
    }

    private String unescapeJson(String value) {
        return value.replace("\\\"", "\"")
                .replace("\\\\", "\\")
                .replace("\\/", "/")
                .replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t");
    }

    private void forwardLoginError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    private GoogleConfig readConfig() {
        String clientId = firstNonBlank(System.getProperty("google.client.id"), System.getenv("GOOGLE_CLIENT_ID"));
        String clientSecret = firstNonBlank(System.getProperty("google.client.secret"), System.getenv("GOOGLE_CLIENT_SECRET"));
        return new GoogleConfig(clientId, clientSecret);
    }

    private String redirectUri(HttpServletRequest request) {
        return request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort()
                + request.getContextPath()
                + "/oauth2callback";
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.trim();
            }
        }
        return "";
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static final class GoogleConfig {

        private final String clientId;
        private final String clientSecret;

        private GoogleConfig(String clientId, String clientSecret) {
            this.clientId = clientId;
            this.clientSecret = clientSecret;
        }

        private boolean isReady() {
            return !clientId.isBlank() && !clientSecret.isBlank();
        }
    }

    private static final class GoogleProfile {

        private final String email;
        private final String name;
        private final String picture;

        private GoogleProfile(String email, String name, String picture) {
            this.email = email;
            this.name = name;
            this.picture = picture;
        }
    }
}
