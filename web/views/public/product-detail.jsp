<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
 <title>${product.name}</title>
 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
 <%@include file="../common/head.jsp"%>
 <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
</head>
<body>
<c:set var="activePage" value="products" scope="request"/>
<%@ include file="/views/common/header.jsp" %>
<main class="page-shell detail-page" data-variant-picker><section class="detail-hero">
 <div class="gallery"><div class="main-photo"><img id="mainProductImage" data-variant-image src="${pageContext.request.contextPath}${product.imageUrl}" alt="${product.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'"></div><div class="thumb-row"><button class="thumb active"><img src="${pageContext.request.contextPath}${product.imageUrl}" onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'"></button><button class="thumb"><span>Front</span></button><button class="thumb"><span>Back</span></button></div></div>
 <div class="detail-summary"><span class="brand-tag"><c:out value="${product.brandName}"/></span><h1><c:out value="${product.name}"/></h1><div class="detail-rating"><span>★★★★★</span> ${product.rating}.0 (${product.reviewCount} reviews) <b data-stock-label class="stock ${product.stock==0?'danger':''}">${product.stock>0?'In stock ('.concat(product.stock).concat(')'):'Out of stock'}</b></div>
  <div class="detail-price" data-variant-price><fmt:formatNumber value="${not empty product.variants?product.variants[0].sellingPrice:product.finalPrice}" pattern="#,##0"/>₫</div><c:if test="${product.discount>0}"><del><fmt:formatNumber value="${product.sellingPrice}" pattern="#,##0"/>₫</del><span class="discount-note">Save ${product.discount}%</span></c:if>
  <c:if test="${not empty product.variants}"><div class="option-block"><label>MEMORY</label><div class="memory-options"><c:forEach items="${product.memoryOptions}" var="m" varStatus="loop"><button type="button" class="memory-option ${loop.first?'active':''}" data-memory="${m.memoryKey}">${m.memoryLabel}</button></c:forEach></div></div><div class="option-block"><label>COLOR: <b data-color-name>${product.colorOptions[0].colorName}</b></label><div class="color-options"><c:forEach items="${product.colorOptions}" var="color" varStatus="loop"><button type="button" class="color-option ${loop.first?'active':''}" data-color="${color.colorName}" title="${color.colorName}" style="--variant-color:${color.colorHex}"></button></c:forEach></div></div><div hidden><c:forEach items="${product.variants}" var="v"><span data-variant data-memory="${v.memoryKey}" data-color="${v.colorName}" data-price="${v.sellingPrice}" data-image="${pageContext.request.contextPath}${v.imageUrl}" data-stock="${v.stock}"></span></c:forEach></div></c:if>
  <div class="purchase-row"><div class="quantity"><button type="button" data-qty="minus">−</button><input id="qty" value="1" readonly><button type="button" data-qty="plus" data-max="${product.stock}">+</button></div><button class="btn primary wide" data-cart-button ${product.stock==0?'disabled':''}>Add to Cart</button><button class="heart square">♡</button></div>
  <div class="shipping">✓ <strong>Free shipping</strong> · Official warranty ${product.warrantyMonths} months</div>
 </div></section>
 <section class="spec-section"><div class="tabs"><button class="active">Specifications</button><button>Reviews (${product.reviewCount})</button><button>Shipping & Returns</button></div><div class="spec-grid">
  <div class="spec"><span>Brand</span><b><c:out value="${product.brandName}"/></b></div><div class="spec"><span>Category</span><b><c:out value="${product.categoryName}"/></b></div><div class="spec"><span>Release year</span><b>${product.releaseYear}</b></div><div class="spec"><span>Rating</span><b>${product.rating}/5</b></div><div class="spec"><span>SKU</span><b><c:out value="${product.sku}"/></b></div><div class="spec"><span>Barcode</span><b><c:out value="${product.barcode}"/></b></div><div class="spec"><span>Stock</span><b>${product.stock} units</b></div><div class="spec"><span>Warranty</span><b>${product.warrantyMonths} months</b></div>
 </div><c:if test="${not empty product.description}"><p class="description"><c:out value="${product.description}"/></p></c:if></section>
</main>
<%@ include file="/views/common/footer.jsp" %>
<script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
