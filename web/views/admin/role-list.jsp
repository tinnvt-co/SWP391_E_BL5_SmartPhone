<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Roles | SmartPhone store</title>
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
                padding: 24px;
            }

            .table-panel {
                margin-top: 18px;
                overflow: hidden;
                border: 1px solid rgba(15, 23, 42, 0.08);
                border-radius: 8px;
                background: #fff;
            }

            .table {
                margin-bottom: 0;
            }

            .table > :not(caption) > * > * {
                padding: 1rem 1.15rem;
                border-bottom-color: #eef2f7;
            }

            .table-light th {
                background: #f8fafc;
                color: #64748b;
                font-size: 0.75rem;
                font-weight: 800;
                letter-spacing: 0.07em;
                text-transform: uppercase;
            }

            .role-id {
                color: #64748b;
                font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
                font-size: 0.9rem;
            }

            .badge-soft-success {
                background: #ecfdf5;
                color: #10b981;
            }

            .badge-soft-danger {
                background: #fef2f2;
                color: #ef4444;
            }

            .badge-soft-success,
            .badge-soft-danger {
                font-weight: 800;
                padding: 0.42em 0.75em;
            }

            @media (max-width: 991.98px) {
                .dashboard-grid {
                    grid-template-columns: 1fr;
                }

                .profile-card {
                    position: static;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="profile" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Role Management</h1>
                <p>Manage system roles, permissions, and security access levels.</p>
            </div>
        </section>

        <main class="dashboard-shell">
            <div class="container">
                <div class="dashboard-grid">
                    <aside class="panel profile-card">
                        <div class="d-flex align-items-center gap-3">
                            <c:choose>
                                <c:when test="${not empty currentUser.image}">
                                    <img class="avatar" src="${currentUser.image}" alt="${currentUser.name}">
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
                            <a href="${pageContext.request.contextPath}/admin/users">
                                <i class="bi bi-people"></i> User Management
                            </a>
                            <a class="active" href="${pageContext.request.contextPath}/admin/roles">
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
                        <div class="d-flex align-items-end justify-content-between gap-3 flex-wrap">
                            <div>
                                <h2 class="h4 fw-bold mb-1">Role Management</h2>
                                <p class="text-muted mb-0">${roles.size()} roles found</p>
                            </div>
                        </div>

                        <div class="table-panel table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th class="text-nowrap">Role Name</th>
                                        <th>Permissions</th>
                                        <th class="text-nowrap">Created At</th>
                                        <th class="text-nowrap">Updated At</th>
                                        <th class="text-nowrap">Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${roles}" var="r">
                                        <tr>
                                            <td class="text-nowrap">
                                                <div class="fw-bold text-dark"><c:out value="${r.name}"/></div>
                                            </td>
                                            <td>
                                                <c:forEach items="${r.permissions}" var="p">
                                                    <span class="badge rounded-pill bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 me-1 mb-1 fw-semibold"><c:out value="${p}"/></span>
                                                </c:forEach>
                                                <c:if test="${empty r.permissions}">
                                                    <span class="text-muted small fst-italic">No permissions</span>
                                                </c:if>
                                            </td>
                                            <td class="text-secondary text-nowrap">
                                                <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td class="text-secondary text-nowrap">
                                                <fmt:formatDate value="${r.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td class="text-nowrap">
                                                <span class="badge rounded-pill ${r.status == 'ACTIVE' ? 'badge-soft-success' : 'badge-soft-danger'}">
                                                    <c:out value="${r.status}"/>
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty roles}">
                                        <tr>
                                            <td colspan="5" class="text-center py-4 text-muted">No roles found.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
