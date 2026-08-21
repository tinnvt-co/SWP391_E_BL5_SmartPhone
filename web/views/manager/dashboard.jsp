<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Management Center</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell manager-dashboard">
            <!-- Welcome banner -->
            <section class="manager-welcome">
                <div>
                    <span class="manager-kicker">MANAGEMENT CENTER</span>
                    <h1>Welcome back, <c:out value="${currentUser.name}"/>.</h1>
                    <p>Run your smartphone catalog, monitor inventory, track orders and review revenue — all from one workspace.</p>
                </div>
                <div class="manager-welcome-actions">
                    <a class="manager-profile-chip" href="${pageContext.request.contextPath}/profile" title="View profile">
                        <span class="manager-profile-avatar"><c:out value="${currentUser.name.substring(0,1).toUpperCase()}"/></span>
                        <span class="manager-profile-meta">
                            <strong><c:out value="${currentUser.name}"/></strong>
                            <small><i class="bi bi-person-circle"></i> My profile</small>
                        </span>
                    </a>
                    <a class="btn subtle manager-preview" href="${pageContext.request.contextPath}/home">
                        View storefront →
                    </a>
                </div>
            </section>

            <!-- Top summary: 8 KPI cards -->
            <section class="manager-summary-grid">
                <article>
                    <span class="summary-icon blue">▦</span>
                    <div><small>TOTAL PRODUCTS</small><strong>${totalProducts}</strong></div>
                    <em>${activeProducts} active</em>
                </article>
                <article>
                    <span class="summary-icon green">✓</span>
                    <div><small>ACTIVE PRODUCTS</small><strong>${activeProducts}</strong></div>
                    <em>Visible in the storefront</em>
                </article>
                <article>
                    <span class="summary-icon orange">!</span>
                    <div><small>OUT OF STOCK</small><strong>${outOfStockProducts}</strong></div>
                    <em>Require attention</em>
                </article>
                <article>
                    <span class="summary-icon purple">◇</span>
                    <div><small>CATALOG STRUCTURE</small><strong>${totalCategories + totalBrands}</strong></div>
                    <em>${totalCategories} categories · ${totalBrands} brands</em>
                </article>

                <article>
                    <span class="summary-icon indigo">📦</span>
                    <div><small>INVENTORY SKUs</small><strong>${stockStats[0]}</strong></div>
                    <em>${stockStats[2]} low · ${stockStats[3]} out</em>
                </article>
                <article>
                    <span class="summary-icon pink">%</span>
                    <div><small>ACTIVE DISCOUNTS</small><strong>${activeDiscounts}</strong></div>
                    <em>${totalDiscounts} total campaigns</em>
                </article>
                <article>
                    <span class="summary-icon teal">🛒</span>
                    <div><small>TODAY'S ORDERS</small><strong>${todayOrders}</strong></div>
                    <em><fmt:formatNumber value="${todayRevenue}" pattern="#,##0"/>₫ revenue</em>
                </article>
                <article>
                    <span class="summary-icon amber">📈</span>
                    <div><small>TOTAL REVENUE</small><strong><fmt:formatNumber value="${totalRevenue}" pattern="#,##0"/>₫</strong></div>
                    <em>${totalDelivered} delivered · ${totalProcessing} processing</em>
                </article>
            </section>

            <!-- Module navigation: 13 cards -->
            <div class="manager-section-title">
                <span>YOUR WORKSPACE</span>
                <h2>What would you like to manage?</h2>
            </div>

            <section class="manager-module-grid">
                <a class="manager-module product-module" href="${pageContext.request.contextPath}/manager/products">
                    <span class="module-icon">▦</span>
                    <span class="module-count">${totalProducts} products</span>
                    <h3>Manage Products</h3>
                    <p>Add smartphones and update specifications, variants, prices, stock and product images.</p>
                    <b>Open product management <span>→</span></b>
                </a>

                <a class="manager-module category-module" href="${pageContext.request.contextPath}/manager/categories">
                    <span class="module-icon">◇</span>
                    <span class="module-count">${totalCategories} categories</span>
                    <h3>Manage Categories</h3>
                    <p>Organize phones by features such as gaming, foldable, AI and camera phone.</p>
                    <b>Open category management <span>→</span></b>
                </a>

                <a class="manager-module brand-module" href="${pageContext.request.contextPath}/manager/brands">
                    <span class="module-icon">◎</span>
                    <span class="module-count">${totalBrands} brands</span>
                    <h3>Manage Brands</h3>
                    <p>Maintain smartphone manufacturers and control which brands appear in the store.</p>
                    <b>Open brand management <span>→</span></b>
                </a>

                <a class="manager-module supplier-module"
                   href="${pageContext.request.contextPath}/manager/supplier">
                    <span class="module-icon">🏢</span>
                    <span class="module-count">${totalSuppliers} suppliers</span>
                    <h3>Manage Suppliers</h3>
                    <p>
                        Manage suppliers, contact information
                        and the product variants they provide.
                    </p>
                    <b>
                        Open supplier management
                        <span>→</span>
                    </b>
                </a>

                <a class="manager-module inventory-module" href="${pageContext.request.contextPath}/manager/inventory">
                    <span class="module-icon">📦</span>
                    <span class="module-count">${stockStats[0]} SKUs</span>
                    <h3>Manage Inventory</h3>
                    <p>Track stock levels per variant, perform stock-in, adjustments and monitor low-stock alerts.</p>
                    <b>Open inventory <span>→</span></b>
                </a>
                    
                <a class="manager-module import-module" href="${pageContext.request.contextPath}/manager/import">
                    <span class="module-icon">📦</span>
                    <span class="module-count">${totalImportOrder} Import</span>
                    <h3>Manage Import</h3>
                    <p>Create, view import order, tracking import status</p>
                    <b>Open import management<span>→</span></b>
                </a>

                <a class="manager-module discount-module" href="${pageContext.request.contextPath}/manager/discounts">
                    <span class="module-icon">%</span>
                    <span class="module-count">${activeDiscounts} active</span>
                    <h3>Manage Discounts</h3>
                    <p>Create promotional campaigns, set percentage rates and define start/end dates.</p>
                    <b>Open discount management <span>→</span></b>
                </a>

                <a class="manager-module discount-module" href="${pageContext.request.contextPath}/manager/vouchers">
                    <span class="module-icon">🎟️</span>
                    <span class="module-count">Vouchers</span>
                    <h3>Manage Vouchers</h3>
                    <p>Create and manage discount codes that customers can save and apply during checkout.</p>
                    <b>Open voucher management <span>→</span></b>
                </a>

                <a class="manager-module order-module" href="${pageContext.request.contextPath}/manager/orders">
                    <span class="module-icon">🛒</span>
                    <span class="module-count">${todayOrders} today</span>
                    <h3>Manage Orders</h3>
                    <p>Search, review and process customer orders, imports and refunds in one queue.</p>
                    <b>Open order queue <span>→</span></b>
                </a>

                <a class="manager-module stats-module" href="${pageContext.request.contextPath}/manager/sales-stats">
                    <span class="module-icon">📊</span>
                    <span class="module-count">12 month view</span>
                    <h3>Sales Statistics</h3>
                    <p>Compare revenue, orders and items sold across 7 days, 30 days, month, 90 days or 12 months.</p>
                    <b>Open sales stats <span>→</span></b>
                </a>

                <a class="manager-module feedback-module" href="${pageContext.request.contextPath}/manager/feedback">
                    <span class="module-icon">⭐</span>
                    <span class="module-count">Customer voices</span>
                    <h3>Customer Reviews</h3>
                    <p>Read what shoppers are saying and reply to keep the conversation going.</p>
                    <b>Open review queue <span>→</span></b>
                </a>

                <a class="manager-module complaint-module" href="${pageContext.request.contextPath}/manager/complaint">
                    <span class="module-icon">⚠️</span>
                    <span class="module-count">${pendingComplaints} pending</span>
                    <h3>Customer Complaints</h3>
                    <p>Review customer-submitted complaints, track resolution status and reply to keep service quality high.</p>
                    <b>Open complaint queue <span>→</span></b>
                </a>

                <a class="manager-module cancel-module" href="${pageContext.request.contextPath}/manager/cancel-request">
                    <span class="module-icon">🚫</span>
                    <span class="module-count">${totalPending} pending</span>
                    <h3>Cancel Requests</h3>
                    <p>Approve or reject customer cancellation requests and keep order statuses in sync.</p>
                    <b>Open cancel queue <span>→</span></b>
                </a>

                <a class="manager-module refund-module" href="${pageContext.request.contextPath}/manager/return-request">
                    <span class="module-icon">↩️</span>
                    <span class="module-count">${pendingRefunds} pending</span>
                    <h3>Refund Requests</h3>
                    <p>Approve or reject customer refund requests for delivered orders and view attached evidence.</p>
                    <b>Open refund queue <span>→</span></b>
                </a>

                <a class="manager-module revenue-module" href="${pageContext.request.contextPath}/manager/revenue">
                    <span class="module-icon">💰</span>
                    <span class="module-count">live today</span>
                    <h3>Revenue Dashboard</h3>
                    <p>Track today's revenue, hourly performance, top products, brands and channels in real time.</p>
                    <b>Open revenue dashboard <span>→</span></b>
                </a>
            </section>

            <!-- Operational snapshots -->
            <div class="manager-section-title">
                <span>QUICK PULSE</span>
                <h2>Operational snapshots</h2>
            </div>

            <div class="manager-snapshot-grid">
                <!-- Recent orders -->
                <section class="snapshot-card">
                    <header>
                        <div>
                            <h3>Recent Orders</h3>
                            <p>${totalToday} placed today · ${totalProcessing} processing</p>
                        </div>
                        <a class="btn subtle" href="${pageContext.request.contextPath}/manager/orders">View all →</a>
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
                                            <b><fmt:formatNumber value="${o.totalPrice}" pattern="#,##0"/>₫</b>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </section>

                <!-- Low stock -->
                <section class="snapshot-card">
                    <header>
                        <div>
                            <h3>Low &amp; Out of Stock</h3>
                            <p>${stockStats[2]} low · ${stockStats[3]} out of stock</p>
                        </div>
                        <a class="btn subtle" href="${pageContext.request.contextPath}/manager/inventory?status=LOW">View all →</a>
                    </header>
                    <c:choose>
                        <c:when test="${empty lowStockItems}">
                            <div class="empty-state"><p>All variants are well-stocked.</p></div>
                        </c:when>
                        <c:otherwise>
                            <ul class="snapshot-list">
                                <c:forEach items="${lowStockItems}" var="s">
                                    <li>
                                        <div class="snapshot-main">
                                            <strong><c:out value="${s.productName}"/></strong>
                                            <span class="status ${s.stock<=0?'cancelled':'status-low'}">
                                                ${s.stock<=0?'OUT':'LOW'} · ${s.stock}
                                            </span>
                                        </div>
                                        <div class="snapshot-meta">
                                            <small><c:out value="${s.brandName}"/> · ${s.memoryLabel} · <c:out value="${s.colorName}"/></small>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </section>

                <!-- Top selling products -->
                <section class="snapshot-card">
                    <header>
                        <div>
                            <h3>Top Sellers (30d)</h3>
                            <p>Best 5 variants by quantity sold</p>
                        </div>
                        <a class="btn subtle" href="${pageContext.request.contextPath}/manager/sales-stats?range=30">View stats →</a>
                    </header>
                    <c:choose>
                        <c:when test="${empty topProducts}">
                            <div class="empty-state"><p>No sales in the last 30 days.</p></div>
                        </c:when>
                        <c:otherwise>
                            <ul class="snapshot-list">
                                <c:forEach items="${topProducts}" var="p" varStatus="st">
                                    <li>
                                        <div class="snapshot-main">
                                            <strong>#${st.count} <c:out value="${p.productName}"/></strong>
                                            <span class="snapshot-qty">${p.soldQuantity} sold</span>
                                        </div>
                                        <div class="snapshot-meta">
                                            <small><c:out value="${p.variantLabel}"/><c:if test="${not empty p.brandName}"> · <c:out value="${p.brandName}"/></c:if></small>
                                            <b><fmt:formatNumber value="${p.revenue}" pattern="#,##0"/>₫</b>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </section>

                <!-- Active discounts -->
                <section class="snapshot-card">
                    <header>
                        <div>
                            <h3>Active Discounts</h3>
                            <p>${activeDiscounts} campaigns running</p>
                        </div>
                        <a class="btn subtle" href="${pageContext.request.contextPath}/manager/discounts">Manage →</a>
                    </header>
                    <c:choose>
                        <c:when test="${empty activeDiscountList}">
                            <div class="empty-state"><p>No active discount campaigns.</p></div>
                        </c:when>
                        <c:otherwise>
                            <ul class="snapshot-list discount-list">
                                <c:forEach items="${activeDiscountList}" var="d">
                                    <li>
                                        <div class="snapshot-main">
                                            <strong><c:out value="${d.name}"/></strong>
                                            <span class="discount-pill"><fmt:formatNumber value="${d.rate}" pattern="0.##"/>%</span>
                                        </div>
                                        <div class="snapshot-meta">
                                            <small>${d.productCount} products · <fmt:formatDate value="${d.end}" pattern="dd/MM/yyyy"/></small>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </section>
            </div>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
