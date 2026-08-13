<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
    <title>Category Management</title>
    <%@include file="../common/head.jsp"%>
</head>
<body>
    <c:set var="pageRole" value="Manager"/>
    <c:set var="pageName" value="Manage Category"/>
    <%@include file="../common/topbar.jsp"%>

    <main class="page-shell">
        <div class="page-heading">
            <div>
                <h1>Category Management</h1>
                <p>Manage phone price segments</p>
            </div>
            <div class="page-heading-actions">
                <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Back to dashboard</a>
                <a class="btn primary large"
                   href="${pageContext.request.contextPath}/manager/categories?action=form">
                    + Add Category
                </a>
            </div>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert success">Category saved successfully.</div>
        </c:if>

        <section class="entity-grid list-style">
            <c:forEach items="${categories}" var="category">
                <article class="entity-card ${!category.active ? 'muted' : ''}">
                    <span class="entity-icon">${category.initial}</span>

                    <div class="entity-copy">
                        <h3><c:out value="${category.name}"/></h3>
                        <p>${category.productCount} products · ${category.active ? 'Active' : 'Inactive'}</p>
                    </div>

                    <div class="actions">
                        <a class="btn subtle"
                           href="${pageContext.request.contextPath}/manager/categories?action=form&id=${category.id}">
                            Edit
                        </a>
                        <form method="post" onsubmit="return confirmDeactivate('category')">
                            <input type="hidden" name="action" value="deactivate">
                            <input type="hidden" name="id" value="${category.id}">
                            <button class="btn danger">Deactivate</button>
                        </form>
                    </div>
                </article>
            </c:forEach>
        </section>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
</body>
</html>
