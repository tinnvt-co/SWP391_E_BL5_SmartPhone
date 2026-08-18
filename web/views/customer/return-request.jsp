<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Refund request | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        <style>
            .rr-shell {
                padding:40px 0 64px;
            }
            .rr-panel {
                max-width:860px;
                margin:0 auto;
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:16px;
                box-shadow:0 4px 12px rgba(15,23,42,0.06);
                overflow:hidden;
            }
            .rr-header {
                padding:24px;
                border-bottom:1px solid #e5e7eb;
            }
            .rr-header h1 {
                margin:0;
                font-weight:800;
            }
            .rr-header p {
                color:#64748b;
                margin:6px 0 0;
            }
            .rr-body {
                padding:24px;
            }
            .order-summary {
                background:#f8fafc;
                border:1px solid #e2e8f0;
                border-radius:10px;
                padding:16px;
                margin-bottom:18px;
            }
            .order-summary .kv {
                display:flex;
                justify-content:space-between;
                padding:6px 0;
                font-size:.94rem;
            }
            .order-summary .kv b {
                color:#0f172a;
            }
            .item-row {
                display:flex;
                gap:12px;
                padding:12px 0;
                border-bottom:1px dashed #eef2f7;
            }
            .item-row:last-child {
                border-bottom:none;
            }
            .item-thumb {
                width:60px;
                height:60px;
                border-radius:8px;
                overflow:hidden;
                background:#fff;
                flex:0 0 60px;
                display:flex;
                align-items:center;
                justify-content:center;
                border:1px solid #e5e7eb;
            }
            .item-thumb img {
                max-width:100%;
                max-height:100%;
            }
            .item-meta {
                color:#64748b;
                font-size:.85rem;
            }

            .upload-card {
                border:2px dashed #cbd5e1;
                border-radius:10px;
                padding:22px;
                text-align:center;
                background:#fbfdff;
                transition: all .15s ease;
            }
            .upload-card:hover {
                border-color: #93c5fd;
                background: #eff6ff;
            }
            .upload-card input[type=file] {
                display:none;
            }
            .upload-card label {
                cursor:pointer;
                color:#1d4ed8;
                font-weight:700;
            }
            .upload-card .preview {
                margin-top:12px;
            }
            .upload-card .preview img {
                max-height:160px;
                border-radius:8px;
                border:1px solid #e2e8f0;
            }
            .bank-card {
                border:1px solid #bfdbfe;
                border-radius:12px;
                padding:18px;
                background:#eff6ff;
                margin-bottom:18px;
            }
            .bank-card h5 {
                margin:0 0 6px;
                font-weight:900;
                color:#1e3a8a;
            }
            .bank-card p {
                margin:0 0 14px;
                color:#475569;
            }

            .status-active   {
                background:#fef3c7;
                color:#92400e;
                border-color:#fde68a;
            }
            .status-approved {
                background:#dcfce7;
                color:#166534;
                border-color:#86efac;
            }
            .status-rejected {
                background:#fee2e2;
                color:#991b1b;
                border-color:#fecaca;
            }

            .flash-message {
                padding:14px 18px;
                background:#ecfdf5;
                border:1px solid #bbf7d0;
                border-radius:10px;
                color:#166534;
                margin-bottom:18px;
            }
            .flash-message.error {
                background:#fef2f2;
                border-color:#fecaca;
                color:#991b1b;
            }
            .error-message {
                background:#fef2f2;
                border:1px solid #fecaca;
                border-radius:10px;
                padding:14px 18px;
                color:#991b1b;
                margin-bottom:18px;
            }

            .btn-submit {
                background:#16a34a;
                color:#fff;
                border:none;
                padding:10px 22px;
                border-radius:8px;
                font-weight:700;
            }
            .btn-submit:hover {
                background:#15803d;
                color:#fff;
            }

            .thread-bubble {
                border:1px solid #e2e8f0;
                border-radius:10px;
                padding:14px 16px;
                margin-bottom:14px;
                background:#f8fafc;
            }
            .thread-bubble.manager {
                background:#eef2ff;
                border-color:#c7d2fe;
            }

            .rr-list {
                width:100%;
                border-collapse:collapse;
            }
            .rr-list th, .rr-list td {
                padding:12px 10px;
                border-bottom:1px solid #eef2f7;
                text-align:left;
                font-size:.94rem;
            }
            .rr-list th {
                background:#f8fafc;
                color:#475569;
                font-weight:700;
                font-size:.78rem;
                text-transform:uppercase;
                letter-spacing:.04em;
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="orders" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="rr-shell">
            <div class="container">
                <div class="rr-panel">

                    <c:choose>
                        <%-- =========================================================== --%>
                        <%--  LIST VIEW                                                --%>
                        <%-- =========================================================== --%>
                        <c:when test="${view == 'list'}">
                            <div class="rr-header">
                                <h1><i class="bi bi-arrow-counterclockwise"></i> My refund requests</h1>
                                <p>Track the status of every refund you have submitted.</p>
                            </div>
                            <div class="rr-body">
                                <c:choose>
                                    <c:when test="${empty myRequests}">
                                        <div style="text-align:center; color:#64748b; padding:40px 0;">
                                            <i class="bi bi-inbox" style="font-size:3rem; color:#cbd5e1;"></i>
                                            <h4 style="margin:14px 0 4px; font-weight:900;">No refund requests yet</h4>
                                            <p style="margin:0;">Open any delivered order from your order history and tap "Refund" to start one.</p>
                                            <a href="${pageContext.request.contextPath}/order-history" class="btn btn-outline-primary mt-3">
                                                <i class="bi bi-receipt"></i> Back to order history
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <table class="rr-list">
                                            <thead>
                                                <tr><th>Order</th><th>Created</th><th>Items</th><th>Status</th><th>Action</th></tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="r" items="${myRequests}">
                                                    <tr>
                                                        <td><b>#${r.transactionId}</b></td>
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
                                                        <td>
                                                            <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/return-request?id=${r.id}">
                                                                <i class="bi bi-eye"></i> View
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:when>

                        <%-- =========================================================== --%>
                        <%--  DETAIL VIEW                                              --%>
                        <%-- =========================================================== --%>
                        <c:when test="${view == 'detail'}">
                            <div class="rr-header">
                                <h1><i class="bi bi-arrow-counterclockwise"></i> Refund #${request.id}
                                    for order #${request.transactionId}</h1>
                                <p>Submitted <fmt:formatDate value="${request.createdAt}" pattern="dd MMM yyyy HH:mm"/>.
                                    Current status:
                                    <span class="status-pill
                                          <c:choose>
                                              <c:when test="${request.status == 'ACTIVE'}">status-active</c:when>
                                              <c:when test="${request.status == 'APPROVED'}">status-approved</c:when>
                                              <c:otherwise>status-rejected</c:otherwise>
                                          </c:choose>">
                                        ${request.status}
                                    </span>
                                </p>
                            </div>
                            <div class="rr-body">
                                <div class="thread-bubble ${request.status == 'APPROVED' || request.status == 'REJECTED' ? 'manager' : ''}">
                                    <div style="font-weight:800; color:#0f172a;">Your reason</div>
                                    <div style="white-space:pre-wrap; color:#0f172a; margin-top:6px;"><c:out value="${request.description}"/></div>
                                </div>

                                <c:if test="${request.hasBankInfo}">
                                    <div class="bank-card">
                                        <h5><i class="bi bi-bank"></i> Refund bank information</h5>
                                        <div class="row g-2">
                                            <div class="col-md-4"><b>Bank</b><br><c:out value="${request.bankName}"/></div>
                                            <div class="col-md-4"><b>Account number</b><br><c:out value="${request.bankAccountNumber}"/></div>
                                            <div class="col-md-4"><b>Account holder</b><br><c:out value="${request.bankAccountHolder}"/></div>
                                        </div>
                                    </div>
                                </c:if>

                                <c:if test="${not empty request.image}">
                                    <h5 style="font-weight:900; margin-top:18px;">Attached image</h5>
                                    <img src="${pageContext.request.contextPath}/assets/images/refund/${request.image}"
                                         alt="refund evidence"
                                         style="max-height:240px; border:1px solid #e2e8f0; border-radius:8px;">
                                </c:if>

                                <h5 style="font-weight:900; margin-top:24px;">Items in this request</h5>
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
                                                    <div class="item-meta">${it.variantLabel} &middot; qty ${it.amount}</div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>

                                <c:if test="${not empty request.reviewedByName}">
                                    <p style="margin-top:18px; color:#475569;">
                                        Reviewed by <b>${request.reviewedByName}</b>
                                        <c:if test="${request.reviewedAt != null}">
                                            on <fmt:formatDate value="${request.reviewedAt}" pattern="dd MMM yyyy HH:mm"/>
                                        </c:if>
                                    </p>
                                </c:if>

                                <a href="${pageContext.request.contextPath}/order-history" class="btn btn-outline-secondary mt-3">
                                    <i class="bi bi-arrow-left"></i> Back to order history
                                </a>
                            </div>
                        </c:when>

                        <%-- =========================================================== --%>
                        <%--  FORM VIEW (default)                                      --%>
                        <%-- =========================================================== --%>
                        <c:otherwise>
                            <div class="rr-header">
                                <h1><i class="bi bi-arrow-counterclockwise"></i> Request a refund</h1>
                                <p>Describe what went wrong and attach a photo so our team can review your case quickly.</p>
                            </div>

                            <div class="rr-body">
                                <c:if test="${not empty flash}">
                                    <div class="flash-message ${flash.contains('characters') || flash.contains('eligible') || flash.contains('pending') ? 'error' : ''}">
                                        <c:out value="${flash}"/>
                                    </div>
                                </c:if>

                                <c:if test="${not empty error}">
                                    <div class="error-message"><c:out value="${error}"/></div>
                                </c:if>

                                <c:if test="${alreadyRequested}">
                                    <div class="flash-message error">
                                        You already have a pending refund request for this order. Please wait for our team to review it.
                                    </div>
                                    <c:if test="${not empty activeRequest}">
                                        <p>
                                            <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/return-request?id=${activeRequest.id}">
                                                <i class="bi bi-eye"></i> View pending request
                                            </a>
                                        </p>
                                    </c:if>
                                </c:if>

                                <c:choose>
                                    <c:when test="${empty order}">
                                        <p style="color:#64748b;">Order not found.</p>
                                        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/order-history">
                                            <i class="bi bi-arrow-left"></i> Back to order history
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="order-summary">
                                            <div class="kv"><span>Order</span><b>#${order.id}</b></div>
                                            <div class="kv"><span>Placed on</span><b><fmt:formatDate value="${order.createdAt}" pattern="dd MMM yyyy HH:mm"/></b></div>
                                            <div class="kv"><span>Total</span><b><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>₫</b></div>
                                            <div class="kv"><span>Status</span><b>${order.status}</b></div>
                                        </div>

                                        <h5 style="font-weight:900;">Items in this order</h5>
                                        <c:choose>
                                            <c:when test="${empty order.items}">
                                                <p style="color:#64748b;">This order has no items.</p>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="it" items="${order.items}">
                                                    <div class="item-row">
                                                        <div class="item-thumb">
                                                            <c:if test="${not empty it.productImage}">
                                                                <img src="${pageContext.request.contextPath}/assets/images/products/${it.productImage}" alt="${it.productName}">
                                                            </c:if>
                                                        </div>
                                                        <div style="flex:1;">
                                                            <div style="font-weight:900;">${it.productName}</div>
                                                            <div class="item-meta">
                                                                ${it.memoryLabel} &middot; ${it.colorName} &middot; qty ${it.amount} &middot; <fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/>₫
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>

                                        <c:if test="${!alreadyRequested}">
                                            <form method="post" action="${pageContext.request.contextPath}/return-request"
                                                  enctype="multipart/form-data" class="mt-4">
                                                <input type="hidden" name="orderId" value="${order.id}">

                                                <div class="mb-3">
                                                    <label for="description" class="form-label" style="font-weight:700;">Reason for refund</label>
                                                    <textarea id="description" name="description" class="form-control" maxlength="255" minlength="5" required
                                                              placeholder="Tell us what happened (e.g. wrong item, arrived broken, etc.)"><c:out value="${description}"/></textarea>
                                                    <div class="form-text">5 to 255 characters.</div>
                                                </div>

                                                <div class="bank-card">
                                                    <h5><i class="bi bi-bank"></i> Bank information for refund</h5>
                                                    <p>This order has been paid, so please provide the bank account that should receive the refund.</p>
                                                    <div class="row g-3">
                                                        <div class="col-md-4">
                                                            <label class="form-label" for="bankName">Bank name*</label>
                                                            <input id="bankName" 
                                                                   name="bankName" 
                                                                   class="form-control" 
                                                                   maxlength="80" 
                                                                   required placeholder="NCB, Vietcombank..." 
                                                                   value="<c:out value='${bankName}'/>">
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="form-label" for="bankAccountNumber">Account number*</label>
                                                            <input id="bankAccountNumber" 
                                                                   name="bankAccountNumber" 
                                                                   class="form-control" 
                                                                   maxlength="40" 
                                                                   required placeholder="Account number"
                                                                   value="<c:out value='${bankAccountNumber}'/>">
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="form-label" for="bankAccountHolder">Account holder*</label>
                                                            <input id="bankAccountHolder" 
                                                                   name="bankAccountHolder" 
                                                                   class="form-control" 
                                                                   maxlength="80" 
                                                                   required placeholder="Full account name"
                                                                   value="<c:out value='${bankAccountHolder}'/>">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="mb-3">
                                                    <label class="form-label" style="font-weight:700;">Photo evidence (optional)</label>
                                                    <div class="upload-card" id="uploadCard">
                                                        <i class="bi bi-cloud-arrow-up" style="font-size:2rem; color:#94a3b8;"></i>
                                                        <p style="margin:8px 0 6px;">
                                                            <label for="image">
                                                                <i class="bi bi-paperclip"></i> Click to choose an image
                                                            </label>
                                                            <input type="file" id="image" name="image" accept="image/*">
                                                        </p>
                                                        <small style="color:#64748b;">JPG/PNG/WEBP, up to 5 MB.</small>
                                                        <div class="preview" id="preview" style="display:none;">
                                                            <img id="previewImg" alt="preview">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="d-flex justify-content-end gap-2">
                                                    <a href="${pageContext.request.contextPath}/order-history" class="btn btn-outline-secondary">Cancel</a>
                                                    <button type="submit" class="btn-submit"><i class="bi bi-send"></i> Submit refund request</button>
                                                </div>
                                            </form>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script>
            (function () {
                var input = document.getElementById('image');
                var preview = document.getElementById('preview');
                var previewImg = document.getElementById('previewImg');
                if (!input)
                    return;
                input.addEventListener('change', function () {
                    var f = input.files && input.files[0];
                    if (!f) {
                        preview.style.display = 'none';
                        return;
                    }
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        previewImg.src = e.target.result;
                        preview.style.display = 'block';
                    };
                    reader.readAsDataURL(f);
                });
            })();
        </script>
    </body>
</html>
