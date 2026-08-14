<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="swp-layout-header">
    <div class="swp-layout-topbar">
        <div class="swp-layout-container swp-layout-topbar-inner">
            <span><i class="bi bi-truck"></i> Fast delivery for Ho Chi Minh City and Ha Noi</span>
            <span><i class="bi bi-shield-check"></i> Official warranty on every active product</span>
        </div>
    </div>

    <nav class="swp-layout-nav">
        <div class="swp-layout-container swp-layout-nav-inner">
            <a class="swp-layout-brand" href="${pageContext.request.contextPath}/home">
                <span class="swp-layout-brand-mark">S</span>
                <span>SmartPhone store</span>
            </a>

            <button class="swp-layout-toggler navbar-toggler" type="button" data-bs-toggle="collapse"
                    data-bs-target="#mainNav" aria-controls="mainNav" aria-expanded="false"
                    aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="swp-layout-collapse collapse navbar-collapse" id="mainNav">
                <ul class="swp-layout-links">
                    <li>
                        <a class="swp-layout-link ${activePage == 'home' ? 'is-active' : ''}"
                           href="${pageContext.request.contextPath}/home">Home</a>
                    </li>
                    <li>
                        <a class="swp-layout-link ${activePage == 'products' ? 'is-active' : ''}"
                           href="${pageContext.request.contextPath}/products">Products</a>
                    </li>
                    <li>
                        <a class="swp-layout-link" href="${pageContext.request.contextPath}/home#categories">Categories</a>
                    </li>
                    <li>
                        <a class="swp-layout-link" href="${pageContext.request.contextPath}/home#services">Services</a>
                    </li>
                </ul>

                <div class="swp-layout-actions">
                    <c:if test="${currentRole == 'Manager'}">
                        <a class="swp-layout-action swp-layout-action-manager"
                           href="${pageContext.request.contextPath}/manager">
                            <i class="bi bi-speedometer2"></i> Management Center
                        </a>
                    </c:if>
                    <c:if test="${currentRole == 'Staff'}">
                        <a class="swp-layout-action swp-layout-action-staff"
                           href="${pageContext.request.contextPath}/staff">
                            <i class="bi bi-clipboard-check"></i> Staff Center
                        </a>
                    </c:if>

                    <button class="swp-layout-icon-btn" type="button" title="Search">
                        <i class="bi bi-search"></i>
                    </button>
                    <c:if test="${empty currentUser || currentRole == 'Customer'}">
                        <a class="swp-layout-icon-btn ${activePage == 'wishlist' ? 'is-active' : ''}"
                           href="${pageContext.request.contextPath}/wishlist" title="Wishlist">
                            <i class="bi bi-heart"></i>
                        </a>
                    </c:if>
                    <a class="swp-layout-icon-btn" href="${pageContext.request.contextPath}/cart" title="Cart">
                        <i class="bi bi-bag"></i>
                    </a>

                    <c:choose>
                        <c:when test="${not empty currentUser}">
                            <div class="dropdown">
                                <button class="swp-layout-action swp-layout-action-secondary dropdown-toggle"
                                        type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="bi bi-person-circle"></i> ${currentUser.name}
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li>
                                        <h6 class="dropdown-header">${currentRole}</h6>
                                    </li>
                                    <c:if test="${currentRole == 'Staff'}">
                                        <li>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/staff">
                                                <i class="bi bi-clipboard-check me-2"></i>Staff Center
                                            </a>
                                        </li>
                                    </c:if>
                                    <li>
                                        <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                            <i class="bi bi-person me-2"></i>Profile
                                        </a>
                                    </li>
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
                            <a class="swp-layout-action swp-layout-action-secondary"
                               href="${pageContext.request.contextPath}/login">
                                <i class="bi bi-box-arrow-in-right"></i> Login
                            </a>
                        </c:otherwise>
                    </c:choose>

                    <a class="swp-layout-action swp-layout-action-primary"
                       href="${pageContext.request.contextPath}/products">
                        <i class="bi bi-grid"></i> Shop
                    </a>
                </div>
            </div>
        </div>
    </nav>
</header>
