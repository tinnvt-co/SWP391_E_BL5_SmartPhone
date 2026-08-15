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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
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
