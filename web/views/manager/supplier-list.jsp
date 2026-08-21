<%--
    Document   : supplier-list
    Created on : Aug 19, 2026
    Author     : KhanhVNHE191788
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
                padding-bottom: 50px;
            }
            /* =========================
               TOOLBAR
               ========================= */
            .supplier-toolbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 16px;
                margin-bottom: 22px;
                flex-wrap: wrap;
            }
            .supplier-filters {
                display: flex;
                align-items: center;
                gap: 10px;
                flex-wrap: wrap;
            }
            .supplier-search {
                width: 300px;
                min-width: 220px;
            }
            .supplier-search input {
                height: 42px;
                border: 1px solid #dfe3e8;
                border-radius: 10px;
                padding: 0 14px;
                outline: none;
                width: 100%;
            }
            .supplier-search input:focus {
                border-color: #9ca3af;
            }
            .supplier-filter-select {
                height: 42px;
                border: 1px solid #dfe3e8;
                border-radius: 10px;
                padding: 0 36px 0 12px;
                background: #fff;
                min-width: 150px;
            }
            .supplier-create-btn {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                height: 42px;
                padding: 0 17px;
                border-radius: 10px;
                text-decoration: none;
                font-weight: 650;
            }
            /* =========================
               TABLE
               ========================= */
            .supplier-card {
                background: #fff;
                border: 1px solid #e7e9ee;
                border-radius: 18px;
                box-shadow: 0 8px 24px rgba(20, 25, 40, .05);
                overflow: hidden;
            }
            .supplier-table-wrapper {
                overflow-x: auto;
            }
            .supplier-table {
                width: 100%;
                border-collapse: collapse;
                min-width: 900px;
            }
            .supplier-table th {
                padding: 15px 18px;
                background: #f8f9fb;
                color: #727984;
                font-size: 11px;
                font-weight: 750;
                text-transform: uppercase;
                letter-spacing: .05em;
                border-bottom: 1px solid #e8ebef;
                white-space: nowrap;
            }
            .supplier-table td {
                padding: 17px 18px;
                border-bottom: 1px solid #eef0f3;
                vertical-align: middle;
                color: #252a31;
                font-size: 14px;
            }
            .supplier-table tbody tr:last-child td {
                border-bottom: none;
            }
            .supplier-table tbody tr:hover {
                background: #fafbfc;
            }
            .supplier-name {
                font-weight: 700;
                color: #20242b;
                text-decoration: none;
            }
            .supplier-name:hover {
                text-decoration: underline;
            }
            .supplier-id {
                margin-top: 3px;
                color: #8a919b;
                font-size: 12px;
                font-family: monospace;
            }
            .supplier-address {
                max-width: 260px;
                color: #606874;
            }
            .supplier-description {
                max-width: 250px;
                color: #737b86;
            }
            /* =========================
               STATUS
               ========================= */
            .supplier-status {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                padding: 6px 11px;
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
            .status-dot {
                width: 7px;
                height: 7px;
                border-radius: 50%;
                background: currentColor;
            }
            /* =========================
               ACTION
               ========================= */
            .supplier-action {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 36px;
                height: 36px;
                border-radius: 9px;
                color: #475569;
                text-decoration: none;
            }
            .supplier-action:hover {
                background: #f1f5f9;
                color: #111827;
            }
            /* =========================
               EMPTY
               ========================= */
            .empty-state {
                text-align: center;
                padding: 65px 20px;
                color: #7b828c;
            }
            .empty-state i {
                display: block;
                font-size: 38px;
                margin-bottom: 12px;
                color: #a3aab4;
            }
            .empty-state h3 {
                margin-bottom: 5px;
                font-size: 18px;
                color: #3f4650;
            }
            .empty-state p {
                margin: 0;
                font-size: 14px;
            }
            /* =========================
               PAGINATION
               ========================= */
            .supplier-pagination {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 17px 20px;
                border-top: 1px solid #eef0f3;
                gap: 15px;
                flex-wrap: wrap;
            }
            .pagination-info {
                color: #7b828c;
                font-size: 13px;
            }
            .pagination-buttons {
                display: flex;
                align-items: center;
                gap: 5px;
            }
            .page-btn {
                min-width: 36px;
                height: 36px;
                padding: 0 9px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 8px;
                border: 1px solid #e1e5ea;
                background: #fff;
                color: #4b5563;
                text-decoration: none;
                font-size: 13px;
                font-weight: 600;
            }
            .page-btn:hover {
                background: #f5f6f8;
                color: #111827;
            }
            .page-btn.active {
                background: #111827;
                border-color: #111827;
                color: #fff;
            }
            .page-btn.disabled {
                opacity: .45;
                pointer-events: none;
            }
            .page-dots {
                min-width: 25px;
                text-align: center;
                color: #8b929c;
            }
            @media (max-width: 850px) {

                .supplier-toolbar {
                    align-items: stretch;
                }
                .supplier-filters {
                    width: 100%;
                }
                .supplier-search {
                    width: 100%;
                }
                .supplier-create-btn {
                    width: 100%;
                    justify-content: center;
                }
                .supplier-pagination {
                    justify-content: center;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>
        <main class="page-shell supplier-page">
            <!-- =========================
                 PAGE HEADING
                 ========================= -->
            <div class="page-heading">
                <div>
                    <span class="manager-kicker">
                        PROCUREMENT
                    </span>
                    <h1>Suppliers</h1>
                    <p>
                        Manage suppliers and their supplied product variants.
                    </p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn primary supplier-create-btn"
                       href="${pageContext.request.contextPath}/manager/supplier?action=detail&id=0">
                        <i class="bi bi-plus-lg"></i>
                        Create Supplier
                    </a>
                </div>
            </div>
            <c:if test="${not empty sessionScope.msgErr}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <c:out value="${sessionScope.msgErr}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="msgErr" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.msgOk}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <c:out value="${sessionScope.msgOk}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="msgOk" scope="session"/>
            </c:if>
                        
            <!-- =========================
                 FILTER
                 ========================= -->
            <form method="get"
                  action="${pageContext.request.contextPath}/manager/supplier"
                  class="supplier-toolbar">
                <input type="hidden"
                       name="action"
                       value="list">
                <div class="supplier-filters">
                    <!-- SEARCH -->
                    <div class="supplier-search">
                        <input type="text"
                               name="keyword"
                               value="<c:out value='${keyword}'/>"
                               placeholder="Search supplier name, phone...">
                    </div>
                    <!-- STATUS -->
                    <select name="status"
                            class="supplier-filter-select"
                            onchange="this.form.submit()">
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
                    <!-- SEARCH BUTTON -->
                    <button type="submit"
                            class="btn subtle"
                            style="height:42px;">
                        <i class="bi bi-search"></i>
                        Search
                    </button>
                </div>
            </form>
            <!-- =========================
                 SUPPLIER TABLE
                 ========================= -->
            <section class="supplier-card">
                <div class="supplier-table-wrapper">
                    <c:choose>
                        <c:when test="${empty suppliers}">
                            <div class="empty-state">
                                <i class="bi bi-building"></i>
                                <h3>No suppliers found</h3>
                                <p>
                                    Try changing your search or create a new supplier.
                                </p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="supplier-table">
                                <thead>
                                    <tr>
                                        <th>
                                            Supplier
                                        </th>
                                        <th>
                                            Phone
                                        </th>
                                        <th>
                                            Address
                                        </th>
                                        <th>
                                            Products
                                        </th>
                                        <th>
                                            Status
                                        </th>
                                        <th>
                                            Created
                                        </th>
                                        <th>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="supplier"
                                               items="${suppliers}">
                                        <tr>
                                            <!-- SUPPLIER -->
                                            <td>
                                                <a class="supplier-name"
                                                   href="${pageContext.request.contextPath}/manager/supplier?action=detail&id=${supplier.id}">
                                                    <c:out value="${supplier.name}"/>
                                                </a>
                                                <div class="supplier-id">
                                                    #${supplier.id}
                                                </div>
                                            </td>
                                            <!-- PHONE -->
                                            <td>
                                                <c:out value="${supplier.phone}"/>
                                            </td>
                                            <!-- ADDRESS -->
                                            <td>
                                                <div class="supplier-address">
                                                    <c:out value="${supplier.address}"/>
                                                </div>
                                            </td>
                                            <!-- PRODUCT VARIANT COUNT -->
                                            <td>
                                                <strong>
                                                    ${supplier.productVariantCount}
                                                </strong>
                                                <span style="color:#8a919b;">
                                                    variants
                                                </span>
                                            </td>
                                            <!-- STATUS -->
                                            <td>
                                                <c:choose>
                                                    <c:when test="${supplier.status == 'ACTIVE'}">
                                                        <span class="supplier-status active">
                                                            <span class="status-dot"></span>
                                                            Active
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="supplier-status inactive">
                                                            <span class="status-dot"></span>
                                                            Inactive
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <!-- CREATED -->
                                            <td>
                                                <fmt:formatDate
                                                    value="${supplier.createdAt}"
                                                    pattern="dd/MM/yyyy"/>
                                            </td>
                                            <!-- DETAIL -->
                                            <td style="text-align:right;">
                                                <a class="supplier-action"
                                                   title="View supplier"
                                                   href="${pageContext.request.contextPath}/manager/supplier?action=detail&id=${supplier.id}">
                                                    <i class="bi bi-chevron-right"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
                <!-- =========================
                     PAGINATION
                     ========================= -->
                <c:if test="${totalPages > 1}">
                    <div class="supplier-pagination">
                        <div class="pagination-info">
                            Showing
                            <strong>${startItem}</strong>
                            -
                            <strong>${endItem}</strong>
                            of
                            <strong>${totalSuppliers}</strong>
                            suppliers
                        </div>
                        <div class="pagination-buttons">
                            <!-- PREVIOUS -->
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <a class="page-btn"
                                       href="${pageContext.request.contextPath}/manager/supplier?action=list&keyword=${urlKeyword}&status=${status}&page=${currentPage - 1}">
                                        <i class="bi bi-chevron-left"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="page-btn disabled">
                                        <i class="bi bi-chevron-left"></i>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <!-- PAGE NUMBERS -->
                            <c:forEach var="page"
                                       begin="${startPage}"
                                       end="${endPage}">
                                <a class="page-btn ${page == currentPage ? 'active' : ''}"
                                   href="${pageContext.request.contextPath}/manager/supplier?action=list&keyword=${urlKeyword}&status=${status}&page=${page}">
                                    ${page}
                                </a>
                            </c:forEach>
                            <!-- NEXT -->
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <a class="page-btn"
                                       href="${pageContext.request.contextPath}/manager/supplier?action=list&keyword=${urlKeyword}&status=${status}&page=${currentPage + 1}">
                                        <i class="bi bi-chevron-right"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="page-btn disabled">
                                        <i class="bi bi-chevron-right"></i>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>
            </section>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>