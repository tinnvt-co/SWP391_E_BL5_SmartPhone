<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>${brand.id == 0 ? 'Add' : 'Edit'} Brand</title>
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
                    <h1>${brand.id == 0 ? 'Add Brand' : 'Edit Brand'}</h1>
                    <p>Brand information</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Dashboard</a>
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager/brands">Back to brands</a>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alert error"><c:out value="${error}"/></div>
            </c:if>

            <form method="post" class="entity-form" id="brandForm"
                  action="${pageContext.request.contextPath}/manager/brands">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="${brand.id}">

                <label>
                    Brand name *
                    <input name="name" minlength="2" maxlength="50"
                           data-brand-text="name"
                           value="<c:out value='${brand.name}'/>" required>
                    <small>Use letters, numbers and spaces only. Maximum 50 characters.</small>
                </label>

                <label>
                    Description
                    <textarea name="description" maxlength="255" rows="4"
                              data-brand-text="description"><c:out value="${brand.description}"/></textarea>
                    <small>Optional. Use letters, numbers and spaces only. Maximum 255 characters.</small>
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
        <%@ include file="/views/common/footer.jsp" %>
        <script src="${pageContext.request.contextPath}/assets/js/manager-brand-form.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
