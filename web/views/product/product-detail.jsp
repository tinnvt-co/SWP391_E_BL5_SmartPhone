<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${product.name} | SmartPhone store</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/store.css">
    </head>
    <body class="detail-page">
        <c:set var="activePage" value="products" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="container">
            <section class="detail-panel">
                <div class="row g-4 align-items-start">
                    <div class="col-lg-6">
                        <div class="product-media">
                            <c:if test="${product.hasDiscount()}">
                                <span class="detail-discount-badge">-${product.discountPercent}%</span>
                            </c:if>
                            <img src="${pageContext.request.contextPath}${product.image}" alt="${product.name}"
                                 onerror="this.src='${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png'">
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="meta mb-2">${product.brandName} â€¢ ${product.categoryName}</div>
                        <h1 class="product-title mb-3">${product.name}</h1>
                        <p class="text-muted">${product.description}</p>
                        <div class="mb-3">
                            <span class="spec">Full HD+</span>
                            <span class="spec">${product.secondSpec}</span>
                            <span class="spec">${product.warrantyMonths} month warranty</span>
                        </div>
                        <div class="price mb-1">
                            <fmt:formatNumber value="${product.finalPrice}" type="number" maxFractionDigits="0"/>&#273;
                        </div>
                        <c:if test="${product.hasDiscount()}">
                            <div class="mb-3">
                                <span class="old-price"><fmt:formatNumber value="${product.sellingPrice}" type="number" maxFractionDigits="0"/>&#273;</span>
                                <span class="text-danger fw-bold">-${product.discountPercent}%</span>
                            </div>
                        </c:if>
                        <div class="mb-4 text-muted">
                            <i class="bi bi-star-fill text-warning"></i> ${product.displayRating}
                            <span class="mx-2">â€¢</span>
                            ÄÃ£ bÃ¡n ${product.soldText}
                            <span class="mx-2">â€¢</span>
                            Stock: ${product.inventoryAmount}
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <button class="btn btn-primary primary-action px-4" type="button"><i class="bi bi-bag-plus"></i> Add to cart</button>
                            <button class="btn btn-outline-secondary primary-action px-4" type="button"><i class="bi bi-heart"></i> Wishlist</button>
                        </div>
                    </div>
                </div>
            </section>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>

