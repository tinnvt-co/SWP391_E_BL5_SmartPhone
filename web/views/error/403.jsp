<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access denied | SWP Mobile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <style>
        body {
            background: #f7f8fb;
            color: #111827;
        }

        .error-shell {
            min-height: 54vh;
            display: grid;
            place-items: center;
            padding: 72px 20px;
        }

        .error-panel {
            width: min(620px, 100%);
            background: #ffffff;
            border: 1px solid rgba(15, 23, 42, 0.08);
            border-radius: 8px;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            padding: 36px;
            text-align: center;
        }

        .error-icon {
            width: 58px;
            height: 58px;
            margin: 0 auto 18px;
            border-radius: 50%;
            display: grid;
            place-items: center;
            color: #dc2626;
            background: #fee2e2;
            font-size: 1.6rem;
        }

        .error-code {
            margin-bottom: 8px;
            font-size: 0.78rem;
            font-weight: 800;
            letter-spacing: 0.14em;
            color: #dc2626;
            text-transform: uppercase;
        }

        .error-panel h1 {
            margin-bottom: 12px;
            font-size: clamp(1.8rem, 4vw, 2.35rem);
            font-weight: 900;
        }

        .error-panel p {
            margin: 0 auto 24px;
            max-width: 480px;
            color: #64748b;
        }
    </style>
</head>
<body>
<%@ include file="/views/common/header.jsp" %>

<main class="error-shell">
    <section class="error-panel">
        <div class="error-icon">
            <i class="bi bi-shield-lock"></i>
        </div>
        <div class="error-code">403 Forbidden</div>
        <h1>You do not have permission</h1>
        <p>Your account role is not allowed to access this function. Please contact an administrator if this looks wrong.</p>
        <a class="primary-action" href="${pageContext.request.contextPath}/home">
            <i class="bi bi-house-door"></i> Back to homepage
        </a>
    </section>
</main>

<%@ include file="/views/common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
