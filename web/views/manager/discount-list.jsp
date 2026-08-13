<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Discount Management</title><%@include file="../common/head.jsp"%></head><body><c:set var="pageRole" value="Manager"/><c:set var="pageName" value="Manage Discount"/><%@include file="../common/topbar.jsp"%>
<main class="page-shell">
 <div class="page-heading"><div><h1>Discount Management</h1><p>${discounts.size()} discounts listed</p></div><a class="btn primary large" href="${pageContext.request.contextPath}/manager/discounts?action=form">+ Add Discount</a></div>
 <c:if test="${not empty param.message}"><div class="alert success">Discount ${param.message}.</div></c:if>

 <div class="entity-table-wrap">
  <table class="entity-table discount-table">
   <thead>
    <tr>
     <th>ID</th>
     <th>Name</th>
     <th>Description</th>
     <th>Rate</th>
     <th>Start</th>
     <th>End</th>
     <th>Products</th>
     <th>Status</th>
     <th class="actions-col">Actions</th>
    </tr>
   </thead>
   <tbody>
    <c:forEach items="${discounts}" var="item">
     <tr>
      <td class="muted">#${item.id}</td>
      <td>
       <div class="discount-cell">
        <span class="entity-icon small">${item.initial}</span>
        <div>
         <strong><c:out value="${item.name}"/></strong>
         <small>Updated <fmt:formatDate value="${item.updatedAt}" pattern="MMM dd, HH:mm"/></small>
        </div>
       </div>
      </td>
      <td class="muted"><c:out value="${item.description}"/></td>
      <td><span class="rate-pill"><fmt:formatNumber value="${item.rate}" pattern="0.##"/>%</span></td>
      <td><fmt:formatDate value="${item.start}" pattern="MMM dd, yyyy HH:mm"/></td>
      <td><fmt:formatDate value="${item.end}" pattern="MMM dd, yyyy HH:mm"/></td>
      <td>
       <c:choose>
        <c:when test="${item.productCount == 0}">
         <span class="muted">All products</span>
        </c:when>
        <c:otherwise>
         <span class="badge"><b>${item.productCount}</b> product(s)</span>
        </c:otherwise>
       </c:choose>
      </td>
      <td><span class="${item.statusClass}">${item.computedStatus}</span></td>
      <td class="actions-col">
       <a class="btn subtle small" href="${pageContext.request.contextPath}/manager/discounts?action=form&id=${item.id}">Edit</a>
       <form method="post" class="inline" onsubmit="return confirm('Delete this discount? This cannot be undone.')">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="id" value="${item.id}">
        <button class="btn danger small">Delete</button>
       </form>
      </td>
     </tr>
    </c:forEach>
    <c:if test="${empty discounts}">
     <tr><td colspan="9" class="empty-row">No discounts yet. Click <b>+ Add Discount</b> to create your first one.</td></tr>
    </c:if>
   </tbody>
  </table>
 </div>
</main>
<script>
(function () {
    function refresh() {
        document.querySelectorAll('.discount-table tbody tr').forEach(function (row) {
            var s = row.getAttribute('data-start'), e = row.getAttribute('data-end');
            if (!s || !e) return;
            var start = new Date(s).getTime(), end = new Date(e).getTime(), now = Date.now();
            var pill = row.querySelector('.status-pill');
            if (!pill) return;
            var label, cls;
            if (now < start) { label = 'Scheduled'; cls = 'status-pill status-scheduled'; }
            else if (now > end) { label = 'Expired'; cls = 'status-pill status-expired'; }
            else { label = 'Active'; cls = 'status-pill status-active'; }
            pill.textContent = label;
            pill.className = cls;
        });
    }
    refresh();
    setInterval(refresh, 30000);
})();
</script>
</body></html>
