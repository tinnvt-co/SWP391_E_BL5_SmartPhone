<%-- 
    Document   : profile-sidebar
    Created on : Aug 24, 2026, 12:27:20 AM
    Author     : KhanhVNHE191788
--%>

<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Reusable profile sidebar.

    Requires:
      - request attribute "profile" (name, username, image, roleName)
        to already be set by the calling controller.
      - request attribute "sidebarActive" set by the including page
        BEFORE the include, so the right link gets the "active" class.
        Values used below: profile | storeinfo | admin-users | admin-roles
        | order-history | wishlist | cart | shipper-orders | staff-orders
        | change-password

    Usage in a page:
      <c:set var="sidebarActive" value="profile" scope="request"/>
      <div class="dashboard-grid">
          <%@ include file="/views/common/profile-sidebar.jsp" %>
          <section> ... page content ... </section>
      </div>
--%>
<aside class="panel profile-card">
    <div class="d-flex align-items-center gap-3">
        <c:choose>
            <c:when test="${not empty profile.image}">
                <img class="avatar" src="${profile.image}" alt="${profile.name}">
            </c:when>
            <c:otherwise>
                <div class="avatar-fallback">${fn:substring(profile.name, 0, 1)}</div>
            </c:otherwise>
        </c:choose>
        <div>
            <h2 class="h5 fw-black mb-1">${profile.name}</h2>
            <div class="text-muted small">@${profile.username}</div>
        </div>
    </div>

    <div class="mt-4">
        <span class="role-pill">
            <i class="bi bi-shield-check"></i> ${profile.roleName}
        </span>
    </div>

    <nav class="profile-menu">
        <a class="${sidebarActive == 'profile' ? 'active' : ''}"
           href="${pageContext.request.contextPath}/profile">
            <i class="bi bi-person"></i> My Profile
        </a>

        <c:if test="${fn:toLowerCase(profile.roleName) == 'manager'}">
            <a class="${sidebarActive == 'storeinfo' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/manager/storeinfo">
                <i class="bi bi-house-door"></i> Store Information
            </a>
        </c:if>

        <c:if test="${fn:toLowerCase(profile.roleName) == 'admin'}">
            <a class="${sidebarActive == 'admin-users' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/users">
                <i class="bi bi-people"></i> User Management
            </a>
            <a class="${sidebarActive == 'admin-roles' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/roles">
                <i class="bi bi-shield-lock"></i> Roles
            </a>
        </c:if>

        <c:if test="${fn:toLowerCase(profile.roleName) == 'customer'}">
            <a class="${sidebarActive == 'order-history' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/order-history">
                <i class="bi bi-receipt"></i> Order History
            </a>
            <a class="${sidebarActive == 'wishlist' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/wishlist">
                <i class="bi bi-heart"></i> Wishlist
            </a>
            <a class="${sidebarActive == 'cart' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/cart">
                <i class="bi bi-bag"></i> Cart
            </a>
        </c:if>

        <c:if test="${fn:toLowerCase(profile.roleName) == 'shipper'}">
            <a class="${sidebarActive == 'shipper-orders' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/shipper/orders">
                <i class="bi bi-box-seam"></i> Delivery Orders
            </a>
        </c:if>

        <c:if test="${fn:toLowerCase(profile.roleName) == 'staff'}">
            <a class="${sidebarActive == 'staff-orders' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/staff/orders">
                <i class="bi bi-card-list"></i> Manage Orders
            </a>
        </c:if>

        <a class="${sidebarActive == 'change-password' ? 'active' : ''}"
           href="${pageContext.request.contextPath}/change-password">
            <i class="bi bi-shield-lock"></i> Change Password
        </a>

        <a href="${pageContext.request.contextPath}/logout">
            <i class="bi bi-box-arrow-right"></i> Logout
        </a>
    </nav>
</aside>

