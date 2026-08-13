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
        .input-group-text { background:#f5f7fa; color:var(--muted); cursor:pointer; }
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

            <h1>Reset Password</h1>
            <p>Create a new password, then login again with your account.</p>

            <c:choose>
                <c:when test="${invalidToken}">
                    <div class="alert alert-danger d-flex align-items-center gap-2 py-2">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <span>Reset link is invalid or expired.</span>
                    </div>
                    <a class="btn primary-action w-100" href="${pageContext.request.contextPath}/forgot-password">
                        Request another link
                    </a>
                </c:when>
                <c:otherwise>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger d-flex align-items-center gap-2 py-2">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                            <span>${error}</span>
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/reset-password" autocomplete="off">
                        <input type="hidden" name="token" value="${token}">

                        <div class="mb-3">
                            <label class="form-label" for="newPassword">New password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input id="newPassword" name="newPassword" type="password" class="form-control"
                                       minlength="6" maxlength="20" required autofocus>
                                <button class="input-group-text" type="button" data-toggle-password="newPassword" title="Show password">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label" for="confirmPassword">Confirm new password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-shield-check"></i></span>
                                <input id="confirmPassword" name="confirmPassword" type="password" class="form-control"
                                       minlength="6" maxlength="20" required>
                                <button class="input-group-text" type="button" data-toggle-password="confirmPassword" title="Show password">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <button class="btn primary-action w-100" type="submit">
                            <i class="bi bi-check-circle me-1"></i> Save new password
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<script>
    document.querySelectorAll('[data-toggle-password]').forEach(button => {
        button.addEventListener('click', function () {
            const input = document.getElementById(this.dataset.togglePassword);
            if (!input) return;
            const show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            this.innerHTML = show ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
            this.title = show ? 'Hide password' : 'Show password';
        });
    });
</script>
</body>
</html>

