<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Staff Center</title>
        <%@include file="../common/head.jsp"%>
    </head>
    <body>
        <c:set var="pageRole" value="Staff"/>
        <c:set var="pageName" value="Dashboard"/>
        <%@include file="../common/topbar.jsp"%>

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

                <a class="manager-module order-module" href="${pageContext.request.contextPath}/staff/orders?status=PENDING">
                    <span class="module-icon">&#9201;</span>
                    <span class="module-count">PENDING</span>
                    <h3>Pending Orders</h3>
                    <p>Jump straight to the orders waiting for confirmation and start the fulfillment flow.</p>
                    <b>Review pending <span>→</span></b>
                </a>

                <a class="manager-module order-module" href="${pageContext.request.contextPath}/staff/orders?status=PROCESSING">
                    <span class="module-icon">&#9881;</span>
                    <span class="module-count">PROCESSING</span>
                    <h3>Processing Orders</h3>
                    <p>Track orders currently being packed and prepared for shipment.</p>
                    <b>Continue processing <span>→</span></b>
                </a>

                <a class="manager-module order-module" href="${pageContext.request.contextPath}/staff/orders?status=SHIPPING">
                    <span class="module-icon">&#128666;</span>
                    <span class="module-count">SHIPPING</span>
                    <h3>Shipping Orders</h3>
                    <p>Monitor orders handed off to shippers and confirm delivery with customers.</p>
                    <b>Check shipping <span>→</span></b>
                </a>

                <a class="manager-module profile-module" href="${pageContext.request.contextPath}/profile">
                    <span class="module-icon">&#128100;</span>
                    <span class="module-count">account</span>
                    <h3>My Profile</h3>
                    <p>View and update your personal information, contact details and delivery address.</p>
                    <b>Open profile <span>→</span></b>
                </a>

                <a class="manager-module profile-module" href="${pageContext.request.contextPath}/change-password">
                    <span class="module-icon">&#128274;</span>
                    <span class="module-count">security</span>
                    <h3>Change Password</h3>
                    <p>Keep your account secure by rotating your password regularly.</p>
                    <b>Update password <span>→</span></b>
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
    </body>
</html>