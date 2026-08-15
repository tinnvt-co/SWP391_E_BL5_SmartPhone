<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Forgot Password | SmartPhone store</title>
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
                        <span class="auth-hero-eyebrow"><i class="bi bi-shield-lock"></i> Password recovery</span>
                        <h1>Forgot your password? We’ll help you get back in.</h1>
                        <p>Enter the email tied to your account. We’ll send instructions to safely create a new password.</p>
                        <ul class="auth-hero-features">
                            <li><i class="bi bi-check-circle-fill"></i> Secure, single-use reset link</li>
                            <li><i class="bi bi-check-circle-fill"></i> No password is stored in plain text</li>
                            <li><i class="bi bi-check-circle-fill"></i> Friendly support if you get stuck</li>
                        </ul>
                    </section>

                    <section class="auth-panel">
                        <div class="auth-panel-top">
                            <a class="auth-back-link" href="${pageContext.request.contextPath}/login">
                                <i class="bi bi-arrow-left"></i> Back to login
                            </a>
                        </div>

                        <h1>Forgot password</h1>
                        <p class="lead">Enter your account email. We will send a reset link if the email exists.</p>

                        <c:if test="${not empty error}">
                            <div class="auth-alert danger">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span>${error}</span>
                            </div>
                        </c:if>
                        <c:if test="${not empty success}">
                            <div class="auth-alert success">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>${success}</span>
                            </div>
                        </c:if>

                        <form class="auth-form" method="post" action="${pageContext.request.contextPath}/forgot-password" autocomplete="on">
                            <div class="mb-4">
                                <label class="form-label" for="email">Email</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                    <input id="email" name="email" type="email" class="form-control"
                                           value="${email}" placeholder="you@example.com" maxlength="255" required autofocus>
                                </div>
                            </div>

                            <button class="btn auth-submit w-100" type="submit">
                                <i class="bi bi-send me-1"></i> Send reset link
                            </button>
                        </form>
                    </section>
                </div>
            </div>
        </main>
    </body>
</html>

