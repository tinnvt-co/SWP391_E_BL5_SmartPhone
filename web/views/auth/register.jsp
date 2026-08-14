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
        <style>
            :root {
                --ink: #17202a;
                --muted: #657486;
                --line: #dce3ea;
                --blue: #1665d8;
                --green: #17a673;
            }

            body {
                min-height: 100vh;
                margin: 0;
                color: var(--ink);
                font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
                background:
                    linear-gradient(90deg, rgba(255,255,255,0.98) 0%, rgba(255,255,255,0.95) 50%, rgba(255,255,255,0.52) 100%),
                    url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center right / cover no-repeat;
            }

            .auth-shell {
                min-height: 100vh;
                display: flex;
                align-items: center;
                padding: 2rem 0;
            }

            .brand-mark {
                width: 42px;
                height: 42px;
                border-radius: 8px;
                background: linear-gradient(135deg, var(--blue), var(--green));
                color: #fff;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-weight: 850;
            }

            .auth-panel {
                width: min(100%, 620px);
                background: rgba(255, 255, 255, 0.95);
                border: 1px solid var(--line);
                border-radius: 8px;
                box-shadow: 0 22px 70px rgba(23, 32, 42, 0.16);
                padding: 1.6rem;
                backdrop-filter: blur(14px);
            }

            .auth-panel h1 {
                font-size: 1.65rem;
                font-weight: 850;
                margin: 1.1rem 0 0.35rem;
            }

            .auth-panel p {
                color: var(--muted);
                margin-bottom: 1.4rem;
                line-height: 1.6;
            }

            .form-label {
                color: var(--ink);
                font-weight: 750;
                font-size: 0.9rem;
            }

            .input-group-text,
            .form-control {
                min-height: 46px;
                border-color: var(--line);
            }

            .input-group-text {
                background: #f5f7fa;
                color: var(--muted);
            }

            .form-control:focus {
                border-color: var(--blue);
                box-shadow: 0 0 0 0.2rem rgba(22, 101, 216, 0.12);
            }

            .primary-action {
                min-height: 46px;
                border-radius: 8px;
                background: var(--blue);
                border-color: var(--blue);
                color: #fff;
                font-weight: 800;
            }

            .primary-action:hover {
                background: #0f56be;
                border-color: #0f56be;
                color: #fff;
            }

            .back-link,
            .switch-link {
                color: var(--muted);
                font-weight: 700;
                text-decoration: none;
            }

            .back-link:hover,
            .switch-link:hover {
                color: var(--blue);
            }

            .form-note {
                color: var(--muted);
                font-size: 0.84rem;
            }

            @media (max-width: 767.98px) {
                body {
                    background:
                        linear-gradient(180deg, rgba(255,255,255,0.98), rgba(255,255,255,0.9)),
                        url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center bottom / cover no-repeat;
                }

                .auth-shell {
                    align-items: flex-start;
                }
            }
        </style>
    </head>
    <body>
        <main class="auth-shell">
            <div class="container">
                <a class="back-link d-inline-flex align-items-center gap-2 mb-3" href="${pageContext.request.contextPath}/home">
                    <i class="bi bi-arrow-left"></i> Back to store
                </a>

                <section class="auth-panel">
                    <div class="d-flex align-items-center justify-content-between gap-3">
                        <div class="d-flex align-items-center gap-2">
                            <span class="brand-mark">S</span>
                            <strong>SmartPhone store</strong>
                        </div>
                        <a class="switch-link" href="${pageContext.request.contextPath}/login">
                            <i class="bi bi-box-arrow-in-right me-1"></i> Login
                        </a>
                    </div>

                    <h1>Create Account</h1>
                    <p>Register as a customer to save your cart, wishlist, orders, and feedback history.</p>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger d-flex align-items-center gap-2 py-2">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                            <span>${error}</span>
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/register" autocomplete="on">
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
                                    <button class="input-group-text" type="button" data-toggle-password="password" title="Show password">
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
                                    <button class="input-group-text" type="button" data-toggle-password="confirmPassword" title="Show password">
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

                        <div class="form-note mt-3">
                            New accounts are created with the Customer role.
                        </div>

                        <button class="btn primary-action w-100 mt-4" type="submit">
                            <i class="bi bi-person-plus me-1"></i> Create account
                        </button>
                    </form>
                </section>
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

