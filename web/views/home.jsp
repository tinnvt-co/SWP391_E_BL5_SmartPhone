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
            color: inherit;
            text-decoration: none;
        }

        .category-tile:hover { color: inherit; }

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
            color: inherit;
            text-decoration: none;
            display: block;
        }

        .product-card:hover {
            transform: translateY(-3px);
            border-color: rgba(240, 93, 79, 0.35);
            box-shadow: 0 18px 42px rgba(23, 32, 42, 0.1);
            color: inherit;
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

        .home-feature-card {
            min-height: 650px;
            border-color: #dde2e8;
            border-radius: 12px;
            box-shadow: 0 5px 18px rgba(25, 35, 50, 0.12);
            display: flex;
            flex-direction: column;
        }

        .home-feature-card .product-visual {
            height: 360px;
            aspect-ratio: auto;
            padding: 30px 48px 22px;
        }

        .home-feature-card .product-visual img {
            object-fit: contain;
        }

        .product-heart {
            position: absolute;
            right: 28px;
            top: 26px;
            z-index: 4;
            width: 40px;
            height: 40px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #111;
            font-size: 31px;
        }

        .product-label {
            position: absolute;
            left: 20px;
            bottom: 0;
            z-index: 3;
            background: #d90000;
            color: #fff;
            border-radius: 999px;
            padding: 12px 20px;
            font-size: 18px;
            line-height: 1;
            font-weight: 500;
        }

        .home-feature-card .product-body {
            flex: 1;
            display: flex;
            flex-direction: column;
            padding: 28px 20px 24px;
        }

        .home-feature-content {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .home-feature-card .eyebrow {
            display: block;
            color: #697386;
            font-size: 19px;
            letter-spacing: 0;
            margin-bottom: 16px;
        }

        .home-title {
            min-height: 62px;
            margin-bottom: 22px;
            color: #111827;
            font-size: 24px;
            line-height: 1.28;
            font-weight: 500;
        }

        .home-feature-card .product-body > .product-name,
        .home-feature-card .product-body > .product-specs,
        .home-feature-card .product-body > .product-promo,
        .home-feature-card .product-body > .price-row,
        .home-feature-card .product-body > .old-price-row,
        .home-feature-card .product-body > .product-rating-row {
            display: none;
        }

        .home-memory-options {
            display: flex;
            flex-wrap: wrap;
            gap: 11px;
            margin-bottom: 12px;
        }

        .home-memory-chip {
            min-width: 120px;
            min-height: 50px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid #d8dee7;
            border-radius: 12px;
            color: #333a45;
            background: #fff;
            font-size: 17px;
            font-weight: 500;
        }

        .home-memory-chip:first-child {
            border-color: #1f6fff;
            box-shadow: 0 0 0 1px #1f6fff inset;
            color: #085dff;
        }

        .home-color-options {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin: 2px 0 26px;
        }

        .home-color-dot {
            width: 42px;
            height: 42px;
            border: 4px solid #fff;
            border-radius: 50%;
            background: var(--variant-color, #d1d5db);
            box-shadow: 0 0 0 2px #cdd2d8;
        }

        .home-color-dot:first-child {
            box-shadow: 0 0 0 3px #357cff;
        }

        .home-price-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin: 0 0 22px;
        }

        .home-price-row .price {
            color: #b40000;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            font-size: 31px;
            font-weight: 850;
        }

        .home-cart-icon {
            position: relative;
            min-width: 62px;
            height: 56px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #91858f;
            font-size: 38px;
        }

        .home-cart-icon span {
            position: absolute;
            right: 0;
            top: 0;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #5543c9;
            color: #fff;
            font-size: 22px;
            line-height: 27px;
            text-align: center;
        }

        .home-warranty {
            margin-top: auto;
            min-height: 74px;
            display: flex;
            align-items: center;
            border-radius: 10px;
            background: #f0f1f4;
            color: #555d69;
            padding: 16px;
            font-size: 19px;
            line-height: 1.35;
        }

        .home-feature-card .product-rating-row {
            margin-top: 22px;
            gap: 6px;
            color: #ff7900;
            font-size: 17px;
        }

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
                <span class="eyebrow"><i class="bi bi-lightning-charge-fill"></i> New devices in stock</span>
                <h1>SmartPhone store</h1>
                <p>
                    Discover flagship smartphones, tablets, and accessories with clear pricing,
                    live stock visibility, and a clean shopping flow built for everyday buyers.
                </p>
                <div class="d-flex flex-wrap gap-2 mt-4">
                <a class="btn primary-action px-4" href="${pageContext.request.contextPath}/products"><i class="bi bi-bag-check"></i> Explore products</a>
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
            <div class="section-title">
                <div>
                    <h2>Featured Products</h2>
                    <p>Top active items from the SmartPhone database.</p>
                </div>
                <a href="${pageContext.request.contextPath}/products" class="btn secondary-action px-3"><i class="bi bi-arrow-right"></i> View all</a>
            </div>

            <div class="product-grid">
                <c:forEach var="product" items="${featuredProducts}">
                    <a class="product-card home-feature-card" href="${pageContext.request.contextPath}/products?action=detail&id=${product.id}">
                        <div class="product-visual image-missing">
                            <span class="product-heart"><i class="bi bi-heart"></i></span>
                            <span class="product-label">H&agrave;ng ch&iacute;nh h&atilde;ng</span>
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
                            <div class="home-feature-content">
                                <span class="eyebrow"><c:out value="${product.brandName}"/></span>
                                <h3 class="home-title">${product.name}</h3>
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
                                                    <span class="home-color-dot" title="${color.colorName}" style="--variant-color:${color.colorHex}"></span>
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
                                        <fmt:formatNumber value="${not empty product.variants ? product.variants[0].sellingPrice : product.finalPrice}" type="number" maxFractionDigits="0"/> &#273;
                                    </div>
                                    <span class="home-cart-icon"><i class="bi bi-cart3"></i><span>+</span></span>
                                </div>
                                <div class="home-warranty">B&#7843;o h&agrave;nh ch&iacute;nh h&atilde;ng ${product.warrantyMonths} th&aacute;ng</div>
                                <div class="product-rating-row">
                                    <i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i>
                                </div>
                            </div>
                            <h3 class="product-name">${product.name}</h3>
                            <div class="product-specs">
                                <span class="spec-chip">Full HD+</span>
                                <span class="spec-chip">${product.secondSpec}</span>
                            </div>
                            <p class="product-promo">Online giÃ¡ ráº» quÃ¡</p>
                            <div class="price-row">
                                <div class="price">
                                    <fmt:formatNumber value="${product.sellingPrice}" type="number" maxFractionDigits="0"/>Ä‘
                                </div>
                            </div>
                            <div class="old-price-row">
                                <span class="old-price">
                                    <fmt:formatNumber value="${product.originalPrice}" type="number" maxFractionDigits="0"/>Ä‘
                                </span>
                                <span class="discount-rate">-${product.discountPercent}%</span>
                            </div>
                            <div class="product-rating-row">
                                <i class="bi bi-star-fill"></i>
                                <span>${product.displayRating}</span>
                                <span>â€¢</span>
                                <span>ÄÃ£ bÃ¡n ${product.soldText}</span>
                            </div>
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

<%@ include file="/views/common/footer.jsp" %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

