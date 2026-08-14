<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Revenue Dashboard</title><link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body{
                background:#f5f6fa
            }
            .dash-shell{
                display:grid;
                grid-template-columns:280px 1fr;
                gap:24px;
                padding:24px;
                max-width:1600px;
                margin:0 auto
            }
            .sidebar{
                background:#fff;
                border-radius:18px;
                padding:24px;
                height:fit-content;
                position:sticky;
                top:24px;
                box-shadow:0 4px 24px rgba(60,80,140,.06)
            }
            .sidebar h3{
                margin:0 0 6px;
                font-size:18px;
                font-weight:700;
                font-family:'Roboto Slab',serif
            }
            .sidebar p.sub{
                color:#7a87a6;
                font-size:13px;
                margin:0 0 20px
            }
            .filter-group{
                margin-bottom:18px
            }
            .filter-group label{
                display:block;
                font-size:12px;
                font-weight:600;
                color:#5b6577;
                margin-bottom:6px;
                text-transform:uppercase;
                letter-spacing:.5px
            }
            .filter-group select,.filter-group input{
                width:100%;
                padding:10px 12px;
                border:1px solid #e3e8f1;
                border-radius:10px;
                font-size:14px;
                background:#fff;
                color:#1f2940;
                font-family:inherit;
                outline:none
            }
            .filter-group select:focus,.filter-group input:focus{
                border-color:var(--blue)
            }
            .btn-apply{
                display:block;
                width:100%;
                padding:12px;
                background:var(--blue);
                color:#fff;
                border:none;
                border-radius:10px;
                font-weight:600;
                font-size:14px;
                cursor:pointer;
                margin-top:8px
            }
            .btn-apply:hover{
                background:#2b5db8
            }
            .stat-grid{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:20px;
                margin-bottom:24px
            }
            @media(max-width:1100px){
                .stat-grid{
                    grid-template-columns:repeat(2,1fr)
                }
            }
            .stat-card{
                background:#fff;
                border-radius:18px;
                padding:22px;
                box-shadow:0 4px 24px rgba(60,80,140,.06);
                position:relative;
                overflow:hidden
            }
            .stat-card .label{
                font-size:12px;
                font-weight:600;
                color:#7a87a6;
                text-transform:uppercase;
                letter-spacing:.5px;
                margin-bottom:10px
            }
            .stat-card .value{
                font-size:26px;
                font-weight:700;
                font-family:'Roboto Slab',serif;
                color:#1f2940
            }
            .stat-card .delta{
                font-size:13px;
                font-weight:600;
                margin-top:8px;
                display:inline-flex;
                align-items:center;
                gap:4px;
                padding:3px 8px;
                border-radius:6px
            }
            .stat-card .delta.up{
                background:#e8f7ee;
                color:#16a34a
            }
            .stat-card .delta.down{
                background:#fdecec;
                color:#dc2626
            }
            .stat-card .delta.flat{
                background:#eef1f7;
                color:#7a87a6
            }
            .stat-card .icon{
                position:absolute;
                top:22px;
                right:22px;
                width:44px;
                height:44px;
                border-radius:12px;
                display:grid;
                place-items:center;
                font-size:20px
            }
            .icon.blue{
                background:#eaf0ff;
                color:#4361ee
            }
            .icon.green{
                background:#e8f7ee;
                color:#16a34a
            }
            .icon.purple{
                background:#f0eaff;
                color:#7c3aed
            }
            .icon.orange{
                background:#fff1e6;
                color:#f97316
            }
            .dash-main{
                display:flex;
                flex-direction:column;
                gap:24px
            }
            .chart-card{
                background:#fff;
                border-radius:18px;
                padding:26px;
                box-shadow:0 4px 24px rgba(60,80,140,.06)
            }
            .chart-card .head{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:18px;
                flex-wrap:wrap;
                gap:14px
            }
            .chart-card h2{
                margin:0;
                font-size:20px;
                font-weight:700;
                font-family:'Roboto Slab',serif
            }
            .chart-card .sub{
                color:#7a87a6;
                font-size:13px;
                margin-top:4px
            }
            .chart-tabs{
                display:inline-flex;
                background:#f5f6fa;
                border:1px solid #e3e8f1;
                border-radius:10px;
                padding:4px;
                gap:2px
            }
            .chart-tabs button{
                padding:8px 16px;
                border:none;
                background:transparent;
                color:#5b6577;
                font-weight:600;
                font-size:13px;
                border-radius:8px;
                cursor:pointer;
                font-family:inherit
            }
            .chart-tabs button.active{
                background:#fff;
                color:var(--blue);
                box-shadow:0 2px 8px rgba(60,80,140,.08)
            }
            .chart-area{
                height:280px;
                display:flex;
                align-items:flex-end;
                gap:6px;
                padding:16px 0 0;
                position:relative
            }
            .chart-area .col{
                flex:1;
                display:flex;
                flex-direction:column;
                align-items:center;
                gap:6px;
                height:100%
            }
            .chart-area .bar{
                width:100%;
                background:linear-gradient(180deg,#6594f1,#4361ee);
                border-radius:6px 6px 0 0;
                min-height:3px;
                position:relative;
                transition:.2s
            }
            .chart-area .bar:hover{
                background:linear-gradient(180deg,#7da4f4,#3457d4)
            }
            .chart-area .bar.zero{
                background:#e3e8f1
            }
            .chart-area .bar .tip{
                position:absolute;
                top:-26px;
                left:50%;
                transform:translateX(-50%);
                background:#1f2940;
                color:#fff;
                padding:3px 8px;
                border-radius:6px;
                font-size:11px;
                white-space:nowrap;
                opacity:0;
                pointer-events:none;
                transition:.15s
            }
            .chart-area .bar:hover .tip{
                opacity:1
            }
            .chart-axis{
                display:flex;
                gap:6px;
                padding-top:10px;
                color:#7a87a6;
                font-size:11px
            }
            .chart-axis span{
                flex:1;
                text-align:center
            }
            .two-col{
                display:grid;
                grid-template-columns:1.4fr 1fr;
                gap:24px
            }
            @media(max-width:1200px){
                .two-col{
                    grid-template-columns:1fr
                }
            }
            .txn-list{
                display:flex;
                flex-direction:column
            }
            .txn-row{
                display:flex;
                align-items:center;
                gap:14px;
                padding:14px 0;
                border-top:1px solid #eef1f7
            }
            .txn-row:first-child{
                border-top:none
            }
            .txn-row .avatar{
                width:42px;
                height:42px;
                border-radius:50%;
                background:#eaf0ff;
                color:#4361ee;
                display:grid;
                place-items:center;
                font-weight:700;
                font-size:14px;
                flex-shrink:0
            }
            .txn-row .info{
                flex:1;
                min-width:0
            }
            .txn-row .info strong{
                display:block;
                font-size:14px;
                color:#1f2940
            }
            .txn-row .info small{
                color:#7a87a6;
                font-size:12px
            }
            .txn-row .amount{
                font-weight:700;
                font-family:'Roboto Slab',serif;
                color:#1f2940
            }
            .channel-list{
                display:flex;
                flex-direction:column;
                gap:14px;
                padding-top:8px
            }
            .channel-row{
                display:flex;
                align-items:center;
                gap:14px
            }
            .channel-row .name{
                width:100px;
                font-weight:600;
                font-size:14px
            }
            .channel-row .track{
                flex:1;
                height:10px;
                background:#f5f6fa;
                border-radius:6px;
                overflow:hidden
            }
            .channel-row .fill{
                height:100%;
                background:linear-gradient(90deg,#4361ee,#5d8ffc);
                border-radius:6px
            }
            .channel-row .pct{
                width:80px;
                text-align:right;
                font-weight:600;
                color:#4361ee;
                font-family:'Roboto Slab',serif
            }
            .top-products-grid{
                display:grid;
                grid-template-columns:1fr;
                gap:10px;
                padding-top:8px
            }
            .tp{
                display:flex;
                align-items:center;
                gap:14px;
                padding:10px;
                border-radius:10px;
                background:#f8f9fc
            }
            .tp .rank{
                width:30px;
                height:30px;
                border-radius:50%;
                background:#eaf0ff;
                color:#4361ee;
                display:grid;
                place-items:center;
                font-weight:700;
                font-size:13px;
                flex-shrink:0
            }
            .tp .rank.gold{
                background:#fff5e0;
                color:#d97706
            }
            .tp .rank.silver{
                background:#f0f0f5;
                color:#64748b
            }
            .tp .rank.bronze{
                background:#fef0e6;
                color:#c2410c
            }
            .tp .info{
                flex:1;
                min-width:0
            }
            .tp .info strong{
                display:block;
                font-size:13px;
                color:#1f2940;
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap
            }
            .tp .info small{
                color:#7a87a6;
                font-size:11px
            }
            .tp .rev{
                font-weight:700;
                font-size:13px;
                color:#4361ee;
                font-family:'Roboto Slab',serif
            }
            @media(max-width:900px){
                .dash-shell{
                    grid-template-columns:1fr
                }
                .sidebar{
                    position:static
                }
            }
        </style>
    </head><body><c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <div class="dash-shell">

            <aside class="sidebar">
                <h3>🔍 Filters</h3>
                <p class="sub">Customize the dashboard view</p>

                <form method="get" action="${pageContext.request.contextPath}/manager/revenue">
                    <div class="filter-group">
                        <label>Date Range</label>
                        <select name="range">
                            <option value="today" selected>Today</option>
                            <option value="7d">Last 7 days</option>
                            <option value="30d">Last 30 days</option>
                            <option value="month">This month</option>
                            <option value="year">This year</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label>From Date</label>
                        <input type="date" name="from" value="${today}"/>
                    </div>
                    <div class="filter-group">
                        <label>To Date</label>
                        <input type="date" name="to" value="${today}"/>
                    </div>

                    <div class="filter-group">
                        <label>Channel</label>
                        <select name="channel">
                            <option value="">All channels</option>
                            <c:forEach items="${channels}" var="ch">
                                <option value="${ch.channel}"><c:out value="${ch.channel}"/></option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label>Order Status</label>
                        <select name="status">
                            <option value="">All status</option>
                            <option value="COMPLETED">Completed</option>
                            <option value="SHIPPING">Shipping</option>
                            <option value="DELIVERED">Delivered</option>
                        </select>
                    </div>

                    <button class="btn-apply" type="submit">Apply Filters</button>
                </form>
            </aside>

            <div class="dash-main">

                <div class="stat-grid">
                    <div class="stat-card">
                        <div class="icon blue">💰</div>
                        <div class="label">Total Revenue</div>
                        <div class="value"><fmt:formatNumber value="${todayRevenue}" pattern="#,##0"/>₫</div>
                        <c:choose>
                            <c:when test="${revChange.doubleValue()>0}"><span class="delta up">▲ ${revChange}%</span></c:when>
                            <c:when test="${revChange.doubleValue()<0}"><span class="delta down">▼ <fmt:formatNumber value="${revChange.abs()}" pattern="#,##0.#"/>%</span></c:when>
                            <c:otherwise><span class="delta flat">— 0%</span></c:otherwise>
                        </c:choose>
                    </div>

                    <div class="stat-card">
                        <div class="icon green">📈</div>
                        <div class="label">Estimated Profit</div>
                        <div class="value"><fmt:formatNumber value="${estimatedProfit}" pattern="#,##0"/>₫</div>
                        <span class="delta up">▲ 18% margin</span>
                    </div>

                    <div class="stat-card">
                        <div class="icon purple">🛒</div>
                        <div class="label">Total Orders</div>
                        <div class="value"><c:out value="${todayOrders}"/></div>
                        <c:choose>
                            <c:when test="${orderChange>0}"><span class="delta up">▲ <fmt:formatNumber value="${orderChange}" pattern="#,##0.#"/>%</span></c:when>
                            <c:when test="${orderChange<0}"><span class="delta down">▼ <fmt:formatNumber value="${0-orderChange}" pattern="#,##0.#"/>%</span></c:when>
                            <c:otherwise><span class="delta flat">— 0%</span></c:otherwise>
                        </c:choose>
                    </div>

                    <div class="stat-card">
                        <div class="icon orange">💎</div>
                        <div class="label">Avg Order Value</div>
                        <div class="value"><fmt:formatNumber value="${avgOrderValue}" pattern="#,##0"/>₫</div>
                        <span class="delta flat">Today</span>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="head">
                        <div>
                            <h2>Revenue Today's</h2>
                            <div class="sub">Hourly revenue for <c:out value="${today}"/></div>
                        </div>
                        <div class="chart-tabs">
                            <button class="active" onclick="setChartView(this, 'hour')">By hour</button>
                            <button onclick="setChartView(this, 'cum')">Cumulative</button>
                        </div>
                    </div>
                    <c:set var="maxRev" value="0"/>
                    <c:forEach items="${hourChart}" var="h">
                        <c:if test="${h.revenue.doubleValue() > maxRev}"><c:set var="maxRev" value="${h.revenue.doubleValue()}"/></c:if>
                    </c:forEach>
                    <div class="chart-area" id="chartArea">
                        <c:forEach items="${hourChart}" var="h">
                            <c:set var="pct" value="${maxRev>0?(h.revenue.doubleValue()*100/maxRev):0}"/>
                            <div class="col">
                                <div class="bar ${h.revenue.doubleValue()==0?'zero':''}" style="height:${pct>0?(pct*2.4):3}px" data-val="${h.revenue}">
                                    <div class="tip"><fmt:formatNumber value="${h.revenue}" pattern="#,##0"/>₫</div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="chart-axis">
                        <c:forEach items="${hourChart}" var="h">
                            <span><c:out value="${h.period}"/>h</span>
                        </c:forEach>
                    </div>
                </div>

                <div class="two-col">
                    <div class="chart-card">
                        <div class="head">
                            <div>
                                <h2>Top Products by Sales</h2>
                                <div class="sub">Best sellers today</div>
                            </div>
                        </div>
                        <div class="top-products-grid">
                            <c:choose>
                                <c:when test="${empty topProducts}">
                                    <p style="color:#7a87a6;text-align:center;padding:30px">No product sales today.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${topProducts}" var="p" varStatus="st">
                                        <div class="tp">
                                            <div class="rank ${st.count==1?'gold':(st.count==2?'silver':(st.count==3?'bronze':''))}">${st.count}</div>
                                            <div class="info">
                                                <strong><c:out value="${p.productName}"/></strong>
                                                <small><c:out value="${p.variantLabel}"/></small>
                                            </div>
                                            <div class="rev"><fmt:formatNumber value="${p.revenue}" pattern="#,##0"/>₫</div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="chart-card">
                        <div class="head">
                            <div>
                                <h2>Channels</h2>
                                <div class="sub">Revenue by payment method</div>
                            </div>
                        </div>
                        <c:choose>
                            <c:when test="${empty channels}">
                                <p style="color:#7a87a6;text-align:center;padding:30px">No payment data.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="channel-list">
                                    <c:forEach items="${channels}" var="c">
                                        <div class="channel-row">
                                            <div class="name">
                                                <c:choose>
                                                    <c:when test="${c.channel=='ORDER'}">🛒 Web Orders</c:when>
                                                    <c:when test="${c.channel=='POS'}">🏬 POS Store</c:when>
                                                    <c:otherwise>📦 <c:out value="${c.channel}"/></c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="track"><div class="fill" style="width:${c.percentage}%"></div></div>
                                            <div class="pct"><fmt:formatNumber value="${c.percentage}" pattern="#,##0.#"/>%</div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>
        </div>

        <script>
            function setChartView(btn, mode) {
                btn.parentNode.querySelectorAll('button').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                const area = document.getElementById('chartArea');
                const bars = [...area.querySelectorAll('.bar')];
                let cum = 0;
                if (mode === 'cum') {
                    bars.forEach(b => {
                        cum += parseFloat(b.dataset.val || 0);
                        b.style.height = (cum * 0.01) + 'px';
                    });
                } else {
                    const max = Math.max(...bars.map(b => parseFloat(b.dataset.val || 0)), 1);
                    bars.forEach(b => {
                        const v = parseFloat(b.dataset.val || 0);
                        b.style.height = (v * 240 / max) + 'px';
                    });
                }
            }
        </script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body></html>