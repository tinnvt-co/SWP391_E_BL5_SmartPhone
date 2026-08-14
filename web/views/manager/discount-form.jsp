<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%><%@taglib prefix="fn" uri="jakarta.tags.functions"%>
<!DOCTYPE html><html><head><title>${discount.id==0?'Add Discount':'Edit Discount'}</title><link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <%@include file="../common/head.jsp"%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css"></head><body><c:set var="activePage" value="manager" scope="request"/>
    <%@ include file="/views/common/header.jsp" %>
<fmt:formatDate var="startValue" value="${discount.start}" pattern="yyyy-MM-dd'T'HH:mm"/>
<fmt:formatDate var="endValue" value="${discount.end}" pattern="yyyy-MM-dd'T'HH:mm"/>

<main class="page-shell form-large">
 <div class="page-heading"><div><h1>${discount.id==0?'Add Discount':'Edit Discount'}</h1><p>Schedule a discount and pick the products it applies to</p></div></div>
 <c:if test="${not empty error}"><div class="alert error"><c:out value="${error}"/></div></c:if>

 <form method="post" class="entity-form" id="discount-form">
  <input type="hidden" name="id" value="${discount.id}">

  <section class="form-section">
   <h3 class="form-section-title">📝 Basic information</h3>
   <label>Discount name *
    <input name="name" maxlength="255" placeholder="e.g. New Year Sale 2026, Flash Sale Friday, Member 10% Off..." value="<c:out value='${discount.name}'/>" required>
   </label>
   <label>Short description
    <textarea name="description" maxlength="255" rows="2" placeholder="e.g. Valid for flagship phones only, ends Friday midnight."><c:out value="${discount.description}"/></textarea>
   </label>
  </section>

  <section class="form-section">
   <h3 class="form-section-title">💸 Discount details</h3>
   <div class="form-grid">
    <label>Discount rate (% ) *
     <input type="number" name="rate" min="0.01" max="100" step="0.01" value="<c:out value='${discount.rate}'/>" required>
    </label>
    <label>Start date & time *
     <input type="datetime-local" name="start" id="startInput" value="${startValue}" required>
    </label>
    <label>End date & time *
     <input type="datetime-local" name="end" id="endInput" value="${endValue}" required>
    </label>
   </div>
  </section>

  <section class="form-section">
   <h3 class="form-section-title">📦 Apply to products</h3>
   <p class="form-hint">Pick the products this discount will apply to. Leave empty to apply to <b>all products</b>.</p>
   <div class="product-picker">
    <div class="product-picker-toolbar">
     <input type="search" id="productSearch" placeholder="Search products by name or SKU...">
     <button type="button" class="btn subtle" id="selectAll">Select all</button>
     <button type="button" class="btn subtle" id="clearAll">Clear</button>
    </div>
    <div class="product-picker-list" id="productList">
     <c:forEach items="${products}" var="p">
      <label class="product-picker-row" data-name="${fn:toLowerCase(p.name)} ${fn:toLowerCase(p.sku)}">
       <input type="checkbox" name="productIds" value="${p.id}" <c:if test="${selectedIds.contains(p.id)}">checked</c:if>>
       <span class="pp-name">${p.name}</span>
       <span class="pp-meta">${p.brandName} · <fmt:formatNumber value="${p.sellingPrice}" pattern="#,##0"/>₫</span>
      </label>
     </c:forEach>
     <c:if test="${empty products}">
      <div class="empty-row">No products available.</div>
     </c:if>
    </div>
    <div class="product-picker-summary">
     <span><b id="pickedCount">0</b> product(s) selected</span>
     <c:if test="${discount.id > 0}"><span class="${discount.statusClass}" id="liveStatusPill">${discount.computedStatus}</span></c:if>
    </div>
   </div>
  </section>

  <c:if test="${discount.id > 0}">
   <div class="form-meta">
    <span><b>ID:</b> #${discount.id}</span>
    <span><b>Created:</b> <fmt:formatDate value="${discount.createdAt}" pattern="MMM dd, yyyy HH:mm"/></span>
    <span><b>Updated:</b> <fmt:formatDate value="${discount.updatedAt}" pattern="MMM dd, yyyy HH:mm"/></span>
   </div>
  </c:if>

  <div class="form-actions"><a class="btn subtle" href="${pageContext.request.contextPath}/manager/discounts">Cancel</a><button class="btn primary large">Save Discount</button></div>
 </form>
</main>

<script>
(function () {
    var startEl = document.getElementById('startInput');
    var endEl   = document.getElementById('endInput');
    var pill    = document.getElementById('liveStatusPill');
    var picked  = document.getElementById('pickedCount');
    var search  = document.getElementById('productSearch');
    var list    = document.getElementById('productList');
    var selectAll = document.getElementById('selectAll');
    var clearAll  = document.getElementById('clearAll');

    function refreshPicked() {
        if (!picked) return;
        picked.textContent = list.querySelectorAll('input[type=checkbox]:checked').length;
    }

    function recomputeStatus() {
        if (!pill || !startEl || !endEl) return;
        var s = startEl.value ? new Date(startEl.value).getTime() : null;
        var e = endEl.value   ? new Date(endEl.value).getTime()   : null;
        var now = Date.now();
        var label, cls;
        if (s !== null && now < s) { label = 'Scheduled'; cls = 'status-pill status-scheduled'; }
        else if (e !== null && now > e) { label = 'Expired'; cls = 'status-pill status-expired'; }
        else { label = 'Active'; cls = 'status-pill status-active'; }
        pill.textContent = label;
        pill.className = cls;
    }

    if (list) {
        list.addEventListener('change', refreshPicked);
        refreshPicked();
    }
    if (search) {
        search.addEventListener('input', function () {
            var q = search.value.trim().toLowerCase();
            list.querySelectorAll('.product-picker-row').forEach(function (row) {
                var hay = row.getAttribute('data-name') || '';
                row.style.display = !q || hay.indexOf(q) >= 0 ? '' : 'none';
            });
        });
    }
    if (selectAll) selectAll.addEventListener('click', function () {
        list.querySelectorAll('.product-picker-row').forEach(function (row) {
            if (row.style.display !== 'none') row.querySelector('input').checked = true;
        });
        refreshPicked();
    });
    if (clearAll) clearAll.addEventListener('click', function () {
        list.querySelectorAll('input[type=checkbox]').forEach(function (cb) { cb.checked = false; });
        refreshPicked();
    });
    if (startEl) startEl.addEventListener('change', recomputeStatus);
    if (endEl)   endEl.addEventListener('change',   recomputeStatus);
    recomputeStatus();
})();
</script>
<%@ include file="/views/common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body></html>
