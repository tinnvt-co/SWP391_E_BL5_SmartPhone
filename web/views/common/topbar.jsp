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
</aside>
