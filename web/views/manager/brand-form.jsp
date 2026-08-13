<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
    <title>${brand.id == 0 ? 'Add' : 'Edit'} Brand</title>
    <%@include file="../common/head.jsp"%>
</head>
<body>
    <c:set var="pageRole" value="Manager"/>
    <c:set var="pageName" value="${brand.id == 0 ? 'Add Brand' : 'Edit Brand'}"/>
    <%@include file="../common/topbar.jsp"%>

    <main class="page-shell form-small">
        <div class="page-heading">
            <div>
                <h1>${brand.id == 0 ? 'Add Brand' : 'Edit Brand'}</h1>
                <p>Brand information</p>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert error"><c:out value="${error}"/></div>
        </c:if>

        <form method="post" class="entity-form">
            <input type="hidden" name="id" value="${brand.id}">

            <label>
                Brand name *
                <input name="name" maxlength="50"
                       value="<c:out value='${brand.name}'/>" required>
            </label>

            <label>
                Description
                <textarea name="description" maxlength="255" rows="4"><c:out value="${brand.description}"/></textarea>
            </label>

            <label>
                Status
                <select name="status">
                    <option value="ACTIVE" ${brand.active || brand.id == 0 ? 'selected' : ''}>Active</option>
                    <option value="INACTIVE" ${!brand.active && brand.id > 0 ? 'selected' : ''}>Inactive</option>
                </select>
            </label>

            <div class="form-actions">
                <a class="btn subtle" href="${pageContext.request.contextPath}/manager/brands">Cancel</a>
                <button class="btn primary large">Save Brand</button>
            </div>
        </form>
    </main>
</body>
</html>
