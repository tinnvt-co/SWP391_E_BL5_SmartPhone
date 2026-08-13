<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SWP Mobile | Smartphone Store</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --ink: #17202a;
            --muted: #657486;
            --line: #dce3ea;
            --soft: #f5f7fa;
            --blue: #1665d8;
            --green: #17a673;
            --coral: #f05d4f;
            --amber: #f7b731;
        }

        * { box-sizing: border-box; }
        body {
            margin: 0;
            background: #ffffff;
            color: var(--ink);
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            letter-spacing: 0;
        }

        .topbar {
            background: #101820;
            color: rgba(255, 255, 255, 0.78);
            font-size: 0.82rem;
        }

        .site-nav {
            background: rgba(255, 255, 255, 0.96);
            border-bottom: 1px solid var(--line);
            backdrop-filter: blur(12px);
        }

        .brand-mark {
            width: 38px;
            height: 38px;
            border-radius: 8px;
            background: linear-gradient(135deg, var(--blue), var(--green));
            color: #fff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
        }

        .nav-link {
            color: var(--muted);
            font-weight: 600;
            font-size: 0.92rem;
        }

        .nav-link:hover { color: var(--blue); }

        .icon-btn {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            border: 1px solid var(--line);
            background: #fff;
            color: var(--ink);
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .hero {
            min-height: 520px;
            background:
                linear-gradient(90deg, rgba(255,255,255,0.96) 0%, rgba(255,255,255,0.88) 34%, rgba(255,255,255,0.22) 62%, rgba(255,255,255,0.05) 100%),
                url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center right / cover no-repeat;
            border-bottom: 1px solid var(--line);
            display: flex;
            align-items: center;
        }

        .hero-copy {
            max-width: 610px;
            padding-top: 4rem;
            padding-bottom: 4rem;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            color: var(--green);
            background: rgba(23, 166, 115, 0.1);
            border: 1px solid rgba(23, 166, 115, 0.22);
            border-radius: 8px;
            padding: 0.45rem 0.7rem;
            font-weight: 700;
            font-size: 0.82rem;
        }

        .hero h1 {
            font-size: clamp(2.4rem, 5vw, 4.8rem);
            line-height: 1;
            font-weight: 850;
            margin: 1.2rem 0 1rem;
        }

        .hero p {
            color: var(--muted);
            font-size: 1.08rem;
            line-height: 1.7;
            max-width: 520px;
        }

        .primary-action,
        .secondary-action {
            min-height: 44px;
            border-radius: 8px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
        }

        .primary-action {
            background: var(--blue);
            color: #fff;
            border: 1px solid var(--blue);
        }

        .primary-action:hover {
            background: #0f56be;
            border-color: #0f56be;
            color: #fff;
        }

        .secondary-action {
            background: #fff;
            color: var(--ink);
            border: 1px solid var(--line);
        }

        .hero-metrics {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 0.75rem;
            max-width: 520px;
            margin-top: 1.4rem;
        }

        .metric {
            border-left: 3px solid var(--blue);
            padding: 0.25rem 0 0.25rem 0.8rem;
        }

        .metric strong {
            display: block;
            font-size: 1.35rem;
        }

        .metric span {
            color: var(--muted);
            font-size: 0.82rem;
            font-weight: 600;
        }

        .section-band { padding: 3rem 0; }
        .section-soft { background: var(--soft); border-block: 1px solid var(--line); }

        .section-title {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1.35rem;
        }

        .section-title h2 {
            font-size: 1.5rem;
            font-weight: 800;
            margin: 0;
        }

        .section-title p {
            color: var(--muted);
            margin: 0.35rem 0 0;
        }

        .category-strip {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 1rem;
        }

        .category-tile,
        .product-card,
        .service-item,
        .promo-panel {
            background: #fff;
            border: 1px solid var(--line);
            border-radius: 8px;
        }

        .category-tile {
            padding: 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.9rem;
        }

        .category-icon {
            width: 46px;
            height: 46px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            background: #101820;
            flex: 0 0 46px;
        }

        .category-tile:nth-child(2) .category-icon { background: var(--coral); }
        .category-tile:nth-child(3) .category-icon { background: var(--green); }

        .category-tile h3 {
            font-size: 1rem;
            font-weight: 800;
            margin: 0;
        }

        .category-tile p {
            margin: 0.15rem 0 0;
            color: var(--muted);
            font-size: 0.86rem;
        }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 1.1rem;
        }

        .product-card {
            overflow: hidden;
            border-radius: 8px;
            border: 1px solid #eef1f5;
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
        }

        .product-card:hover {
            transform: translateY(-3px);
            border-color: rgba(240, 93, 79, 0.35);
            box-shadow: 0 18px 42px rgba(23, 32, 42, 0.1);
        }

        .product-visual {
            position: relative;
            aspect-ratio: 1 / 1;
            background: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            padding: 1.1rem 0.85rem 0.4rem;
        }

        .product-visual img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        .product-visual:not(.image-missing) .mock-phone-stage { display: none; }

        .mock-phone-stage {
            position: relative;
            width: min(100%, 235px);
            height: 235px;
        }

        .mock-phone-back,
        .mock-phone-front {
            position: absolute;
            bottom: 8px;
            border-radius: 18px;
            box-shadow: 0 14px 28px rgba(23, 32, 42, 0.18);
        }

        .mock-phone-back {
            left: 10px;
            width: 96px;
            height: 186px;
            background: linear-gradient(150deg, #fff1f1, #f3d9df);
            border: 1px solid #e9c7ce;
        }

        .mock-camera {
            position: absolute;
            top: 16px;
            left: 12px;
            width: 48px;
            height: 66px;
            border-radius: 14px;
            background: rgba(255,255,255,0.45);
            border: 1px solid rgba(255,255,255,0.75);
        }

        .mock-camera::before,
        .mock-camera::after {
            content: "";
            position: absolute;
            left: 7px;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: radial-gradient(circle at 45% 42%, #3d4754 0 22%, #101820 24% 55%, #2d3440 57% 100%);
            border: 2px solid #d9dfe6;
        }

        .mock-camera::before { top: 7px; }
        .mock-camera::after { bottom: 7px; }

        .mock-phone-front {
            left: 86px;
            width: 116px;
            height: 202px;
            background: #101820;
            border: 2px solid #101820;
            padding: 7px 6px 6px;
        }

        .mock-phone-screen {
            position: relative;
            width: 100%;
            height: 100%;
            border-radius: 13px;
            background:
                linear-gradient(180deg, rgba(255,255,255,0.9), rgba(255,255,255,0.2) 28%, transparent 29%),
                radial-gradient(circle at 72% 76%, rgba(255,255,255,0.72) 0 15%, transparent 16%),
                linear-gradient(145deg, #e5f6ff 0%, #4fb8f2 35%, #1851b8 64%, #071a3e 100%);
            overflow: hidden;
        }

        .mock-phone-screen::before {
            content: "";
            position: absolute;
            top: 7px;
            left: 50%;
            transform: translateX(-50%);
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #101820;
        }

        .mock-product-name {
            position: absolute;
            top: 25px;
            left: 9px;
            right: 9px;
            color: #101820;
            font-size: 0.72rem;
            font-weight: 900;
            line-height: 1.05;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .mock-model {
            position: absolute;
            left: 27px;
            right: 27px;
            bottom: 12px;
            height: 82px;
            border-radius: 40px 40px 18px 18px;
            background:
                radial-gradient(circle at 50% 22%, #f7c6aa 0 18%, transparent 19%),
                linear-gradient(160deg, transparent 0 34%, rgba(255,255,255,0.82) 35% 100%);
        }

        .product-ai-badge {
            position: absolute;
            top: 1.15rem;
            right: 0.9rem;
            color: #f08200;
            font-size: 1.15rem;
            font-weight: 900;
            letter-spacing: 0;
        }

        .product-ai-badge i { font-size: 0.76rem; vertical-align: top; }

        .stock-badge { display: none; }

        .product-body { padding: 0.2rem 1rem 1rem; }

        .product-name {
            min-height: 54px;
            margin: 0 0 0.65rem;
            color: #111827;
            font-size: 1.04rem;
            font-weight: 500;
            line-height: 1.5;
        }

        .product-specs {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-bottom: 0.65rem;
        }

        .spec-chip {
            display: inline-flex;
            align-items: center;
            min-height: 28px;
            padding: 0.25rem 0.48rem;
            border-radius: 5px;
            background: #f1f3f7;
            color: #68758b;
            font-size: 0.86rem;
            font-weight: 700;
        }

        .product-promo {
            color: #ff7a1a;
            font-size: 0.92rem;
            font-weight: 800;
            margin: 0 0 0.35rem;
        }

        .price-row { margin-bottom: 0.28rem; }

        .price {
            color: #e02d2d;
            font-size: 1.28rem;
            line-height: 1.2;
            font-weight: 850;
        }

        .old-price-row {
            display: flex;
            align-items: center;
            gap: 0.55rem;
            margin-bottom: 0.7rem;
            color: #8b97aa;
            font-size: 0.9rem;
        }

        .old-price {
            text-decoration: line-through;
        }

        .discount-rate {
            color: #e02d2d;
            font-weight: 850;
        }

        .product-rating-row {
            display: flex;
            align-items: center;
            gap: 0.35rem;
            color: #58657a;
            font-size: 0.9rem;
            font-weight: 650;
        }

        .product-rating-row .bi-star-fill { color: #ffb400; }

        .mini-action {
            width: 38px;
            height: 38px;
            border-radius: 8px;
            border: 1px solid var(--line);
            background: var(--ink);
            color: #fff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .promo-panel {
            min-height: 210px;
            background:
                linear-gradient(90deg, rgba(16, 24, 32, 0.92), rgba(16, 24, 32, 0.72)),
                url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center right / cover no-repeat;
            color: #fff;
            padding: 2rem;
            display: flex;
            align-items: center;
        }

        .promo-panel p {
            color: rgba(255, 255, 255, 0.78);
            max-width: 520px;
        }

        .service-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 1rem;
        }

        .service-item {
            padding: 1.15rem;
            display: flex;
            gap: 0.8rem;
        }

        .service-item i {
            color: var(--green);
            font-size: 1.4rem;
        }

        .service-item h3 {
            font-size: 0.95rem;
            font-weight: 800;
            margin: 0;
        }

        .service-item p {
            color: var(--muted);
            font-size: 0.84rem;
            margin: 0.25rem 0 0;
        }

        .footer {
            background: #101820;
            color: rgba(255,255,255,0.72);
            padding: 2rem 0;
        }

        .footer strong { color: #fff; }

        @media (max-width: 991.98px) {
            .hero {
                min-height: 560px;
                background:
                    linear-gradient(180deg, rgba(255,255,255,0.98) 0%, rgba(255,255,255,0.88) 45%, rgba(255,255,255,0.25) 100%),
                    url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center bottom / cover no-repeat;
                align-items: flex-start;
            }

            .hero-copy { padding-top: 2.4rem; }
            .product-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
            .service-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }

        @media (max-width: 767.98px) {
            .topbar { display: none; }
            .hero { min-height: 620px; }
            .hero-metrics,
            .category-strip,
            .product-grid,
            .service-grid {
                grid-template-columns: 1fr;
            }
            .section-title { align-items: flex-start; flex-direction: column; }
            .product-name,
            .product-desc {
                min-height: auto;
            }
        }
    </style>
</head>
<body>
<div class="topbar py-2">
    <div class="container d-flex align-items-center justify-content-between gap-3">
        <span><i class="bi bi-truck me-1"></i> Fast delivery for Ho Chi Minh City and Ha Noi</span>
        <span><i class="bi bi-shield-check me-1"></i> Official warranty on every active product</span>
    </div>
</div>

<nav class="navbar navbar-expand-lg site-nav sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="${pageContext.request.contextPath}/home">
            <span class="brand-mark">S</span>
            <span>SWP Mobile</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav"
                aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/home">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="#products">Products</a></li>
                <li class="nav-item"><a class="nav-link" href="#categories">Categories</a></li>
                <li class="nav-item"><a class="nav-link" href="#services">Services</a></li>
            </ul>
            <div class="d-flex align-items-center gap-2">
                <button class="icon-btn" type="button" title="Search"><i class="bi bi-search"></i></button>
                <button class="icon-btn" type="button" title="Wishlist"><i class="bi bi-heart"></i></button>
                <button class="icon-btn" type="button" title="Cart"><i class="bi bi-bag"></i></button>
                <c:choose>
                    <c:when test="${not empty currentUser}">
                        <div class="dropdown">
                            <button class="btn secondary-action px-3 dropdown-toggle" type="button"
                                    data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-person-circle"></i> ${currentUser.name}
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><h6 class="dropdown-header">${currentRole}</h6></li>
                                <li><a class="dropdown-item" href="#"><i class="bi bi-person me-2"></i>Profile</a></li>
                                <li><a class="dropdown-item" href="#"><i class="bi bi-receipt me-2"></i>Orders</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                                    <i class="bi bi-box-arrow-right me-2"></i>Logout
                                </a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a class="btn secondary-action px-3" href="${pageContext.request.contextPath}/login">
                            <i class="bi bi-box-arrow-in-right"></i> Login
                        </a>
                    </c:otherwise>
                </c:choose>
                <a class="btn primary-action px-3" href="#products"><i class="bi bi-grid"></i> Shop</a>
            </div>
        </div>
    </div>
</nav>

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
                <span class="eyebrow"><i class="bi bi-lightning-charge-fill"></i> New devices in stock</span>
                <h1>SWP Mobile</h1>
                <p>
                    Discover flagship smartphones, tablets, and accessories with clear pricing,
                    live stock visibility, and a clean shopping flow built for everyday buyers.
                </p>
                <div class="d-flex flex-wrap gap-2 mt-4">
                    <a class="btn primary-action px-4" href="#products"><i class="bi bi-bag-check"></i> Explore products</a>
                    <a class="btn secondary-action px-4" href="#categories"><i class="bi bi-phone"></i> Browse categories</a>
                </div>
                <div class="hero-metrics">
                    <div class="metric">
                        <strong>${activeProductCount}</strong>
                        <span>Active products</span>
                    </div>
                    <div class="metric">
                        <strong>${availableProductCount}</strong>
                        <span>Available now</span>
                    </div>
                    <div class="metric">
                        <strong>12m</strong>
                        <span>Warranty options</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="section-band section-soft" id="categories">
        <div class="container">
            <div class="section-title">
                <div>
                    <h2>Shop By Category</h2>
                    <p>Quick paths into the current catalog.</p>
                </div>
            </div>
            <div class="category-strip">
                <c:forEach var="category" items="${categories}">
                    <article class="category-tile">
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
                    </article>
                </c:forEach>
            </div>
        </div>
    </section>

    <section class="section-band" id="products">
        <div class="container">
            <div class="section-title">
                <div>
                    <h2>Featured Products</h2>
                    <p>Top active items from the SmartPhone database.</p>
                </div>
                <a href="#" class="btn secondary-action px-3"><i class="bi bi-arrow-right"></i> View all</a>
            </div>

            <div class="product-grid">
                <c:forEach var="product" items="${featuredProducts}">
                    <article class="product-card">
                        <div class="product-visual image-missing">
                            <span class="stock-badge">
                                <c:choose>
                                    <c:when test="${product.inventoryAmount > 0}">${product.inventoryAmount} in stock</c:when>
                                    <c:otherwise>Out of stock</c:otherwise>
                                </c:choose>
                            </span>
                            <span class="product-ai-badge"><i class="bi bi-stars"></i>AI</span>
                            <div class="mock-phone-stage" aria-hidden="true">
                                <div class="mock-phone-back">
                                    <div class="mock-camera"></div>
                                </div>
                                <div class="mock-phone-front">
                                    <div class="mock-phone-screen">
                                        <div class="mock-product-name">${product.name}</div>
                                        <div class="mock-model"></div>
                                    </div>
                                </div>
                            </div>
                            <c:if test="${not empty product.image}">
                                <c:choose>
                                    <c:when test="${fn:startsWith(product.image, '/')}">
                                        <img src="${pageContext.request.contextPath}${product.image}" alt="${product.name}"
                                             onload="this.closest('.product-visual').classList.remove('image-missing')"
                                             onerror="this.remove()">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/${product.image}" alt="${product.name}"
                                             onload="this.closest('.product-visual').classList.remove('image-missing')"
                                             onerror="this.remove()">
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </div>
                        <div class="product-body">
                            <h3 class="product-name">${product.name}</h3>
                            <div class="product-specs">
                                <span class="spec-chip">Full HD+</span>
                                <span class="spec-chip">${product.secondSpec}</span>
                            </div>
                            <p class="product-promo">Online giá rẻ quá</p>
                            <div class="price-row">
                                <div class="price">
                                    <fmt:formatNumber value="${product.sellingPrice}" type="number" maxFractionDigits="0"/>đ
                                </div>
                            </div>
                            <div class="old-price-row">
                                <span class="old-price">
                                    <fmt:formatNumber value="${product.originalPrice}" type="number" maxFractionDigits="0"/>đ
                                </span>
                                <span class="discount-rate">-${product.discountPercent}%</span>
                            </div>
                            <div class="product-rating-row">
                                <i class="bi bi-star-fill"></i>
                                <span>${product.displayRating}</span>
                                <span>•</span>
                                <span>Đã bán ${product.soldText}</span>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </div>
    </section>

    <section class="section-band section-soft">
        <div class="container">
            <div class="promo-panel">
                <div>
                    <span class="eyebrow"><i class="bi bi-percent"></i> Smart upgrade</span>
                    <h2 class="fw-bold mt-3 mb-2">Flagship performance with store-ready support.</h2>
                    <p class="mb-4">Compare stock, warranty, and price before checkout. Your catalog data stays connected to the database behind the scene.</p>
                    <a class="btn primary-action px-4" href="#products"><i class="bi bi-phone-flip"></i> Pick a device</a>
                </div>
            </div>
        </div>
    </section>

    <section class="section-band" id="services">
        <div class="container">
            <div class="service-grid">
                <article class="service-item">
                    <i class="bi bi-truck"></i>
                    <div>
                        <h3>Fast Delivery</h3>
                        <p>Order flow prepared for delivery tracking and shipper updates.</p>
                    </div>
                </article>
                <article class="service-item">
                    <i class="bi bi-shield-check"></i>
                    <div>
                        <h3>Warranty First</h3>
                        <p>Warranty months are visible on each product card.</p>
                    </div>
                </article>
                <article class="service-item">
                    <i class="bi bi-credit-card"></i>
                    <div>
                        <h3>Flexible Payment</h3>
                        <p>Supports cash, bank transfer, and online payment records.</p>
                    </div>
                </article>
                <article class="service-item">
                    <i class="bi bi-chat-square-text"></i>
                    <div>
                        <h3>Feedback Ready</h3>
                        <p>Reviews and staff replies already fit the database model.</p>
                    </div>
                </article>
            </div>
        </div>
    </section>
</main>

<footer class="footer">
    <div class="container d-flex flex-column flex-md-row justify-content-between gap-3">
        <div><strong>SWP Mobile</strong><br><span>Smartphone store management and shopping experience.</span></div>
        <div class="d-flex gap-3">
            <a class="text-white-50" href="#products">Products</a>
            <a class="text-white-50" href="#categories">Categories</a>
            <a class="text-white-50" href="#services">Services</a>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
