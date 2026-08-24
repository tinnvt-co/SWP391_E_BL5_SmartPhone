<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Password | SmartPhone store</title>
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
                        <span class="auth-hero-eyebrow"><i class="bi bi-key"></i> Set a new password</span>
                        <h1>Almost done — choose a fresh password.</h1>
                        <p>Use uppercase, lowercase, number, and special characters to keep your account safe.</p>
                        <ul class="auth-hero-features">
                            <li><i class="bi bi-check-circle-fill"></i> Encrypted in transit</li>
                            <li><i class="bi bi-check-circle-fill"></i> Old token becomes invalid</li>
                            <li><i class="bi bi-check-circle-fill"></i> You can sign in right after</li>
                        </ul>
                    </section>

                    <section class="auth-panel">
                        <div class="auth-panel-top">
                            <a class="auth-back-link" href="${pageContext.request.contextPath}/login">
                                <i class="bi bi-arrow-left"></i> Back to login
                            </a>
                        </div>

                        <h1>Reset your password</h1>
                        <p class="lead">Create a new password, then login again with your account.</p>

                        <c:choose>
                            <c:when test="${invalidToken}">
                                <div class="auth-alert danger">
                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                    <span>Reset link is invalid or expired.</span>
                                </div>
                                <a class="btn auth-submit w-100" href="${pageContext.request.contextPath}/forgot-password">
                                    Request another link
                                </a>
                            </c:when>
                            <c:otherwise>
                                <c:if test="${not empty error}">
                                    <div class="auth-alert danger">
                                        <i class="bi bi-exclamation-triangle-fill"></i>
                                        <span>${error}</span>
                                    </div>
                                </c:if>

                                <form class="auth-form" method="post" action="${pageContext.request.contextPath}/reset-password" autocomplete="off">
                                    <input type="hidden" name="token" value="${token}">

                                    <div class="mb-3">
                                        <label class="form-label" for="newPassword">New password</label>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                            <input id="newPassword" name="newPassword" type="password" class="form-control"
                                                   minlength="6" maxlength="20"
                                                   pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9\s])\S{6,20}"
                                                   title="Use 6-20 characters with at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character."
                                                   required autofocus>
                                            <button class="input-group-text btn-toggle" type="button" data-toggle-password="newPassword" title="Show password">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label" for="confirmPassword">Confirm new password</label>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="bi bi-shield-check"></i></span>
                                            <input id="confirmPassword" name="confirmPassword" type="password" class="form-control"
                                                   minlength="6" maxlength="20"
                                                   pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9\s])\S{6,20}"
                                                   title="Use 6-20 characters with at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character."
                                                   required>
                                            <button class="input-group-text btn-toggle" type="button" data-toggle-password="confirmPassword" title="Show password">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <button class="btn auth-submit w-100" type="submit">
                                        <i class="bi bi-check-circle me-1"></i> Save new password
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </section>
                </div>
            </div>
        </main>

        <script>
            document.querySelectorAll('[data-toggle-password]').forEach(button => {
                button.addEventListener('click', function () {
                    const input = document.getElementById(this.dataset.togglePassword);
                    if (!input)
                        return;
                    const show = input.type === 'password';
                    input.type = show ? 'text' : 'password';
                    this.innerHTML = show ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
                    this.title = show ? 'Hide password' : 'Show password';
                });
            });
        </script>
    </body>
</html>

