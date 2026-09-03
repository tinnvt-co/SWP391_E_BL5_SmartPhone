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

        <%-- Một form dùng chung: brand.id = 0 là Add, ID dương là Edit. --%>
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

            <%-- Controller forward lại cùng BrandModel để giữ dữ liệu khi validate lỗi. --%>
            <c:if test="${not empty error}">
                <div class="alert error"><c:out value="${error}"/></div>
            </c:if>

            <%-- novalidate tắt kiểm tra mặc định của trình duyệt; Controller chịu trách nhiệm validate. --%>
            <form method="post" class="entity-form" novalidate
                  action="${pageContext.request.contextPath}/manager/brands">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="${brand.id}">

                <label>
                    Brand name *
                    <input name="name" value="<c:out value='${brand.name}'/>">
                </label>

                <label>
                    Description
                    <textarea name="description" rows="4"><c:out value="${brand.description}"/></textarea>
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
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
