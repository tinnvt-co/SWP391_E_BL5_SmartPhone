<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Register | SmartPhone store</title>
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
                        <span class="auth-hero-eyebrow"><i class="bi bi-stars"></i> Join the community</span>
                        <h1>Create your account and unlock the best deals.</h1>
                        <p>Save addresses for faster checkout, track every order, and earn member-only rewards.</p>
                        <ul class="auth-hero-features">
                            <li><i class="bi bi-check-circle-fill"></i> Save multiple shipping addresses</li>
                            <li><i class="bi bi-check-circle-fill"></i> Exclusive new-customer offers</li>
                            <li><i class="bi bi-check-circle-fill"></i> Personalized recommendations</li>
                        </ul>
                    </section>

                    <section class="auth-panel">
                        <div class="auth-panel-top">
                            <a class="auth-back-link" href="${pageContext.request.contextPath}/home">
                                <i class="bi bi-arrow-left"></i> Back to store
                            </a>
                            <a class="auth-link" href="${pageContext.request.contextPath}/login">
                                <i class="bi bi-box-arrow-in-right me-1"></i> Login
                            </a>
                        </div>

                        <h1>Create your account</h1>
                        <p class="lead">Register as a customer to save your cart, wishlist, orders and feedback history.</p>

                        <c:if test="${not empty error}">
                            <div class="auth-alert danger">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span>${error}</span>
                            </div>
                        </c:if>

                        <form class="auth-form" method="post" action="${pageContext.request.contextPath}/register" autocomplete="on">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label" for="name">Full name</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-person-badge"></i></span>
                                        <input id="name" name="name" type="text" class="form-control"
                                               value="${form.name}" placeholder="Your full name" maxlength="255" required autofocus>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="username">Username</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-person"></i></span>
                                        <input id="username" name="username" type="text" class="form-control"
                                               value="${form.username}" placeholder="4-50 characters" maxlength="50" required>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="email">Email</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                        <input id="email" name="email" type="email" class="form-control"
                                               value="${form.email}" placeholder="you@example.com" maxlength="255" required>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="phone">Phone</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                                        <input id="phone" name="phone" type="tel" class="form-control"
                                               value="${form.phone}" placeholder="9-15 digits" maxlength="15" required>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="password">Password</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                        <input id="password" name="password" type="password" class="form-control"
                                               placeholder="6-20 characters" maxlength="20" required>
                                        <button class="input-group-text btn-toggle" type="button" data-toggle-password="password" title="Show password">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="confirmPassword">Confirm password</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-shield-lock"></i></span>
                                        <input id="confirmPassword" name="confirmPassword" type="password" class="form-control"
                                               placeholder="Retype password" maxlength="20" required>
                                        <button class="input-group-text btn-toggle" type="button" data-toggle-password="confirmPassword" title="Show password">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label" for="age">Age</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-calendar3"></i></span>
                                        <input id="age" name="age" type="number" class="form-control"
                                               value="${form.age}" placeholder="Optional" min="13" max="100">
                                    </div>
                                </div>

                                <div class="col-md-8">
                                    <label class="form-label" for="address">Address</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-geo-alt"></i></span>
                                        <input id="address" name="address" type="text" class="form-control"
                                               value="${form.address}" placeholder="Delivery address" maxlength="255" required>
                                    </div>
                                </div>
                            </div>

                            <div class="auth-note mt-3">
                                <i class="bi bi-info-circle me-1"></i> New accounts are created with the Customer role.
                            </div>

                            <button class="btn auth-submit w-100 mt-4" type="submit">
                                <i class="bi bi-person-plus me-1"></i> Create account
                            </button>
                        </form>
                    </section>
                </div>
            </div>
        </main>

        <script>
            document.querySelectorAll('[data-toggle-password]').forEach(button => {
                button.addEventListener('click', function () {
                    const input = document.getElementById(this.dataset.togglePassword);
                    const icon = this.querySelector('i');
                    const show = input.type === 'password';
                    input.type = show ? 'text' : 'password';
                    icon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
                    this.title = show ? 'Hide password' : 'Show password';
                });
            });
        </script>
    </body>
</html>

