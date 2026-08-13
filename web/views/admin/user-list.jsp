<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Users | SmartPhone store</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <style>
        body { background:#f5f7fa; color:#17202a; font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif; display: flex; flex-direction: column; min-height: 100vh; margin: 0; }
        .page-shell { padding:2rem 0 3rem; flex: 1 0 auto; }
        .toolbar { background:#fff; border:1px solid #dce3ea; border-radius:8px; padding:1rem; display:flex; gap:.75rem; align-items:center; flex-wrap:wrap; }
        .toolbar .form-control, .toolbar .form-select, .toolbar .btn { min-height:44px; border-radius:8px; }
        .table-panel { background:#fff; border:1px solid #dce3ea; border-radius:8px; padding:1rem; margin-top:1.3rem; }
    </style>
</head>
<body>
<c:set var="activePage" value="users" scope="request"/>
<%@ include file="/views/common/header.jsp" %>

<main class="page-shell">
    <div class="container">
        <div class="d-flex align-items-end justify-content-between gap-3 flex-wrap mb-3">
            <div>
                <h1 class="fw-bold mb-1">User Management</h1>
                <p class="text-muted mb-0">${users.size()} users found</p>
            </div>
        </div>

        <section class="table-panel table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>User</th>
                        <th>Role</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${users}" var="u">
                        <tr>
                            <td>#${u.id}</td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <c:choose>
                                        <c:when test="${not empty u.image}">
                                            <img src="${pageContext.request.contextPath}${u.image}" alt="${u.name}" style="width: 36px; height: 36px; border-radius: 50%; object-fit: cover;">
                                        </c:when>
                                        <c:otherwise>
                                            <div style="width: 36px; height: 36px; border-radius: 50%; background: #e9ecef; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #495057;">
                                                ${empty u.name ? '?' : u.name.substring(0,1).toUpperCase()}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <div class="fw-bold"><c:out value="${u.name}"/></div>
                                        <div class="small text-muted">@<c:out value="${u.username}"/></div>
                                    </div>
                                </div>
                            </td>
                            <td><span class="badge bg-secondary"><c:out value="${u.roleName}"/></span></td>
                            <td><c:out value="${u.email}"/></td>
                            <td><c:out value="${u.phone}"/></td>
                            <td>
                                <span class="badge ${u.active ? 'bg-success' : 'bg-danger'}">
                                    ${u.active ? 'Active' : 'Inactive'}
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty users}">
                        <tr><td colspan="6" class="text-center py-4 text-muted">No users found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>
    </div>
</main>
<%@ include file="/views/common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
