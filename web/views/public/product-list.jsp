<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
 <title>All Smartphones</title>
 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
 <%@include file="../common/head.jsp"%>
 <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
</head>
<body>
<c:set var="activePage" value="products" scope="request"/>
<%@ include file="/views/common/header.jsp" %>
<main class="page-shell catalog-page">
 <div class="page-heading"><div><h1>All Smartphones</h1><p>${products.size()} products found</p></div></div>
 <form id="catalogForm" class="catalog-toolbar" method="get" action="${pageContext.request.contextPath}/products" novalidate>
   <input type="hidden" id="brandFilter" name="brand" value="${selectedBrand}">
   <div class="filter-pills">
    <button class="pill ${empty selectedBrand ? 'active' : ''}" type="button" data-brand="">All</button>
    <c:forEach items="${brands}" var="b"><button class="pill ${selectedBrand == b.id ? 'active' : ''}" type="button" data-brand="${b.id}"><c:out value="${b.name}"/></button></c:forEach>
   </div>
   <div class="catalog-controls">
    <div class="search-box"><span><i class="bi bi-search"></i></span><input id="productSearch" name="q" value="<c:out value='${keyword}'/>" type="search" maxlength="100" placeholder="Search product name..." autocomplete="off" aria-label="Search product by name"><button type="submit">Search</button></div>
    <select name="sort" class="dark-select" onchange="this.form.requestSubmit()" aria-label="Sort products"><option value="newest" ${selectedSort=='newest'?'selected':''}>Sort: Newest</option><option value="price-asc" ${selectedSort=='price-asc'?'selected':''}>Price: Low to high</option><option value="price-desc" ${selectedSort=='price-desc'?'selected':''}>Price: High to low</option></select>
   </div>
 </form>
 <c:if test="${not empty validationError}"><div class="catalog-error"><c:out value="${validationError}"/></div></c:if>
 <section class="product-grid">
  <c:forEach items="${products}" var="p">
   <article class="product-card" data-variant-picker data-detail-url="${pageContext.request.contextPath}/products?action=detail&id=${p.id}">
    <div class="product-media">
     <button class="heart" type="button" aria-label="Add to wishlist"><i class="bi bi-heart"></i></button>
     <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"><img data-variant-image src="${pageContext.request.contextPath}${p.imageUrl}" alt="${p.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'"></a>
     <span class="product-label">H&agrave;ng ch&iacute;nh h&atilde;ng</span>
    </div>
    <div class="product-info">
     <span class="eyebrow"><c:out value="${p.brandName}"/></span>
     <h3><a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"><c:out value="${p.name}"/></a></h3>
     <c:if test="${not empty p.variants}"><div class="memory-options"><c:forEach items="${p.memoryOptions}" var="m" varStatus="loop"><button type="button" class="memory-option ${loop.first?'active':''}" data-memory="${m.memoryKey}">${m.memoryLabel}</button></c:forEach></div><div class="color-options"><c:forEach items="${p.colorOptions}" var="color" varStatus="loop"><button type="button" class="color-option ${loop.first?'active':''}" data-color="${color.colorName}" title="${color.colorName}" style="--variant-color:${color.colorHex}"></button></c:forEach></div><div hidden><c:forEach items="${p.variants}" var="v"><span data-variant data-memory="${v.memoryKey}" data-color="${v.colorName}" data-price="${v.sellingPrice}" data-image="${pageContext.request.contextPath}${v.imageUrl}" data-stock="${v.stock}"></span></c:forEach></div></c:if>
     <div class="card-bottom"><div><c:if test="${p.discount>0}"><del><fmt:formatNumber value="${p.sellingPrice}" pattern="#,##0"/> &#273;</del></c:if><strong class="price" data-variant-price><fmt:formatNumber value="${not empty p.variants?p.variants[0].sellingPrice:p.finalPrice}" pattern="#,##0"/> &#273;</strong></div><button class="cart-button" data-cart-button ${p.stock==0?'disabled':''} aria-label="Add to cart"><i class="bi bi-cart3"></i><span>+</span></button></div>
     <div class="promotion">B&#7843;o h&agrave;nh ch&iacute;nh h&atilde;ng ${p.warrantyMonths} th&aacute;ng</div>
     <div class="product-footer"><div class="rating"><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i></div></div>
    </div>
   </article>
  </c:forEach>
 </section>
 <c:if test="${empty products}"><div class="empty-state">No matching products found.</div></c:if>
</main>
<%@ include file="/views/common/footer.jsp" %>
<script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
