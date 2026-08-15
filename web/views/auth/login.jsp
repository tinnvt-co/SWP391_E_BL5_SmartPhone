<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login | SmartPhone store</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
    </head>
    <body class="auth-page">
        <main class="auth-shell">
            <div class="container">
                <div class="auth-split">
                    <section class="auth-hero">
                        <a class="auth-brand" href="${pageContext.request.contextPath}/home">
                            <span class="auth-brand-mark">S</span>
                            <span>SmartPhone store</span>
                        </a>
                        <span class="auth-hero-eyebrow"><i class="bi bi-lightning-charge-fill"></i> Welcome back</span>
                        <h1>Sign in to continue your shopping journey.</h1>
                        <p>Track orders, manage your wishlist, write reviews and access exclusive deals — all in one place.</p>
                        <ul class="auth-hero-features">
                            <li><i class="bi bi-check-circle-fill"></i> Fast & secure checkout</li>
                            <li><i class="bi bi-check-circle-fill"></i> Wishlist and order history</li>
                            <li><i class="bi bi-check-circle-fill"></i> Exclusive member discounts</li>
                        </ul>
                    </section>

                    <section class="auth-panel">
                        <div class="auth-panel-top">
                            <a class="auth-back-link" href="${pageContext.request.contextPath}/home">
                                <i class="bi bi-arrow-left"></i> Back to store
                            </a>
                        </div>

                        <h1>Login to your account</h1>
                        <p class="lead">Continue shopping, manage orders, or work with store operations.</p>

                        <c:if test="${not empty error}">
                            <div class="auth-alert danger">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span>${error}</span>
                            </div>
                        </c:if>

                        <c:if test="${param.logout == 'success'}">
                            <div class="auth-alert success">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>You have signed out successfully.</span>
                            </div>
                        </c:if>

                        <c:if test="${param.reset == 'success'}">
                            <div class="auth-alert success">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>Your password has been reset. Please login again.</span>
                            </div>
                        </c:if>

                        <form class="auth-form" method="post" action="${pageContext.request.contextPath}/login" autocomplete="on">
                            <input type="hidden" name="redirect" value="<c:out value='${redirect}'/>"/>
                            <input type="hidden" name="requiredRole" value="<c:out value='${requiredRole}'/>"/>
                            <c:if test="${requiredRole == 'manager'}">
                                <div class="auth-info">
                                    Please sign in with a Manager account to access the management workspace.
                                </div>
                            </c:if>
                            <div class="mb-3">
                                <label class="form-label" for="username">Username</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                                    <input id="username" name="username" type="text" class="form-control"
                                           value="${username}" placeholder="Enter username" maxlength="255" required autofocus>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label" for="password">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                    <input id="password" name="password" type="password" class="form-control"
                                           placeholder="Enter password" maxlength="20" required>
                                    <button class="input-group-text btn-toggle" type="button" id="togglePassword" title="Show password">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <div class="d-flex align-items-center justify-content-between gap-3 mb-4">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="remember" id="remember"
                                           ${rememberChecked ? 'checked' : ''}>
                                    <label class="form-check-label" for="remember">Remember me</label>
                                </div>
                                <a class="auth-link" href="${pageContext.request.contextPath}/forgot-password">
                                    Forgot password?
                                </a>
                            </div>

                            <button class="btn auth-submit w-100" type="submit">
                                <i class="bi bi-box-arrow-in-right me-1"></i> Login
                            </button>
                        </form>

                        <div class="auth-divider">or</div>

                        <a class="auth-google w-100"
                           href="${pageContext.request.contextPath}/login-google">
                            <i class="bi bi-google"></i>
                            Continue with Google
                        </a>

                        <div class="auth-bottom-text">
                            New customer?
                            <a class="auth-link" href="${pageContext.request.contextPath}/register">Create an account</a>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <script>
            document.getElementById('togglePassword').addEventListener('click', function () {
                const input = document.getElementById('password');
                const icon = this.querySelector('i');
                const show = input.type === 'password';
                input.type = show ? 'text' : 'password';
                icon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
                this.title = show ? 'Hide password' : 'Show password';
            });
        </script>
    </body>
</html>

