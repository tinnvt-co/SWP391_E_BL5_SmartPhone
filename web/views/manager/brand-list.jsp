<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Brand Management</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell">
            <div class="page-heading">
                <div>
                    <h1>Brand Management</h1>
                    <p>${brands.size()} brands listed</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Back to dashboard</a>
                    <a class="btn primary large"
                       href="${pageContext.request.contextPath}/manager/brands?action=form">
                        + Add Brand
                    </a>
                </div>
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
                               href="${pageContext.request.contextPath}/manager/brands?action=products&id=${brand.id}">
                                Products
                            </a>
                            <a class="btn subtle"
                               href="${pageContext.request.contextPath}/manager/brands?action=form&id=${brand.id}">
                                Edit
                            </a>
                            <form method="post" onsubmit="return confirmStatusChange('brand', ${!brand.active})">
                                <input type="hidden" name="action" value="set-status">
                                <input type="hidden" name="id" value="${brand.id}">
                                <input type="hidden" name="status" value="${brand.active ? 'INACTIVE' : 'ACTIVE'}">
                                <button class="btn ${brand.active ? 'danger' : 'primary'}">
                                    ${brand.active ? 'Deactivate' : 'Activate'}
                                </button>
                            </form>
                        </div>
                    </article>
                </c:forEach>
            </section>
        </main>

        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
