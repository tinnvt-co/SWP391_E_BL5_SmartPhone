<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Sales Statistics</title><%@include file="../common/head.jsp"%>
<style>
.chart-row{display:flex;align-items:flex-end;gap:6px;height:280px;padding:20px 16px 0;border-bottom:1px solid var(--line)}
.chart-row .bar{flex:1;background:linear-gradient(180deg,var(--blue),#2b5db8);border-radius:6px 6px 0 0;position:relative;min-height:4px;transition:.2s}
.chart-row .bar:hover{background:linear-gradient(180deg,#6594f1,var(--blue))}
.chart-row .bar .val{position:absolute;top:-22px;left:50%;transform:translateX(-50%);font-size:10px;color:var(--muted);white-space:nowrap}
.chart-row .bar.empty{background:#1a2030}
.chart-axis{display:flex;gap:6px;padding:10px 16px 0;color:var(--muted);font-size:11px}
.chart-axis span{flex:1;text-align:center;white-space:nowrap}
.top-list{padding:8px 0}
.top-item{display:flex;align-items:center;gap:16px;padding:14px 24px;border-top:1px solid #202633}
.top-item:first-child{border-top:none}
.rank{display:grid;place-items:center;width:36px;height:36px;border-radius:50%;background:#1a2948;color:#5d8ffc;font:700 14px monospace;flex-shrink:0}
.rank.gold{background:#1f2937;color:#fbbf24}
.rank.silver{background:#1f2937;color:#cbd5e1}
.rank.bronze{background:#1f2937;color:#d97706}
.top-info{flex:1;min-width:0}
.top-info strong{display:block;font-size:15px;margin-bottom:4px}
.top-info small{color:var(--muted);font-size:13px}
.top-metrics{display:flex;gap:24px;text-align:right}
.top-metrics div{display:flex;flex-direction:column}
.top-metrics .lbl{color:var(--muted);font-size:11px;text-transform:uppercase;letter-spacing:.5px}
.top-metrics .val{font-weight:700;font-size:16px;color:var(--text)}
.top-metrics .val.price{color:var(--blue);font-family:'Roboto Slab',serif}
.filter-bar{display:flex;align-items:center;gap:14px;flex-wrap:wrap;margin-bottom:24px;padding:18px 22px;background:var(--surface);border:1px solid var(--line);border-radius:17px}
.filter-bar .seg{display:inline-flex;background:var(--bg);border:1px solid var(--line);border-radius:11px;overflow:hidden}
.filter-bar .seg a{padding:11px 18px;color:var(--muted);font-weight:600;border-right:1px solid var(--line)}
.filter-bar .seg a:last-child{border-right:none}
.filter-bar .seg a.active{background:var(--blue);color:#fff}
.year-pill{display:inline-flex;align-items:center;gap:8px;background:var(--bg);border:1px solid var(--line);border-radius:11px;padding:6px 14px}
.year-pill select{background:transparent;border:none;color:var(--text);font-weight:600;outline:none;cursor:pointer}
.brand-bar-row{display:flex;align-items:center;gap:14px;padding:14px 24px;border-top:1px solid #202633}
.brand-bar-row:first-child{border-top:none}
.brand-bar-row .brand-name{width:130px;font-weight:600;flex-shrink:0;font-size:14px}
.brand-bar-row .bar-track{flex:1;height:10px;background:#1a2030;border-radius:6px;overflow:hidden}
.brand-bar-row .bar-fill{height:100%;background:linear-gradient(90deg,var(--blue),#5d8ffc);border-radius:6px}
.brand-bar-row .brand-rev{width:140px;text-align:right;font-weight:700;font-family:'Roboto Slab',serif;color:var(--blue);flex-shrink:0}
.brand-bar-row .brand-sold{width:90px;text-align:right;color:var(--muted);font-size:13px;flex-shrink:0}
.two-col{display:grid;grid-template-columns:1fr 1fr;gap:24px}
@media(max-width:1100px){.two-col{grid-template-columns:1fr}}
</style>
</head><body>
<c:set var="pageRole" value="Manager"/><c:set var="pageName" value="Sales Statistics"/><%@include file="../common/topbar.jsp"%>
<main class="page-shell">

 <div class="page-heading">
  <div>
   <h1>📊 Sales Statistics</h1>
   <p>Overview from <c:out value="${fromDate}"/> to <c:out value="${toDate}"/></p>
  </div>
  <a class="btn subtle" href="${pageContext.request.contextPath}/manager/sales-stats">↻ Refresh</a>
 </div>

 <div class="filter-bar">
  <div class="seg">
   <a href="${pageContext.request.contextPath}/manager/sales-stats?range=7&year=${year}"  class="${range=='7'?'active':''}">7 days</a>
   <a href="${pageContext.request.contextPath}/manager/sales-stats?range=30&year=${year}" class="${range=='30'?'active':''}">30 days</a>
   <a href="${pageContext.request.contextPath}/manager/sales-stats?range=month&year=${year}" class="${range=='month'?'active':''}">This month</a>
   <a href="${pageContext.request.contextPath}/manager/sales-stats?range=90&year=${year}" class="${range=='90'?'active':''}">90 days</a>
   <a href="${pageContext.request.contextPath}/manager/sales-stats?range=12m&year=${year}" class="${range=='12m'?'active':''}">12 months</a>
  </div>
  <div class="year-pill">
   <span style="color:var(--muted);font-size:12px">YEAR</span>
   <select onchange="location='${pageContext.request.contextPath}/manager/sales-stats?range=${range}&year='+this.value">
    <c:forEach items="${years}" var="y">
     <option value="${y}" ${y==year?'selected':''}>${y}</option>
    </c:forEach>
   </select>
  </div>
  <span style="color:var(--muted);font-size:13px;margin-left:auto">Showing ${chartData.size()} ${isMonthlyView?'months':'days'} of data</span>
 </div>

 <section class="stats-grid">
  <article><span>REVENUE</span><strong><fmt:formatNumber value="${overview.revenue}" pattern="#,##0"/>₫</strong><i class=""></i></article>
  <article><span>ORDERS</span><strong><c:out value="${overview.orderCount}"/></strong><i class="green"></i></article>
  <article><span>PRODUCTS SOLD</span><strong><c:out value="${overview.productSold}"/></strong><i class="purple"></i></article>
  <article><span>AVG ORDER VALUE</span>
   <strong><fmt:formatNumber value="${avgOrderValue}" pattern="#,##0"/>₫</strong>
   <i class="pink"></i>
  </article>
 </section>

 <section class="table-panel" style="margin-bottom:32px">
  <div style="padding:24px 26px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:14px">
   <div>
    <h3 style="margin:0;font-family:'Roboto Slab',serif;font-size:22px">📈 Revenue Trend ${isMonthlyView?year:''}</h3>
    <p style="margin:4px 0 0;color:var(--muted);font-size:14px">
     <c:choose>
      <c:when test="${isMonthlyView}">Monthly revenue for year ${year}</c:when>
      <c:otherwise>Daily revenue in selected range</c:otherwise>
     </c:choose>
    </p>
   </div>
  </div>
  <c:choose>
   <c:when test="${empty chartData}">
    <div class="empty-state"><p>No sales data in this period.</p></div>
   </c:when>
   <c:otherwise>
    <c:set var="maxRev" value="0"/>
    <c:forEach items="${chartData}" var="d">
     <c:if test="${d.revenue.doubleValue() > maxRev}"><c:set var="maxRev" value="${d.revenue.doubleValue()}"/></c:if>
    </c:forEach>
    <div class="chart-row">
     <c:forEach items="${chartData}" var="d">
      <c:set var="h" value="${maxRev>0?(d.revenue.doubleValue()*240/maxRev):4}"/>
      <div class="bar ${d.revenue.doubleValue()==0?'empty':''}" style="height:${h}px" title="<c:out value='${d.period}'/> · <fmt:formatNumber value='${d.revenue}' pattern='#,##0'/>₫ · ${d.orderCount} orders · ${d.productSold} items">
       <c:if test="${maxRev>0 && d.revenue.doubleValue()/maxRev>0.15}"><span class="val"><fmt:formatNumber value="${d.revenue}" pattern="#,##0"/></span></c:if>
      </div>
     </c:forEach>
    </div>
    <div class="chart-axis">
     <c:forEach items="${chartData}" var="d">
      <span><c:choose><c:when test="${isMonthlyView}"><c:out value="${d.period}"/></c:when><c:otherwise><c:out value="${d.period.substring(5)}"/></c:otherwise></c:choose></span>
     </c:forEach>
    </div>
   </c:otherwise>
  </c:choose>
 </section>

 <div class="two-col">
  <section class="table-panel">
   <div style="padding:24px 26px;border-bottom:1px solid var(--line)">
    <h3 style="margin:0;font-family:'Roboto Slab',serif;font-size:22px">🏆 Top Selling Products</h3>
    <p style="margin:4px 0 0;color:var(--muted);font-size:14px">Best 10 variants in selected range</p>
   </div>
   <c:choose>
    <c:when test="${empty topProducts}">
     <div class="empty-state"><p>No product sales in this period.</p></div>
    </c:when>
    <c:otherwise>
     <div class="top-list">
      <c:forEach items="${topProducts}" var="p" varStatus="st">
       <div class="top-item">
        <div class="rank ${st.count==1?'gold':(st.count==2?'silver':(st.count==3?'bronze':''))}">${st.count}</div>
        <div class="top-info">
         <strong><c:out value="${p.productName}"/></strong>
         <small><c:out value="${p.variantLabel}"/>${p.brandName!=null?' · '.concat(p.brandName):''}</small>
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

  <section class="table-panel">
   <div style="padding:24px 26px;border-bottom:1px solid var(--line)">
    <h3 style="margin:0;font-family:'Roboto Slab',serif;font-size:22px">🏷️ Top Brands</h3>
    <p style="margin:4px 0 0;color:var(--muted);font-size:14px">Best 8 brands by revenue</p>
   </div>
   <c:choose>
    <c:when test="${empty topBrands}">
     <div class="empty-state"><p>No brand sales in this period.</p></div>
    </c:when>
    <c:otherwise>
     <c:set var="maxBrandRev" value="0"/>
     <c:forEach items="${topBrands}" var="b">
      <c:if test="${b.revenue.doubleValue() > maxBrandRev}"><c:set var="maxBrandRev" value="${b.revenue.doubleValue()}"/></c:if>
     </c:forEach>
     <div>
      <c:forEach items="${topBrands}" var="b" varStatus="st">
       <c:set var="w" value="${maxBrandRev>0?(b.revenue.doubleValue()*100/maxBrandRev):0}"/>
       <div class="brand-bar-row">
        <div class="brand-name">#${st.count} <c:out value="${b.brandName}"/></div>
        <div class="bar-track"><div class="bar-fill" style="width:${w}%"></div></div>
        <div class="brand-sold"><c:out value="${b.soldQuantity}"/> items</div>
        <div class="brand-rev"><fmt:formatNumber value="${b.revenue}" pattern="#,##0"/>₫</div>
       </div>
      </c:forEach>
     </div>
    </c:otherwise>
   </c:choose>
  </section>
 </div>

</main>
<script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
</body></html>