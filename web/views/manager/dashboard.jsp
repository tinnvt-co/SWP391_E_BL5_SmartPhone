<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
    <title>Management Center</title>
    <%@include file="../common/head.jsp"%>
</head>
<body>
    <c:set var="pageRole" value="Manager"/>
    <c:set var="pageName" value="Dashboard"/>
    <%@include file="../common/topbar.jsp"%>

    <main class="page-shell manager-dashboard">
        <section class="manager-welcome">
            <div>
                <span class="manager-kicker">MANAGEMENT CENTER</span>
                <h1>Welcome back, <c:out value="${currentUser.name}"/>.</h1>
                <p>Manage your smartphone catalog, price segments and brands from one workspace.</p>
            </div>
            <a class="btn subtle manager-preview" href="${pageContext.request.contextPath}/home">
                View storefront →
            </a>
        </section>

        <section class="manager-summary-grid">
            <article>
                <span class="summary-icon blue">▦</span>
                <div><small>TOTAL PRODUCTS</small><strong>${totalProducts}</strong></div>
                <em>${activeProducts} active</em>
            </article>
            <article>
                <span class="summary-icon green">✓</span>
                <div><small>ACTIVE PRODUCTS</small><strong>${activeProducts}</strong></div>
                <em>Visible in the storefront</em>
            </article>
            <article>
                <span class="summary-icon orange">!</span>
                <div><small>OUT OF STOCK</small><strong>${outOfStockProducts}</strong></div>
                <em>Require attention</em>
            </article>
            <article>
                <span class="summary-icon purple">◇</span>
                <div><small>CATALOG STRUCTURE</small><strong>${totalCategories + totalBrands}</strong></div>
                <em>${totalCategories} categories · ${totalBrands} brands</em>
            </article>
        </section>

        <div class="manager-section-title">
            <span>YOUR WORKSPACE</span>
            <h2>What would you like to manage?</h2>
        </div>

        <section class="manager-module-grid">
            <a class="manager-module product-module" href="${pageContext.request.contextPath}/manager/products">
                <span class="module-icon">▦</span>
                <span class="module-count">${totalProducts} products</span>
                <h3>Manage Products</h3>
                <p>Add smartphones and update specifications, variants, prices, stock and product images.</p>
                <b>Open product management <span>→</span></b>
            </a>

            <a class="manager-module category-module" href="${pageContext.request.contextPath}/manager/categories">
                <span class="module-icon">◇</span>
                <span class="module-count">${totalCategories} categories</span>
                <h3>Manage Categories</h3>
                <p>Organize phones into price segments such as budget, mid-range and high-end.</p>
                <b>Open category management <span>→</span></b>
            </a>

            <a class="manager-module brand-module" href="${pageContext.request.contextPath}/manager/brands">
                <span class="module-icon">◎</span>
                <span class="module-count">${totalBrands} brands</span>
                <h3>Manage Brands</h3>
                <p>Maintain smartphone manufacturers and control which brands appear in the store.</p>
                <b>Open brand management <span>→</span></b>
            </a>
        </section>
    </main>
</body>
</html>
