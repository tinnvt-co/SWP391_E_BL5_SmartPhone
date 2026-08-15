<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Products | SmartPhone store</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/store.css">
    </head>
    <body class="catalog-page">
        <c:set var="activePage" value="products" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell">
            <div class="container">
                <div class="d-flex align-items-end justify-content-between gap-3 flex-wrap mb-3">
                    <div>
                        <h1 class="fw-bold mb-1">All Smartphones</h1>
                        <p class="text-muted mb-0">${products.size()} products found</p>
                    </div>
                </div>

                <form class="toolbar" method="get" action="${pageContext.request.contextPath}/products">
                    <input class="form-control flex-grow-1 search-input" name="q" type="search"
                           value="${keyword}" maxlength="100" placeholder="Search product name, brand, category...">
                    <select class="form-select sort-select" name="sort">
                        <option value="newest" ${selectedSort == 'newest' ? 'selected' : ''}>Sort: Newest</option>
                        <option value="price-asc" ${selectedSort == 'price-asc' ? 'selected' : ''}>Price: Low to high</option>
                        <option value="price-desc" ${selectedSort == 'price-desc' ? 'selected' : ''}>Price: High to low</option>
                    </select>
                    <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i> Search</button>
                </form>

                <c:if test="${not empty validationError}">
                    <div class="alert alert-danger mt-3">${validationError}</div>
                </c:if>

                <c:choose>
                    <c:when test="${empty products}">
                        <div class="empty-state">No matching products found.</div>
                    </c:when>
                    <c:otherwise>
                        <section class="product-grid">
                            <c:forEach var="product" items="${products}">
                                <a class="product-card" href="${pageContext.request.contextPath}/products?action=detail&id=${product.id}">
                                    <div class="product-visual image-missing">
                                        <span class="ai-badge"><i class="bi bi-stars"></i>AI</span>
                                        <div class="mock-phone" aria-hidden="true"></div>
                                        <c:if test="${not empty product.image}">
                                            <img src="${pageContext.request.contextPath}${product.image}" alt="${product.name}"
                                                 onload="this.closest('.product-visual').classList.remove('image-missing')"
                                                 onerror="this.remove()">
                                        </c:if>
                                    </div>
                                    <div class="product-body">
                                        <h2 class="product-name">${product.name}</h2>
                                        <div class="specs">
                                            <span class="spec">Full HD+</span>
                                            <span class="spec">${product.secondSpec}</span>
                                        </div>
                                        <p class="promo">Online giÃ¡ ráº» quÃ¡</p>
                                        <div class="price"><fmt:formatNumber value="${product.finalPrice}" type="number" maxFractionDigits="0"/>Ä‘</div>
                                        <div><span class="old-price"><fmt:formatNumber value="${product.sellingPrice}" type="number" maxFractionDigits="0"/>Ä‘</span><span class="discount">-${product.discountPercent}%</span></div>
                                        <div class="rating-row"><i class="bi bi-star-fill"></i><span>${product.displayRating}</span><span>â€¢</span><span>ÄÃ£ bÃ¡n ${product.soldText}</span></div>
                                    </div>
                                </a>
                            </c:forEach>
                        </section>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>

