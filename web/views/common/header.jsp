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
                    <c:if test="${currentRole ne 'Admin' and currentRole ne 'ADMIN' and currentRole ne 'Shipper' and currentRole ne 'SHIPPER' and currentRole ne 'Staff' and currentRole ne 'STAFF'}">
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
                    </c:if>
                    <c:if test="${currentRole == 'Admin' or currentRole == 'ADMIN'}">
                        <li>
                            <a class="swp-layout-link ${activePage == 'users' ? 'is-active' : ''}" href="${pageContext.request.contextPath}/admin/users">Users</a>
                        </li>
                        <li>
                            <a class="swp-layout-link ${activePage == 'roles' ? 'is-active' : ''}" href="${pageContext.request.contextPath}/admin/roles">Roles</a>
                        </li>
                    </c:if>
                    <c:if test="${currentRole == 'Shipper' or currentRole == 'SHIPPER'}">
                        <li>
                            <a class="swp-layout-link ${activePage == 'shipper-orders' ? 'is-active' : ''}" href="${pageContext.request.contextPath}/shipper/orders">Assigned Orders</a>
                        </li>
                    </c:if>
                    <c:if test="${currentRole == 'Staff' or currentRole == 'STAFF'}">
                        <li>
                            <a class="swp-layout-link ${activePage == 'staff-dashboard' ? 'is-active' : ''}" href="${pageContext.request.contextPath}/staff">Dashboard</a>
                        </li>
                        <li>
                            <a class="swp-layout-link ${activePage == 'staff-orders' ? 'is-active' : ''}" href="${pageContext.request.contextPath}/staff/orders">Manage Orders</a>
                        </li>
                    </c:if>
                </ul>

                <div class="swp-layout-actions">
                    <c:if test="${currentRole == 'Manager'}">
                        <a class="swp-layout-action swp-layout-action-manager"
                           href="${pageContext.request.contextPath}/manager">
                            <i class="bi bi-speedometer2"></i> Management Center
                        </a>
                    </c:if>

                    <c:if test="${currentRole == 'Staff' or currentRole == 'STAFF'}">
                        <a class="swp-layout-action swp-layout-action-staff"
                           href="${pageContext.request.contextPath}/staff">
                            <i class="bi bi-clipboard-check"></i> Staff manager
                        </a>
                    </c:if>

                    <c:if test="${currentRole ne 'Admin' and currentRole ne 'ADMIN' and currentRole ne 'Shipper' and currentRole ne 'SHIPPER' and currentRole ne 'Staff' and currentRole ne 'STAFF' and currentRole ne 'Manager' and currentRole ne 'MANAGER'}">
                        <c:if test="${empty currentUser || currentRole == 'Customer'}">
                            <a class="swp-layout-icon-btn ${activePage == 'wishlist' ? 'is-active' : ''}"
                               href="${pageContext.request.contextPath}/wishlist" title="Wishlist">
                                <i class="bi bi-heart"></i>
                                <c:if test="${wishlistCount > 0}">
                                    <span class="badge-count">${wishlistCount}</span>
                                </c:if>
                            </a>
                        </c:if>
                        <a class="swp-layout-icon-btn ${activePage == 'cart' ? 'is-active' : ''}" href="${pageContext.request.contextPath}/cart" title="Cart">
                            <i class="bi bi-bag"></i>
                            <c:if test="${cartCount > 0}">
                                <span class="badge-count">${cartCount}</span>
                            </c:if>
                        </a>
                    </c:if>

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
                                    <li>
                                        <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                            <i class="bi bi-person me-2"></i>Profile
                                        </a>
                                    </li>
                                    <c:if test="${currentRole == 'Customer' or currentRole == 'CUSTOMER'}">
                                        <li>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/chat" onclick="window.location.href=this.href;return true;">
                                                <i class="bi bi-chat-dots me-2"></i>Chat with Manager
                                            </a>
                                        </li>
                                    </c:if>
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
                </div>
            </div>
        </div>
    </nav>
</header>
<script>
    (function () {
        document.addEventListener('click', function (event) {
            if (window.bootstrap) {
                return;
            }

            var dropdownButton = event.target.closest('[data-bs-toggle="dropdown"]');
            if (dropdownButton) {
                event.preventDefault();
                var menu = dropdownButton.parentElement ? dropdownButton.parentElement.querySelector('.dropdown-menu') : null;
                document.querySelectorAll('.dropdown-menu.show').forEach(function (openMenu) {
                    if (openMenu !== menu) {
                        openMenu.classList.remove('show');
                    }
                });
                if (menu) {
                    menu.classList.toggle('show');
                    dropdownButton.setAttribute('aria-expanded', menu.classList.contains('show') ? 'true' : 'false');
                }
                return;
            }

            // Handle dropdown item click - navigate normally
            var dropdownItem = event.target.closest('.dropdown-item');
            if (dropdownItem && dropdownItem.href) {
                var menu = dropdownItem.closest('.dropdown-menu');
                if (menu) {
                    menu.classList.remove('show');
                }
                window.location.href = dropdownItem.href;
                return;
            }

            var collapseButton = event.target.closest('[data-bs-toggle="collapse"]');
            if (collapseButton) {
                event.preventDefault();
                var target = document.querySelector(collapseButton.getAttribute('data-bs-target'));
                if (target) {
                    target.classList.toggle('show');
                    collapseButton.setAttribute('aria-expanded', target.classList.contains('show') ? 'true' : 'false');
                }
                return;
            }

            document.querySelectorAll('.dropdown-menu.show').forEach(function (openMenu) {
                openMenu.classList.remove('show');
            });
        });
    })();
</script>
