<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>My Profile | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body>
        <c:set var="activePage" value="profile" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Profile Dashboard</h1>
                <p>Manage your customer information, delivery contact, and account details from one place.</p>
            </div>
        </section>

        <main class="dashboard-shell">
            <div class="container">
                <div class="dashboard-grid">
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
                            <a class="active" href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                            <c:if test="${fn:toLowerCase(profile.roleName) == 'admin'}">
                                <a href="${pageContext.request.contextPath}/admin/users">
                                    <i class="bi bi-people"></i> User Management
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/roles">
                                    <i class="bi bi-shield-lock"></i> Roles
                                </a>
                            </c:if>
                            <c:if test="${fn:toLowerCase(profile.roleName) == 'customer'}">
                                <a href="${pageContext.request.contextPath}/order-history">
                                    <i class="bi bi-receipt"></i> Order History
                                </a>
                                <a href="${pageContext.request.contextPath}/wishlist">
                                    <i class="bi bi-heart"></i> Wishlist
                                </a>
                                <a href="${pageContext.request.contextPath}/cart">
                                    <i class="bi bi-bag"></i> Cart
                                </a>
                                <a href="${pageContext.request.contextPath}/checkout">
                                    <i class="bi bi-bag-check"></i> Checkout
                                </a>
                            </c:if>
                            <c:if test="${fn:toLowerCase(profile.roleName) == 'shipper'}">
                                <a href="${pageContext.request.contextPath}/shipper/orders">
                                    <i class="bi bi-box-seam"></i> Delivery Orders
                                </a>
                            </c:if>
                            <c:if test="${fn:toLowerCase(profile.roleName) == 'staff'}">
                                <a href="${pageContext.request.contextPath}/staff/orders">
                                    <i class="bi bi-card-list"></i> Manage Orders
                                </a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/change-password">
                                <i class="bi bi-shield-lock"></i> Change Password
                            </a>
                            <a href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </nav>
                    </aside>

                    <section>
                        <div class="stat-grid">
                            <div class="stat-box">
                                <span>Account status</span>
                                <strong>${profile.status}</strong>
                            </div>
                            <div class="stat-box">
                                <span>Role</span>
                                <strong>${profile.roleName}</strong>
                            </div>
                            <div class="stat-box">
                                <span>Age</span>
                                <strong><c:out value="${empty profile.age ? '-' : profile.age}"/></strong>
                            </div>
                        </div>

                        <div class="panel content-panel">
                            <div class="d-flex align-items-center justify-content-between gap-3 flex-wrap mb-3">
                                <div>
                                    <h2 class="h4 fw-bold mb-1">Personal Information</h2>
                                    <p class="text-muted mb-0">Keep your contact information ready for checkout and delivery.</p>
                                </div>
                                <a class="btn secondary-action" href="${pageContext.request.contextPath}/products">
                                    <i class="bi bi-grid"></i> Continue shopping
                                </a>
                            </div>

                            <c:if test="${not empty error}">
                                <div class="alert alert-danger d-flex align-items-center gap-2">
                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                    <span>${error}</span>
                                </div>
                            </c:if>
                            <c:if test="${not empty success}">
                                <div class="alert alert-success d-flex align-items-center gap-2">
                                    <i class="bi bi-check-circle-fill"></i>
                                    <span>${success}</span>
                                </div>
                            </c:if>

                            <form method="post" action="${pageContext.request.contextPath}/profile" autocomplete="on">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label" for="username">Username</label>
                                        <input id="username" class="form-control readonly-field" value="${profile.username}" readonly>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label" for="email">Email</label>
                                        <input id="email" class="form-control readonly-field" value="${profile.email}" readonly>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label" for="name">Full name</label>
                                        <input id="name" name="name" class="form-control" value="${profile.name}"
                                               maxlength="255" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label" for="phone">Phone</label>
                                        <input id="phone" name="phone" class="form-control" value="${profile.phone}"
                                               placeholder="9-15 digits" maxlength="15">
                                    </div>

                                    <div class="col-md-4">
                                        <label class="form-label" for="age">Age</label>
                                        <input id="age" name="age" type="number" class="form-control"
                                               value="${profile.age}" min="13" max="100">
                                    </div>

                                    <div class="col-md-8">
                                        <label class="form-label" for="image">Avatar URL</label>
                                        <input id="image" name="image" class="form-control" value="${profile.image}"
                                               placeholder="https://..." maxlength="255">
                                    </div>

                                    <div class="col-12">
                                        <label class="form-label" for="address">Delivery address</label>
                                        <input id="address" name="address" class="form-control" value="${profile.address}"
                                               placeholder="Your delivery address" maxlength="255">
                                    </div>
                                </div>

                                <div class="d-flex align-items-center justify-content-end gap-2 mt-4">
                                    <button class="btn primary-action" type="submit">
                                        <i class="bi bi-save"></i> Save changes
                                    </button>
                                </div>
                            </form>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>

