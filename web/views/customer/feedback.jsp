<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Review | SmartPhone store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <style>
        body { background:#f6f8fb; color:#111827; }
        .feedback-shell { padding:42px 0 70px; }
        .feedback-panel { max-width:640px; margin:0 auto; background:#fff; border:1px solid rgba(15,23,42,.08); border-radius:8px; padding:32px; box-shadow:0 18px 45px rgba(15,23,42,.08); }
    </style>
</head>
<body>
<c:set var="activePage" value="orders" scope="request"/>
<%@ include file="/views/common/header.jsp" %>
<main class="feedback-shell">
    <div class="container">
        <div class="feedback-panel">
            <h2 style="font-weight:900; margin-bottom:8px;"><i class="bi bi-star"></i> Write a Review</h2>
            <p style="color:#64748b;">Review feature is coming soon. Thank you for your purchase!</p>
            <c:if test="${not empty param.orderId}">
                <p style="color:#64748b;">For order <strong>#${param.orderId}</strong>.</p>
            </c:if>
            <a href="${pageContext.request.contextPath}/order-history" class="btn btn-outline-secondary mt-3">
                <i class="bi bi-arrow-left"></i> Back to order history
            </a>
        </div>
    </div>
</main>
<%@ include file="/views/common/footer.jsp" %>
</body>
</html>
