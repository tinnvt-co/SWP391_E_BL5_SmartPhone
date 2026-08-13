<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
    <title>Brand Management</title>
    <%@include file="../common/head.jsp"%>
</head>
<body>
    <c:set var="pageRole" value="Manager"/>
    <c:set var="pageName" value="Manage Brand"/>
    <%@include file="../common/topbar.jsp"%>

    <main class="page-shell">
        <div class="page-heading">
            <div>
                <h1>Brand Management</h1>
                <p>${brands.size()} brands listed</p>
            </div>
            <a class="btn primary large"
               href="${pageContext.request.contextPath}/manager/brands?action=form">
                + Add Brand
            </a>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert success">Brand saved successfully.</div>
        </c:if>

        <section class="entity-grid brand-style">
            <c:forEach items="${brands}" var="brand">
                <article class="entity-card ${!brand.active ? 'muted' : ''}">
                    <span class="entity-icon">${brand.initial}</span>

                    <div class="entity-copy">
                        <h3><c:out value="${brand.name}"/></h3>
                        <p>${brand.productCount} products</p>
                        <small>${brand.active ? 'Active' : 'Inactive'}</small>
                    </div>

                    <div class="actions">
                        <a class="btn subtle"
                           href="${pageContext.request.contextPath}/manager/brands?action=form&id=${brand.id}">
                            Edit
                        </a>
                        <form method="post" onsubmit="return confirmDeactivate('brand')">
                            <input type="hidden" name="action" value="deactivate">
                            <input type="hidden" name="id" value="${brand.id}">
                            <button class="btn danger">Delete</button>
                        </form>
                    </div>
                </article>
            </c:forEach>
        </section>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
</body>
</html>
