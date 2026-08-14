<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Wishlist | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body {
                background:#f6f8fb;
                color:#111827;
            }
            .wishlist-shell {
                padding:42px 0 70px;
            }
            .wishlist-panel {
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                overflow:hidden;
            }
            .wishlist-header {
                padding:24px;
                border-bottom:1px solid #eef2f7;
                display:flex;
                justify-content:space-between;
                gap:16px;
                flex-wrap:wrap;
            }
            .wishlist-header h1 {
                margin:0;
                font-weight:900;
            }
            .wishlist-item {
                display:grid;
                grid-template-columns:92px minmax(0,1fr) auto;
                gap:18px;
                align-items:center;
                padding:20px 24px;
                border-bottom:1px solid #eef2f7;
            }
            .wishlist-item img {
                width:92px;
                height:92px;
                object-fit:cover;
                border-radius:8px;
                background:#f1f5f9;
            }
            .wishlist-item h3 {
                margin:0 0 4px;
                font-size:1.05rem;
                font-weight:900;
            }
            .wishlist-item h3 a {
                color:inherit;
                text-decoration:none;
            }
            .wishlist-meta {
                color:#64748b;
                font-size:.92rem;
            }
            .wishlist-price {
                margin-top:8px;
                color:#b91c1c;
                font-weight:900;
                font-size:1.1rem;
            }
            .wishlist-actions {
                display:flex;
                align-items:center;
                justify-content:flex-end;
                gap:10px;
                flex-wrap:wrap;
            }
            .primary-action,.secondary-action {
                min-height:44px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                padding:0 18px;
                border-radius:8px;
                font-weight:800;
                text-decoration:none;
            }
            .primary-action {
                border:1px solid #16a34a;
                background:#16a34a;
                color:#fff;
            }
            .primary-action:hover {
                background:#15803d;
                border-color:#15803d;
                color:#fff;
            }
            .secondary-action {
                border:1px solid #dbe3ec;
                background:#fff;
                color:#111827;
            }
            .secondary-action:hover {
                color:#1665d8;
                border-color:#b9c9ef;
            }
            .danger-action {
                min-height:44px;
                border:1px solid #fecaca;
                background:#fff;
                color:#dc2626;
                border-radius:8px;
                padding:0 14px;
                font-weight:800;
            }
            .danger-action:hover {
                background:#fef2f2;
            }
            .wishlist-empty {
                padding:60px 24px;
                color:#64748b;
                text-align:center;
            }
            @media(max-width:700px){
                .wishlist-item{
                    grid-template-columns:78px minmax(0,1fr)
                }
                .wishlist-item img{
                    width:78px;
                    height:78px
                }
                .wishlist-actions{
                    grid-column:1 / -1;
                    justify-content:flex-start
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="wishlist" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="wishlist-shell">
            <div class="container">
                <section class="wishlist-panel">
                    <div class="wishlist-header">
                        <div>
                            <h1>Wishlist</h1>
                            <p class="text-muted mb-0">${wishlistCount} favorite products</p>
                        </div>
                        <a class="primary-action" href="${pageContext.request.contextPath}/products">
                            <i class="bi bi-grid"></i> Continue shopping
                        </a>
                    </div>

                    <c:if test="${param.status == 'added'}">
                        <div class="alert alert-success m-3 mb-0">Product added to wishlist.</div>
                    </c:if>
                    <c:if test="${param.status == 'removed'}">
                        <div class="alert alert-success m-3 mb-0">Product removed from wishlist.</div>
                    </c:if>
                    <c:if test="${param.status == 'moved'}">
                        <div class="alert alert-success m-3 mb-0">Product moved to cart.</div>
                    </c:if>
                    <c:if test="${not empty param.wishlistError}">
                        <div class="alert alert-danger m-3 mb-0"><c:out value="${param.wishlistError}"/></div>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty wishlistItems}">
                            <div class="wishlist-empty">
                                <i class="bi bi-heart d-block mb-3" style="font-size:3rem;"></i>
                                Your wishlist is empty.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${wishlistItems}" var="item">
                                <div class="wishlist-item">
                                    <a href="${pageContext.request.contextPath}/products?action=detail&id=${item.productId}">
                                        <img src="${pageContext.request.contextPath}${item.imageUrl}" alt="${item.productName}"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
                                    </a>
                                    <div>
                                        <div class="wishlist-meta"><c:out value="${item.brandName}"/></div>
                                        <h3>
                                            <a href="${pageContext.request.contextPath}/products?action=detail&id=${item.productId}">
                                                <c:out value="${item.productName}"/>
                                            </a>
                                        </h3>
                                        <div class="wishlist-meta"><c:out value="${item.variantLabel}"/> &middot; Stock ${item.stock}</div>
                                        <div class="wishlist-price"><fmt:formatNumber value="${item.sellingPrice}" pattern="#,##0"/> &#273;</div>
                                    </div>
                                    <div class="wishlist-actions">
                                        <form method="post" action="${pageContext.request.contextPath}/wishlist">
                                            <input type="hidden" name="action" value="moveToCart">
                                            <input type="hidden" name="variantId" value="${item.productVariantId}">
                                            <button class="primary-action" type="submit" ${item.stock == 0 ? 'disabled' : ''}>
                                                <i class="bi bi-cart-plus"></i> Add to cart
                                            </button>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/wishlist">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="variantId" value="${item.productVariantId}">
                                            <button class="danger-action" type="submit">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </section>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
