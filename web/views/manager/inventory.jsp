<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Inventory Management</title><link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <%@include file="../common/head.jsp"%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css"></head><body><c:set var="activePage" value="manager" scope="request"/>
    <%@ include file="/views/common/header.jsp" %>
<main class="page-shell">
 <div class="page-heading">
  <div>
   <h1>📦 Inventory Management</h1>
   <p>${stocks.size()} variants in stock</p>
  </div>
  <a class="btn primary large" href="javascript:void(0)" onclick="openStockIn()">+ Stock In</a>
 </div>

 <c:if test="${not empty param.message}"><div class="alert success"><c:out value="${param.message}"/></div></c:if>
 <c:if test="${not empty param.error}"><div class="alert error"><c:out value="${param.error}"/></div></c:if>

 <section class="stats-grid">
  <article><span>TOTAL SKU</span><strong><c:out value="${stats[0]}"/></strong><i class=""></i></article>
  <article><span>IN STOCK</span><strong><c:out value="${stats[1]}"/></strong><i class="green"></i></article>
  <article><span>LOW STOCK</span><strong><c:out value="${stats[2]}"/></strong><i class="purple"></i></article>
  <article><span>OUT OF STOCK</span><strong><c:out value="${stats[3]}"/></strong><i class="pink"></i></article>
 </section>

 <section class="table-panel">
  <form class="search-row" method="get">
   <input name="keyword" value="<c:out value='${keyword}'/>" placeholder="Search by product name, color or brand..." maxlength="100">
   <select name="status">
    <option value="" ${empty param.status?'selected':''}>All Status</option>
    <option value="OK" ${param.status=='OK'?'selected':''}>In Stock</option>
    <option value="LOW" ${param.status=='LOW'?'selected':''}>Low Stock</option>
    <option value="OUT" ${param.status=='OUT'?'selected':''}>Out of Stock</option>
   </select>
   <button class="btn primary">Search</button>
  </form>
  <div class="table-wrap"><table><thead><tr><th>SKU</th><th>Product</th><th>Brand</th><th class="center">Quantity</th><th class="center">Min Stock</th><th class="center">Status</th><th class="center">Actions</th></tr></thead><tbody>
   <c:choose>
    <c:when test="${empty stocks}">
     <tr><td colspan="7"><div class="empty-state">No inventory items found</div></td></tr>
    </c:when>
    <c:otherwise>
     <c:forEach items="${stocks}" var="s">
      <tr>
       <td class="mono">${s.productName.replaceAll("[^A-Za-z]","").length()>4?s.productName.replaceAll("[^A-Za-z]","").substring(0,4):s.productName.replaceAll("[^A-Za-z]","")}-${s.memoryLabel.replaceAll("[^0-9-]","")}-<c:choose><c:when test="${s.colorName!=null&&s.colorName.length()>1}">${s.colorName.replaceAll("[^A-Za-z]","").substring(0,2).toUpperCase()}</c:when><c:otherwise>NA</c:otherwise></c:choose></td>
       <td>
        <div>
         <strong><c:out value='${s.productName}'/></strong>
         <small>${s.memoryLabel} · <c:out value='${s.colorName}'/></small>
        </div>
       </td>
       <td><span class="brand-tag"><c:out value='${s.brandName!=null?s.brandName:"-"}'/></span></td>
       <td class="center price-small"><c:out value='${s.stock}'/></td>
       <td class="center"><c:out value='${s.minAmount}'/></td>
       <td class="center">
        <c:choose>
         <c:when test="${s.stock<=0}"><span class="status cancelled">Out of Stock</span></c:when>
         <c:when test="${s.stock<=5}"><span class="status status-low">Low Stock</span></c:when>
         <c:otherwise><span class="status active">In Stock</span></c:otherwise>
        </c:choose>
       </td>
       <td class="center">
        <div class="actions">
         <a class="btn subtle" href="javascript:void(0)" onclick="openStockIn(${s.variantId},'<c:out value='${s.productName}'/> - ${s.memoryLabel} - <c:out value='${s.colorName}'/>')">+ Stock In</a>
         <a class="btn subtle" href="javascript:void(0)" onclick="openAdjust(${s.variantId},${s.stock},'<c:out value='${s.productName}'/> - ${s.memoryLabel} - <c:out value='${s.colorName}'/>')">Adjust</a>
        </div>
       </td>
      </tr>
     </c:forEach>
    </c:otherwise>
   </c:choose>
  </tbody></table></div>
 </section>
</main>

<!-- Stock In Modal -->
<div id="stockInModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:999;align-items:center;justify-content:center">
 <form method="post" action="${pageContext.request.contextPath}/manager/inventory" class="entity-form" style="max-width:420px;width:90%;border-radius:17px">
  <h3 style="margin:0 0 14px;font-family:'Roboto Slab',serif;font-size:24px">📥 Stock In</h3>
  <input type="hidden" name="action" value="stockIn">
  <input type="hidden" name="variantId" id="siVariantId">
  <div><label>Product<div id="siProduct" style="font-weight:700;padding:10px;background:var(--surface2);border-radius:10px;margin-top:6px"></div></label></div>
  <div><label>Quantity<input type="number" name="quantity" min="1" required></label></div>
  <div><label>Note<input type="text" name="note" placeholder="e.g. Supplier XYZ import"></label></div>
  <div class="form-actions"><button type="button" class="btn subtle" onclick="closeModals()">Cancel</button><button type="submit" class="btn primary">Confirm</button></div>
 </form>
</div>

<!-- Adjust Modal -->
<div id="adjustModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:999;align-items:center;justify-content:center">
 <form method="post" action="${pageContext.request.contextPath}/manager/inventory" class="entity-form" style="max-width:420px;width:90%;border-radius:17px">
  <h3 style="margin:0 0 14px;font-family:'Roboto Slab',serif;font-size:24px">⚙ Adjust Stock</h3>
  <input type="hidden" name="action" value="adjust">
  <input type="hidden" name="variantId" id="adjVariantId">
  <div><label>Product<div id="adjProduct" style="font-weight:700;padding:10px;background:var(--surface2);border-radius:10px;margin-top:6px"></div></label></div>
  <div><label>New Stock<input type="number" name="newStock" id="adjStock" min="0" required></label></div>
  <div><label>Reason<input type="text" name="note" placeholder="e.g. Stocktake, damaged goods..."></label></div>
  <div class="form-actions"><button type="button" class="btn subtle" onclick="closeModals()">Cancel</button><button type="submit" class="btn primary">Confirm</button></div>
 </form>
</div>

<script>
function openStockIn(variantId, name){
 if(variantId){
  document.getElementById('siVariantId').value = variantId;
  document.getElementById('siProduct').textContent = name;
 }
 document.getElementById('stockInModal').style.display='flex';
}
function openAdjust(variantId, currentStock, name){
 document.getElementById('adjVariantId').value = variantId;
 document.getElementById('adjProduct').textContent = name;
 document.getElementById('adjStock').value = currentStock;
 document.getElementById('adjustModal').style.display='flex';
}
function closeModals(){
 document.getElementById('stockInModal').style.display='none';
 document.getElementById('adjustModal').style.display='none';
}
window.onclick = function(e){
 if(e.target.id==='stockInModal'||e.target.id==='adjustModal') closeModals();
}
</script>
<script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
<%@ include file="/views/common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body></html>
