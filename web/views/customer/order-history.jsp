<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Order History | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/complaint.css">
    </head>
    <body>
        <c:set var="activePage" value="orders" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Profile Dashboard</h1>
                <p>Manage your profile, orders, wishlist, and checkout information from one place.</p>
            </div>
        </section>

        <main class="dashboard-shell">
            <div class="container">
                <div class="dashboard-grid">
                    <aside class="panel profile-card">
                        <div class="d-flex align-items-center gap-3">
                            <c:choose>
                                <c:when test="${not empty currentUser.image}">
                                    <img class="avatar" src="${currentUser.image}" alt="${currentUser.name}">
                                </c:when>
                                <c:otherwise>
                                    <div class="avatar-fallback">${fn:substring(currentUser.name, 0, 1)}</div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <h2 class="h5 fw-black mb-1">${currentUser.name}</h2>
                                <div class="text-muted small">@${currentUser.username}</div>
                            </div>
                        </div>

                        <div class="mt-4">
                            <span class="role-pill">
                                <i class="bi bi-shield-check"></i> ${currentRole}
                            </span>
                        </div>

                        <nav class="profile-menu">
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                            <a class="active" href="${pageContext.request.contextPath}/order-history">
                                <i class="bi bi-receipt"></i> Order History
                            </a>
                            <a href="${pageContext.request.contextPath}/wishlist">
                                <i class="bi bi-heart"></i> Wishlist
                            </a>
                            <a href="${pageContext.request.contextPath}/cart">
                                <i class="bi bi-bag"></i> Cart
                            </a>
                            <a href="${pageContext.request.contextPath}/change-password">
                                <i class="bi bi-shield-lock"></i> Change Password
                            </a>
                            <a href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </nav>
                    </aside>

                    <section>
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
                                    <c:if test="${not empty param.message}">
                                        <div class="alert-flash">
                                            <i class="bi bi-check-circle"></i>
                                            <span>${param.message}</span>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty param.error}">
                                        <div class="alert-flash error">
                                            <i class="bi bi-exclamation-circle"></i>
                                            <span>${param.error}</span>
                                        </div>
                                    </c:if>
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
                                                            <c:choose>
                                                                <c:when test="${o.status == 'COMPLETED' && !o.hasBlockingRefund}">
                                                                    <a class="review-btn" href="${pageContext.request.contextPath}/feedback?orderId=${o.id}">
                                                                        <i class="bi bi-star-fill"></i> Review
                                                                    </a>
                                                                </c:when>
                                                            </c:choose>
                                                            <c:choose>
                                                                <c:when test="${o.status == 'COMPLETED' && !o.hasOpenRefund}">
                                                                    <a class="refund-btn" href="${pageContext.request.contextPath}/return-request?orderId=${o.id}">
                                                                        <i class="bi bi-arrow-counterclockwise"></i> Refund
                                                                    </a>
                                                                </c:when>
                                                                <c:when test="${(o.status == 'DELIVERED' || o.status == 'COMPLETED') && o.hasOpenRefund}">
                                                                    <span class="refund-pending"><i class="bi bi-clock-history"></i> Refund pending</span>
                                                                </c:when>
                                                            </c:choose>
                                                            <c:choose>
                                                                <c:when test="${o.status == 'DELIVERED' && !o.hasOpenComplaint}">
                                                                    <form method="post" action="${pageContext.request.contextPath}/customer/complete-order" class="inline-form">
                                                                        <input type="hidden" name="orderId" value="${o.id}">
                                                                        <button type="submit" class="complete-btn"
                                                                                title="Mark this order as received & completed"
                                                                                onclick="return confirm('Mark this order as completed? You will then be able to review your products or request a refund.');">
                                                                            <i class="bi bi-check2-circle"></i> Completed
                                                                        </button>
                                                                    </form>
                                                                </c:when>
                                                            </c:choose>
                                                            <c:choose>
                                                                <c:when test="${o.status == 'DELIVERED' && !o.hasOpenComplaint}">
                                                                    <a class="complaint-btn" href="${pageContext.request.contextPath}/customer/complaint?orderId=${o.id}">
                                                                        <i class="bi bi-megaphone-fill"></i> Complaint
                                                                    </a>
                                                                </c:when>
                                                                <c:when test="${o.status == 'DELIVERED' && o.hasOpenComplaint}">
                                                                    <a class="complaint-btn open" href="${pageContext.request.contextPath}/customer/complaint?orderId=${o.id}">
                                                                        <i class="bi bi-chat-dots-fill"></i> View complaint
                                                                    </a>
                                                                </c:when>
                                                            </c:choose>
                                                            <c:choose>
                                                                <c:when test="${o.hasCancelPending}">
                                                                    <span class="cancel-pending"><i class="bi bi-clock-history"></i> Cancel pending</span>
                                                                </c:when>
                                                                <c:when test="${o.status != 'DELIVERED' && o.status != 'COMPLETED' && o.status != 'CANCELLED' && o.status != 'CANCEL_REQUESTED'}">
                                                                    <button type="button" class="cancel-btn"
                                                                            data-bs-toggle="modal"
                                                                            data-bs-target="#cancelOrderModal"
                                                                            data-order-id="${o.id}"
                                                                            data-order-code="${o.code}">
                                                                        <i class="bi bi-x-circle"></i> Cancel
                                                                    </button>
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
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>

        <div class="modal fade" id="cancelOrderModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content cancel-modal">
                    <form method="post" action="${pageContext.request.contextPath}/customer/cancel-request" id="cancelOrderForm">
                        <div class="modal-header">
                            <h5 class="modal-title">
                                <i class="bi bi-x-circle"></i> Request cancellation
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <p class="cancel-modal-sub">
                                You are about to request cancellation for order <strong id="cancelModalOrderCode">--</strong>.
                                Please pick a reason &mdash; our staff will review your request shortly.
                            </p>
                            <input type="hidden" name="orderId" id="cancelModalOrderId" value="">

                            <label class="cancel-modal-label">Reason</label>
                            <div class="cancel-reasons">
                                <label class="cancel-reason-option">
                                    <input type="radio" name="reason" value="CHANGED_MIND" required>
                                    <span class="cancel-reason-body">
                                        <i class="bi bi-emoji-frown"></i>
                                        <strong>Changed my mind</strong>
                                        <small>I no longer want this product.</small>
                                    </span>
                                </label>
                                <label class="cancel-reason-option">
                                    <input type="radio" name="reason" value="WRONG_PRODUCT">
                                    <span class="cancel-reason-body">
                                        <i class="bi bi-bag-x"></i>
                                        <strong>Ordered wrong product</strong>
                                        <small>I picked the wrong variant / model.</small>
                                    </span>
                                </label>
                                <label class="cancel-reason-option">
                                    <input type="radio" name="reason" value="FOUND_CHEAPER">
                                    <span class="cancel-reason-body">
                                        <i class="bi bi-tag"></i>
                                        <strong>Found a cheaper price</strong>
                                        <small>I found the same item cheaper elsewhere.</small>
                                    </span>
                                </label>
                                <label class="cancel-reason-option">
                                    <input type="radio" name="reason" value="LONG_DELIVERY">
                                    <span class="cancel-reason-body">
                                        <i class="bi bi-truck"></i>
                                        <strong>Delivery takes too long</strong>
                                        <small>Estimated delivery is too slow.</small>
                                    </span>
                                </label>
                                <label class="cancel-reason-option">
                                    <input type="radio" name="reason" value="OTHER">
                                    <span class="cancel-reason-body">
                                        <i class="bi bi-three-dots"></i>
                                        <strong>Other reason</strong>
                                        <small>Tell us more below.</small>
                                    </span>
                                </label>
                            </div>

                            <div class="cancel-other-wrap" id="cancelOtherWrap" hidden>
                                <label class="cancel-modal-label" for="cancelCustomReason">Tell us more</label>
                                <textarea class="cancel-other-input" name="customReason" id="cancelCustomReason"
                                          maxlength="500" rows="3"
                                          placeholder="Please describe your reason (max 500 characters)"></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Keep order</button>
                            <button type="submit" class="btn btn-danger">
                                <i class="bi bi-send"></i> Submit request
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (function () {
                var modal = document.getElementById('cancelOrderModal');
                if (!modal) {
                    return;
                }
                modal.addEventListener('show.bs.modal', function (event) {
                    var button = event.relatedTarget;
                    if (!button) {
                        return;
                    }
                    var orderId = button.getAttribute('data-order-id');
                    var orderCode = button.getAttribute('data-order-code');
                    document.getElementById('cancelModalOrderId').value = orderId || '';
                    document.getElementById('cancelModalOrderCode').textContent = orderCode || '';
                });

                var form = document.getElementById('cancelOrderForm');
                var otherWrap = document.getElementById('cancelOtherWrap');
                var others = form.querySelectorAll('input[name="reason"]');
                others.forEach(function (radio) {
                    radio.addEventListener('change', function () {
                        if (radio.value === 'OTHER' && radio.checked) {
                            otherWrap.hidden = false;
                        } else if (radio.value !== 'OTHER') {
                            otherWrap.hidden = true;
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
                        var text = document.getElementById('cancelCustomReason').value.trim();
                        if (!text) {
                            event.preventDefault();
                            document.getElementById('cancelCustomReason').focus();
                        }
                    }
                });
            })();
        </script>
    </body>
</html>
