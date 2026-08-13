<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="topbarRole" value="${not empty pageRole ? pageRole : (currentRole == 'Staff' ? 'Staff' : (currentRole == 'Manager' ? 'Manager' : 'Customer'))}"/>
<c:set var="topbarHome" value="${topbarRole == 'Staff' ? '/staff' : (topbarRole == 'Manager' ? '/manager' : '/home')}"/>
<c:set var="topbarInitial" value="${topbarRole == 'Staff' ? 'S' : (topbarRole == 'Manager' ? 'M' : 'C')}"/>
<c:set var="topbarBrand" value="${topbarRole == 'Staff' ? 'Staff Center' : (topbarRole == 'Manager' ? 'Management Center' : 'SmartPhone')}"/>
<header class="topbar">
    <button class="menu-button" type="button" onclick="document.body.classList.toggle('nav-open')" aria-label="Menu">&#9776;</button>
    <nav class="breadcrumb"><a href="${pageContext.request.contextPath}${topbarHome}">${topbarRole}</a><b>/</b><strong>${pageName}</strong></nav>
    <div class="top-user"><a class="manager-store-link" href="${pageContext.request.contextPath}/home">View storefront</a><span class="role-pill role-${topbarRole == 'Staff' ? 'staff' : 'manager'}">${topbarRole}</span><span class="avatar">${topbarInitial}</span></div>
</header>
<aside class="side-nav">
    <div class="manager-nav-brand"><span>S</span><div><strong>SmartPhone</strong><small>${topbarBrand}</small></div></div>

    <p class="manager-nav-label">OVERVIEW</p>
    <a class="${pageName == 'Dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}${topbarHome}">
        <span class="nav-icon"></span>Dashboard
    </a>

    <c:choose>
        <c:when test="${topbarRole == 'Staff'}">
            <p class="manager-nav-label">OPERATIONS</p>
            <a class="${pageName == 'Manage Orders' || pageName == 'Order Detail' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/orders">
                <span class="nav-icon"></span>Manage Orders
            </a>
        </c:when>
        <c:otherwise>
            <p class="manager-nav-label">CATALOG</p>
            <a href="${pageContext.request.contextPath}/products"><span class="nav-icon"></span>View Products</a>
            <a class="${pageName == 'Manage Products' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/products">
                <span class="nav-icon"></span>Manage Products
            </a>
            <a class="${pageName == 'Manage Category' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/categories">
                <span class="nav-icon"></span>Manage Category
            </a>
            <a class="${pageName == 'Manage Brand' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/brands">
                <span class="nav-icon"></span>Manage Brand
            </a>

            <p class="manager-nav-label">OPERATIONS</p>
            <a class="${pageName == 'Manage Inventory' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/inventory">
                <span class="nav-icon"></span>Manage Inventory
            </a>
            <a class="${pageName == 'Manage Orders' || pageName == 'Order Detail' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/orders">
                <span class="nav-icon"></span>Manage Orders
            </a>
            <a href="${pageContext.request.contextPath}/staff/orders"><span class="nav-icon"></span>Staff Orders</a>

            <p class="manager-nav-label">PROMOTIONS</p>
            <a class="${pageName == 'Manage Discount' || pageName == 'Add Discount' || pageName == 'Edit Discount' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/discounts">
                <span class="nav-icon"></span>Manage Discount
            </a>

            <p class="manager-nav-label">ANALYTICS</p>
            <a class="${pageName == 'Sales Statistics' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/sales-stats">
                <span class="nav-icon"></span>Sales Statistics
            </a>
            <a class="${pageName == 'Revenue' ? 'active' : ''} nav-emphasis" href="${pageContext.request.contextPath}/manager/revenue">
                <span class="nav-icon"></span>Revenue Dashboard
            </a>
        </c:otherwise>
    </c:choose>
</aside>