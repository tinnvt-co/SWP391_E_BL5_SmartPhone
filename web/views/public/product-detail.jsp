<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>${product.name}</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/store.css">
    </head>
    <body>
        <c:set var="activePage" value="products" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>
        <main class="page-shell detail-page" data-variant-picker><a class="product-detail-back" href="${pageContext.request.contextPath}/products"><i class="bi bi-arrow-left"></i> Back to products</a><c:if test="${param.wishlistStatus == 'added'}"><div class="alert alert-success">Product added to wishlist.</div></c:if><c:if test="${not empty param.wishlistError}"><div class="alert alert-danger"><c:out value="${param.wishlistError}"/></div></c:if><section class="detail-hero">
                <div class="gallery"><div class="main-photo"><img id="mainProductImage" data-variant-image src="${pageContext.request.contextPath}${product.imageUrl}" alt="${product.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'"><c:if test="${product.hasDiscount()}"><span class="detail-discount-badge">-${product.discountPercent}%</span></c:if></div><div class="thumb-row"><button type="button" class="thumb active" data-gallery-view="front" data-gallery-image="${pageContext.request.contextPath}${product.variants[0].imageUrl}" aria-label="View front image"><img data-front-thumb src="${pageContext.request.contextPath}${product.variants[0].imageUrl}" alt="Front view"></button><button type="button" class="thumb" data-gallery-view="back" data-gallery-image="${pageContext.request.contextPath}${product.variants[0].backImageUrl}" aria-label="View back image"><img data-back-thumb src="${pageContext.request.contextPath}${product.variants[0].backImageUrl}" alt="Back view"></button></div><div class="gallery-caption" data-gallery-caption>Front view</div></div>
                <div class="detail-summary"><span class="brand-tag"><c:out value="${product.brandName}"/></span><h1><c:out value="${product.name}"/></h1><div class="detail-rating">
                        <c:set var="ratingForDisplay" value="${empty avgRating ? 0 : avgRating}"/>
                        <c:set var="countForDisplay" value="${empty feedbackCount ? product.reviewCount : feedbackCount}"/>
                        <c:if test="${countForDisplay > 0}">
                            <span class="review-summary-stars">
                                <c:forEach begin="1" end="5" var="s">
                                    <c:choose><c:when test="${s <= ratingForDisplay}">&#9733;</c:when><c:otherwise>&#9734;</c:otherwise></c:choose>
                                </c:forEach>
                            </span>
                            <fmt:formatNumber value="${ratingForDisplay}" pattern="#.#" maxFractionDigits="1"/>
                            (${countForDisplay} reviews)
                        </c:if>
                        <b data-stock-label class="stock ${product.stock==0?'danger':''}">${product.stock>0?'In stock ('.concat(product.stock).concat(')'):'Out of stock'}</b>
                    </div>
                    <c:set var="detailFinalPrice" value="${(not empty product.variants ? (product.variants[0].sellingPrice - (product.variants[0].sellingPrice * product.discount / 100)) : product.finalPrice)}"/><c:set var="detailOriginalPrice" value="${(not empty product.variants ? product.variants[0].sellingPrice : product.sellingPrice)}"/><div class="detail-price" data-variant-price><fmt:formatNumber value="${detailFinalPrice}" pattern="#,##0"/>₫</div><c:if test="${product.discount>0}"><del><fmt:formatNumber value="${detailOriginalPrice}" pattern="#,##0"/>₫</del><span class="discount-note">-${product.discountPercent}%</span></c:if>
                    <c:if test="${not empty product.variants}"><div class="option-block"><label>MEMORY</label><div class="memory-options"><c:forEach items="${product.memoryOptions}" var="m" varStatus="loop"><button type="button" class="memory-option ${loop.first?'active':''}" data-memory="${m.memoryKey}">${m.memoryLabel}</button></c:forEach></div></div><div class="option-block"><label for="productColor">COLOR</label><select id="productColor" class="color-select detail-color-select" data-color-select><c:forEach items="${product.colorOptions}" var="color"><option value="<c:out value='${color.colorName}'/>"><c:out value="${color.colorName}"/></option></c:forEach></select></div><div hidden><c:forEach items="${product.variants}" var="v"><c:set var="vFinal" value="${v.sellingPrice - (v.sellingPrice * product.discount / 100)}"/><span data-variant data-variant-id="${v.id}" data-memory="${v.memoryKey}" data-color="<c:out value='${v.colorName}'/>" data-price="${vFinal}" data-original-price="${v.sellingPrice}" data-image="${pageContext.request.contextPath}${v.imageUrl}" data-front-image="${pageContext.request.contextPath}${v.imageUrl}" data-back-image="${pageContext.request.contextPath}${v.backImageUrl}" data-stock="${v.stock}"></span></c:forEach></div></c:if>
                    <div class="purchase-row"><div class="quantity"><button type="button" data-qty="minus">−</button><input id="qty" value="1" readonly><button type="button" data-qty="plus" data-max="${product.stock}">+</button></div><c:if test="${currentRole ne 'Admin' and currentRole ne 'ADMIN' and currentRole ne 'Shipper' and currentRole ne 'SHIPPER' and currentRole ne 'Staff' and currentRole ne 'STAFF' and currentRole ne 'Manager' and currentRole ne 'MANAGER'}"><button class="btn primary wide" data-cart-button ${product.stock==0?'disabled':''}>Add to Cart</button><button class="heart square" type="button" data-wishlist-button aria-label="Add to wishlist">♡</button></c:if></div>
                    <div class="shipping">✓ <strong>Free shipping</strong> · Official warranty ${product.warrantyMonths} months</div>
                </div></section>
            <section class="spec-section"><div class="tabs"><button class="active">Specifications</button><button>Reviews (${countForDisplay})</button><button>Shipping & Returns</button></div><div class="spec-grid">
                    <div class="spec"><span>Brand</span><b><c:out value="${product.brandName}"/></b></div><div class="spec"><span>Categories</span><b><c:out value="${product.categoryNames}"/></b></div><div class="spec"><span>Release year</span><b>${product.releaseYear}</b></div><c:if test="${countForDisplay > 0}"><div class="spec"><span>Rating</span><b><fmt:formatNumber value="${ratingForDisplay}" pattern="#.#" maxFractionDigits="1"/>/5</b></div></c:if><div class="spec"><span>Stock</span><b>${product.stock} units</b></div><div class="spec"><span>Warranty</span><b>${product.warrantyMonths} months</b></div>
                </div><c:if test="${not empty product.description}"><p class="description"><c:out value="${product.description}"/></p></c:if></section>

                <section class="reviews-section" id="reviews-section">
                    <div class="container">
                        <h2>Customer reviews</h2>

                        <div class="review-summary">
                            <div class="review-summary-big">
                            <c:choose>
                                <c:when test="${countForDisplay > 0}"><fmt:formatNumber value="${avgRating}" pattern="#.#" maxFractionDigits="1"/></c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <c:if test="${countForDisplay > 0}">
                                <div class="review-summary-stars">
                                    <c:forEach begin="1" end="5" var="s">
                                        <c:choose><c:when test="${s <= ratingForDisplay}">&#9733;</c:when><c:otherwise>&#9734;</c:otherwise></c:choose>
                                    </c:forEach>
                                </div>
                            </c:if>
                            <div class="review-summary-count">${countForDisplay} review<c:if test="${countForDisplay != 1}">s</c:if></div>
                            </div>
                        </div>

                    <c:choose>
                        <c:when test="${empty reviews}">
                            <div class="review-empty">
                                <i class="bi bi-chat-square"></i>
                                <h4>No reviews yet</h4>
                                <p>Be the first to share your experience with this product.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="review-list">
                                <c:forEach var="rw" items="${reviews}">
                                    <div class="review-card">
                                        <div class="review-card-head">
                                            <div>
                                                <div class="review-author"><c:out value="${rw.feedback.userName}"/></div>
                                                <div class="review-variant">${rw.feedback.productName} &middot; <c:out value="${rw.feedback.variantLabel}"/></div>
                                            </div>
                                            <div class="review-meta-right">
                                                <div class="review-rating">
                                                    <c:forEach begin="1" end="5" var="s">
                                                        <c:choose><c:when test="${s <= rw.feedback.rating}">&#9733;</c:when><c:otherwise>&#9734;</c:otherwise></c:choose>
                                                    </c:forEach>
                                                </div>
                                                <div class="review-time">
                                                    <fmt:formatDate value="${rw.feedback.createdAt}" pattern="dd MMM yyyy"/>
                                                    <c:if test="${rw.feedback.edited}">
                                                        <span title="Edited"><i class="bi bi-pencil-square"></i></span>
                                                        </c:if>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="review-content"><c:out value="${rw.feedback.content}"/></div>
                                        <c:if test="${not empty rw.replies}">
                                            <div class="review-replies">
                                                <c:forEach var="rep" items="${rw.replies}">
                                                    <div class="review-reply">
                                                        <div class="review-reply-head">
                                                            <div>
                                                                <strong><c:out value="${rep.userName}"/></strong>
                                                                <span class="review-reply-role">${rep.manager ? 'Manager' : 'Customer'}</span>
                                                            </div>
                                                            <div class="review-time">
                                                                <fmt:formatDate value="${rep.createdAt}" pattern="dd MMM yyyy HH:mm"/>
                                                            </div>
                                                        </div>
                                                        <div class="review-content"><c:out value="${rep.content}"/></div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script>
            var APP_CONTEXT_PATH = '${pageContext.request.contextPath}';
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
