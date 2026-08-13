<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} | SWP Mobile</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <style>
        body { background:#f5f7fa; color:#17202a; font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif; }
        .detail-panel { background:#fff; border:1px solid #dce3ea; }
        .detail-panel { border-radius:8px; padding:1.5rem; margin:2rem 0 3rem; }
        .product-media { aspect-ratio:1/1; background:#fff; border:1px solid #eef1f5; border-radius:8px; display:flex; align-items:center; justify-content:center; padding:1rem; }
        .product-media img { width:100%; height:100%; object-fit:contain; }
        .product-title { font-size:2rem; font-weight:850; line-height:1.2; }
        .meta { color:#657486; font-weight:700; }
        .price { color:#e02d2d; font-size:1.8rem; font-weight:900; }
        .old-price { color:#8b97aa; text-decoration:line-through; margin-right:.5rem; }
        .spec { background:#f1f3f7; color:#68758b; border-radius:5px; padding:.32rem .58rem; font-weight:750; display:inline-flex; margin-right:.4rem; }
        .primary-action { min-height:46px; border-radius:8px; font-weight:800; }
    </style>
</head>
<body>
<c:set var="activePage" value="products" scope="request"/>
<%@ include file="/views/common/header.jsp" %>

<main class="container">
    <section class="detail-panel">
        <div class="row g-4 align-items-start">
            <div class="col-lg-6">
                <div class="product-media">
                    <img src="${pageContext.request.contextPath}${product.image}" alt="${product.name}"
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png'">
                </div>
            </div>
            <div class="col-lg-6">
                <div class="meta mb-2">${product.brandName} • ${product.categoryName}</div>
                <h1 class="product-title mb-3">${product.name}</h1>
                <p class="text-muted">${product.description}</p>
                <div class="mb-3">
                    <span class="spec">Full HD+</span>
                    <span class="spec">${product.secondSpec}</span>
                    <span class="spec">${product.warrantyMonths} month warranty</span>
                </div>
                <div class="price mb-1">
                    <fmt:formatNumber value="${product.sellingPrice}" type="number" maxFractionDigits="0"/>đ
                </div>
                <div class="mb-3">
                    <span class="old-price"><fmt:formatNumber value="${product.originalPrice}" type="number" maxFractionDigits="0"/>đ</span>
                    <span class="text-danger fw-bold">-${product.discountPercent}%</span>
                </div>
                <div class="mb-4 text-muted">
                    <i class="bi bi-star-fill text-warning"></i> ${product.displayRating}
                    <span class="mx-2">•</span>
                    Đã bán ${product.soldText}
                    <span class="mx-2">•</span>
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
