<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>All Smartphones</title><%@include file="../common/head.jsp"%></head><body>
<c:set var="pageRole" value="Public"/><c:set var="pageName" value="View Products"/><%@include file="../common/topbar.jsp"%>
<main class="page-shell">
 <div class="page-heading"><div><h1>All Smartphones</h1><p>${products.size()} products found</p></div></div>
 <form id="catalogForm" class="catalog-toolbar" method="get" action="${pageContext.request.contextPath}/products" novalidate>
   <input type="hidden" id="brandFilter" name="brand" value="${selectedBrand}">
   <div class="filter-pills">
    <button class="pill ${empty selectedBrand ? 'active' : ''}" type="button" data-brand="">All</button>
    <c:forEach items="${brands}" var="b"><button class="pill ${selectedBrand == b.id ? 'active' : ''}" type="button" data-brand="${b.id}"><c:out value="${b.name}"/></button></c:forEach>
   </div>
   <div class="catalog-controls">
    <div class="search-box"><span>⌕</span><input id="productSearch" name="q" value="<c:out value='${keyword}'/>" type="search" maxlength="100" placeholder="Search product name..." autocomplete="off" aria-label="Search product by name"><button type="submit">Search</button></div>
    <select name="sort" class="dark-select" onchange="this.form.requestSubmit()" aria-label="Sort products"><option value="newest" ${selectedSort=='newest'?'selected':''}>Sort: Newest</option><option value="price-asc" ${selectedSort=='price-asc'?'selected':''}>Price: Low to high</option><option value="price-desc" ${selectedSort=='price-desc'?'selected':''}>Price: High to low</option></select>
   </div>
 </form>
 <c:if test="${not empty validationError}"><div class="catalog-error"><c:out value="${validationError}"/></div></c:if>
 <section class="product-grid">
  <c:forEach items="${products}" var="p">
   <article class="product-card" data-variant-picker>
    <div class="product-media">
     <c:if test="${p.discount > 0}"><span class="badge sale">-${p.discount}%</span></c:if>
     <button class="heart" type="button" aria-label="Add to wishlist">♡</button>
     <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"><img data-variant-image src="${pageContext.request.contextPath}${p.image}" alt="${p.name}" onerror="this.src='https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=900&q=80'"></a>
     <span class="product-label">${p.discount > 0 ? 'Sản phẩm HOT' : 'Hàng chính hãng'}</span>
    </div>
    <div class="product-info">
     <span class="eyebrow"><c:out value="${p.brandName}"/></span>
     <h3><a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"><c:out value="${p.name}"/></a></h3>
     <c:if test="${not empty p.variants}"><div class="memory-options"><c:forEach items="${p.memoryOptions}" var="m" varStatus="loop"><button type="button" class="memory-option ${loop.first?'active':''}" data-memory="${m.memoryKey}">${m.memoryLabel}</button></c:forEach></div><div class="color-options"><c:forEach items="${p.colorOptions}" var="color" varStatus="loop"><button type="button" class="color-option ${loop.first?'active':''}" data-color="${color.colorName}" title="${color.colorName}" style="--variant-color:${color.colorHex}"></button></c:forEach></div><div hidden><c:forEach items="${p.variants}" var="v"><span data-variant data-memory="${v.memoryKey}" data-color="${v.colorName}" data-price="${v.sellingPrice}" data-image="${pageContext.request.contextPath}${v.image}" data-stock="${v.stock}"></span></c:forEach></div></c:if>
     <div class="card-bottom"><div><c:if test="${p.discount>0}"><del><fmt:formatNumber value="${p.sellingPrice}" pattern="#,##0"/> ₫</del></c:if><strong class="price" data-variant-price><fmt:formatNumber value="${not empty p.variants?p.variants[0].sellingPrice:p.finalPrice}" pattern="#,##0"/> ₫</strong></div><button class="cart-button" data-cart-button ${p.stock==0?'disabled':''} aria-label="Add to cart">🛒<span>+</span></button></div>
     <div class="promotion">Bảo hành chính hãng ${p.warrantyMonths} tháng</div>
     <div class="product-footer"><div class="rating">★★★★★</div></div>
    </div>
   </article>
  </c:forEach>
 </section>
 <c:if test="${empty products}"><div class="empty-state">No matching products found.</div></c:if>
</main><script src="${pageContext.request.contextPath}/assets/js/store.js"></script></body></html>
