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
    <style>
        :root { --ink:#17202a; --muted:#657486; --line:#dce3ea; --blue:#1665d8; --green:#17a673; }
        body {
            min-height: 100vh;
            margin: 0;
            color: var(--ink);
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background:
                linear-gradient(90deg, rgba(255,255,255,0.98) 0%, rgba(255,255,255,0.93) 45%, rgba(255,255,255,0.46) 100%),
                url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center right / cover no-repeat;
        }
        .auth-shell { min-height:100vh; display:flex; align-items:center; padding:2rem 0; }
        .auth-panel {
            width:min(100%,440px);
            background:rgba(255,255,255,.94);
            border:1px solid var(--line);
            border-radius:8px;
            box-shadow:0 22px 70px rgba(23,32,42,.16);
            padding:1.6rem;
            backdrop-filter:blur(14px);
        }
        .brand-mark {
            width:42px; height:42px; border-radius:8px;
            background:linear-gradient(135deg,var(--blue),var(--green));
            color:#fff; display:inline-flex; align-items:center; justify-content:center; font-weight:850;
        }
        .auth-panel h1 { font-size:1.65rem; font-weight:850; margin:1.1rem 0 .35rem; }
        .auth-panel p { color:var(--muted); margin-bottom:1.4rem; line-height:1.6; }
        .form-label { color:var(--ink); font-weight:750; font-size:.9rem; }
        .input-group-text,.form-control { min-height:46px; border-color:var(--line); }
        .input-group-text { background:#f5f7fa; color:var(--muted); }
        .form-control:focus { border-color:var(--blue); box-shadow:0 0 0 .2rem rgba(22,101,216,.12); }
        .primary-action { min-height:46px; border-radius:8px; background:var(--blue); border-color:var(--blue); color:#fff; font-weight:800; }
        .primary-action:hover { background:#0f56be; border-color:#0f56be; color:#fff; }
        .back-link { color:var(--muted); font-weight:700; text-decoration:none; }
        .back-link:hover { color:var(--blue); }
    </style>
</head>
<body>
<main class="auth-shell">
    <div class="container">
        <a class="back-link d-inline-flex align-items-center gap-2 mb-3" href="${pageContext.request.contextPath}/login">
            <i class="bi bi-arrow-left"></i> Back to login
        </a>

        <section class="auth-panel">
            <div class="d-flex align-items-center gap-2">
                <span class="brand-mark">S</span>
                <strong>SmartPhone store</strong>
            </div>

            <h1>Forgot Password</h1>
            <p>Enter your account email. We will send a reset link if the email exists.</p>

            <c:if test="${not empty error}">
                <div class="alert alert-danger d-flex align-items-center gap-2 py-2">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <span>${error}</span>
                </div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="alert alert-success d-flex align-items-center gap-2 py-2">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>${success}</span>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/forgot-password" autocomplete="on">
                <div class="mb-4">
                    <label class="form-label" for="email">Email</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                        <input id="email" name="email" type="email" class="form-control"
                               value="${email}" placeholder="you@example.com" maxlength="255" required autofocus>
                    </div>
                </div>

                <button class="btn primary-action w-100" type="submit">
                    <i class="bi bi-send me-1"></i> Send reset link
                </button>
            </form>
        </section>
    </div>
</main>
</body>
</html>

