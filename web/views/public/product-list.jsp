<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title><c:out value="${catalogTitle}"/> | SmartPhone Store</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    </head>
    <body>
        <c:set var="activePage" value="products" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>
        <main class="page-shell catalog-page">
            <div class="page-heading catalog-heading">
                <div>
                    <c:if test="${not empty selectedCategoryName}">
                        <span class="catalog-heading-label">Selected category</span>
                    </c:if>
                    <h1><c:out value="${catalogTitle}"/></h1>
                    <p>${totalProducts} products found</p>
                </div>
            </div>
            <form id="catalogForm" class="catalog-toolbar" method="get" action="${pageContext.request.contextPath}/products" novalidate>
                <input type="hidden" id="brandFilter" name="brand" value="${selectedBrand}">
                <input type="hidden" name="category" value="${selectedCategory}">
                <div class="filter-pills">
                    <button class="pill ${empty selectedBrand ? 'active' : ''}" type="button" data-brand="">All</button>
                    <c:forEach items="${brands}" var="b"><button class="pill ${selectedBrand == b.id ? 'active' : ''}" type="button" data-brand="${b.id}"><c:out value="${b.name}"/></button></c:forEach>
                    </div>
                    <div class="catalog-controls">
                        <div class="search-box">
                            <span class="search-icon" aria-hidden="true"><i class="bi bi-search"></i></span>
                            <input id="productSearch" name="q" value="<c:out value='${keyword}'/>" type="search"
                                   maxlength="100" placeholder="Search smartphones by name..." autocomplete="off"
                                   aria-label="Search smartphone by name">
                            <button class="search-button" type="submit"><i class="bi bi-search"></i><span>Search</span></button>
                        </div>
                        <div class="sort-box">
                            <i class="bi bi-sliders" aria-hidden="true"></i>
                            <select name="sort" class="dark-select" onchange="this.form.requestSubmit()" aria-label="Sort products">
                                <option value="newest" ${selectedSort=='newest'?'selected':''}>Sort: Newest</option>
                                <option value="price-asc" ${selectedSort=='price-asc'?'selected':''}>Price: Low to high</option>
                                <option value="price-desc" ${selectedSort=='price-desc'?'selected':''}>Price: High to low</option>
                            </select>
                        </div>
                    </div>
                </div>
            </form>
            <c:if test="${not empty validationError}"><div class="catalog-error"><c:out value="${validationError}"/></div></c:if>
            <c:if test="${param.wishlistStatus == 'added'}"><div class="alert alert-success">Product added to wishlist.</div></c:if>
            <c:if test="${not empty param.wishlistError}"><div class="alert alert-danger"><c:out value="${param.wishlistError}"/></div></c:if>
                <section class="product-grid">
                <c:forEach items="${products}" var="p">
                    <article class="product-card" data-variant-picker data-detail-url="${pageContext.request.contextPath}/products?action=detail&id=${p.id}">
                        <div class="product-media">
                            <button class="heart" type="button" data-wishlist-button aria-label="Add to wishlist"><i class="bi bi-heart"></i></button>
                            <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"><img data-variant-image src="${pageContext.request.contextPath}${p.imageUrl}" alt="${p.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'"></a>
                            <span class="product-label">H&agrave;ng ch&iacute;nh h&atilde;ng</span>
                            <c:if test="${p.hasDiscount()}">
                                <span class="discount-badge" aria-label="Discount ${p.discountPercent}%">-${p.discountPercent}%</span>
                            </c:if>
                        </div>
                        <div class="product-info">
                            <span class="eyebrow"><c:out value="${p.brandName}"/></span>
                            <h3><a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"><c:out value="${p.name}"/></a></h3>
                            <c:if test="${not empty p.variants}"><div class="memory-options"><c:forEach items="${p.memoryOptions}" var="m" varStatus="loop"><button type="button" class="memory-option ${loop.first?'active':''}" data-memory="${m.memoryKey}">${m.memoryLabel}</button></c:forEach></div><label class="color-select-label">Color<select class="color-select" data-color-select><c:forEach items="${p.colorOptions}" var="color"><option value="<c:out value='${color.colorName}'/>"><c:out value="${color.colorName}"/></option></c:forEach></select></label><div hidden><c:forEach items="${p.variants}" var="v"><c:set var="variantFinal" value="${v.sellingPrice - (v.sellingPrice * p.discount / 100)}"/><span data-variant data-variant-id="${v.id}" data-memory="${v.memoryKey}" data-color="<c:out value='${v.colorName}'/>" data-price="${variantFinal}" data-original-price="${v.sellingPrice}" data-image="${pageContext.request.contextPath}${v.imageUrl}" data-stock="${v.stock}"></span></c:forEach></div></c:if>
                            <div class="card-bottom"><div><c:if test="${p.discount>0}"><del><fmt:formatNumber value="${p.sellingPrice}" pattern="#,##0"/> &#273;</del><span class="discount-rate">-${p.discountPercent}%</span></c:if><c:set var="displayPrice" value="${(not empty p.variants ? (p.variants[0].sellingPrice - (p.variants[0].sellingPrice * p.discount / 100)) : p.finalPrice)}"/><strong class="price" data-variant-price><fmt:formatNumber value="${displayPrice}" pattern="#,##0"/> &#273;</strong></div><button class="cart-button" data-cart-button ${p.stock==0?'disabled':''} aria-label="Add to cart"><i class="bi bi-cart3"></i><span>+</span></button></div>
                            <div class="promotion">B&#7843;o h&agrave;nh ch&iacute;nh h&atilde;ng ${p.warrantyMonths} th&aacute;ng</div>
                            <c:if test="${p.reviewCount > 0}">
                                <div class="product-footer">
                                    <div class="rating" aria-label="${p.rating} out of 5 stars from ${p.reviewCount} reviews">
                                        <c:forEach begin="1" end="5" var="star">
                                            <i class="bi ${star <= p.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                                        </c:forEach>
                                        <span>${p.rating}/5 (${p.reviewCount})</span>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </article>
                </c:forEach>
            </section>
            <c:if test="${totalPages > 1}">
                <nav class="catalog-pagination" aria-label="Product pagination">
                    <c:url var="previousPageUrl" value="/products">
                        <c:param name="page" value="${currentPage - 1}"/>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:param name="sort" value="${selectedSort}"/>
                    </c:url>
                    <a class="page-btn ${currentPage <= 1 ? 'disabled' : ''}" href="${currentPage <= 1 ? '#' : previousPageUrl}" aria-label="Previous page"><i class="bi bi-chevron-left"></i></a>
                        <c:forEach var="pageNumber" begin="${startPage}" end="${endPage}">
                            <c:url var="pageUrl" value="/products">
                                <c:param name="page" value="${pageNumber}"/>
                                <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                                <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                                <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                                <c:param name="sort" value="${selectedSort}"/>
                            </c:url>
                        <a class="page-btn ${pageNumber == currentPage ? 'active' : ''}" href="${pageUrl}">${pageNumber}</a>
                    </c:forEach>
                    <c:url var="nextPageUrl" value="/products">
                        <c:param name="page" value="${currentPage + 1}"/>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:param name="sort" value="${selectedSort}"/>
                    </c:url>
                    <a class="page-btn ${currentPage >= totalPages ? 'disabled' : ''}" href="${currentPage >= totalPages ? '#' : nextPageUrl}" aria-label="Next page"><i class="bi bi-chevron-right"></i></a>
                </nav>
            </c:if>
            <c:if test="${empty products}"><div class="empty-state">No matching products found.</div></c:if>
            </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
