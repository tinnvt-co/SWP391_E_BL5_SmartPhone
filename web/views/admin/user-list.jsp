<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>User Management | SmartPhone store</title>
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

            .user-avatar,
            .user-avatar-fallback {
                width: 42px;
                height: 42px;
                border-radius: 50%;
                border: 2px solid #fff;
                box-shadow: 0 3px 10px rgba(15, 23, 42, 0.08);
            }

            .user-avatar {
                object-fit: cover;
            }

            .user-avatar-fallback {
                display: grid;
                place-items: center;
                background: linear-gradient(135deg, #e2e8f0, #cbd5e1);
                color: #334155;
                font-weight: 900;
            }

            .user-id {
                color: #64748b;
                font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
                font-size: 0.9rem;
            }

            .badge-soft-success {
                background: #ecfdf5;
                color: #10b981;
            }

            .badge-soft-primary {
                background: #eff6ff;
                color: #3b82f6;
            }

            .badge-soft-info {
                background: #f0fdfa;
                color: #0d9488;
            }

            .badge-soft-danger {
                background: #fef2f2;
                color: #ef4444;
            }

            .badge-soft-secondary {
                background: #f1f5f9;
                color: #475569;
            }

            .badge-soft-success,
            .badge-soft-primary,
            .badge-soft-info,
            .badge-soft-danger,
            .badge-soft-secondary {
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
                <h1>User Management</h1>
                <p>Manage system users, reset passwords, and lock/unlock accounts.</p>
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
                        <div class="d-flex align-items-end justify-content-between gap-3 flex-wrap">
                            <div>
                                <h2 class="h4 fw-bold mb-1">User Management</h2>
                                <p class="text-muted mb-0">${users.size()} users found</p>
                            </div>
                            <div>
                                <a href="${pageContext.request.contextPath}/admin/users?action=create" class="btn btn-primary fw-bold">
                                    <i class="bi bi-plus-lg me-1"></i> Create New User
                                </a>
                            </div>
                        </div>

                        <div class="table-panel table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>User</th>
                                        <th>Role</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Status</th>
                                        <th class="text-end">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${users}" var="u">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center gap-3">
                                                    <c:choose>
                                                        <c:when test="${not empty u.image}">
                                                            <img class="user-avatar" src="${pageContext.request.contextPath}${u.image}" alt="${u.name}">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="user-avatar-fallback">
                                                                ${empty u.name ? '?' : fn:toUpperCase(fn:substring(u.name, 0, 1))}
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div>
                                                        <div class="fw-bold text-dark"><c:out value="${u.name}"/></div>
                                                        <div class="small text-muted">@<c:out value="${u.username}"/></div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${fn:toLowerCase(u.roleName) == 'admin'}">
                                                        <span class="badge rounded-pill badge-soft-danger"><c:out value="${u.roleName}"/></span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(u.roleName) == 'manager'}">
                                                        <span class="badge rounded-pill badge-soft-primary"><c:out value="${u.roleName}"/></span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(u.roleName) == 'staff'}">
                                                        <span class="badge rounded-pill badge-soft-info"><c:out value="${u.roleName}"/></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge rounded-pill badge-soft-secondary"><c:out value="${u.roleName}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-secondary"><c:out value="${u.email}"/></td>
                                            <td class="text-secondary"><c:out value="${u.phone}"/></td>
                                            <td>
                                                <span class="badge rounded-pill ${u.active ? 'badge-soft-success' : 'badge-soft-danger'}">
                                                    ${u.active ? 'Active' : 'Inactive'}
                                                </span>
                                            </td>
                                            <td class="text-end">
                                                <c:if test="${u.id != currentUser.id}">
                                                    <c:choose>
                                                        <c:when test="${u.active}">
                                                            <button type="button" class="btn btn-sm btn-outline-danger border-0" onclick="showConfirmModal(${u.id}, 'deactivate', 'Lock')" title="Lock">
                                                                <i class="bi bi-lock-fill"></i>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn btn-sm btn-outline-success border-0" onclick="showConfirmModal(${u.id}, 'activate', 'Unlock')" title="Unlock">
                                                                <i class="bi bi-unlock-fill"></i>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>
                                                <a href="${pageContext.request.contextPath}/admin/users?action=edit&id=${u.id}" class="btn btn-sm btn-outline-primary border-0 ms-1" title="Edit">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                <c:if test="${u.id != 1 && u.id != currentUser.id}">
                                                    <button type="button" class="btn btn-sm btn-outline-danger border-0 ms-1" onclick="showConfirmModal(${u.id}, 'delete', 'Delete')" title="Delete">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty users}">
                                        <tr>
                                            <td colspan="6" class="text-center py-4 text-muted">No users found.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                            
                            <c:if test="${totalPages > 1}">
                                <div class="d-flex justify-content-center mt-4 mb-2">
                                    <nav aria-label="Page navigation">
                                        <ul class="pagination">
                                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                                <a class="page-link" href="?page=${currentPage - 1}">Previous</a>
                                            </li>
                                            <c:forEach begin="1" end="${totalPages}" var="p">
                                                <li class="page-item ${currentPage == p ? 'active' : ''}">
                                                    <a class="page-link" href="?page=${p}">${p}</a>
                                                </li>
                                            </c:forEach>
                                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                                <a class="page-link" href="?page=${currentPage + 1}">Next</a>
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>

        <div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-sm modal-dialog-centered">
                <div class="modal-content border-0 shadow rounded-4">
                    <div class="modal-body p-4 text-center">
                        <div class="mb-3 text-warning">
                            <i class="bi bi-exclamation-circle" style="font-size: 3rem;"></i>
                        </div>
                        <h5 class="modal-title mb-2" id="confirmModalLabel">Confirm Action</h5>
                        <p class="text-muted mb-4" id="confirmModalText">Are you sure?</p>
                        <form method="post" action="${pageContext.request.contextPath}/admin/users">
                            <input type="hidden" name="id" id="modalUserId">
                            <input type="hidden" name="action" id="modalUserAction">
                            <div class="d-flex justify-content-center gap-2">
                                <button type="button" class="btn btn-light px-4 rounded-pill" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-primary px-4 rounded-pill" id="modalConfirmBtn">Confirm</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                                            function showConfirmModal(id, action, actionText) {
                                                                document.getElementById('modalUserId').value = id;
                                                                document.getElementById('modalUserAction').value = action;
                                                                document.getElementById('confirmModalText').innerText =
                                                                        'Are you sure you want to ' + actionText.toLowerCase() + ' this user?';

                                                                var confirmBtn = document.getElementById('modalConfirmBtn');
                                                                if (action === 'delete') {
                                                                    confirmBtn.className = 'btn btn-danger px-4 rounded-pill';
                                                                    confirmBtn.innerText = 'Delete User';
                                                                } else if (action === 'deactivate') {
                                                                    confirmBtn.className = 'btn btn-danger px-4 rounded-pill';
                                                                    confirmBtn.innerText = 'Lock User';
                                                                } else {
                                                                    confirmBtn.className = 'btn btn-success px-4 rounded-pill';
                                                                    confirmBtn.innerText = 'Unlock User';
                                                                }

                                                                var modal = new bootstrap.Modal(document.getElementById('confirmModal'));
                                                                modal.show();
                                                            }
        </script>
    </body>
</html>
