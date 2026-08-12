<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Order Management</title><%@include file="../common/head.jsp"%></head><body>
<c:set var="pageRole" value="Manager"/><c:set var="pageName" value="Manage Orders"/><%@include file="../common/topbar.jsp"%>
<main class="page-shell">
 <div class="page-heading"><div><h1>Order Management</h1><p>${orders.size()} orders shown</p></div></div>
 <c:if test="${not empty param.message}"><div class="alert success"><c:out value="${param.message}"/></div></c:if>
 <c:if test="${not empty validationError}"><div class="alert error"><c:out value="${validationError}"/></div></c:if>
 <section class="stats-grid">
  <article><span>TODAY'S ORDERS</span><strong>${totalToday}</strong><i class=""></i></article>
  <article><span>PROCESSING</span><strong>${totalProcessing}</strong><i class="green"></i></article>
  <article><span>DELIVERED</span><strong>${totalDelivered}</strong><i class="purple"></i></article>
  <article><span>CANCELLED</span><strong>${totalCancelled}</strong><i class="pink"></i></article>
 </section>
 <section class="table-panel">
  <form class="search-row" method="get">
   <input name="q" value="<c:out value='${keyword}'/>" placeholder="Search by order id, customer name or username..." maxlength="100">
   <select name="status"><option value="">All Status</option>
    <c:forEach items="${statuses}" var="s"><option value="${s}" ${selectedStatus==s?'selected':''}><c:out value="${s}"/></option></c:forEach>
   </select>
   <select name="type"><option value="ALL" ${selectedType=='ALL'?'selected':''}>All Types</option><option value="ORDER" ${selectedType=='ORDER'?'selected':''}>Customer Order</option><option value="IMPORT" ${selectedType=='IMPORT'?'selected':''}>Import</option></select>
   <button class="btn primary">Search</button>
  </form>
  <div class="table-wrap"><table><thead><tr><th>Order ID</th><th>Customer</th><th>Type</th><th>Status</th><th>Items</th><th>Total</th><th>Method</th><th>Created</th><th>Actions</th></tr></thead><tbody>
   <c:forEach items="${orders}" var="o">
    <tr>
     <td class="mono">${o.code}</td>
     <td><div class="order-customer"><span class="order-customer-avatar">${empty o.userName ? '?' : o.userName.substring(0,1).toUpperCase()}</span><div class="order-customer-info"><strong><c:out value="${o.userName}"/></strong><small>@<c:out value="${o.username}"/></small></div></div></td>
     <td><span class="${o.type=='IMPORT'?'order-type-import':'order-type-order'}">${o.type}</span></td>
     <td><span class="status status-${o.status.toLowerCase()}">${o.status}</span></td>
     <td>${o.itemCount}</td>
     <td class="price-small"><fmt:formatNumber value="${o.totalPrice}" pattern="#,##0"/>₫</td>
     <td><span class="order-method">${o.method}</span></td>
     <td><small style="font-family:monospace;color:var(--muted)"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></small></td>
     <td><div class="actions order-actions"><a class="btn subtle" href="${pageContext.request.contextPath}/manager/orders?action=detail&id=${o.id}">Detail</a></div></td>
    </tr>
   </c:forEach>
  </tbody></table></div>
  <c:if test="${empty orders}"><div class="order-empty"><h2>No orders found</h2><p>Try changing your filters or clearing the search keyword.</p></div></c:if>
 </section>
</main>
<script src="${pageContext.request.contextPath}/assets/js/store.js"></script></body></html>