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
                            <a href="${pageContext.request.contextPath}/checkout">
                                <i class="bi bi-bag-check"></i> Checkout
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
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
