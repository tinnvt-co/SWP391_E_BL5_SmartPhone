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
        .toolbar { background:#fff; border:1px solid #dce3ea; border-radius:12px; padding:1rem; display:flex; gap:.75rem; align-items:center; flex-wrap:wrap; box-shadow: 0 4px 24px rgba(23,32,42,.03); }
        .toolbar .form-control, .toolbar .form-select, .toolbar .btn { min-height:44px; border-radius:8px; }
        
        /* Premium Table Styles */
        .table-panel { 
            background: #fff; 
            border-radius: 14px; 
            box-shadow: 0 8px 32px rgba(23,32,42,.05); 
            border: 1px solid rgba(220, 227, 234, 0.6);
            margin-top: 1.3rem; 
            overflow: hidden;
            padding: 0;
        }
        .table { margin-bottom: 0; }
        .table > :not(caption) > * > * {
            padding: 1rem 1.25rem;
            border-bottom-color: #f0f2f5;
        }
        .table-light th {
            background-color: #f8fafc;
            color: #64748b;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-weight: 700;
            border-bottom: 2px solid #e2e8f0;
        }
        .table tbody tr {
            transition: all 0.2s ease;
            position: relative;
        }
        .table tbody tr:hover {
            background-color: #f8fafc;
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0,0,0,.04);
            z-index: 10;
        }
        .avatar-img, .avatar-initial {
            box-shadow: 0 3px 10px rgba(0,0,0,.08);
            border: 2px solid #fff;
        }
        .badge-soft-success {
            background-color: #ecfdf5 !important;
            color: #10b981 !important;
            font-weight: 600;
            padding: 0.4em 0.75em;
        }
        .badge-soft-danger {
            background-color: #fef2f2 !important;
            color: #ef4444 !important;
            font-weight: 600;
            padding: 0.4em 0.75em;
        }
        .badge-soft-secondary {
            background-color: #f1f5f9 !important;
            color: #475569 !important;
            font-weight: 600;
            padding: 0.4em 0.75em;
        }
        .user-id {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            color: #64748b;
            font-size: 0.9em;
        }
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
                            <td class="user-id">#${u.id}</td>
                            <td>
                                <div class="d-flex align-items-center gap-3">
                                    <c:choose>
                                        <c:when test="${not empty u.image}">
                                            <img src="${pageContext.request.contextPath}${u.image}" alt="${u.name}" class="avatar-img" style="width: 42px; height: 42px; border-radius: 50%; object-fit: cover;">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="avatar-initial" style="width: 42px; height: 42px; border-radius: 50%; background: linear-gradient(135deg, #e2e8f0, #cbd5e1); display: flex; align-items: center; justify-content: center; font-weight: bold; color: #334155; font-size: 1.1rem;">
                                                ${empty u.name ? '?' : u.name.substring(0,1).toUpperCase()}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <div class="fw-bold text-dark"><c:out value="${u.name}"/></div>
                                        <div class="small" style="color: #64748b;">@<c:out value="${u.username}"/></div>
                                    </div>
                                </div>
                            </td>
                            <td><span class="badge rounded-pill badge-soft-secondary"><c:out value="${u.roleName}"/></span></td>
                            <td class="text-secondary"><c:out value="${u.email}"/></td>
                            <td class="text-secondary"><c:out value="${u.phone}"/></td>
                            <td>
                                <span class="badge rounded-pill ${u.active ? 'badge-soft-success' : 'badge-soft-danger'}">
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
