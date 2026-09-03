<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Refund queue | Manager | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
        <style>
            body {
                background:#f6f8fb;
                color:#111827;
            }
            .rr-shell {
                padding:32px 0 70px;
            }
            .rr-panel {
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                padding:24px;
                margin-bottom:18px;
            }
            .rr-title {
                font-weight:900;
                margin:0 0 4px;
            }
            .rr-sub {
                color:#64748b;
                font-size:.9rem;
            }
            .rr-table {
                width:100%;
                border-collapse:collapse;
            }
            .rr-table th, .rr-table td {
                padding:12px 10px;
                border-bottom:1px solid #eef2f7;
                vertical-align:top;
                font-size:.92rem;
            }
            .rr-table th {
                background:#f8fafc;
                color:#475569;
                font-weight:700;
                font-size:.78rem;
                text-transform:uppercase;
                letter-spacing:.4px;
                text-align:left;
            }
            .rr-table tr:last-child td {
                border-bottom:none;
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
            .status-pill.status-active   {
                background:#fef3c7;
                color:#92400e;
                border-color:#fde68a;
            }
            .status-pill.status-approved {
                background:#dcfce7;
                color:#166534;
                border-color:#86efac;
            }
            .status-pill.status-rejected {
                background:#fee2e2;
                color:#991b1b;
                border-color:#fecaca;
            }

            .thread {
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                padding:24px;
            }
            .thread h2 {
                margin:0 0 6px;
                font-weight:900;
            }
            .thread-meta {
                color:#64748b;
                font-size:.9rem;
                margin-bottom:18px;
            }
            .thread-bubble {
                border:1px solid #e2e8f0;
                border-radius:10px;
                padding:14px 16px;
                margin-bottom:14px;
                background:#f8fafc;
            }
            .thread-bubble-content {
                white-space:pre-wrap;
                color:#0f172a;
            }
            .thread-bubble-author {
                font-weight:800;
            }
            .thread-bubble-role {
                font-size:.72rem;
                text-transform:uppercase;
                letter-spacing:.4px;
                color:#475569;
                margin-left:6px;
            }
            .item-row {
                display:flex;
                gap:12px;
                padding:10px 0;
                border-bottom:1px dashed #eef2f7;
            }
            .item-row:last-child {
                border-bottom:none;
            }
            .item-thumb {
                width:60px;
                height:60px;
                border-radius:6px;
                overflow:hidden;
                background:#fff;
                flex:0 0 60px;
                display:flex;
                align-items:center;
                justify-content:center;
            }
            .item-thumb img {
                max-width:100%;
                max-height:100%;
            }
            .item-meta {
                color:#64748b;
                font-size:.85rem;
            }
            .refund-payment-card {
                border:1px solid #bfdbfe;
                border-radius:12px;
                padding:16px;
                background:#eff6ff;
                margin:18px 0;
            }
            .refund-payment-card h5 {
                margin:0 0 6px;
                color:#1e3a8a;
                font-weight:900;
            }
            .refund-payment-card p {
                margin:0 0 12px;
                color:#475569;
            }

            .flash-message {
                padding:12px 14px;
                background:#ecfdf5;
                border:1px solid #bbf7d0;
                border-radius:8px;
                color:#166534;
                margin-bottom:14px;
            }
            .flash-message.error {
                background:#fef2f2;
                border-color:#fecaca;
                color:#991b1b;
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="refunds" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="rr-shell">
            <div class="container">

                <c:choose>
                    <c:when test="${view == 'detail'}">
                        <div class="rr-panel">
                            <h1 class="rr-title"><i class="bi bi-arrow-counterclockwise"></i> Refund #${request.id}</h1>
                            <p class="rr-sub">Reading customer's refund request for order #${request.transactionId}.</p>
                            <a href="${pageContext.request.contextPath}/manager/return-request" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-arrow-left"></i> Back to queue
                            </a>
                        </div>

                        <c:if test="${not empty param.flash}">
                            <div class="flash-message ${param.flash.contains('Invalid') || param.flash.contains('no longer') ? 'error' : ''}">
                                <c:out value="${param.flash}"/>
                            </div>
                        </c:if>

                        <div class="thread">
                            <h2>Order #${request.transactionId}
                                <span class="status-pill
                                      <c:choose>
                                          <c:when test="${request.status == 'ACTIVE'}">status-active</c:when>
                                          <c:when test="${request.status == 'APPROVED'}">status-approved</c:when>
                                          <c:otherwise>status-rejected</c:otherwise>
                                      </c:choose>" style="margin-left:6px;">${request.status}</span>
                            </h2>
                            <div class="thread-meta">
                                Submitted by <c:out value="${request.userName}"/>
                                on <fmt:formatDate value="${request.createdAt}" pattern="dd MMM yyyy HH:mm"/>
                                <c:if test="${request.updatedAt != null}">
                                    &middot; last update <fmt:formatDate value="${request.updatedAt}" pattern="dd MMM yyyy HH:mm"/>
                                </c:if>
                            </div>

                            <div class="thread-bubble">
                                <div class="thread-bubble-author"><c:out value="${request.userName}"/>
                                    <span class="thread-bubble-role">Customer</span>
                                </div>
                                <div class="thread-bubble-content"><c:out value="${request.description}"/></div>
                            </div>

                            <c:if test="${request.hasBankInfo}">
                                <div class="refund-payment-card">
                                    <h5><i class="bi bi-bank"></i> Customer refund bank information</h5>
                                    <p>Use this account for the refund transfer after VNPay sandbox confirmation.</p>
                                    <div class="row g-2">
                                        <div class="col-md-4"><b>Bank</b><br><c:out value="${request.bankName}"/></div>
                                        <div class="col-md-4"><b>Account number</b><br><c:out value="${request.bankAccountNumber}"/></div>
                                        <div class="col-md-4"><b>Account holder</b><br><c:out value="${request.bankAccountHolder}"/></div>
                                    </div>
                                </div>
                            </c:if>

                            <c:if test="${not empty request.image}">
                                <h5 style="font-weight:900; margin-top:18px;">Photo evidence</h5>
                                <img src="${pageContext.request.contextPath}/assets/images/refund/${request.image}"
                                     alt="evidence"
                                     style="max-height:260px; border:1px solid #e2e8f0; border-radius:8px;">
                            </c:if>

                            <h5 style="font-weight:900; margin-top:24px;">Items requested for refund</h5>
                            <c:choose>
                                <c:when test="${empty request.items}">
                                    <p style="color:#64748b;">No items recorded.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="it" items="${request.items}">
                                        <div class="item-row">
                                            <div class="item-thumb">
                                                <c:if test="${not empty it.variantImage}">
                                                    <img src="${pageContext.request.contextPath}/assets/images/products/${it.variantImage}" alt="${it.productName}">
                                                </c:if>
                                            </div>
                                            <div style="flex:1;">
                                                <div style="font-weight:900;">${it.productName}</div>
                                                <div class="item-meta">${it.variantLabel} &middot; qty ${it.amount} &middot; <fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/>₫</div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>

                            <c:if test="${request.status == 'ACTIVE'}">
                                <form method="post" action="${pageContext.request.contextPath}/manager/return-request" class="mt-4">
                                    <input type="hidden" name="action" value="decide">
                                    <input type="hidden" name="id" value="${request.id}">
                                    <div class="d-flex justify-content-end gap-2">
                                        <button type="submit" name="decision" value="reject" class="btn btn-outline-danger"
                                                onclick="return confirm('Reject this refund request?');">
                                            <i class="bi bi-x-lg"></i> Reject
                                        </button>
                                        <button type="submit" name="decision" value="approve" class="btn btn-success"
                                                onclick="return confirm('Approve this refund request and continue to VNPay sandbox if payment is required?');">
                                            <i class="bi bi-credit-card"></i> Approve / VNPay refund
                                        </button>
                                    </div>
                                </form>
                            </c:if>

                            <c:if test="${request.status != 'ACTIVE' && not empty request.reviewedByName}">
                                <p style="margin-top:18px; color:#475569;">
                                    Reviewed by <b>${request.reviewedByName}</b>
                                    <c:if test="${request.reviewedAt != null}">
                                        on <fmt:formatDate value="${request.reviewedAt}" pattern="dd MMM yyyy HH:mm"/>
                                    </c:if>
                                </p>
                            </c:if>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="rr-panel">
                            <h1 class="rr-title"><i class="bi bi-arrow-counterclockwise"></i> Refund queue</h1>
                            <p class="rr-sub">Review every customer refund request and decide whether to approve or reject it.</p>

                            <form method="get" action="${pageContext.request.contextPath}/manager/return-request" class="mt-3" style="display:flex; gap:8px; flex-wrap:wrap;">
                                <input type="text" name="keyword" class="form-control" placeholder="Search customer, order id, or content"
                                       value="<c:out value='${filter.keyword}'/>" style="max-width:280px;">
                                <select name="status" class="form-select" style="max-width:180px;">
                                    <option value="">All statuses</option>
                                    <option value="ACTIVE"   ${filter.status == 'ACTIVE'   ? 'selected' : ''}>Pending</option>
                                    <option value="APPROVED" ${filter.status == 'APPROVED' ? 'selected' : ''}>Approved</option>
                                    <option value="REJECTED" ${filter.status == 'REJECTED' ? 'selected' : ''}>Rejected</option>
                                </select>
                                <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Filter</button>
                                <a href="${pageContext.request.contextPath}/manager/return-request" class="btn btn-outline-secondary">Reset</a>
                            </form>
                        </div>

                        <div class="rr-panel">
                            <c:choose>
                                <c:when test="${empty requests}">
                                    <div style="text-align:center; padding:40px 20px; color:#64748b;">
                                        <i class="bi bi-inbox" style="font-size:3rem; color:#cbd5e1;"></i>
                                        <h4 style="margin:12px 0 4px; font-weight:900;">No refund requests</h4>
                                        <p style="margin:0;">Nothing matches the current filter. Try a broader search or check back later.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table class="rr-table">
                                        <thead>
                                            <tr><th>Order</th><th>Customer</th><th>Created</th><th>Items</th><th>Status</th><th style="text-align:right;">Action</th></tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="r" items="${requests}">
                                                <tr>
                                                    <td><b>#${r.transactionId}</b></td>
                                                    <td><c:out value="${r.userName}"/></td>
                                                    <td><fmt:formatDate value="${r.createdAt}" pattern="dd MMM yyyy HH:mm"/></td>
                                                    <td>${r.itemCount}</td>
                                                    <td>
                                                        <span class="status-pill
                                                              <c:choose>
                                                                  <c:when test="${r.status == 'ACTIVE'}">status-active</c:when>
                                                                  <c:when test="${r.status == 'APPROVED'}">status-approved</c:when>
                                                                  <c:otherwise>status-rejected</c:otherwise>
                                                              </c:choose>">
                                                            ${r.status}
                                                        </span>
                                                    </td>
                                                    <td style="text-align:right;">
                                                        <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/manager/return-request?action=view&id=${r.id}">
                                                            <i class="bi bi-eye"></i> Review
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
    </body>
</html>
