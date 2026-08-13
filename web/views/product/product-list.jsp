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
    <style>
        body { background:#f5f7fa; color:#17202a; font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif; }
        .page-shell { padding:2rem 0 3rem; }
        .toolbar { background:#fff; border:1px solid #dce3ea; border-radius:8px; padding:1rem; display:flex; gap:.75rem; align-items:center; flex-wrap:wrap; }
        .toolbar .form-control, .toolbar .form-select, .toolbar .btn { min-height:44px; border-radius:8px; }
        .product-grid { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:1.1rem; margin-top:1.3rem; }
        .product-card { background:#fff; border:1px solid #eef1f5; border-radius:8px; overflow:hidden; transition:.2s ease; text-decoration:none; color:inherit; }
        .product-card:hover { transform:translateY(-3px); box-shadow:0 18px 42px rgba(23,32,42,.1); color:inherit; }
        .product-visual { position:relative; aspect-ratio:1/1; background:#fff; display:flex; align-items:center; justify-content:center; padding:1rem; }
        .product-visual img { width:100%; height:100%; object-fit:contain; }
        .image-missing img { display:none; }
        .mock-phone { width:92px; height:170px; border-radius:18px; background:linear-gradient(145deg,#e5f6ff,#1851b8 60%,#071a3e); border:6px solid #101820; box-shadow:0 16px 32px rgba(23,32,42,.18); position:relative; }
        .mock-phone::before { content:""; position:absolute; top:7px; left:50%; width:7px; height:7px; transform:translateX(-50%); border-radius:50%; background:#101820; }
        .ai-badge { position:absolute; top:.85rem; right:.85rem; color:#f08200; font-weight:900; }
        .product-body { padding:0 1rem 1rem; }
        .product-name { min-height:54px; font-size:1.04rem; line-height:1.5; margin:0 0 .65rem; font-weight:550; }
        .specs { display:flex; gap:.5rem; margin-bottom:.65rem; flex-wrap:wrap; }
        .spec { background:#f1f3f7; color:#68758b; border-radius:5px; padding:.25rem .48rem; font-size:.86rem; font-weight:700; }
        .promo { color:#ff7a1a; font-weight:800; margin:0 0 .35rem; }
        .price { color:#e02d2d; font-size:1.28rem; font-weight:850; }
        .old-price { color:#8b97aa; text-decoration:line-through; margin-right:.45rem; }
        .discount { color:#e02d2d; font-weight:850; }
        .rating-row { color:#58657a; font-weight:650; font-size:.9rem; display:flex; gap:.35rem; align-items:center; margin-top:.55rem; }
        .rating-row i { color:#ffb400; }
        .empty-state { background:#fff; border:1px solid #dce3ea; border-radius:8px; text-align:center; padding:3rem; color:#657486; margin-top:1.3rem; }
        @media (max-width:991.98px){ .product-grid{grid-template-columns:repeat(2,minmax(0,1fr));} }
        @media (max-width:575.98px){ .product-grid{grid-template-columns:1fr;} .toolbar{display:block;} .toolbar>*{margin-bottom:.7rem;} }
    </style>
</head>
<body>
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
            <input class="form-control flex-grow-1" style="min-width:240px" name="q" type="search"
                   value="${keyword}" maxlength="100" placeholder="Search product name, brand, category...">
            <select class="form-select" style="max-width:220px" name="sort">
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
                                <div class="price"><fmt:formatNumber value="${product.sellingPrice}" type="number" maxFractionDigits="0"/>Ä‘</div>
                                <div><span class="old-price"><fmt:formatNumber value="${product.originalPrice}" type="number" maxFractionDigits="0"/>Ä‘</span><span class="discount">-${product.discountPercent}%</span></div>
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

