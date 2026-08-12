<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Discount Management</title><%@include file="../common/head.jsp"%></head><body><c:set var="pageRole" value="Manager"/><c:set var="pageName" value="Manage Discount"/><%@include file="../common/topbar.jsp"%>
<main class="page-shell">
 <div class="page-heading"><div><h1>Discount Management</h1><p>${discounts.size()} discounts listed</p></div><a class="btn primary large" href="${pageContext.request.contextPath}/manager/discounts?action=form">+ Add Discount</a></div>
 <c:if test="${not empty param.message}"><div class="alert success">Discount saved successfully.</div></c:if>
 <section class="entity-grid brand-style">
  <c:forEach items="${discounts}" var="item">
   <article class="entity-card ${!item.active?'muted':''}">
    <span class="entity-icon">${item.initial}</span>
    <div class="entity-copy">
     <h3><c:out value="${item.name}"/></h3>
     <p><fmt:formatNumber value="${item.rate}" pattern="0.##"/>% · ${item.productCount} products</p>
     <small>${item.active?'Active':'Inactive'} · <fmt:formatDate value="${item.start}" pattern="dd/MM/yyyy"/> - <fmt:formatDate value="${item.end}" pattern="dd/MM/yyyy"/></small>
    </div>
    <div class="actions">
     <a class="btn subtle" href="${pageContext.request.contextPath}/manager/discounts?action=form&id=${item.id}">Edit</a>
     <form method="post" onsubmit="return confirmDeactivate('discount')"><input type="hidden" name="action" value="deactivate"><input type="hidden" name="id" value="${item.id}"><button class="btn danger">Del</button></form>
    </div>
   </article>
  </c:forEach>
 </section>
</main>
<script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
</body></html>