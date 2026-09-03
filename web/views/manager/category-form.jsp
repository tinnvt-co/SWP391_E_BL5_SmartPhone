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

        <%-- Một form dùng chung: category.id = 0 là Add, ID dương là Edit. --%>
        <main class="page-shell form-small">
            <div class="page-heading">
                <div>
                    <h1>${category.id == 0 ? 'Add Category' : 'Edit Category'}</h1>
                    <p>Create a phone feature group such as Gaming, Foldable, AI or Camera phone</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Dashboard</a>
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager/categories">Back to categories</a>
                </div>
            </div>

            <%-- Controller forward lại cùng CategoryModel để giữ dữ liệu khi validate lỗi. --%>
            <c:if test="${not empty error}">
                <div class="alert error"><c:out value="${error}"/></div>
            </c:if>

            <%-- novalidate tắt kiểm tra mặc định của trình duyệt; Controller chịu trách nhiệm validate. --%>
            <form method="post" class="entity-form" novalidate
                  action="${pageContext.request.contextPath}/manager/categories">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="${category.id}">

                <label>
                    Category name *
                    <input name="name" value="<c:out value='${category.name}'/>">
                </label>

                <label>
                    Description
                    <textarea name="description" rows="4"><c:out value="${category.description}"/></textarea>
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
