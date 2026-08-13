<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
    <title>${category.id == 0 ? 'Add' : 'Edit'} Category</title>
    <%@include file="../common/head.jsp"%>
</head>
<body>
    <c:set var="pageRole" value="Manager"/>
    <c:set var="pageName" value="${category.id == 0 ? 'Add Category' : 'Edit Category'}"/>
    <%@include file="../common/topbar.jsp"%>

    <main class="page-shell form-small">
        <div class="page-heading">
            <div>
                <h1>${category.id == 0 ? 'Add Category' : 'Edit Category'}</h1>
                <p>Use a price segment such as High-end, Upper mid-range, Mid-range or Budget</p>
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
</body>
</html>
