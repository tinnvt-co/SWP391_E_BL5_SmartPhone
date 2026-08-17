<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SmartPhone store | Home</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    </head>
    <body>
        <c:set var="activePage" value="home" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main>
            <section class="hero">
                <div class="container">
                    <div class="hero-copy">
                        <c:if test="${param.login == 'success'}">
                            <div class="alert alert-success d-inline-flex align-items-center gap-2 py-2 mb-3">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>Welcome back, ${currentUser.name}.</span>
                            </div>
                        </c:if>
                        <c:if test="${param.logout == 'success'}">
                            <div class="alert alert-success d-inline-flex align-items-center gap-2 py-2 mb-3">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>You have signed out successfully.</span>
                            </div>
                        </c:if>
                        <c:if test="${param.register == 'success'}">
                            <div class="alert alert-success d-inline-flex align-items-center gap-2 py-2 mb-3">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>Your account has been created. Welcome, ${currentUser.name}.</span>
                            </div>
                        </c:if>
                        <span class="hero-eyebrow"><i class="bi bi-lightning-charge-fill"></i> New devices in stock</span>
                        <h1>SmartPhone store</h1>
                        <p>
                            Discover flagship smartphones, tablets, and accessories with clear pricing,
                            live stock visibility, and a clean shopping flow built for everyday buyers.
                        </p>
                        <div class="hero-actions">
                            <a class="btn-primary-action" href="${pageContext.request.contextPath}/products"><i class="bi bi-bag-check"></i> Explore products</a>
                            <a class="btn-secondary-action" href="#categories"><i class="bi bi-phone"></i> Browse categories</a>
                        </div>
                        <div class="hero-metrics">
                            <div class="hero-metric">
                                <strong>${activeProductCount}</strong>
                                <span>Active products</span>
                            </div>
                            <div class="hero-metric">
                                <strong>${availableProductCount}</strong>
                                <span>Available now</span>
                            </div>
                            <div class="hero-metric">
                                <strong>12m</strong>
                                <span>Warranty options</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <c:if test="${currentRole == 'Staff'}">
                <section class="section-band">
                    <div class="container">
                        <div class="staff-cta-panel">
                            <div class="staff-cta-art">
                                <span class="staff-cta-icon"><i class="bi bi-clipboard-check"></i></span>
                                <span class="staff-cta-decor"></span>
                            </div>
                            <div class="staff-cta-content">
                                <span class="hero-eyebrow"><i class="bi bi-shield-lock-fill"></i> STAFF ACCESS</span>
                                <h2>Welcome back, <c:out value="${currentUser.name}"/>. Ready to process today's orders?</h2>
                                <p>
                                    Use the Staff Center to search, review and update customer orders.
                                    Your work helps keep the fulfillment queue moving.
                                </p>
                                <ul class="staff-cta-features">
                                    <li><i class="bi bi-check2-circle"></i> Process pending &amp; processing orders</li>
                                    <li><i class="bi bi-check2-circle"></i> Track shipping &amp; delivery status</li>
                                    <li><i class="bi bi-check2-circle"></i> Reply to customer feedback</li>
                                </ul>
                            </div>
                            <div class="staff-cta-actions">
                                <a class="btn-primary-action staff-cta-btn"
                                   href="${pageContext.request.contextPath}/staff">
                                    <i class="bi bi-arrow-right-circle"></i> Open Staff Center
                                </a>
                                <small>Authorized personnel only</small>
                            </div>
                        </div>
                    </div>
                </section>
            </c:if>

            <section class="section-band section-soft" id="categories">
                <div class="container">
                    <div class="section-header">
                        <div>
                            <h2>Shop By Category</h2>
                            <p>Quick paths into the current catalog.</p>
                        </div>
                    </div>
                    <div class="category-strip">
                        <c:forEach var="category" items="${categories}">
                            <a class="category-tile" href="${pageContext.request.contextPath}/products?category=${category.id}">
                                <span class="category-icon">
                                    <c:choose>
                                        <c:when test="${category.name == 'Accessory'}"><i class="bi bi-earbuds"></i></c:when>
                                        <c:when test="${category.name == 'Tablet'}"><i class="bi bi-tablet-landscape"></i></c:when>
                                        <c:otherwise><i class="bi bi-phone"></i></c:otherwise>
                                    </c:choose>
                                </span>
                                <div>
                                    <h3>${category.name}</h3>
                                    <p>${category.productCount} products</p>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </section>

            <section class="section-band" id="products">
                <div class="container">
                    <div class="section-header">
                        <div>
                            <h2>Featured Products</h2>
                            <p>Top active items from the SmartPhone database.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/products" class="btn-secondary-action"><i class="bi bi-arrow-right"></i> View all</a>
                    </div>

                    <div class="product-grid">
                        <c:forEach var="product" items="${featuredProducts}">
                            <a class="product-card home-feature-card" href="${pageContext.request.contextPath}/products?action=detail&id=${product.id}">
                                <div class="product-visual">
                                    <span class="product-heart"><i class="bi bi-heart"></i></span>
                                    <span class="product-label">H&agrave;ng ch&iacute;nh h&atilde;ng</span>
                                    <c:if test="${product.hasDiscount()}">
                                        <span class="discount-badge">-${product.discountPercent}%</span>
                                    </c:if>
                                    <img src="${pageContext.request.contextPath}${product.imageUrl}" alt="${product.name}"
                                         onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
                                </div>
                                <div class="product-body">
                                    <p class="product-brand"><c:out value="${product.brandName}"/></p>
                                    <h3 class="product-name">${product.name}</h3>
                                    <c:choose>
                                        <c:when test="${not empty product.variants}">
                                            <div class="home-memory-options">
                                                <c:forEach items="${product.memoryOptions}" var="memory" varStatus="loop">
                                                    <c:if test="${loop.index < 3}">
                                                        <span class="home-memory-chip">${memory.memoryLabel}</span>
                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                            <div class="home-color-options">
                                                <c:forEach items="${product.colorOptions}" var="color" varStatus="loop">
                                                    <c:if test="${loop.index < 4}">
                                                        <span class="home-memory-chip"><c:out value="${color.colorName}"/></span>
                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="home-memory-options">
                                                <span class="home-memory-chip">Full HD+</span>
                                                <span class="home-memory-chip">${product.secondSpec}</span>
                                            </div>
                                            <div class="home-color-options">
                                                <span class="home-color-dot" style="--variant-color:#e7a8b7"></span>
                                                <span class="home-color-dot" style="--variant-color:#7e96b2"></span>
                                                <span class="home-color-dot" style="--variant-color:#d7dadd"></span>
                                                <span class="home-color-dot" style="--variant-color:#20242b"></span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="home-price-row">
                                        <div class="price">
                                            <fmt:formatNumber value="${not empty product.variants ? (product.variants[0].sellingPrice - (product.variants[0].sellingPrice * product.discount / 100)) : product.finalPrice}" type="number" maxFractionDigits="0"/> &#273;
                                        </div>
                                        <span class="home-cart-icon"><i class="bi bi-cart3"></i></span>
                                    </div>
                                    <c:if test="${product.hasDiscount()}">
                                        <div class="old-price-row">
                                            <span class="old-price"><fmt:formatNumber value="${not empty product.variants ? product.variants[0].sellingPrice : product.sellingPrice}" type="number" maxFractionDigits="0"/> &#273;</span>
                                            <span class="discount-rate">-${product.discountPercent}%</span>
                                        </div>
                                    </c:if>
                                    <div class="home-warranty">B&#7843;o h&agrave;nh ch&iacute;nh h&atilde;ng ${product.warrantyMonths} th&aacute;ng</div>
                                    <c:if test="${product.reviewCount > 0}">
                                        <div class="product-rating-row" aria-label="${product.rating} out of 5 stars from ${product.reviewCount} reviews">
                                            <c:forEach begin="1" end="5" var="star">
                                                <i class="bi ${star <= product.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                                            </c:forEach>
                                            <span>${product.rating}/5 (${product.reviewCount})</span>
                                        </div>
                                    </c:if>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </section>

            <section class="section-band section-soft">
                <div class="container">
                    <div class="promo-panel">
                        <div>
                            <span class="hero-eyebrow"><i class="bi bi-percent"></i> Smart upgrade</span>
                            <h2 class="fw-bold mt-3 mb-2">Flagship performance with store-ready support.</h2>
                            <p class="mb-4">Compare stock, warranty, and price before checkout. Your catalog data stays connected to the database behind the scene.</p>
                            <a class="btn-primary-action" href="#products"><i class="bi bi-phone-flip"></i> Pick a device</a>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-band" id="services">
                <div class="container">
                    <div class="service-grid">
                        <article class="service-item">
                            <span class="service-icon"><i class="bi bi-truck"></i></span>
                            <div>
                                <h3>Fast Delivery</h3>
                                <p>Order flow prepared for delivery tracking and shipper updates.</p>
                            </div>
                        </article>
                        <article class="service-item">
                            <span class="service-icon"><i class="bi bi-shield-check"></i></span>
                            <div>
                                <h3>Warranty First</h3>
                                <p>Warranty months are visible on each product card.</p>
                            </div>
                        </article>
                        <article class="service-item">
                            <span class="service-icon"><i class="bi bi-credit-card"></i></span>
                            <div>
                                <h3>Flexible Payment</h3>
                                <p>Supports cash, bank transfer, and online payment records.</p>
                            </div>
                        </article>
                        <article class="service-item">
                            <span class="service-icon"><i class="bi bi-chat-square-text"></i></span>
                            <div>
                                <h3>Feedback Ready</h3>
                                <p>Reviews and staff replies already fit the database model.</p>
                            </div>
                        </article>
                    </div>
                </div>
            </section>
        </main>

        <%@ include file="/views/common/footer.jsp" %>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>

