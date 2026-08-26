<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cancel request | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        <style>
            .cr-shell { padding:40px 0 64px; }
            .cr-panel {
                max-width:860px;
                margin:0 auto;
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:16px;
                box-shadow:0 4px 12px rgba(15,23,42,0.06);
                overflow:hidden;
            }
            .cr-header { padding:24px; border-bottom:1px solid #e5e7eb; }
            .cr-header h1 { margin:0; font-weight:800; }
            .cr-header p { color:#64748b; margin:6px 0 0; }
            .cr-body { padding:24px; }

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
            .order-summary .kv b { color:#0f172a; }

            .item-row {
                display:flex;
                gap:12px;
                padding:12px 0;
                border-bottom:1px dashed #eef2f7;
            }
            .item-row:last-child { border-bottom:none; }
            .item-thumb {
                width:60px; height:60px; border-radius:8px;
                overflow:hidden; background:#fff; flex:0 0 60px;
                display:flex; align-items:center; justify-content:center;
                border:1px solid #e5e7eb;
            }
            .item-thumb img { max-width:100%; max-height:100%; }
            .item-meta { color:#64748b; font-size:.85rem; }

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
            .bank-card p { margin:0 0 14px; color:#475569; }

            .reason-card {
                border:1px solid #e2e8f0;
                border-radius:12px;
                padding:14px;
                margin-bottom:14px;
                cursor:pointer;
                transition:all .15s ease;
                display:flex;
                gap:12px;
                align-items:flex-start;
            }
            .reason-card:hover { border-color:#93c5fd; background:#f8fbff; }
            .reason-card input[type=radio] { margin-top:4px; }
            .reason-card.active {
                border-color:#2563eb;
                background:#eff6ff;
                box-shadow:0 0 0 3px rgba(37,99,235,.1);
            }
            .reason-card i { font-size:1.4rem; color:#2563eb; }
            .reason-card strong { display:block; font-weight:800; }
            .reason-card small { color:#64748b; }

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
                background:#dc2626;
                color:#fff;
                border:none;
                padding:10px 22px;
                border-radius:8px;
                font-weight:700;
            }
            .btn-submit:hover { background:#b91c1c; color:#fff; }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="orders" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="cr-shell">
            <div class="container">
                <div class="cr-panel">

                    <div class="cr-header">
                        <h1><i class="bi bi-x-circle"></i> Request cancellation</h1>
                        <%-- Phần header: hiển thị thông báo khác nhau tùy theo đã thanh toán (VNPay) hay COD (chưa trả tiền) --%>
                        <p>
                            <c:choose>
                                <%-- VNPay: đã thanh toán online -> cần nhập thông tin ngân hàng để hoàn tiền --%>
                                <c:when test="${isPaid}">
                                    This order was paid online. Please tell us why you want to cancel and provide a bank account so we can refund you through VNPay.
                                </c:when>
                                <%-- COD: chưa thanh toán -> chỉ cần lý do, staff sẽ duyệt --%>
                                <c:otherwise>
                                    This is a Cash-on-Delivery order. Tell us why you want to cancel and staff will review your request.
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>

                    <div class="cr-body">
                        <c:if test="${not empty flash}">
                            <div class="flash-message ${flash.contains('characters') || flash.contains('eligible') || flash.contains('pending') || flash.contains('complete') ? 'error' : ''}">
                                <c:out value="${flash}"/>
                            </div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="error-message"><c:out value="${error}"/></div>
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
                                    <div class="kv"><span>Payment</span><b>${order.method}</b></div>
                                </div>

                                <c:choose>
                                    <c:when test="${alreadyRequested}">
                                        <div class="flash-message error">
                                            You already have a pending cancellation request for this order. Please wait for our team to review it.
                                        </div>
                                        <a href="${pageContext.request.contextPath}/order-history" class="btn btn-outline-secondary">
                                            <i class="bi bi-arrow-left"></i> Back to order history
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="${pageContext.request.contextPath}/customer/cancel-request" id="cancelRequestForm">
                                            <input type="hidden" name="orderId" value="${order.id}">

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

                                            <h5 style="font-weight:900; margin-top:24px;">Reason for cancellation</h5>
                                            <label class="reason-card">
                                                <input type="radio" name="reason" value="CHANGED_MIND" required>
                                                <i class="bi bi-emoji-frown"></i>
                                                <div>
                                                    <strong>Changed my mind</strong>
                                                    <small>I no longer want this product.</small>
                                                </div>
                                            </label>
                                            <label class="reason-card">
                                                <input type="radio" name="reason" value="WRONG_PRODUCT">
                                                <i class="bi bi-bag-x"></i>
                                                <div>
                                                    <strong>Ordered wrong product</strong>
                                                    <small>I picked the wrong variant / model.</small>
                                                </div>
                                            </label>
                                            <label class="reason-card">
                                                <input type="radio" name="reason" value="FOUND_CHEAPER">
                                                <i class="bi bi-tag"></i>
                                                <div>
                                                    <strong>Found a cheaper price</strong>
                                                    <small>I found the same item cheaper elsewhere.</small>
                                                </div>
                                            </label>
                                            <label class="reason-card">
                                                <input type="radio" name="reason" value="LONG_DELIVERY">
                                                <i class="bi bi-truck"></i>
                                                <div>
                                                    <strong>Delivery takes too long</strong>
                                                    <small>Estimated delivery is too slow.</small>
                                                </div>
                                            </label>
                                            <label class="reason-card">
                                                <input type="radio" name="reason" value="OTHER">
                                                <i class="bi bi-three-dots"></i>
                                                <div>
                                                    <strong>Other reason</strong>
                                                    <small>Tell us more below.</small>
                                                </div>
                                            </label>

                                            <div class="mb-3" id="customReasonWrap" style="display:none;">
                                                <label for="customReason" class="form-label" style="font-weight:700;">Tell us more</label>
                                                <textarea id="customReason" name="customReason" class="form-control" maxlength="500"
                                                          placeholder="Please describe your reason (max 500 characters)"></textarea>
                                            </div>

                                            <%-- CHỈ VNPay mới hiển thị phần nhập thông tin ngân hàng để hoàn tiền, COD thì không cần (chưa trả tiền) --%>
                                            <c:if test="${isPaid}">
                                                <div class="bank-card">
                                                    <h5><i class="bi bi-bank"></i> Bank information for refund</h5>
                                                    <p>This order has been paid online, so please provide the bank account that should receive the refund.</p>
                                                    <div class="row g-3">
                                                        <div class="col-md-4">
                                                            <label class="form-label" for="bankName">Bank name*</label>
                                                            <input id="bankName" name="bankName" class="form-control"
                                                                   maxlength="80" required placeholder="NCB, Vietcombank...">
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="form-label" for="bankAccountNumber">Account number*</label>
                                                            <input id="bankAccountNumber" name="bankAccountNumber" class="form-control"
                                                                   maxlength="40" required placeholder="Account number">
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="form-label" for="bankAccountHolder">Account holder*</label>
                                                            <input id="bankAccountHolder" name="bankAccountHolder" class="form-control"
                                                                   maxlength="80" required placeholder="Full account name">
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <div class="d-flex justify-content-end gap-2 mt-4">
                                                <a href="${pageContext.request.contextPath}/order-history" class="btn btn-outline-secondary">Keep order</a>
                                                <button type="submit" class="btn-submit">
                                                    <i class="bi bi-send"></i> Submit cancel request
                                                </button>
                                            </div>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script>
            (function () {
                var form = document.getElementById('cancelRequestForm');
                if (!form) {
                    return;
                }
                var cards = form.querySelectorAll('.reason-card');
                var customWrap = document.getElementById('customReasonWrap');

                cards.forEach(function (card) {
                    card.addEventListener('click', function () {
                        cards.forEach(function (c) { c.classList.remove('active'); });
                        card.classList.add('active');
                        var radio = card.querySelector('input[type="radio"]');
                        if (radio) {
                            radio.checked = true;
                            if (radio.value === 'OTHER') {
                                customWrap.style.display = 'block';
                            } else if (customWrap) {
                                customWrap.style.display = 'none';
                            }
                        }
                    });
                });

                form.addEventListener('submit', function (event) {
                    var selected = form.querySelector('input[name="reason"]:checked');
                    if (!selected) {
                        event.preventDefault();
                        return;
                    }
                    if (selected.value === 'OTHER') {
                        var text = document.getElementById('customReason').value.trim();
                        if (!text) {
                            event.preventDefault();
                            document.getElementById('customReason').focus();
                        }
                    }
                });
            })();
        </script>
    </body>
</html>