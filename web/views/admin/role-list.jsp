<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Roles | SmartPhone store</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <style>
        body { background:#f5f7fa; color:#17202a; font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif; display: flex; flex-direction: column; min-height: 100vh; margin: 0; }
        .page-shell { padding:2rem 0 3rem; flex: 1 0 auto; }
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
        .role-id {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            color: #64748b;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
<c:set var="activePage" value="roles" scope="request"/>
<%@ include file="/views/common/header.jsp" %>

<main class="page-shell">
    <div class="container">
        <div class="d-flex align-items-end justify-content-between gap-3 flex-wrap mb-3">
            <div>
                <h1 class="fw-bold mb-1">Role Management</h1>
                <p class="text-muted mb-0">${roles.size()} roles found</p>
            </div>
        </div>

        <section class="table-panel table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Role Name</th>
                        <th>Created At</th>
                        <th>Updated At</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${roles}" var="r">
                        <tr>
                            <td class="role-id">#${r.id}</td>
                            <td><div class="fw-bold text-dark"><c:out value="${r.name}"/></div></td>
                            <td class="text-secondary"><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td class="text-secondary"><fmt:formatDate value="${r.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td>
                                <span class="badge rounded-pill ${r.status == 'ACTIVE' ? 'badge-soft-success' : 'badge-soft-danger'}">
                                    <c:out value="${r.status}"/>
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty roles}">
                        <tr><td colspan="5" class="text-center py-4 text-muted">No roles found.</td></tr>
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
