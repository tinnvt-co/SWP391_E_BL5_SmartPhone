<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><title>Order #${order.code} | SmartPhone store</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
<style>
    body { background:#f6f8fb; color:#111827; }
    .detail-shell { padding:42px 0 70px; }
    .detail-panel { max-width:760px; margin:0 auto; background:#fff; border:1px solid rgba(15,23,42,.08); border-radius:8px; box-shadow:0 18px 45px rgba(15,23,42,.08); overflow:hidden; }
    .detail-header { padding:24px; border-bottom:1px solid #eef2f7; display:flex; justify-content:space-between; align-items:flex-start; gap:16px; flex-wrap:wrap; }
    .detail-header h1 { margin:0; font-weight:900; }
    .detail-meta { color:#64748b; font-size:.92rem; margin-top:4px; }
    .detail-pill { display:inline-block; padding:5px 12px; border-radius:999px; font-size:.72rem; font-weight:800; letter-spacing:.4px; text-transform:uppercase; }
    .detail-pill.status { background:#e0f2fe; color:#075985; }
    .detail-pill.type { background:#ede9fe; color:#5b21b6; }
    .detail-summary { padding:18px 24px; background:#f8fafc; border-bottom:1px solid #eef2f7; display:flex; justify-content:space-between; gap:16px; flex-wrap:wrap; }
    .detail-summary strong { color:#0f172a; font-size:1.05rem; }
    .detail-items { padding:24px; }
    .detail-items table { width:100%; border-collapse:collapse; }
    .detail-items th, .detail-items td { padding:10px 8px; text-align:left; font-size:.92rem; border-bottom:1px solid #eef2f7; }
    .detail-items th { color:#64748b; font-weight:700; font-size:.78rem; text-transform:uppercase; letter-spacing:.4px; }
    .detail-items td.num { text-align:right; }
    .detail-total { padding:18px 24px; border-top:1px solid #eef2f7; text-align:right; font-weight:900; color:#b91c1c; font-size:1.2rem; }
    .detail-footer { padding:18px 24px; border-top:1px solid #eef2f7; display:flex; gap:10px; flex-wrap:wrap; justify-content:space-between; align-items:center; }
</style>
</head><body>
<c:set var="activePage" value="orders" scope="request"/>
<%@ include file="/views/common/header.jsp" %>
<main class="detail-shell">
    <div class="container">
        <div class="detail-panel">
            <div class="detail-header">
                <div>
                    <h1>Order #${order.id}</h1>
                    <div class="detail-meta">Placed on <fmt:formatDate value="${order.createdAt}" pattern="dd MMM yyyy · HH:mm"/></div>
                </div>
                <div>
                    <span class="detail-pill status">${order.status}</span>
                    <span class="detail-pill type">${order.type}</span>
                </div>
            </div>
            <div class="detail-summary">
                <div><div style="color:#64748b; font-size:.78rem; text-transform:uppercase; letter-spacing:.4px;">Customer</div><strong><c:out value='${order.userName}'/></strong></div>
                <div><div style="color:#64748b; font-size:.78rem; text-transform:uppercase; letter-spacing:.4px;">Method</div><strong><c:out value='${order.method}'/></strong></div>
                <div><div style="color:#64748b; font-size:.78rem; text-transform:uppercase; letter-spacing:.4px;">Items</div><strong>${order.itemCount}</strong></div>
            </div>
            <div class="detail-items">
                <table>
                    <thead><tr><th>Product</th><th>Variant</th><th class="num">Qty</th><th class="num">Total</th></tr></thead>
                    <tbody>
                        <c:forEach var="it" items="${order.items}">
                            <tr>
                                <td><b><c:out value='${it.productName}'/></b><div style="color:#64748b; font-size:.82rem;"><c:out value='${it.brandName}'/></div></td>
                                <td style="color:#64748b;"><c:out value='${it.memoryLabel}'/> / <c:out value='${it.colorName}'/></td>
                                <td class="num">×${it.amount}</td>
                                <td class="num"><fmt:formatNumber value="${it.total}" pattern="#,##0"/>₫</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="detail-total">Total: <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>₫</div>
            <div class="detail-footer">
                <a href="${pageContext.request.contextPath}/order-history" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Back to history
                </a>
                <c:if test="${order.status == 'DELIVERED' || order.status == 'COMPLETED'}">
                    <a class="btn btn-success" href="${pageContext.request.contextPath}/feedback?orderId=${order.id}">
                        <i class="bi bi-star"></i> Review
                    </a>
                </c:if>
            </div>
        </div>
    </div>
</main>
<%@ include file="/views/common/footer.jsp" %>
</body></html>
