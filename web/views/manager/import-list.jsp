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
              href="${pageContext.request.contextPath}/assets/css/style.css">

        <style>
            .import-list-page {
                max-width: 1400px;
                margin: 0 auto;
            }

            .filter-card {
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                padding: 20px;
                margin-bottom: 24px;
            }

            .filter-grid {
                display: grid;
                grid-template-columns: 2fr 1fr 1fr auto;
                gap: 14px;
                align-items: end;
            }

            .table-card {
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

            .import-table th {
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

            .import-table td {
                padding: 15px 16px;
                border-bottom: 1px solid #f1f5f9;
                vertical-align: middle;
            }

            .import-table tbody tr:hover {
                background: #fafafa;
            }

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

            .amount {
                font-weight: 700;
                white-space: nowrap;
            }

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

            .empty-state {
                text-align: center;
                padding: 70px 20px;
                color: #64748b;
            }

            .empty-state i {
                font-size: 42px;
                margin-bottom: 12px;
            }

            .table-actions {
                display: flex;
                justify-content: flex-end;
                gap: 8px;
            }

            .btn-view {
                text-decoration: none;
                white-space: nowrap;
            }

            @media (max-width: 1000px) {
                .filter-grid {
                    grid-template-columns: 1fr 1fr;
                }

                .filter-grid .search-field {
                    grid-column: 1 / -1;
                }
            }

            @media (max-width: 700px) {
                .filter-grid {
                    grid-template-columns: 1fr;
                }

                .filter-grid .search-field {
                    grid-column: auto;
                }

                .table-card {
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
                    <a class="btn primary-action"
                       href="${pageContext.request.contextPath}/manager/import-orders?action=create">
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
            <div class="filter-card">
                <form method="get"
                      action="${pageContext.request.contextPath}/manager/import-orders">
                    <div class="filter-grid">
                        <div class="form-group search-field">
                            <label class="form-label">
                                Search
                            </label>
                            <input type="text"
                                   name="keyword"
                                   class="form-control-custom"
                                   value="<c:out value='${keyword}'/>"
                                   placeholder="Order ID, supplier, creator...">
                        </div>


                        <div class="form-group">
                            <label class="form-label">
                                Status
                            </label>
                            <select name="status"
                                    class="form-control-custom">
                                <option value="">
                                    All statuses
                                </option>
                                <option value="ORDER"
                                        ${selectedStatus == 'ORDER'
                                          ? 'selected'
                                          : ''}>
                                    ORDER
                                </option>
                                <option value="COMPLETE"
                                        ${selectedStatus == 'COMPLETE'
                                          ? 'selected'
                                          : ''}>
                                    COMPLETE
                                </option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                Sort
                            </label>

                            <select name="sort"
                                    class="form-control-custom">
                                <option value="newest"
                                        ${empty selectedSort || selectedSort == 'newest' ? 'selected' : ''}>
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

                        <div class="form-group">
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
            <div class="table-card">
                <c:choose>
                    <c:when test="${empty importOrders}">
                        <div class="empty-state">
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
                                            ${order.itemCount}
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
                                                   href="${pageContext.request.contextPath}/manager/import-orders?action=detail&id=${order.id}">
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
    </body>
</html>
