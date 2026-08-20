<%-- 
    Document   : supplier-detail
    Created on : Aug 19, 2026, 2:53:05 PM
    Author     : admin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>
            ${supplier.id == 0 ? 'New Supplier' : 'Supplier - '}
            <c:if test="${supplier.id != 0}">
                <c:out value="${supplier.name}"/>
            </c:if>
        </title>
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            .supplier-detail-page {
                padding-bottom: 48px;
            }
            .supplier-detail-grid {
                display: grid;
                grid-template-columns: 2fr 1fr;
                gap: 20px;
            }
            .supplier-card {
                background: #fff;
                border: 1px solid #e7e9ee;
                border-radius: 18px;
                padding: 26px;
                box-shadow: 0 8px 24px rgba(20, 25, 40, 0.05);
            }
            .supplier-card h2 {
                margin: 0 0 5px;
                font-size: 20px;
            }
            .supplier-card-subtitle {
                margin: 0 0 24px;
                color: #7a818b;
                font-size: 14px;
            }
            .supplier-identity {
                display: flex;
                align-items: center;
                gap: 16px;
                margin-bottom: 26px;
            }
            .supplier-avatar {
                width: 58px;
                height: 58px;
                border-radius: 15px;
                display: flex;
                align-items: center;
                justify-content: center;
                background: #f1f5f9;
                color: #334155;
                font-size: 24px;
            }
            .supplier-identity h1 {
                margin: 0;
                font-size: 25px;
                font-weight: 750;
            }
            .supplier-id-label {
                margin-top: 4px;
                color: #858c96;
                font-size: 13px;
                font-family: monospace;
            }
            .detail-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .detail-item {
                padding: 15px 0;
                border-bottom: 1px solid #eef0f3;
            }
            .detail-item.full {
                grid-column: 1 / -1;
            }
            .detail-label {
                display: block;
                margin-bottom: 5px;
                color: #858c96;
                font-size: 12px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: .05em;
            }
            .detail-value {
                color: #20242b;
                font-size: 15px;
                font-weight: 550;
            }
            .detail-description {
                color: #626a75;
                line-height: 1.6;
            }
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
            .stat-box {
                padding: 18px;
                border-radius: 14px;
                background: #f8f9fb;
                margin-bottom: 14px;
            }
            .stat-box small {
                display: block;
                color: #858c96;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: .05em;
            }
            .stat-box strong {
                display: block;
                margin-top: 5px;
                font-size: 25px;
            }
            .variant-list {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 18px;
            }
            .variant-pill {
                padding: 7px 11px;
                border-radius: 9px;
                background: #f1f5f9;
                color: #475569;
                font-family: monospace;
                font-size: 13px;
                font-weight: 600;
            }
            .empty-variants {
                padding: 18px;
                border-radius: 12px;
                background: #f8f9fb;
                color: #7b828c;
                font-size: 14px;
            }
            .detail-actions {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
                margin-top: 24px;
            }
            .danger-btn {
                border: 1px solid #f0caca;
                background: #fff;
                color: #b42318;
            }
            .danger-btn:hover {
                background: #fff5f5;
                color: #a61b11;
            }
            @media (max-width: 850px) {
                .supplier-detail-grid {
                    grid-template-columns: 1fr;
                }
                .detail-grid {
                    grid-template-columns: 1fr;
                }
                .detail-item.full {
                    grid-column: auto;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>
        <main class="page-shell supplier-detail-page">
            <!-- ============================================= -->
            <!-- HEADING -->
            <!-- ============================================= -->
            <div class="page-heading">
                <div>
                    <span class="manager-kicker">
                        PROCUREMENT
                    </span>
                    <h1>Supplier Details</h1>
                    <p>
                        View supplier information and supplied products.
                    </p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle"
                       href="${pageContext.request.contextPath}/manager/supplier">
                        ← Back to suppliers
                    </a>
                </div>
            </div>
            <!-- CONTENT -->
            <div class="supplier-detail-grid">
                <!-- MAIN INFORMATION -->
                <section class="supplier-card">
                    <div class="supplier-identity">
                        <div class="supplier-avatar">
                            <i class="bi bi-building"></i>
                        </div>
                        <div>
                            <h1>
                                <c:out value="${supplier.name}"/>
                            </h1>
                            <div class="supplier-id-label">
                                Supplier #${supplier.id}
                            </div>
                        </div>
                    </div>

                    <div class="detail-grid">
                        <!-- NAME -->
                        <div class="detail-item">
                            <span class="detail-label">
                                Supplier Name
                            </span>
                            <span class="detail-value">
                                <c:out value="${supplier.name}"/>
                            </span>
                        </div>

                        <!-- STATUS -->
                        <div class="detail-item">
                            <span class="detail-label">
                                Status
                            </span>
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
                        </div>
                        <!-- PHONE -->
                        <div class="detail-item">
                            <span class="detail-label">
                                Phone
                            </span>
                            <span class="detail-value">
                                <c:out value="${supplier.phone}"/>
                            </span>
                        </div>

                        <!-- ADDRESS -->
                        <div class="detail-item">
                            <span class="detail-label">
                                Address
                            </span>
                            <span class="detail-value">
                                <c:out value="${supplier.address}"/>
                            </span>
                        </div>


                        <!-- DESCRIPTION -->
                        <div class="detail-item full">
                            <span class="detail-label">
                                Description
                            </span>
                            <div class="detail-description">
                                <c:choose>
                                    <c:when test="${not empty supplier.description}">
                                        <c:out value="${supplier.description}"/>
                                    </c:when>
                                    <c:otherwise>
                                        No description provided.
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- NOTE -->
                        <div class="detail-item full">
                            <span class="detail-label">
                                Note
                            </span>
                            <div class="detail-description">
                                <c:choose>
                                    <c:when test="${not empty supplier.note}">
                                        <c:out value="${supplier.note}"/>
                                    </c:when>
                                    <c:otherwise>
                                        No note.
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- CREATED -->
                        <div class="detail-item">
                            <span class="detail-label">
                                Created At
                            </span>
                            <span class="detail-value">
                                <fmt:formatDate
                                    value="${supplier.createdAt}"
                                    pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                        </div>

                        <!-- UPDATED -->
                        <div class="detail-item">
                            <span class="detail-label">
                                Updated At
                            </span>
                            <span class="detail-value">
                                <c:choose>
                                    <c:when test="${not empty supplier.updatedAt}">
                                        <fmt:formatDate
                                            value="${supplier.updatedAt}"
                                            pattern="dd/MM/yyyy HH:mm"/>
                                    </c:when>
                                    <c:otherwise>
                                        Never updated
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </section>

                <!-- RIGHT SUMMARY -->
                <aside>
                    <section class="supplier-card">
                        <h2>Supplier Summary</h2>
                        <p class="supplier-card-subtitle">
                            Current supplier information
                        </p>

                        <div class="stat-box">
                            <small>
                                Product Variants
                            </small>
                            <strong>
                                ${supplier.productVariantCount}
                            </strong>
                        </div>

                        <div class="stat-box">
                            <small>
                                Status
                            </small>
                            <strong style="font-size:18px;">
                                <c:choose>
                                    <c:when test="${supplier.status == 'ACTIVE'}">
                                        Active
                                    </c:when>
                                    <c:otherwise>
                                        Inactive
                                    </c:otherwise>
                                </c:choose>
                            </strong>
                        </div>

                        <div class="detail-actions">
                            <a class="btn primary"
                               href="${pageContext.request.contextPath}/manager/supplier?action=edit&id=${supplier.id}">
                                <i class="bi bi-pencil"></i>
                                Edit
                            </a>

                            <c:choose>
                                <c:when test="${supplier.status == 'ACTIVE'}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/manager/supplier"
                                          onsubmit="return confirm('Deactivate this supplier?');">
                                        <input type="hidden"
                                               name="action"
                                               value="deactivate">
                                        <input type="hidden"
                                               name="id"
                                               value="${supplier.id}">
                                        <button
                                            type="submit"
                                            class="btn danger-btn">
                                            Deactivate
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/manager/supplier">

                                        <input type="hidden"
                                               name="action"
                                               value="activate">

                                        <input type="hidden"
                                               name="id"
                                               value="${supplier.id}">

                                        <button
                                            type="submit"
                                            class="btn subtle">
                                            Activate
                                        </button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </aside>
            </div>


            <!-- PRODUCT VARIANTS -->
            <section class="supplier-card"
                     style="margin-top:20px;">
                <h2>
                    Supplied Product Variants
                </h2>
                <p class="supplier-card-subtitle">
                    Product variants currently associated with this supplier.
                </p>
                <c:choose>
                    <c:when test="${empty productVariantIds}">
                        <div class="empty-variants">
                            <i class="bi bi-box-seam"></i>
                            This supplier does not have any
                            Product variant assigned yet.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="variant-list">
                            <c:forEach
                                items="${productVariantIds}"
                                var="variantId">
                                <span class="variant-pill">
                                    Product Variant #${variantId}
                                </span>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
