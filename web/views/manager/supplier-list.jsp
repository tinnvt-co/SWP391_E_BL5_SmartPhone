<%-- 
    Document   : supplier-list
    Created on : Aug 19, 2026, 2:52:24 PM
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>

        <meta charset="UTF-8">

        <title>Suppliers</title>

        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

        <%@include file="../common/head.jsp"%>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/app-layout.css">

        <style>

            .supplier-page {
                padding-bottom: 48px;
            }

            .supplier-toolbar {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 20px;
                margin-bottom: 24px;
            }

            .supplier-toolbar-left {
                display: flex;
                align-items: center;
                gap: 12px;
                flex: 1;
            }

            .supplier-search {
                min-width: 280px;
                max-width: 420px;
            }

            .supplier-filter {
                min-width: 150px;
            }

            .supplier-table-card {
                background: #fff;
                border: 1px solid #e7e9ee;
                border-radius: 18px;
                overflow: hidden;
                box-shadow: 0 8px 24px rgba(20, 25, 40, 0.05);
            }

            .supplier-table {
                width: 100%;
                border-collapse: collapse;
                margin: 0;
            }

            .supplier-table th {
                padding: 16px 20px;
                background: #f8f9fb;
                color: #6b7280;
                font-size: 12px;
                font-weight: 700;
                letter-spacing: .06em;
                text-transform: uppercase;
                border-bottom: 1px solid #e7e9ee;
                white-space: nowrap;
            }

            .supplier-table td {
                padding: 18px 20px;
                border-bottom: 1px solid #eef0f3;
                vertical-align: middle;
            }

            .supplier-table tbody tr {
                transition: background .15s ease;
            }

            .supplier-table tbody tr:hover {
                background: #fafbfc;
            }

            .supplier-name {
                font-weight: 700;
                color: #17191d;
                text-decoration: none;
            }

            .supplier-name:hover {
                color: #2563eb;
            }

            .supplier-id {
                color: #8a9099;
                font-size: 13px;
                font-family: monospace;
            }

            .supplier-contact {
                display: flex;
                flex-direction: column;
                gap: 3px;
            }

            .supplier-phone {
                font-weight: 600;
            }

            .supplier-address {
                color: #737983;
                font-size: 13px;
                max-width: 300px;
            }

            .supplier-count {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: 38px;
                padding: 6px 10px;
                border-radius: 999px;
                background: #f1f5f9;
                color: #475569;
                font-size: 13px;
                font-weight: 700;
            }

            .supplier-status {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 700;
            }

            .supplier-status.active {
                background: #ecfdf3;
                color: #15803d;
            }

            .supplier-status.inactive {
                background: #f3f4f6;
                color: #6b7280;
            }

            .supplier-status-dot {
                width: 7px;
                height: 7px;
                border-radius: 50%;
                background: currentColor;
            }

            .supplier-actions {
                text-align: right;
                white-space: nowrap;
            }

            .supplier-action {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 34px;
                height: 34px;
                border-radius: 9px;
                color: #68707c;
                text-decoration: none;
            }

            .supplier-action:hover {
                background: #f1f3f6;
                color: #111827;
            }

            .supplier-empty {
                padding: 64px 24px;
                text-align: center;
                color: #777f89;
            }

            .supplier-empty-icon {
                font-size: 36px;
                color: #a1a8b2;
                margin-bottom: 12px;
            }

            .supplier-pagination {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-top: 22px;
            }

            .pagination-info {
                color: #747b85;
                font-size: 13px;
            }

            .pagination-links {
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .page-link-custom {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: 36px;
                height: 36px;
                padding: 0 10px;
                border: 1px solid #e2e5ea;
                border-radius: 9px;
                background: #fff;
                color: #4b5563;
                text-decoration: none;
                font-size: 13px;
                font-weight: 600;
            }

            .page-link-custom:hover {
                background: #f5f7fa;
                color: #111827;
            }

            .page-link-custom.active {
                background: #111827;
                border-color: #111827;
                color: #fff;
            }

            .page-link-custom.disabled {
                pointer-events: none;
                opacity: .45;
            }

            @media (max-width: 900px) {

                .supplier-toolbar {
                    flex-direction: column;
                    align-items: stretch;
                }

                .supplier-toolbar-left {
                    flex-direction: column;
                    align-items: stretch;
                }

                .supplier-search,
                .supplier-filter {
                    max-width: none;
                    width: 100%;
                }

                .supplier-table-card {
                    overflow-x: auto;
                }

                .supplier-table {
                    min-width: 850px;
                }

                .supplier-pagination {
                    flex-direction: column;
                    gap: 14px;
                    align-items: flex-start;
                }
            }

        </style>

    </head>

    <body>

    <c:set var="activePage" value="manager" scope="request"/>

    <%@ include file="/views/common/header.jsp" %>

    <main class="page-shell supplier-page">

        <!-- ============================================= -->
        <!-- PAGE HEADING -->
        <!-- ============================================= -->

        <div class="page-heading">

            <div>
                <span class="manager-kicker">
                    PROCUREMENT
                </span>

                <h1>Suppliers</h1>

                <p>
                    Manage suppliers and the products they provide.
                </p>
            </div>

            <div class="page-heading-actions">

                <a class="btn subtle"
                   href="${pageContext.request.contextPath}/manager">
                    ← Dashboard
                </a>

                <a class="btn primary"
                   href="${pageContext.request.contextPath}/manager/supplier?action=create">
                    <i class="bi bi-plus-lg"></i>
                    Create Supplier
                </a>

            </div>

        </div>


        <!-- ============================================= -->
        <!-- FLASH MESSAGE -->
        <!-- ============================================= -->

        <c:if test="${not empty message}">
            <div class="alert success">
                <c:out value="${message}"/>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert error">
                <c:out value="${error}"/>
            </div>
        </c:if>


        <!-- ============================================= -->
        <!-- TOOLBAR -->
        <!-- ============================================= -->

        <form method="get"
              action="${pageContext.request.contextPath}/manager/supplier"
              class="supplier-toolbar">

            <div class="supplier-toolbar-left">

                <input
                    class="form-control supplier-search"
                    type="search"
                    name="keyword"
                    placeholder="Search supplier name, phone or address..."
                    value="<c:out value='${keyword}'/>">

                <select
                    class="form-select supplier-filter"
                    name="status">

                    <option value="">
                        All status
                    </option>

                    <option value="ACTIVE"
                            ${status == 'ACTIVE' ? 'selected' : ''}>
                        Active
                    </option>

                    <option value="INACTIVE"
                            ${status == 'INACTIVE' ? 'selected' : ''}>
                        Inactive
                    </option>

                </select>

                <button class="btn subtle"
                        type="submit">
                    <i class="bi bi-search"></i>
                    Search
                </button>

            </div>

        </form>


        <!-- ============================================= -->
        <!-- SUPPLIER TABLE -->
        <!-- ============================================= -->

        <section class="supplier-table-card">

            <c:choose>

                <c:when test="${empty suppliers}">

                    <div class="supplier-empty">

                        <div class="supplier-empty-icon">
                            <i class="bi bi-building"></i>
                        </div>

                        <h3>No suppliers found</h3>

                        <p>
                            There are no suppliers matching your search.
                        </p>

                        <a class="btn primary"
                           href="${pageContext.request.contextPath}/manager/supplier?action=create">
                            Create your first supplier
                        </a>

                    </div>

                </c:when>

                <c:otherwise>

                    <table class="supplier-table">

                        <thead>

                            <tr>

                                <th>ID</th>

                                <th>Supplier</th>

                                <th>Contact</th>

                                <th>Address</th>

                                <th>Products</th>

                                <th>Status</th>

                                <th>Created</th>

                                <th></th>

                            </tr>

                        </thead>

                        <tbody>

                        <c:forEach
                            items="${suppliers}"
                            var="supplier">

                            <tr>

                                <td>
                                    <span class="supplier-id">
                                        #${supplier.id}
                                    </span>
                                </td>

                                <td>

                                    <a
                                        class="supplier-name"
                                        href="${pageContext.request.contextPath}/manager/supplier?action=detail&id=${supplier.id}">

                                        <c:out value="${supplier.name}"/>

                                    </a>

                                </td>

                                <td>

                                    <div class="supplier-contact">

                                        <span class="supplier-phone">
                                            <c:out value="${supplier.phone}"/>
                                        </span>

                                    </div>

                                </td>

                                <td>

                                    <div class="supplier-address">

                                        <c:out value="${supplier.address}"/>

                                    </div>

                                </td>

                                <td>

                                    <span class="supplier-count">
                                        ${supplier.productVariantCount}
                                    </span>

                                </td>

                                <td>

                            <c:choose>

                                <c:when test="${supplier.status == 'ACTIVE'}">

                                    <span class="supplier-status active">
                                        <span class="supplier-status-dot"></span>
                                        Active
                                    </span>

                                </c:when>

                                <c:otherwise>

                                    <span class="supplier-status inactive">
                                        <span class="supplier-status-dot"></span>
                                        Inactive
                                    </span>

                                </c:otherwise>

                            </c:choose>

                            </td>

                            <td>

                                <small>
                                    <fmt:formatDate
                                        value="${supplier.createdAt}"
                                        pattern="dd/MM/yyyy"/>
                                </small>

                            </td>

                            <td class="supplier-actions">

                                <a
                                    class="supplier-action"
                                    title="View supplier"
                                    href="${pageContext.request.contextPath}/manager/supplier?action=detail&id=${supplier.id}">

                                    <i class="bi bi-arrow-right"></i>

                                </a>

                            </td>

                            </tr>

                        </c:forEach>

                        </tbody>

                    </table>

                </c:otherwise>

            </c:choose>

        </section>


        <!-- ============================================= -->
        <!-- PAGINATION -->
        <!-- ============================================= -->

        <c:if test="${totalPages > 1}">

            <div class="supplier-pagination">

                <div class="pagination-info">

                    Showing
                    ${(currentPage - 1) * pageSize + 1}
                    -
                    ${currentPage * pageSize > totalSuppliers
                      ? totalSuppliers
                      : currentPage * pageSize}
                    of
                    ${totalSuppliers}
                    suppliers

                </div>


                <div class="pagination-links">

                    <!-- PREVIOUS -->

                    <c:choose>

                        <c:when test="${currentPage > 1}">

                            <a class="page-link-custom"
                               href="${pageContext.request.contextPath}/manager/supplier?keyword=${keyword}&status=${status}&page=${currentPage - 1}">

                                <i class="bi bi-chevron-left"></i>

                            </a>

                        </c:when>

                        <c:otherwise>

                            <span class="page-link-custom disabled">
                                <i class="bi bi-chevron-left"></i>
                            </span>

                        </c:otherwise>

                    </c:choose>


                    <!-- PAGE NUMBERS -->

                    <c:forEach
                        begin="${startPage}"
                        end="${endPage}"
                        var="pageNumber">

                        <a
                            class="page-link-custom ${pageNumber == currentPage ? 'active' : ''}"
                            href="${pageContext.request.contextPath}/manager/supplier?keyword=${keyword}&status=${status}&page=${pageNumber}">

                            ${pageNumber}

                        </a>

                    </c:forEach>


                    <!-- NEXT -->

                    <c:choose>

                        <c:when test="${currentPage < totalPages}">

                            <a class="page-link-custom"
                               href="${pageContext.request.contextPath}/manager/supplier?keyword=${keyword}&status=${status}&page=${currentPage + 1}">

                                <i class="bi bi-chevron-right"></i>

                            </a>

                        </c:when>

                        <c:otherwise>

                            <span class="page-link-custom disabled">
                                <i class="bi bi-chevron-right"></i>
                            </span>

                        </c:otherwise>

                    </c:choose>

                </div>

            </div>

        </c:if>

    </main>

    <%@ include file="/views/common/footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
