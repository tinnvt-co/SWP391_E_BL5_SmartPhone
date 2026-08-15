<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Order History | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body {
                background:#f6f8fb;
                color:#111827;
            }
            .history-shell {
                padding:42px 0 70px;
            }
            .history-panel {
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                overflow:hidden;
            }
            .history-header {
                padding:24px;
                border-bottom:1px solid #eef2f7;
                display:flex;
                justify-content:space-between;
                align-items:center;
                gap:16px;
                flex-wrap:wrap;
            }
            .history-header h1 {
                margin:0;
                font-weight:900;
            }
            .history-sub {
                color:#64748b;
                margin-top:4px;
            }

            .history-table {
                width:100%;
                border-collapse:collapse;
            }
            .history-table th, .history-table td {
                padding:14px 16px;
                text-align:left;
                font-size:.94rem;
                vertical-align:middle;
            }
            .history-table thead th {
                background:#f8fafc;
                color:#475569;
                font-weight:700;
                font-size:.82rem;
                text-transform:uppercase;
                letter-spacing:.4px;
                border-bottom:1px solid #eef2f7;
            }
            .history-table tbody tr {
                border-bottom:1px solid #eef2f7;
            }
            .history-table tbody tr:last-child {
                border-bottom:none;
            }
            .history-code {
                font-weight:900;
                color:#0f172a;
            }
            .history-total {
                font-weight:900;
                color:#b91c1c;
            }

            .status-pill {
                display:inline-block;
                padding:4px 10px;
                border-radius:999px;
                font-size:.72rem;
                font-weight:800;
                letter-spacing:.4px;
                text-transform:uppercase;
                border:1px solid transparent;
            }
            .status-pill.paid {
                background:#ecfdf5;
                color:#15803d;
                border-color:#bbf7d0;
            }
            .status-pill.delivered {
                background:#e0f2fe;
                color:#075985;
                border-color:#bae6fd;
            }
            .status-pill.completed {
                background:#dcfce7;
                color:#166534;
                border-color:#86efac;
            }
            .status-pill.shipping {
                background:#fef3c7;
                color:#92400e;
                border-color:#fde68a;
            }
            .status-pill.processing {
                background:#ede9fe;
                color:#5b21b6;
                border-color:#ddd6fe;
            }
            .status-pill.confirmed {
                background:#dbeafe;
                color:#1e40af;
                border-color:#bfdbfe;
            }
            .status-pill.pending {
                background:#fef3c7;
                color:#92400e;
                border-color:#fde68a;
            }
            .status-pill.cancelled {
                background:#fee2e2;
                color:#991b1b;
                border-color:#fecaca;
            }
            .status-pill.cancel_requested {
                background:#fde68a;
                color:#92400e;
                border-color:#fbbf24;
            }

        .history-actions { display:flex; gap:8px; flex-wrap:wrap; justify-content:flex-end; }
        .view-btn, .review-btn { min-height:36px; display:inline-flex; align-items:center; gap:6px; padding:0 14px; border-radius:6px; font-weight:700; font-size:.85rem; text-decoration:none; border:1px solid transparent; cursor:pointer; }
        .view-btn { background:#fff; border-color:#dbe3ec; color:#111827; }
        .view-btn:hover { color:#1665d8; border-color:#b9c9ef; }
        .review-btn { background:#16a34a; color:#fff; border-color:#16a34a; }
        .review-btn:hover { background:#15803d; border-color:#15803d; color:#fff; }

        .refund-btn { min-height:36px; display:inline-flex; align-items:center; gap:6px; padding:0 14px; border-radius:6px; font-weight:700; font-size:.85rem; text-decoration:none; border:1px solid transparent; cursor:pointer; background:#fff; color:#b91c1c; border-color:#fecaca; }
        .refund-btn:hover { background:#fef2f2; border-color:#f87171; color:#b91c1c; }
        .refund-pending { display:inline-block; padding:4px 10px; border-radius:999px; font-size:.72rem; font-weight:800; letter-spacing:.4px; text-transform:uppercase; border:1px solid #fde68a; background:#fef3c7; color:#92400e; }

            .history-empty {
                padding:60px 24px;
                text-align:center;
                color:#64748b;
            }
            .history-empty i {
                font-size:48px;
                color:#cbd5e1;
                display:block;
                margin-bottom:12px;
            }

            @media(max-width:700px){
                .history-table thead {
                    display:none;
                }
                .history-table, .history-table tbody, .history-table tr, .history-table td {
                    display:block;
                    width:100%;
                }
                .history-table tr {
                    padding:14px 16px;
                    border-bottom:1px solid #eef2f7;
                }
                .history-table td {
                    padding:6px 0;
                    border:none;
                }
                .history-table td::before {
                    content:attr(data-label);
                    display:block;
                    font-size:.72rem;
                    color:#64748b;
                    text-transform:uppercase;
                    letter-spacing:.4px;
                    font-weight:700;
                    margin-bottom:2px;
                }
                .history-actions {
                    justify-content:flex-start;
                    margin-top:8px;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="orders" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="history-shell">
            <div class="container">
                <div class="history-panel">
                    <div class="history-header">
                        <div>
                            <h1><i class="bi bi-receipt"></i> Order History</h1>
                            <div class="history-sub">All purchases you have made on this account.</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/products" class="view-btn">
                            <i class="bi bi-bag"></i> Continue shopping
                        </a>
                    </div>

            <c:choose>
                <c:when test="${empty orders}">
                    <div class="history-empty">
                        <i class="bi bi-bag-x"></i>
                        <h4 style="margin:8px 0 4px; font-weight:900;">No orders yet</h4>
                        <p style="margin:0;">You haven't placed any orders. Start shopping to see your history here.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="history-table">
                        <thead>
                            <tr>
                                <th>Order</th>
                                <th>Placed on</th>
                                <th>Items</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th style="text-align:right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td data-label="Order">
                                        <div class="history-code">#${o.id}</div>
                                        <div style="color:#64748b; font-size:.82rem;">${o.method}</div>
                                    </td>
                                    <td data-label="Placed on">
                                        <fmt:formatDate value="${o.createdAt}" pattern="dd MMM yyyy"/>
                                        <div style="color:#64748b; font-size:.82rem;"><fmt:formatDate value="${o.createdAt}" pattern="HH:mm"/></div>
                                    </td>
                                    <td data-label="Items">${o.itemCount}</td>
                                    <td data-label="Total" class="history-total"><fmt:formatNumber value="${o.totalPrice}" pattern="#,##0"/>₫</td>
                                    <td data-label="Status">
                                        <span class="status-pill ${o.status.toLowerCase()}">${o.status}</span>
                                    </td>
                                    <td data-label="Action">
                                        <div class="history-actions">
                                            <a class="view-btn" href="${pageContext.request.contextPath}/order-detail?id=${o.id}">
                                                <i class="bi bi-eye"></i> View
                                            </a>
                                            <c:if test="${(o.status == 'DELIVERED' || o.status == 'COMPLETED') && !o.hasBlockingRefund}">
                                                <a class="review-btn" href="${pageContext.request.contextPath}/feedback?orderId=${o.id}">
                                                    <i class="bi bi-star"></i> Review
                                                </a>
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${o.status == 'DELIVERED' && !o.hasOpenRefund}">
                                                    <a class="refund-btn" href="${pageContext.request.contextPath}/return-request?orderId=${o.id}">
                                                        <i class="bi bi-arrow-counterclockwise"></i> Refund
                                                    </a>
                                                </c:when>
                                                <c:when test="${o.status == 'DELIVERED' && o.hasOpenRefund}">
                                                    <span class="refund-pending"><i class="bi bi-clock-history"></i> Refund pending</span>
                                                </c:when>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

        <%@ include file="/views/common/footer.jsp" %>
    </body>
</html>
