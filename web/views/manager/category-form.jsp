<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>${category.id == 0 ? 'Add' : 'Edit'} Category</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell form-small">
            <div class="page-heading">
                <div>
                    <h1>${category.id == 0 ? 'Add Category' : 'Edit Category'}</h1>
                    <p>Use a price segment such as High-end, Upper mid-range, Mid-range or Budget</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Dashboard</a>
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager/categories">Back to categories</a>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alert error"><c:out value="${error}"/></div>
            </c:if>

            <form method="post" class="entity-form">
                <input type="hidden" name="id" value="${category.id}">

                <label>
                    Category name *
                    <input name="name" maxlength="25"
                           value="<c:out value='${category.name}'/>" required>
                </label>

                <label>
                    Description
                    <textarea name="description" maxlength="255" rows="4"><c:out value="${category.description}"/></textarea>
                </label>

                <label>
                    Status
                    <select name="status">
                        <option value="ACTIVE" ${category.active || category.id == 0 ? 'selected' : ''}>Active</option>
                        <option value="INACTIVE" ${!category.active && category.id > 0 ? 'selected' : ''}>Inactive</option>
                    </select>
                </label>

                <div class="form-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager/categories">Cancel</a>
                    <button class="btn primary large">Save Category</button>
                </div>
            </form>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
