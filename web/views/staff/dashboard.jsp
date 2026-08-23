<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Staff Center</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <%@include file="../common/head.jsp"%>
    </head>
    <body>
        <c:set var="activePage" value="staff-dashboard" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell manager-dashboard staff-dashboard">
            <!-- Welcome banner -->
            <section class="staff-welcome">
                <div>
                    <span class="staff-kicker">STAFF CENTER</span>
                    <h1>Welcome back, <c:out value="${currentUser.name}"/>.</h1>
                    <p>Process customer orders, update order statuses and keep the fulfillment queue moving — all from one workspace.</p>
                </div>
                <a class="btn subtle staff-preview" href="${pageContext.request.contextPath}/home">
                    View storefront →
                </a>
            </section>

            <!-- Top summary: 4 KPI cards -->
            <section class="manager-summary-grid">
                <article>
                    <span class="summary-icon teal">&#128722;</span>
                    <div><small>TODAY'S ORDERS</small><strong>${totalToday}</strong></div>
                    <em>New orders to process</em>
                </article>
                <article>
                    <span class="summary-icon indigo">&#9881;</span>
                    <div><small>PROCESSING</small><strong>${totalProcessing}</strong></div>
                    <em>In the fulfillment queue</em>
                </article>
                <article>
                    <span class="summary-icon green">&#10003;</span>
                    <div><small>DELIVERED</small><strong>${totalDelivered}</strong></div>
                    <em>Successfully completed</em>
                </article>
                <article>
                    <span class="summary-icon pink">&#10006;</span>
                    <div><small>CANCELLED</small><strong>${totalCancelled}</strong></div>
                    <em>Requires review</em>
                </article>
            </section>

            <!-- Module navigation -->
            <div class="manager-section-title">
                <span>YOUR WORKSPACE</span>
                <h2>What would you like to do?</h2>
            </div>

            <section class="manager-module-grid staff-module-grid">
                <a class="manager-module order-module" href="${pageContext.request.contextPath}/staff/orders">
                    <span class="module-icon">&#128722;</span>
                    <span class="module-count">${totalToday} today</span>
                    <h3>Manage Orders</h3>
                    <p>Search, review and process customer orders. Update statuses from PENDING through DELIVERED.</p>
                    <b>Open order queue <span>→</span></b>
                </a>
            </section>

            <!-- Operational snapshots -->
            <div class="manager-section-title">
                <span>QUICK PULSE</span>
                <h2>Recent activity</h2>
            </div>

            <div class="manager-snapshot-grid">
                <!-- Recent orders -->
                <section class="snapshot-card">
                    <header>
                        <div>
                            <h3>Recent Orders</h3>
                            <p>${totalToday} placed today · ${totalProcessing} processing</p>
                        </div>
                        <a class="btn subtle" href="${pageContext.request.contextPath}/staff/orders">View all →</a>
                    </header>
                    <c:choose>
                        <c:when test="${empty recentOrders}">
                            <div class="empty-state"><p>No orders yet.</p></div>
                        </c:when>
                        <c:otherwise>
                            <ul class="snapshot-list">
                                <c:forEach items="${recentOrders}" var="o">
                                    <li>
                                        <div class="snapshot-main">
                                            <strong class="mono">${o.code}</strong>
                                            <span class="status status-${o.status.toLowerCase()}">${o.status}</span>
                                        </div>
                                        <div class="snapshot-meta">
                                            <small><c:out value="${o.userName}"/> · <fmt:formatDate value="${o.createdAt}" pattern="dd/MM HH:mm"/></small>
                                            <b><fmt:formatNumber value="${o.totalPrice}" pattern="#,##0"/>&nbsp;₫</b>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </section>

                <!-- Status breakdown -->
                <section class="snapshot-card">
                    <header>
                        <div>
                            <h3>Status Breakdown</h3>
                            <p>Snapshot of the order pipeline right now</p>
                        </div>
                        <a class="btn subtle" href="${pageContext.request.contextPath}/staff/orders">Manage →</a>
                    </header>
                    <ul class="snapshot-list">
                        <li>
                            <div class="snapshot-main">
                                <strong>Pending</strong>
                                <span class="snapshot-qty">awaiting</span>
                            </div>
                            <div class="snapshot-meta">
                                <small>New orders to confirm</small>
                            </div>
                        </li>
                        <li>
                            <div class="snapshot-main">
                                <strong>Processing</strong>
                                <span class="snapshot-qty">${totalProcessing}</span>
                            </div>
                            <div class="snapshot-meta">
                                <small>Being packed &amp; prepared</small>
                            </div>
                        </li>
                        <li>
                            <div class="snapshot-main">
                                <strong>Delivered</strong>
                                <span class="snapshot-qty">${totalDelivered}</span>
                            </div>
                            <div class="snapshot-meta">
                                <small>Completed successfully</small>
                            </div>
                        </li>
                        <li>
                            <div class="snapshot-main">
                                <strong>Cancelled</strong>
                                <span class="snapshot-qty">${totalCancelled}</span>
                            </div>
                            <div class="snapshot-meta">
                                <small>Review &amp; follow up</small>
                            </div>
                        </li>
                    </ul>
                </section>
            </div>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
