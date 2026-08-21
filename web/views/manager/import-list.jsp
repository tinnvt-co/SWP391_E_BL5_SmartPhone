<%-- 
    Document   : import-list
    Created on : Aug 20, 2026, 10:36:47 PM
    Author     : KhanhVNHE191788
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">

        <title>Import Orders</title>
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            .form-control-custom {
                width: 100%;
                border: 1px solid #dfe3e8;
                border-radius: 10px;
                padding: 11px 13px;
                font-size: 14px;
                outline: none;
                transition: .2s;
            }

            .form-control-custom:focus {
                border-color: #94a3b8;
                box-shadow: 0 0 0 3px rgba(148, 163, 184, .15);
            }

            textarea.form-control-custom {
                min-height: 100px;
                resize: vertical;
            }

            .import-create-btn {
                width: 100%;
                justify-content: center;
            }
            .import-create-btn {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                height: 42px;
                padding: 0 17px;
                border-radius: 10px;
                text-decoration: none;
                font-weight: 650;
            }
            .import-list-page {
                max-width: 1400px;
                margin: 0 auto;
            }

            /* =========================
               FILTER / TOOLBAR
               ========================= */

            .import-filter-card {
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                padding: 18px 20px;
                margin-bottom: 24px;
            }

            .import-filter-form {
                display: flex;
                align-items: flex-end;
                gap: 14px;
                flex-wrap: wrap;
            }

            .import-filter-search {
                flex: 1;
                min-width: 280px;
            }

            .import-filter-field {
                min-width: 170px;
            }

            .import-filter-action {
                display: flex;
                align-items: flex-end;
            }

            /* =========================
               TABLE
               ========================= */

            .import-table-card {
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                overflow: hidden;
            }

            .import-table {
                width: 100%;
                border-collapse: collapse;
                margin: 0;
            }

            .import-table thead th {
                background: #f8fafc;
                color: #64748b;
                font-size: 12px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: .04em;
                padding: 14px 16px;
                border-bottom: 1px solid #e5e7eb;
                white-space: nowrap;
            }

            .import-table tbody td {
                padding: 15px 16px;
                border-bottom: 1px solid #f1f5f9;
                vertical-align: middle;
            }

            .import-table tbody tr:last-child td {
                border-bottom: none;
            }

            .import-table tbody tr:hover {
                background: #fafafa;
            }

            /* =========================
               CONTENT
               ========================= */

            .order-code {
                font-weight: 700;
                color: #111827;
            }

            .supplier-name {
                font-weight: 600;
                color: #334155;
            }

            .creator-name {
                color: #64748b;
                font-size: 14px;
            }

            .item-count {
                color: #475569;
                font-weight: 500;
            }

            .amount {
                font-weight: 700;
                color: #111827;
                white-space: nowrap;
            }

            /* =========================
               STATUS
               ========================= */

            .status-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 700;
                white-space: nowrap;
            }

            .status-order {
                background: #fff7ed;
                color: #c2410c;
            }

            .status-complete {
                background: #ecfdf5;
                color: #047857;
            }

            /* =========================
               ACTION
               ========================= */

            .table-actions {
                display: flex;
                justify-content: flex-end;
                align-items: center;
            }

            .btn-view {
                text-decoration: none;
                white-space: nowrap;
            }

            /* =========================
               EMPTY STATE
               ========================= */

            .import-empty-state {
                text-align: center;
                padding: 70px 20px;
                color: #64748b;
            }

            .import-empty-state i {
                display: block;
                font-size: 42px;
                margin-bottom: 12px;
            }

            .import-empty-state h3 {
                color: #334155;
                margin-bottom: 8px;
            }

            .import-empty-state p {
                margin: 0;
            }

            /* =========================
               RESPONSIVE
               ========================= */

            @media (max-width: 1000px) {
                .import-filter-form {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                }

                .import-filter-search {
                    grid-column: 1 / -1;
                }
            }

            @media (max-width: 700px) {
                .import-filter-form {
                    grid-template-columns: 1fr;
                }

                .import-filter-search {
                    grid-column: auto;
                }

                .import-table-card {
                    overflow-x: auto;
                }

                .import-table {
                    min-width: 900px;
                }
            }
        </style>
    </head>

    <body>

        <c:set var="activePage"
               value="manager"
               scope="request"/>

        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell import-list-page">

            <!-- =================================================
                 PAGE HEADING
                 ================================================= -->

            <div class="page-heading">
                <div>
                    <span class="manager-kicker">
                        PROCUREMENT
                    </span>
                    <h1>Import Orders</h1>
                    <p>Manage imported products from suppliers.</p>
                </div>

                <div class="page-heading-actions">
                    <a class="btn primary import-create-btn"
                       href="${pageContext.request.contextPath}/manager/import?action=create">
                        <i class="bi bi-plus-lg"></i>
                        Create Import Order
                    </a>
                </div>
            </div>

            <!-- =================================================
                 FLASH MESSAGE
                 ================================================= -->
            <c:if test="${not empty sessionScope.message}">
                <div class="alert alert-success">
                    <c:out value="${sessionScope.message}"/>
                </div>
                <c:remove var="message"
                          scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger">
                    <c:out value="${sessionScope.error}"/>
                </div>
                <c:remove var="error"
                          scope="session"/>
            </c:if>


            <!-- =================================================
                 FILTER
                 ================================================= -->
            <div class="import-filter-card">
                <form method="get"
                      action="${pageContext.request.contextPath}/manager/import">

                    <div class="import-filter-form">

                        <div class="form-group import-filter-search">
                            <label class="form-label">
                                Search
                            </label>

                            <input type="text"
                                   name="keyword"
                                   class="form-control-custom"
                                   value="<c:out value='${keyword}'/>"
                                   placeholder="Order ID, supplier, creator...">
                        </div>

                        <div class="form-group import-filter-field">
                            <label class="form-label">
                                Status
                            </label>

                            <select name="status"
                                    class="form-control-custom">

                                <option value="">
                                    All statuses
                                </option>

                                <option value="ORDER"
                                        ${selectedStatus == 'ORDER' ? 'selected' : ''}>
                                    ORDER
                                </option>

                                <option value="COMPLETE"
                                        ${selectedStatus == 'COMPLETE' ? 'selected' : ''}>
                                    COMPLETE
                                </option>

                            </select>
                        </div>

                        <div class="form-group import-filter-field">
                            <label class="form-label">
                                Sort
                            </label>

                            <select name="sort"
                                    class="form-control-custom">

                                <option value="newest"
                                        ${empty selectedSort || selectedSort == 'newest'
                                          ? 'selected' : ''}>
                                    Newest
                                </option>

                                <option value="oldest"
                                        ${selectedSort == 'oldest' ? 'selected' : ''}>
                                    Oldest
                                </option>

                                <option value="total-desc"
                                        ${selectedSort == 'total-desc' ? 'selected' : ''}>
                                    Highest total
                                </option>

                                <option value="total-asc"
                                        ${selectedSort == 'total-asc' ? 'selected' : ''}>
                                    Lowest total
                                </option>

                            </select>
                        </div>

                        <div class="import-filter-action">
                            <button type="submit"
                                    class="btn primary-action">
                                <i class="bi bi-search"></i>
                                Search
                            </button>
                        </div>

                    </div>
                </form>
            </div>

            <!-- =================================================
                 TABLE
                 ================================================= -->
            <div class="import-table-card">
                <c:choose>
                    <c:when test="${empty importOrders}">
                        <div class="import-empty-state">
                            <i class="bi bi-box-seam"></i>
                            <h3>
                                No import orders found
                            </h3>
                            <p>
                                There are no import orders matching
                                your current filters.
                            </p>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <table class="import-table">
                            <thead>
                                <tr>
                                    <th>Order</th>
                                    <th>Supplier</th>
                                    <th>Created by</th>
                                    <th>Items</th>
                                    <th>Total </th>
                                    <th>Status</th>
                                    <th>Created at</th>
                                    <th>Action </th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="order"
                                           items="${importOrders}">
                                    <tr>
                                        <!-- ORDER -->
                                        <td>
                                            <div class="order-code">
                                                #${order.id}
                                            </div>
                                        </td>

                                        <!-- SUPPLIER -->
                                        <td>
                                            <span class="supplier-name">
                                                <c:out
                                                    value="${order.supplierName}"/>
                                            </span>
                                        </td>

                                        <!-- CREATOR -->
                                        <td>
                                            <span class="creator-name">
                                                <c:out
                                                    value="${order.userName}"/>
                                            </span>
                                        </td>
                                        <!-- ITEMS -->
                                        <td>
                                            <span class="item-count">
                                                ${order.itemCount}
                                            </span>
                                        </td>
                                        <!-- TOTAL -->
                                        <td>
                                            <span class="amount">
                                                <fmt:formatNumber
                                                    value="${order.totalPrice}"
                                                    type="number"
                                                    groupingUsed="true"
                                                    maxFractionDigits="0"/>
                                                ₫
                                            </span>
                                        </td>

                                        <!-- STATUS -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${order.status == 'ORDER'}">
                                                    <span class="status-pill status-order">
                                                        <i class="bi bi-clock"></i>
                                                        ORDER
                                                    </span>
                                                </c:when>
                                                <c:when test="${order.status == 'COMPLETE'}">
                                                    <span class="status-pill status-complete">
                                                        <i class="bi bi-check-circle"></i>
                                                        COMPLETE
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill">
                                                        <c:out
                                                            value="${order.status}"/>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <!-- CREATED -->
                                        <td>
                                            <fmt:formatDate
                                                value="${order.createdAt}"
                                                pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <!-- ACTION -->
                                        <td>
                                            <div class="table-actions">
                                                <a class="btn subtle btn-view"
                                                   href="${pageContext.request.contextPath}/manager/import?action=detail&id=${order.id}">
                                                    <i class="bi bi-eye"></i>
                                                    View
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
