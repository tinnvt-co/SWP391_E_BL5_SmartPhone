<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>${discount.id==0?'Add':'Edit'} Discount</title><%@include file="../common/head.jsp"%></head><body><c:set var="pageRole" value="Manager"/><c:set var="pageName" value="${discount.id==0?'Add Discount':'Edit Discount'}"/><%@include file="../common/topbar.jsp"%>
<main class="page-shell form-small">
 <div class="page-heading"><div><h1>${discount.id==0?'Add Discount':'Edit Discount'}</h1><p>Discount information</p></div></div>
 <c:if test="${not empty error}"><div class="alert error"><c:out value="${error}"/></div></c:if>
 <form method="post" class="entity-form">
  <input type="hidden" name="id" value="${discount.id}">
  <label>Discount name *<input name="name" maxlength="255" value="<c:out value='${discount.name}'/>" required></label>
  <label>Description<textarea name="description" maxlength="255" rows="3"><c:out value="${discount.description}"/></textarea></label>
  <div class="form-grid">
   <label>Rate (% ) *<input type="number" name="rate" min="0.01" max="100" step="0.01" value="<c:out value='${discount.rate}'/>" required></label>
   <label>Status<select name="status"><option value="ACTIVE" ${discount.active||discount.id==0?'selected':''}>Active</option><option value="INACTIVE" ${!discount.active&&discount.id>0?'selected':''}>Inactive</option></select></label>
   <label>Start *<input type="datetime-local" name="start" value="<fmt:formatDate value='${discount.start}' pattern='yyyy-MM-dd''T''HH:mm'/>" required></label>
   <label>End *<input type="datetime-local" name="end" value="<fmt:formatDate value='${discount.end}' pattern='yyyy-MM-dd''T''HH:mm'/>" required></label>
  </div>
  <div class="form-actions"><a class="btn subtle" href="${pageContext.request.contextPath}/manager/discounts">Cancel</a><button class="btn primary large">Save Discount</button></div>
 </form>
</main>
</body></html>