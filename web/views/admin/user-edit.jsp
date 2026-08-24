<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit User | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body {
                background: #f6f8fb;
                color: #111827;
            }

            .profile-hero {
                background:
                    linear-gradient(120deg, rgba(17, 24, 39, 0.9), rgba(22, 101, 216, 0.78)),
                    url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center right / cover no-repeat;
                color: #ffffff;
                padding: 56px 0 92px;
            }

            .profile-hero h1 {
                margin: 0 0 10px;
                font-size: clamp(2rem, 5vw, 3.2rem);
                font-weight: 900;
            }

            .profile-hero p {
                max-width: 660px;
                margin: 0;
                color: rgba(255, 255, 255, 0.78);
            }

            .dashboard-shell {
                margin-top: -58px;
                padding-bottom: 64px;
            }

            .dashboard-grid {
                display: grid;
                grid-template-columns: minmax(250px, 320px) minmax(0, 1fr);
                gap: 22px;
                align-items: start;
            }

            .panel {
                background: #ffffff;
                border: 1px solid rgba(15, 23, 42, 0.08);
                border-radius: 8px;
                box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
            }

            .profile-card {
                padding: 24px;
                position: sticky;
                top: 92px;
            }

            .avatar {
                width: 92px;
                height: 92px;
                border-radius: 50%;
                object-fit: cover;
                border: 4px solid #ffffff;
                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.14);
                background: #e2e8f0;
            }

            .avatar-fallback {
                width: 92px;
                height: 92px;
                border-radius: 50%;
                display: grid;
                place-items: center;
                color: #ffffff;
                background: linear-gradient(135deg, #1665d8, #17a673);
                font-size: 2.3rem;
                font-weight: 900;
                border: 4px solid #ffffff;
                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.14);
            }

            .role-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 7px 11px;
                border-radius: 999px;
                color: #14532d;
                background: #dcfce7;
                font-size: 0.8rem;
                font-weight: 800;
            }

            .profile-menu {
                display: grid;
                gap: 8px;
                margin-top: 22px;
            }

            .profile-menu a {
                min-height: 42px;
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 0 12px;
                border-radius: 8px;
                color: #475569;
                text-decoration: none;
                font-weight: 750;
            }

            .profile-menu a.active,
            .profile-menu a:hover {
                color: #1665d8;
                background: #eff6ff;
            }

            .content-panel {
                padding: 32px;
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="profile" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Edit User</h1>
                <p>Update information for @${user.username}.</p>
            </div>
        </section>

        <main class="dashboard-shell">
            <div class="container">
                <div class="dashboard-grid">
                    <aside class="panel profile-card">
                        <div class="d-flex align-items-center gap-3">
                            <c:choose>
                                <c:when test="${not empty currentUser.image}">
                                    <img class="avatar" src="${pageContext.request.contextPath}${currentUser.image}" alt="${currentUser.name}">
                                </c:when>
                                <c:otherwise>
                                    <div class="avatar-fallback">${fn:substring(currentUser.name, 0, 1)}</div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <h2 class="h5 fw-black mb-1">${currentUser.name}</h2>
                                <div class="text-muted small">@${currentUser.username}</div>
                            </div>
                        </div>

                        <div class="mt-4">
                            <span class="role-pill">
                                <i class="bi bi-shield-check"></i> ${currentRole}
                            </span>
                        </div>

                        <nav class="profile-menu">
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="bi bi-speedometer2"></i> Dashboard
                            </a>
                            <a class="active" href="${pageContext.request.contextPath}/admin/users">
                                <i class="bi bi-people"></i> User Management
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/roles">
                                <i class="bi bi-shield-lock"></i> Roles
                            </a>
                            <a href="${pageContext.request.contextPath}/change-password">
                                <i class="bi bi-key"></i> Change Password
                            </a>
                            <a href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </nav>
                    </aside>

                    <section class="panel content-panel">
                        <div class="mb-4 d-flex align-items-center gap-3">
                            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-light rounded-circle" title="Back to users">
                                <i class="bi bi-arrow-left"></i>
                            </a>
                            <h2 class="h4 fw-bold mb-0">Update Details</h2>
                        </div>

                        <c:if test="${not empty errors}">
                            <div class="alert alert-danger mb-4">
                                <ul class="mb-0">
                                    <c:forEach items="${errors}" var="err">
                                        <li>${err}</li>
                                    </c:forEach>
                                </ul>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/admin/users" method="POST">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${user.id}">

                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label for="username" class="form-label fw-bold">Username</label>
                                    <input type="text" class="form-control bg-light" id="username" name="username" value="${user.username}" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label for="name" class="form-label fw-bold">Full Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="name" name="name" value="${user.name}" required maxlength="50"
                                           placeholder="User's full name">
                                </div>
                                <div class="col-md-6">
                                    <label for="email" class="form-label fw-bold">Email <span class="text-danger">*</span></label>
                                    <input type="email" class="form-control" id="email" name="email" value="${user.email}" required
                                           placeholder="user@example.com">
                                </div>
                                <div class="col-md-6">
                                    <label for="phone" class="form-label fw-bold">Phone Number <span class="text-danger">*</span></label>
                                    <input type="tel" class="form-control" id="phone" name="phone" value="${user.phone}" required
                                           placeholder="0xxxxxxxxx (10 digits)">
                                </div>
                                <div class="col-md-6">
                                    <label for="age" class="form-label fw-bold">Age</label>
                                    <input type="number" class="form-control" id="age" name="age" value="${user.age}" min="10" max="100"
                                           placeholder="10 - 100">
                                </div>
                                <div class="col-md-6">
                                    <label for="roleId" class="form-label fw-bold">Role <span class="text-danger">*</span></label>
                                    <select class="form-select" id="roleId" name="roleId" required>
                                        <option value="" disabled>Select Role...</option>
                                        <c:forEach items="${roles}" var="role">
                                            <c:if test="${(role.status == 'ACTIVE' || user.roleId == role.id) && fn:toLowerCase(role.name) != 'admin'}">
                                                <option value="${role.id}" ${user.roleId == role.id ? 'selected' : ''}>${role.name}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label for="address" class="form-label fw-bold">Address</label>
                                    <textarea class="form-control" id="address" name="address" rows="3" placeholder="Optional">${user.address}</textarea>
                                </div>
                            </div>
                            <hr class="my-4">
                            <div class="d-flex justify-content-end gap-2">
                                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-light px-4 fw-bold">Cancel</a>
                                <button type="submit" class="btn btn-primary px-5 fw-bold">Save Changes</button>
                            </div>
                        </form>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
