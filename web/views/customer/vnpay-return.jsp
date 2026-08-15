<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>VNPay Result | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body {
                background:#f6f8fb;
                color:#111827;
            }
            .result-shell {
                padding:54px 0 80px;
            }
            .result-card {
                max-width:760px;
                margin:0 auto;
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                padding:32px;
            }
            .result-icon {
                width:64px;
                height:64px;
                border-radius:50%;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                font-size:32px;
                margin-bottom:18px;
            }
            .result-icon.success {
                background:#dcfce7;
                color:#16a34a;
            }
            .result-icon.error {
                background:#fee2e2;
                color:#dc2626;
            }
            .result-row {
                display:flex;
                justify-content:space-between;
                gap:20px;
                padding:12px 0;
                border-bottom:1px solid #eef2f7;
            }
            .result-row span {
                color:#64748b;
            }
            .result-row strong {
                text-align:right;
            }
            .primary-action,.secondary-action {
                min-height:44px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                padding:0 18px;
                border-radius:8px;
                font-weight:800;
                text-decoration:none;
            }
            .primary-action {
                border:1px solid #16a34a;
                background:#16a34a;
                color:#fff;
            }
            .primary-action:hover {
                background:#15803d;
                border-color:#15803d;
                color:#fff;
            }
            .secondary-action {
                border:1px solid #dbe3ec;
                background:#fff;
                color:#111827;
            }
            .secondary-action:hover {
                color:#1665d8;
                border-color:#b9c9ef;
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="cart" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="result-shell">
            <section class="result-card">
                <c:choose>
                    <c:when test="${paymentSuccess}">
                        <div class="result-icon success"><i class="bi bi-check2"></i></div>
                        <h1 class="h3 fw-black">Thanh toán VNPay thành công</h1>
                        <p class="text-muted">Giao dịch sandbox đã được xác thực bằng checksum.</p>
                    </c:when>
                    <c:otherwise>
                        <div class="result-icon error"><i class="bi bi-x-lg"></i></div>
                        <h1 class="h3 fw-black">Thanh toán VNPay chưa thành công</h1>
                        <p class="text-muted">Giao dịch bị hủy, thất bại hoặc chữ ký trả về không hợp lệ.</p>
                    </c:otherwise>
                </c:choose>

                <div class="mt-4">
                    <div class="result-row"><span>Mã đơn tạm</span><strong>${txnRef}</strong></div>
                    <div class="result-row"><span>Mã giao dịch VNPay</span><strong>${transactionNo}</strong></div>
                    <div class="result-row"><span>Số tiền</span><strong><fmt:formatNumber value="${amount}" pattern="#,##0"/> &#273;</strong></div>
                    <div class="result-row"><span>Response Code</span><strong>${responseCode}</strong></div>
                    <div class="result-row"><span>Transaction Status</span><strong>${transactionStatus}</strong></div>
                    <div class="result-row"><span>Checksum</span><strong>${validSignature ? 'Valid' : 'Invalid'}</strong></div>
                </div>

                <div class="d-flex gap-2 flex-wrap mt-4">
                    <a class="primary-action" href="${pageContext.request.contextPath}/products"><i class="bi bi-grid"></i> Continue shopping</a>
                    <a class="secondary-action" href="${pageContext.request.contextPath}/cart"><i class="bi bi-cart3"></i> Back to cart</a>
                </div>
            </section>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
