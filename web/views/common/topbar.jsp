<header class="topbar">
    <button class="menu-button" type="button" onclick="document.body.classList.toggle('nav-open')" aria-label="Menu">☰</button>
    <nav class="breadcrumb"><a href="${pageContext.request.contextPath}/manager">Manager</a><b>/</b><strong>${pageName}</strong></nav>
    <div class="top-user"><a class="manager-store-link" href="${pageContext.request.contextPath}/home">View storefront</a><span class="role-pill role-manager">Manager</span><span class="avatar">M</span></div>
</header>
<aside class="side-nav">
    <div class="manager-nav-brand"><span>S</span><div><strong>SmartPhone</strong><small>Management Center</small></div></div>
    <p class="manager-nav-label">YOUR WORKSPACE</p>
    <a class="${pageName == 'Dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager">Dashboard</a>
    <a href="${pageContext.request.contextPath}/products">View Products</a>
    <a class="${pageName == 'Manage Products' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/products">Manage Products</a>
    <a class="${pageName == 'Manage Category' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/categories">Manage Category</a>
    <a class="${pageName == 'Manage Brand' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/brands">Manage Brand</a>
    <a href="${pageContext.request.contextPath}/manager/inventory">Manage Inventory</a>
    <a href="${pageContext.request.contextPath}/manager/discounts">Manage Discount</a>
    <a href="${pageContext.request.contextPath}/manager/sales-stats">Sales Statistics</a>
    <a href="${pageContext.request.contextPath}/manager/revenue" style="background:linear-gradient(90deg,#4361ee22,#4361ee05);color:var(--blue);font-weight:700">📊 Revenue Dashboard</a>
    <a href="${pageContext.request.contextPath}/manager/orders">Manage Orders</a>
    <a href="${pageContext.request.contextPath}/staff/orders">Staff Orders</a>
</aside>
