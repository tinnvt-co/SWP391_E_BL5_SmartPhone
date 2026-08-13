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
        .badge-soft-primary {
            background-color: #eff6ff !important;
            color: #3b82f6 !important;
            font-weight: 600;
            padding: 0.4em 0.75em;
        }
        .badge-soft-info {
            background-color: #f0fdfa !important;
            color: #0d9488 !important;
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
                        <th class="text-end">Actions</th>
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
                            <td>
                                <c:choose>
                                    <c:when test="${u.roleName == 'Admin'}">
                                        <span class="badge rounded-pill badge-soft-danger"><c:out value="${u.roleName}"/></span>
                                    </c:when>
                                    <c:when test="${u.roleName == 'Manager'}">
                                        <span class="badge rounded-pill badge-soft-primary"><c:out value="${u.roleName}"/></span>
                                    </c:when>
                                    <c:when test="${u.roleName == 'Staff'}">
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
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty users}">
                        <tr><td colspan="7" class="text-center py-4 text-muted">No users found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>
    </div>
</main>
<%@ include file="/views/common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Confirm Modal -->
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

<script>
function showConfirmModal(id, action, actionText) {
    document.getElementById('modalUserId').value = id;
    document.getElementById('modalUserAction').value = action;
    document.getElementById('confirmModalText').innerText = 'Are you sure you want to ' + actionText.toLowerCase() + ' this user?';
    
    let confirmBtn = document.getElementById('modalConfirmBtn');
    if(action === 'deactivate') {
        confirmBtn.className = 'btn btn-danger px-4 rounded-pill';
        confirmBtn.innerText = 'Lock User';
    } else {
        confirmBtn.className = 'btn btn-success px-4 rounded-pill';
        confirmBtn.innerText = 'Unlock User';
    }
    
    var myModal = new bootstrap.Modal(document.getElementById('confirmModal'));
    myModal.show();
}
</script>
</body>
</html>
