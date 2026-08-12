<%@page contentType="text/html" pageEncoding="UTF-8"%>
<header class="topbar">
    <button class="menu-button" type="button" onclick="document.body.classList.toggle('nav-open')" aria-label="Menu">☰</button>
    <nav class="breadcrumb"><span class="role-${pageRole == 'Manager' ? 'manager' : 'public'}">${pageRole}</span><b>/</b><strong>${pageName}</strong></nav>
    <div class="top-user"><span class="role-pill role-${pageRole == 'Manager' ? 'manager' : 'public'}">${pageRole}</span><span class="avatar">NVA</span></div>
</header>
<aside class="side-nav">
    <a href="${pageContext.request.contextPath}/products">View Products</a>
    <a href="${pageContext.request.contextPath}/manager/products">Manage Products</a>
    <a href="${pageContext.request.contextPath}/manager/categories">Manage Category</a>
    <a href="${pageContext.request.contextPath}/manager/brands">Manage Brand</a>
    <a href="${pageContext.request.contextPath}/manager/inventory">Manage Inventory</a>
    <a href="${pageContext.request.contextPath}/manager/discounts">Manage Discount</a>
    <a href="${pageContext.request.contextPath}/manager/sales-stats">Sales Statistics</a>
    <a href="${pageContext.request.contextPath}/manager/revenue" style="background:linear-gradient(90deg,#4361ee22,#4361ee05);color:var(--blue);font-weight:700">📊 Revenue Dashboard</a>
    <a href="${pageContext.request.contextPath}/manager/orders">Manage Orders</a>
    <a href="${pageContext.request.contextPath}/staff/orders">Staff Orders</a>
</aside>
