<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
    <title>Business Overview</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <%@include file="../common/head.jsp"%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <style>
        body { background: #f5f6fa }
        .page-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
        }
        .page-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }
        .page-heading h1 { margin: 0; font-size: 28px; font-weight: 700; }
        .page-heading p { margin: 4px 0 0; color: var(--muted); }
        
        .filter-bar {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
            margin-bottom: 24px;
            padding: 18px 22px;
            background: #fff;
            border: 1px solid var(--line);
            border-radius: 17px;
        }
        .filter-bar .seg {
            display: inline-flex;
            background: var(--bg);
            border: 1px solid var(--line);
            border-radius: 11px;
            overflow: hidden
        }
        .filter-bar .seg a {
            padding: 10px 16px;
            color: var(--muted);
            font-weight: 600;
            font-size: 14px;
            border-right: 1px solid var(--line);
            text-decoration: none;
            transition: all 0.2s;
        }
        .filter-bar .seg a:last-child { border-right: none }
        .filter-bar .seg a:hover { background: #e8edf5 }
        .filter-bar .seg a.active {
            background: var(--blue);
            color: #fff
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        @media(max-width: 1200px) { .stats-grid { grid-template-columns: repeat(3, 1fr) } }
        @media(max-width: 768px) { .stats-grid { grid-template-columns: repeat(2, 1fr) } }
        
        .stat-card {
            background: #fff;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 2px 12px rgba(60,80,140,.06);
            position: relative;
            overflow: hidden
        }
        .stat-card .label {
            font-size: 11px;
            font-weight: 600;
            color: #7a87a6;
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-bottom: 8px
        }
        .stat-card .value {
            font-size: 20px;
            font-weight: 700;
            font-family: 'Roboto Slab', serif;
            color: #1f2940
        }
        .stat-card .icon {
            position: absolute;
            top: 16px;
            right: 16px;
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: grid;
            place-items: center;
            font-size: 18px
        }
        .icon.revenue { background: #eaf0ff; color: #4361ee }
        .icon.orders { background: #f0eaff; color: #7c3aed }
        .icon.products { background: #e8f7ee; color: #16a34a }
        .icon.avg { background: #fef3e2; color: #f59e0b }
        .icon.capital { background: #fff1e6; color: #f97316 }
        .icon.profit { background: #e8f7ee; color: #16a34a }
        .icon.loss { background: #fdecec; color: #dc2626 }
        .icon.refund { background: #fdecec; color: #dc2626 }
        .icon.sold { background: #f0eaff; color: #7c3aed }
        
        .card {
            background: #fff;
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 4px 24px rgba(60,80,140,.06);
            margin-bottom: 24px;
        }
        .card h2 {
            margin: 0 0 4px;
            font-size: 18px;
            font-weight: 700;
            font-family: 'Roboto Slab', serif
        }
        .card .sub {
            color: #7a87a6;
            font-size: 13px;
            margin-bottom: 20px
        }
        
        .chart-toggle {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
        }
        .chart-toggle button {
            padding: 8px 16px;
            border: 1px solid var(--line);
            background: #fff;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            color: var(--muted);
            cursor: pointer;
            transition: all 0.2s;
        }
        .chart-toggle button:hover { background: #f5f6fa }
        .chart-toggle button.active {
            background: var(--blue);
            color: #fff;
            border-color: var(--blue);
        }
        
        /* Brand Revenue Chart */
        .brand-chart-wrapper {
            padding: 20px 0;
            overflow-x: auto;
        }
        .brand-chart {
            display: flex;
            align-items: flex-end;
            justify-content: center;
            gap: 24px;
            min-height: 320px;
            padding: 0 10px;
        }
        .brand-bar-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            min-width: 80px;
        }
        .brand-bar-value {
            font-size: 12px;
            font-weight: 700;
            color: #4361ee;
            margin-bottom: 6px;
            font-family: 'Roboto Slab', serif;
        }
        .brand-bar {
            width: 60px;
            border-radius: 8px 8px 4px 4px;
            position: relative;
            transition: all 0.3s ease;
            cursor: pointer;
            min-height: 10px;
        }
        .brand-bar:hover {
            transform: scaleY(1.05);
            filter: brightness(1.1);
        }
        .brand-bar-tooltip {
            display: none;
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            background: #1f2940;
            color: #fff;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 12px;
            white-space: nowrap;
            z-index: 10;
            margin-bottom: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        }
        .brand-bar-tooltip::after {
            content: '';
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            border: 6px solid transparent;
            border-top-color: #1f2940;
        }
        .brand-bar:hover .brand-bar-tooltip {
            display: block;
        }
        .brand-bar-label {
            margin-top: 10px;
            font-size: 12px;
            font-weight: 600;
            color: #5b6577;
            text-align: center;
            max-width: 80px;
            word-wrap: break-word;
        }
        .chart-stats {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid #eef1f7;
        }
        .chart-stat {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 4px;
        }
        .chart-stat .stat-label {
            font-size: 11px;
            text-transform: uppercase;
            color: #7a87a6;
            letter-spacing: 0.5px;
        }
        .chart-stat .stat-value {
            font-size: 16px;
            font-weight: 700;
            color: #1f2940;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .data-table th,
        .data-table td {
            padding: 14px 16px;
            text-align: left;
            border-bottom: 1px solid #eef1f7;
        }
        .data-table th {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .5px;
            color: #7a87a6;
            background: #f8f9fc;
        }
        .data-table tr:hover td { background: #f8f9fc; }
        .data-table td { font-size: 14px; color: #1f2940; }
        .data-table .num {
            font-family: 'Roboto Slab', serif;
            font-weight: 700;
        }
        .data-table .revenue { color: #4361ee }
        .data-table .capital { color: #f97316 }
        .data-table .refund { color: #dc2626 }
        .data-table .profit-val { color: #16a34a; font-weight: 700; }
        .data-table .profit-val.negative { color: #dc2626 }
        .data-table .sold { color: #7c3aed }
        
        .rank-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 26px;
            height: 26px;
            border-radius: 50%;
            font-size: 11px;
            font-weight: 700;
        }
        .rank-badge.gold { background: #fff5e0; color: #d97706 }
        .rank-badge.silver { background: #f0f0f5; color: #64748b }
        .rank-badge.bronze { background: #fef0e6; color: #c2410c }
        
        .two-col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        @media(max-width: 1100px) { .two-col { grid-template-columns: 1fr } }
        
        .top-list { padding: 8px 0 }
        .top-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 14px 16px;
            border-top: 1px solid #eef1f7;
        }
        .top-item:first-child { border-top: none }
        .rank {
            display: grid;
            place-items: center;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #f0eaff;
            color: #7c3aed;
            font-weight: 700;
            font-size: 13px;
            flex-shrink: 0
        }
        .rank.gold { background: #fff5e0; color: #d97706 }
        .rank.silver { background: #f0f0f5; color: #64748b }
        .rank.bronze { background: #fef0e6; color: #c2410c }
        
        .top-info { flex: 1; min-width: 0 }
        .top-info strong { display: block; font-size: 14px; margin-bottom: 2px }
        .top-info small { color: var(--muted); font-size: 12px }
        
        .top-metrics {
            display: flex;
            gap: 16px;
            text-align: right;
        }
        .top-metrics div { display: flex; flex-direction: column }
        .top-metrics .lbl { color: var(--muted); font-size: 10px; text-transform: uppercase; }
        .top-metrics .val { font-weight: 700; font-size: 14px; }
        .top-metrics .val.price { color: var(--blue); font-family: 'Roboto Slab', serif }

        /* Filter Section */
        .filter-section {
            background: #fff;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .filter-group label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #7a87a6;
            letter-spacing: 0.5px;
        }
        .filter-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .filter-select {
            padding: 10px 14px;
            border: 1px solid #e3e8f1;
            border-radius: 8px;
            font-size: 14px;
            color: #1f2940;
            background: #fff;
            cursor: pointer;
            min-width: 100px;
        }
        .filter-select:focus {
            outline: none;
            border-color: #4361ee;
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
        }
        .filter-btn {
            padding: 10px 18px;
            background: #4361ee;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .filter-btn:hover {
            background: #3651d4;
            transform: translateY(-1px);
        }
    </style>
</head>
<body>
    <c:set var="activePage" value="manager" scope="request"/>
    <%@ include file="/views/common/header.jsp" %>

    <main class="page-shell">
        <div class="page-container">
            
            <div class="page-heading">
                <div>
                    <h1>📊 Business Overview</h1>
                    <p>Sales & revenue analysis
                        <c:choose>
                            <c:when test="${not empty param.month && not empty param.year}">
                                for ${param.month}/${param.year}
                            </c:when>
                            <c:when test="${param.range == '7d'}">
                                - Last 7 days
                            </c:when>
                            <c:when test="${param.range == '30d'}">
                                - Last 30 days
                            </c:when>
                            <c:otherwise>
                                - Today
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>

            <!-- Filter Section -->
            <div class="filter-section">
                <form method="get" action="${pageContext.request.contextPath}/manager/business-overview" class="custom-filter">
                    <div class="filter-group">
                        <label>Filter by Month & Year</label>
                        <div class="filter-controls">
                            <select name="month" class="filter-select">
                                <option value="">-- Month --</option>
                                <c:forEach begin="1" end="12" var="m">
                                    <option value="${m}" ${param.month == m ? 'selected' : ''}>${m}</option>
                                </c:forEach>
                            </select>
                            <select name="year" class="filter-select">
                                <option value="">-- Year --</option>
                                <c:forEach begin="2020" end="2026" var="y">
                                    <option value="${y}" ${param.year == y ? 'selected' : ''}>${y}</option>
                                </c:forEach>
                            </select>
                            <button type="submit" class="filter-btn">Apply</button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Overview Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="icon revenue">💰</div>
                    <div class="label">Total Revenue</div>
                    <div class="value"><fmt:formatNumber value="${totalRevenue}" pattern="#,##0"/>₫</div>
                </div>
                <div class="stat-card">
                    <div class="icon orders">🛒</div>
                    <div class="label">Total Orders</div>
                    <div class="value"><fmt:formatNumber value="${totalOrders}" pattern="#,##0"/></div>
                </div>
                <div class="stat-card">
                    <div class="icon sold">📱</div>
                    <div class="label">Products Sold</div>
                    <div class="value"><fmt:formatNumber value="${totalSold}" pattern="#,##0"/></div>
                </div>
                <div class="stat-card">
                    <div class="icon avg">📊</div>
                    <div class="label">Avg Order Value</div>
                    <div class="value"><fmt:formatNumber value="${avgOrderValue}" pattern="#,##0"/>₫</div>
                </div>
            </div>

            <!-- Brand Comparison Chart -->
            <section class="card">
                <h2>📊 Brand Revenue Comparison</h2>
                <p class="sub">Compare total revenue across brands</p>
                
                <c:choose>
                    <c:when test="${empty brandChartData}">
                        <div style="text-align: center; padding: 60px; color: var(--muted);">
                            No data available for this period
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="brand-chart-wrapper">
                            <div class="brand-chart">
                                <c:forEach items="${brandChartData}" var="brand" varStatus="st">
                                    <div class="brand-bar-container">
                                        <div class="brand-bar-value">
                                            <fmt:formatNumber value="${brand.revenue / 1000000}" pattern="#,##0"/>M
                                        </div>
                                        <div class="brand-bar" style="height: ${brand.revenueHeight}px; background: ${brand.barColor};">
                                            <div class="brand-bar-tooltip">
                                                <strong><c:out value="${brand.brandName}"/></strong><br>
                                                Revenue: <fmt:formatNumber value="${brand.revenue}" pattern="#,##0"/>₫<br>
                                                Sold: ${brand.soldQuantity} units
                                            </div>
                                        </div>
                                        <div class="brand-bar-label">
                                            <c:out value="${brand.brandName}"/>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                        <div class="chart-stats">
                            <div class="chart-stat">
                                <span class="stat-label">Total Brands</span>
                                <span class="stat-value">${brandChartData.size()}</span>
                            </div>
                            <div class="chart-stat">
                                <span class="stat-label">Top Brand</span>
                                <span class="stat-value">${not empty brandChartData ? brandChartData[0].brandName : '-'}</span>
                            </div>
                            <div class="chart-stat">
                                <span class="stat-label">Highest Revenue</span>
                                <span class="stat-value"><fmt:formatNumber value="${not empty brandChartData ? brandChartData[0].revenue : 0}" pattern="#,##0"/>₫</span>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <!-- Top Products & Top Brands -->
            <div class="two-col">
                <section class="card">
                    <h2>🏆 Top Selling Products</h2>
                    <p class="sub">Best 10 products in selected period</p>
                    
                    <c:choose>
                        <c:when test="${empty topProducts}">
                            <div style="text-align: center; padding: 40px; color: var(--muted);">
                                No product sales data
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="top-list">
                                <c:forEach items="${topProducts}" var="p" varStatus="st">
                                    <div class="top-item">
                                        <div class="rank ${st.count==1?'gold':(st.count==2?'silver':(st.count==3?'bronze':''))}">${st.count}</div>
                                        <div class="top-info">
                                            <strong><c:out value="${p.productName}"/></strong>
                                            <small><c:out value="${p.variantLabel}"/> ${p.brandName != null ? ' · '.concat(p.brandName) : ''}</small>
                                        </div>
                                        <div class="top-metrics">
                                            <div><span class="lbl">Sold</span><span class="val"><c:out value="${p.soldQuantity}"/></span></div>
                                            <div><span class="lbl">Revenue</span><span class="val price"><fmt:formatNumber value="${p.revenue}" pattern="#,##0"/>₫</span></div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>

                <section class="card">
                    <h2>🏷️ Top Brands by Revenue</h2>
                    <p class="sub">Brand ranking by total revenue</p>
                    
                    <c:choose>
                        <c:when test="${empty brandSummary}">
                            <div style="text-align: center; padding: 40px; color: var(--muted);">
                                No brand data
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:set var="maxBrandRev" value="0"/>
                            <c:forEach items="${brandSummary}" var="b">
                                <c:if test="${b.revenue.doubleValue() > maxBrandRev}">
                                    <c:set var="maxBrandRev" value="${b.revenue.doubleValue()}"/>
                                </c:if>
                            </c:forEach>
                            <div class="top-list">
                                <c:forEach items="${brandSummary}" var="b" varStatus="st">
                                    <c:set var="w" value="${maxBrandRev > 0 ? (b.revenue.doubleValue() * 100 / maxBrandRev) : 0}"/>
                                    <div class="top-item">
                                        <div class="rank ${st.count==1?'gold':(st.count==2?'silver':(st.count==3?'bronze':''))}">${st.count}</div>
                                        <div class="top-info">
                                            <strong><c:out value="${b.brandName}"/></strong>
                                            <small><c:out value="${b.soldQuantity}"/> units sold</small>
                                        </div>
                                        <div class="top-metrics">
                                            <div style="width: 120px;">
                                                <div class="lbl">Revenue</div>
                                                <div class="val price"><fmt:formatNumber value="${b.revenue}" pattern="#,##0"/>₫</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div style="padding: 0 16px 12px;">
                                        <div style="height: 6px; background: #e3e8f1; border-radius: 3px; overflow: hidden;">
                                            <div style="height: 100%; width: ${w}%; background: linear-gradient(90deg, #4361ee, #5d8ffc); border-radius: 3px;"></div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>
            </div>

        </div>
    </main>

    <%@ include file="/views/common/footer.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
