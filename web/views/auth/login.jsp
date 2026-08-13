<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | SWP Mobile</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --ink: #17202a;
            --muted: #657486;
            --line: #dce3ea;
            --blue: #1665d8;
            --green: #17a673;
            --coral: #f05d4f;
        }

        body {
            min-height: 100vh;
            margin: 0;
            color: var(--ink);
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background:
                linear-gradient(90deg, rgba(255,255,255,0.98) 0%, rgba(255,255,255,0.93) 45%, rgba(255,255,255,0.46) 100%),
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
            width: min(100%, 440px);
            background: rgba(255, 255, 255, 0.94);
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

        .google-action {
            min-height: 46px;
            border-radius: 8px;
            border: 1px solid var(--line);
            background: #ffffff;
            color: var(--ink);
            font-weight: 800;
        }

        .google-action:hover {
            border-color: #b8c4d2;
            background: #f8fafc;
            color: var(--ink);
        }

        .auth-divider {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin: 1rem 0;
            color: var(--muted);
            font-size: 0.82rem;
            font-weight: 700;
        }

        .auth-divider::before,
        .auth-divider::after {
            content: "";
            flex: 1;
            height: 1px;
            background: var(--line);
        }

        .quick-login {
            border-top: 1px solid var(--line);
            margin-top: 1.2rem;
            padding-top: 1rem;
        }

        .quick-login code {
            color: var(--coral);
            background: rgba(240, 93, 79, 0.08);
            border-radius: 6px;
            padding: 0.15rem 0.35rem;
        }

        .back-link {
            color: var(--muted);
            font-weight: 700;
            text-decoration: none;
        }

        .back-link:hover { color: var(--blue); }

        @media (max-width: 767.98px) {
            body {
                background:
                    linear-gradient(180deg, rgba(255,255,255,0.98), rgba(255,255,255,0.88)),
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
            <div class="d-flex align-items-center gap-2">
                <span class="brand-mark">S</span>
                <strong>SWP Mobile</strong>
            </div>

            <h1>Welcome Back</h1>
            <p>Login to continue shopping, manage orders, or work with store operations.</p>

            <c:if test="${not empty error}">
                <div class="alert alert-danger d-flex align-items-center gap-2 py-2">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <span>${error}</span>
                </div>
            </c:if>

            <c:if test="${param.logout == 'success'}">
                <div class="alert alert-success d-flex align-items-center gap-2 py-2">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>You have signed out successfully.</span>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login" autocomplete="on">
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
                        <button class="input-group-text" type="button" id="togglePassword" title="Show password">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="d-flex align-items-center justify-content-between gap-3 mb-4">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="remember" id="remember"
                               ${rememberChecked ? 'checked' : ''}>
                        <label class="form-check-label text-muted" for="remember">Remember me</label>
                    </div>
                </div>

                <button class="btn primary-action w-100" type="submit">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Login
                </button>
            </form>

            <div class="auth-divider">or</div>

            <a class="btn google-action w-100 d-inline-flex align-items-center justify-content-center gap-2"
               href="${pageContext.request.contextPath}/login-google">
                <i class="bi bi-google"></i>
                Continue with Google
            </a>

            <div class="text-center small text-muted mt-3">
                New customer?
                <a class="fw-bold text-decoration-none" href="${pageContext.request.contextPath}/register">Create an account</a>
            </div>
        </section>
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
