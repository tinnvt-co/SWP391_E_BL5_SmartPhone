<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/home">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'products' ? 'active' : ''}" href="${pageContext.request.contextPath}/products">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/home#categories">Categories</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/home#services">Services</a>
                </li>
            </ul>
            <div class="d-flex align-items-center gap-2 flex-wrap">
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
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                        <i class="bi bi-person me-2"></i>Profile
                                    </a>
                                </li>
                                <li><a class="dropdown-item" href="#"><i class="bi bi-receipt me-2"></i>Orders</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                                        <i class="bi bi-box-arrow-right me-2"></i>Logout
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a class="btn secondary-action px-3" href="${pageContext.request.contextPath}/login">
                            <i class="bi bi-box-arrow-in-right"></i> Login
                        </a>
                    </c:otherwise>
                </c:choose>
                <a class="btn primary-action px-3" href="${pageContext.request.contextPath}/products">
                    <i class="bi bi-grid"></i> Shop
                </a>
            </div>
        </div>
    </div>
</nav>
