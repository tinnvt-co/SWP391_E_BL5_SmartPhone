<%--
    Document   : import-detail
    Created on : Aug 20, 2026
    Author     : KhanhVNHE191788

    This JSP is shared by:
    - Create import order
    - View import order

    CREATE:
    - order is empty
    - show supplier / payment / note / product form

    DETAIL:
    - order exists
    - show order information / status / imported products

    HISTORY:
    - history exists
    - show history sidebar
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>
            <c:choose>
                <c:when test="${empty order}">Create Import Order</c:when>
                <c:otherwise>Import Order #${order.id}</c:otherwise>
            </c:choose>
        </title>
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            /* =====================================================
               PAGE
               -----------------------------------------------------
               width:100% is required alongside max-width + margin:
               auto so the block always spans the available width
               before being centered — otherwise, if .page-shell
               (from app-layout.css) doesn't force a width, this
               element can shrink to its content and margin:auto
               has nothing to center against.
               ===================================================== */
            .import-detail-page {
                width: 100%;
                max-width: 1400px;
                margin: 0 auto;
                padding-left: 20px;
                padding-right: 20px;
                box-sizing: border-box;
            }

            /* ===== LAYOUT ===== */
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
            .detail-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .detail-card {
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                padding: 24px;
                margin-bottom: 20px;
            }
            .detail-card.full {
                grid-column: 1 / -1;
            }
            .detail-card h2 {
                margin: 0;
                font-size: 18px;
                font-weight: 700;
                color: #111827;
            }
            .detail-card-subtitle {
                margin-top: 6px;
                margin-bottom: 22px;
                color: #64748b;
                font-size: 14px;
            }

            /* ===== SEARCH BOX (supplier name / product name filters) ===== */
            .search-box {
                position: relative;
                margin-bottom: 14px;
            }
            .search-box i {
                position: absolute;
                left: 13px;
                top: 50%;
                transform: translateY(-50%);
                color: #94a3b8;
                font-size: 13px;
            }
            .search-box input {
                padding-left: 34px;
            }
            .filter-empty-hint {
                display: none;
                color: #94a3b8;
                font-size: 13px;
                margin-top: -6px;
                margin-bottom: 14px;
            }
            .filter-empty-hint.visible {
                display: block;
            }

            /* ===== INFORMATION ===== */
            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .info-item {
                display: flex;
                flex-direction: column;
                gap: 5px;
            }
            .info-label {
                font-size: 12px;
                font-weight: 700;
                color: #64748b;
                text-transform: uppercase;
                letter-spacing: .04em;
            }
            .info-value {
                color: #111827;
                font-weight: 600;
            }
            .info-note {
                margin-top: 20px;
                padding-top: 18px;
                border-top: 1px solid #f1f5f9;
            }

            /* ===== STATUS ===== */
            .status-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                width: fit-content;
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

            /* ===== FORM ===== */
            .required {
                color: #dc2626;
            }
            .form-help {
                display: block;
                margin-top: 6px;
                color: #64748b;
                font-size: 13px;
            }
            .import-item-row {
                display: grid;
                grid-template-columns: 3fr 1fr 1fr auto;
                gap: 12px;
                align-items: end;
                padding: 16px;
                background: #f8fafc;
                border: 1px solid #e5e7eb;
                border-radius: 10px;
                margin-bottom: 12px;
            }
            .item-actions {
                display: flex;
                align-items: end;
            }
            .form-actions {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                margin-top: 24px;
                padding-top: 20px;
                border-top: 1px solid #f1f5f9;
            }

            /* ===== PRODUCT TABLE ===== */
            .item-table-wrapper {
                overflow-x: auto;
            }
            .item-table {
                width: 100%;
                border-collapse: collapse;
                margin: 0;
            }
            .item-table th {
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
            .item-table td {
                padding: 15px 16px;
                border-bottom: 1px solid #f1f5f9;
                vertical-align: middle;
            }
            .item-table tbody tr:hover {
                background: #fafafa;
            }
            .product-name {
                font-weight: 700;
                color: #111827;
            }
            .variant-info {
                color: #64748b;
                font-size: 13px;
                margin-top: 3px;
            }
            .item-image {
                width: 52px;
                height: 52px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e5e7eb;
                margin-right: 10px;
            }
            .product-cell {
                display: flex;
                align-items: center;
                min-width: 220px;
            }
            .total-row td {
                font-weight: 700;
                font-size: 16px;
                border-bottom: none;
                padding-top: 18px;
            }

            /* ===== STATUS ACTION ===== */
            .status-action-text {
                color: #64748b;
                line-height: 1.6;
                margin-bottom: 20px;
            }
            .complete-form {
                display: inline;
            }

            /* ===== HISTORY SIDEBAR ===== */
            .history-card {
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                padding: 24px;
                position: sticky;
                top: 20px;
            }
            .history-list {
                position: relative;
                margin-top: 20px;
            }
            .history-item {
                position: relative;
                padding-left: 28px;
                padding-bottom: 22px;
            }
            .history-item:last-child {
                padding-bottom: 0;
            }
            .history-item::before {
                content: "";
                position: absolute;
                left: 5px;
                top: 7px;
                bottom: 0;
                width: 1px;
                background: #e5e7eb;
            }
            .history-item:last-child::before {
                display: none;
            }
            .history-dot {
                position: absolute;
                left: 0;
                top: 4px;
                width: 11px;
                height: 11px;
                border-radius: 50%;
                background: #64748b;
                border: 2px solid #fff;
                box-shadow: 0 0 0 1px #cbd5e1;
            }
            .history-status {
                font-size: 13px;
                font-weight: 700;
                color: #111827;
            }
            .history-date {
                margin-top: 4px;
                font-size: 12px;
                color: #64748b;
            }
            .history-user {
                margin-top: 4px;
                font-size: 13px;
                color: #475569;
            }

            /* ===== DETAIL + HISTORY LAYOUT ===== */
            .detail-with-history {
                display: grid;
                grid-template-columns: minmax(0, 1fr) 320px;
                gap: 20px;
                align-items: start;
            }

            /* When there's no history sidebar to show, don't reserve
               the 320px column — otherwise the main content gets
               pushed left with dead space on the right. */
            .detail-with-history.no-history {
                grid-template-columns: minmax(0, 1fr);
            }

            /* ===== RESPONSIVE ===== */
            @media (max-width: 1100px) {
                .detail-with-history {
                    grid-template-columns: 1fr;
                }
                .history-card {
                    position: static;
                }
            }
            @media (max-width: 900px) {
                .detail-grid {
                    grid-template-columns: 1fr;
                }
                .detail-card.full {
                    grid-column: auto;
                }
                .info-grid {
                    grid-template-columns: 1fr 1fr;
                }
                .import-item-row {
                    grid-template-columns: 1fr 1fr;
                }
                .item-actions {
                    justify-content: flex-start;
                }
            }
            @media (max-width: 650px) {
                .info-grid {
                    grid-template-columns: 1fr;
                }
                .import-item-row {
                    grid-template-columns: 1fr;
                }
                .form-actions {
                    flex-direction: column-reverse;
                }
                .form-actions .btn {
                    width: 100%;
                }
                .item-table {
                    min-width: 850px;
                }
            }
        </style>
    </head>

    <body>

        <c:set var="activePage" value="manager" scope="request"/>

        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell import-detail-page">

            <!-- PAGE HEADING -->
            <div class="page-heading">
                <div>
                    <span class="manager-kicker">PROCUREMENT</span>
                    <c:choose>
                        <c:when test="${empty order}">
                            <h1>Create Import Order</h1>
                            <p>Create a new import order from a supplier.</p>
                        </c:when>
                        <c:otherwise>
                            <h1>Import Order #${order.id}</h1>
                            <p>View import order information and imported products.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager/import">
                        <i class="bi bi-arrow-left"></i>
                        Back to import orders
                    </a>
                </div>
            </div>

            <!-- FLASH MESSAGE -->
            <c:if test="${not empty sessionScope.message}">
                <div class="alert alert-success">
                    <i class="bi bi-check-circle"></i>
                    <c:out value="${sessionScope.message}"/>
                </div>
                <c:remove var="message" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger">
                    <i class="bi bi-exclamation-circle"></i>
                    <c:out value="${sessionScope.error}"/>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>


            <!-- =================== CREATE (order == null) =================== -->
            <c:if test="${empty order}">
                <form method="post" action="${pageContext.request.contextPath}/manager/import">
                    <input type="hidden" name="action" value="create">

                    <div class="detail-grid">

                        <!-- SUPPLIER -->
                        <section class="detail-card">
                            <h2>Supplier</h2>
                            <p class="detail-card-subtitle">Select the supplier for this import order.</p>

                            <!-- Filters the options inside the supplier <select> below by name.
                                 Does not touch the product/variant filtering. -->
                            <div class="search-box">
                                <i class="bi bi-search"></i>
                                <input type="text" id="supplierSearchInput" class="form-control-custom"
                                       placeholder="Search supplier by name...">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Supplier <span class="required">*</span></label>
                                <select name="supplierId" id="supplierSelect" class="form-control-custom" required>
                                    <option value="">-- Select supplier --</option>
                                    <c:forEach var="supplier" items="${suppliers}">
                                        <option value="${supplier.id}"
                                                data-name="${fn:toLowerCase(supplier.name)}"
                                                ${selectedSupplierId == supplier.id ? 'selected' : ''}>
                                            <c:out value="${supplier.name}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                                <span class="form-help">Select a supplier before adding products.</span>
                            </div>
                        </section>


                        <!-- ORDER INFORMATION -->
                        <section class="detail-card">
                            <h2>Order Information</h2>
                            <p class="detail-card-subtitle">Additional information for this import order.</p>

                            <div class="form-group">
                                <label class="form-label">Payment Method</label>
                                <select name="method" class="form-control-custom">
                                    <option value="CASH">Cash</option>
                                    <option value="BANK_TRANSFER">Bank transfer</option>
                                </select>
                            </div>

                            <div class="form-group" style="margin-top: 18px;">
                                <label class="form-label">Note</label>
                                <textarea name="note" class="form-control-custom" rows="4"
                                          maxlength="500" placeholder="Optional note..."></textarea>
                            </div>
                        </section>


                        <!-- PRODUCTS -->
                        <section class="detail-card full">
                            <h2>Import Products</h2>
                            <p class="detail-card-subtitle">Add products, quantities and import prices.</p>

                            <!-- Filters the options inside every "Product Variant" <select> by product
                                 name. Combined (AND) with the currently selected supplier, so picking a
                                 supplier and typing a product name never override each other. -->
                            <div class="search-box">
                                <i class="bi bi-search"></i>
                                <input type="text" id="productSearchInput" class="form-control-custom"
                                       placeholder="Search product by name...">
                            </div>
                            <span class="filter-empty-hint" id="variantFilterEmptyHint">
                                No product matches the current supplier / search filter.
                            </span>

                            <div id="itemsContainer">
                                <div class="import-item-row">

                                    <!-- PRODUCT VARIANT -->
                                    <div class="form-group">
                                        <label class="form-label">Product Variant <span class="required">*</span></label>
                                        <select name="variantId" class="form-control-custom" required>
                                            <option value="">-- Select product --</option>
                                            <c:forEach var="product" items="${products}">
                                                <c:forEach var="variant" items="${product.variants}">
                                                    <option value="${variant.id}"
                                                            data-name="${fn:toLowerCase(product.name)}"
                                                            data-supplier-ids="<c:forEach var="sid" items="${variantSupplierMap[variant.id]}" varStatus="st">${sid}${!st.last ? ',' : ''}</c:forEach>">
                                                        <c:out value="${product.name}"/> -
                                                        ${variant.ramGb}GB / ${variant.storageGb}GB /
                                                        <c:out value="${variant.colorName}"/>
                                                    </option>
                                                </c:forEach>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <!-- QUANTITY -->
                                    <div class="form-group">
                                        <label class="form-label">Quantity</label>
                                        <input type="number" name="quantity" class="form-control-custom"
                                               min="1" max= "999" value="1" required>
                                    </div>

                                    <!-- UNIT PRICE -->
                                    <div class="form-group">
                                        <label class="form-label">Unit Price</label>
                                        <input type="number" name="unitPrice" class="form-control-custom"
                                               min="1" max="1000000000" step="1" required>
                                    </div>

                                    <!-- REMOVE -->
                                    <div class="item-actions">
                                        <button type="button" class="btn subtle" onclick="removeItem(this)">
                                            <i class="bi bi-trash"></i>
                                            Remove
                                        </button>
                                    </div>

                                </div>
                            </div>

                            <!-- ADD PRODUCT -->
                            <button type="button" class="btn subtle" onclick="addItem()">
                                <i class="bi bi-plus-lg"></i>
                                Add product
                            </button>

                            <!-- ACTIONS -->
                            <div class="form-actions">
                                <a class="btn subtle" href="${pageContext.request.contextPath}/manager/import">
                                    Cancel
                                </a>
                                <button type="submit" class="btn primary">
                                    <i class="bi bi-check-lg"></i>
                                    Create Import Order
                                </button>
                            </div>
                        </section>

                    </div>
                </form>
            </c:if>


            <!-- =================== DETAIL (order != null) =================== -->
            <c:if test="${not empty order}">
                <div class="detail-with-history ${empty history ? 'no-history' : ''}">

                    <!-- MAIN DETAIL CONTENT -->
                    <div>
                        <div class="detail-grid">

                            <!-- ORDER INFORMATION -->
                            <section class="detail-card">
                                <h2>Order Information</h2>
                                <p class="detail-card-subtitle">Basic information about this import order.</p>

                                <div class="info-grid">

                                    <div class="info-item">
                                        <span class="info-label">Order ID</span>
                                        <span class="info-value">#${order.id}</span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">Status</span>
                                        <span class="info-value">
                                            <c:choose>
                                                <c:when test="${order.status == 'COMPLETED'}">
                                                    <span class="status-pill status-complete">
                                                        <i class="bi bi-check-circle"></i>
                                                        COMPLETE
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill status-order">
                                                        <i class="bi bi-clock"></i>
                                                        ORDER
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">Supplier</span>
                                        <span class="info-value"><c:out value="${order.supplierName}"/></span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">Created By</span>
                                        <span class="info-value"><c:out value="${order.userName}"/></span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">Created At</span>
                                        <span class="info-value">
                                            <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">Last Updated</span>
                                        <span class="info-value">
                                            <c:choose>
                                                <c:when test="${not empty order.updatedAt}">
                                                    <fmt:formatDate value="${order.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">Payment Method</span>
                                        <span class="info-value">
                                            <c:choose>
                                                <c:when test="${order.method == 'BANK_TRANSFER'}">Bank transfer</c:when>
                                                <c:when test="${order.method == 'CASH'}">Cash</c:when>
                                                <c:otherwise><c:out value="${order.method}"/></c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">Total</span>
                                        <span class="info-value">
                                            <fmt:formatNumber value="${order.totalPrice}" type="number"
                                                              groupingUsed="true" maxFractionDigits="0"/> ₫
                                        </span>
                                    </div>

                                </div>

                                <c:if test="${not empty order.note}">
                                    <div class="info-note" style="overflow-wrap: break-word;
                                         word-break: break-word ">
                                        <span class="info-label">Note</span>
                                        <div style="margin-top: 6px;"><c:out value="${order.note}"/></div>
                                    </div>
                                </c:if>
                            </section>


                            <!-- STATUS ACTION -->
                            <section class="detail-card">
                                <h2>Order Status</h2>
                                <p class="detail-card-subtitle">Available actions for this import order.</p>

                                <c:choose>
                                    <c:when test="${order.status == 'ORDER'}">
                                        <p class="status-action-text">
                                            This order has been created but the imported products
                                            have not been added to inventory yet.
                                        </p>

                                        <form method="post" action="${pageContext.request.contextPath}/manager/import"
                                              class="complete-form">
                                            <input type="hidden" name="action" value="complete">
                                            <input type="hidden" name="id" value="${order.id}">
                                            <button type="submit" class="btn primary"
                                                    onclick="return confirm('Complete this import order? Inventory will be increased.');">
                                                <i class="bi bi-check-circle"></i>
                                                Complete Import Order
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="alert alert-success">
                                            <i class="bi bi-check-circle"></i>
                                            This import order has been completed. Inventory has been updated.
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </section>


                            <!-- PRODUCTS -->
                            <section class="detail-card full">
                                <h2>Imported Products</h2>
                                <p class="detail-card-subtitle">Products included in this import order.</p>

                                <div class="item-table-wrapper">
                                    <table class="item-table">
                                        <thead>
                                            <tr>
                                                <th>Product</th>
                                                <th>Variant</th>
                                                <th>Quantity</th>
                                                <th>Unit Price</th>
                                                <th>Total</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${order.items}">
                                                <tr>
                                                    <td>
                                                        <div class="product-cell">
                                                            <c:if test="${not empty item.productImage}">
                                                                <img class="item-image"
                                                                     src="${pageContext.request.contextPath}${item.imageUrl}"
                                                                     alt="Product">
                                                            </c:if>
                                                            <div>
                                                                <div class="product-name">
                                                                    <c:out value="${item.productName}"/>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="variant-info"><c:out value="${item.memoryLabel}"/></div>
                                                        <div class="variant-info"><c:out value="${item.colorName}"/></div>
                                                    </td>
                                                    <td>${item.amount}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${item.unitPrice}" type="number"
                                                                          groupingUsed="true" maxFractionDigits="0"/> ₫
                                                    </td>
                                                    <td>
                                                        <fmt:formatNumber value="${item.total}" type="number"
                                                                          groupingUsed="true" maxFractionDigits="0"/> ₫
                                                    </td>
                                                </tr>
                                            </c:forEach>

                                            <tr class="total-row">
                                                <td colspan="4" style="text-align: right;">Total</td>
                                                <td>
                                                    <fmt:formatNumber value="${order.totalPrice}" type="number"
                                                                      groupingUsed="true" maxFractionDigits="0"/> ₫
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </section>

                        </div>
                    </div>


                    <!-- HISTORY SIDEBAR -->
                    <c:if test="${not empty history}">
                        <aside class="history-card">
                            <h2>Status History</h2>
                            <p class="detail-card-subtitle">History of this import order.</p>

                            <div class="history-list">
                                <c:forEach var="h" items="${history}">
                                    <div class="history-item">
                                        <span class="history-dot"></span>
                                        <div class="history-status"><c:out value="${h.status}"/></div>
                                        <div class="history-date">
                                            <fmt:formatDate value="${h.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </div>
                                        <c:if test="${not empty h.userName}">
                                            <div class="history-user">By <c:out value="${h.userName}"/></div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </aside>
                    </c:if>

                </div>
            </c:if>

        </main>

        <%@ include file="/views/common/footer.jsp" %>


        <!-- CREATE MODE JAVASCRIPT (only loaded when order is empty) -->
        <c:if test="${empty order}">
            <script>
                /* =========================================================
                 SHARED FILTER STATE
                 ---------------------------------------------------------
                 Every filter (supplier dropdown, product-name search,
                 supplier-name search, selected product variants) writes
                 into this single object. applyVariantFilter()/
                 applySupplierFilter() are the only places that touch
                 `option.hidden`, and each one always ANDs together every
                 active criterion. Never let two separate functions
                 independently set `hidden` on the same option set —
                 that's what causes one filter to silently undo another.
                 ========================================================= */
                const filterState = {
                    supplierId: '',
                    productSearch: '',
                    supplierSearch: '',
                    selectedVariantIds: []
                };

                /* =========================================================
                 SUPPLIER -> VARIANT REVERSE MAP
                 ---------------------------------------------------------
                 Each <option> under select[name="variantId"] already
                 carries data-supplier-ids (built server-side from
                 variantSupplierMap). We invert that once on load into
                 supplierId -> Set(variantId), which is what the
                 "product picked -> narrow supplier list" direction needs.
                 Built once because every item row is a clone of the
                 same option list, so reading the first row is enough.
                 ========================================================= */
                let supplierVariantMap = {};

                function buildSupplierVariantMap() {
                    const map = {};
                    //Lấy select chưa name = variantId, nếu không tìm thấy thì trả về map rỗng
                    const firstSelect = document.querySelector('select[name="variantId"]');
                    if (!firstSelect) {
                        return map;
                    }
                    
                    //tạo map mới để lưu với key là nhà cung cấp và value là list sản phẩm
                    Array.from(firstSelect.options).forEach(function (opt) {
                        if (!opt.value) {
                            return;
                        }
                        const supplierIds = (opt.dataset.supplierIds || '')
                                .split(',')
                                .filter(Boolean);

                        supplierIds.forEach(function (sid) {
                            if (!map[sid]) {
                                map[sid] = new Set();
                            }
                            map[sid].add(opt.value);
                        });
                    });

                    return map;
                }
                
                //lấy tất cả id mà người dùng chọn để phục vụ create trong controller
                function getSelectedVariantIds() {
                    return Array.from(document.querySelectorAll('select[name="variantId"]'))
                            .map(function (select) {
                                return select.value;
                            })
                            .filter(Boolean);
                }
                
                
                function applyVariantFilter() {
                    const selects = document.querySelectorAll('select[name="variantId"]');
                    let anyVisibleAnywhere = false;
                    
                    //lặp qua từng select
                    selects.forEach(function (select) {
                        //chuyển select thành array để duyệt các option của select
                        Array.from(select.options).forEach(function (opt) {
                            if (!opt.value) {
                                // keep the "-- Select product --" placeholder always visible
                                opt.hidden = false;
                                //chuyển đến lần lặp tiếp theo
                                return;
                            }
                            
                            //Lấy danh sách supplier của variant
                            const supplierIds = (opt.dataset.supplierIds || '')
                                    .split(',')
                                    .filter(Boolean);//loại bỏ giá trị rỗng
                            
                            //kiểm tra variant có chưa id của supplier đang chọn không, nếu có trả về true
                            const matchSupplier = !filterState.supplierId
                                    || supplierIds.includes(filterState.supplierId);
                            
                            //lấy tên sản phẩm nếu có trong opt
                            const name = opt.dataset.name || '';
                            //kiểm tra product search
                            const matchSearch = !filterState.productSearch
                                    || name.includes(filterState.productSearch);
                            
                            //kết hợp vừa có search vừa có id supplier mà user yêu cầu
                            const visible = matchSupplier && matchSearch;
                            
                            //thực hiển ẩn, hiện option
                            opt.hidden = !visible;
                            
                            if (visible) {
                                anyVisibleAnywhere = true;
                            }

                            // Nếu sản phẩm đang chọn nhưng bị lọc bỏ thì sẽ bỏ chọn để không bị lỗi khi create
                            if (!visible && opt.selected) {
                                select.value = '';
                            }
                        });
                    });
                    
                    //nếu không thấy thì hiển thị không báo no product found
                    const hint = document.getElementById('variantFilterEmptyHint');
                    if (hint) {
                        hint.classList.toggle('visible', !anyVisibleAnywhere);
                    }

                    // a variant selection may have just been cleared above ->
                    // keep the supplier list in sync with whatever products
                    // are still actually selected
                    filterState.selectedVariantIds = getSelectedVariantIds();
                    applySupplierFilter();
                }
                
                /*
                 * lọc supplier nếu cung cấp tất cả các sản phẩm đã chọn thì sẽ hiển thị nếu không có 
                 * kết quả hợp lệ thì hiển thị không tìm thấy
                 * 
                 */
                function applySupplierFilter() {
                    const select = document.getElementById('supplierSelect');
                    if (!select) {
                        return;
                    }

                    Array.from(select.options).forEach(function (opt) {
                        if (!opt.value) {
                            opt.hidden = false;
                            return;
                        }

                        const name = opt.dataset.name || '';
                        const matchSearch = !filterState.supplierSearch
                                || name.includes(filterState.supplierSearch);

                        // supplier must supply EVERY product currently picked
                        // in the item rows, since one import order has a
                        // single supplier for all its lines
                        const suppliedVariants = supplierVariantMap[opt.value] || new Set();
                        const matchProducts = filterState.selectedVariantIds
                                .every(function (vid) {
                                    return suppliedVariants.has(vid);
                                });

                        const visible = matchSearch && matchProducts;
                        opt.hidden = !visible;

                        if (!visible && opt.selected) {
                            select.value = '';
                            // supplier selection was cleared -> re-run the
                            // product filter so it no longer restricts by
                            // a supplier that's no longer selected
                            filterState.supplierId = '';
                            applyVariantFilter();
                        }
                    });
                }

                function addItem() {
                    const container = document.getElementById('itemsContainer');
                    const firstRow = container.querySelector('.import-item-row');
                    const newRow = firstRow.cloneNode(true);

                    const select = newRow.querySelector('select');
                    if (select) {
                        select.selectedIndex = 0;
                    }

                    newRow.querySelectorAll('input').forEach(function (input) {
                        if (input.name === 'quantity') {
                            input.value = '1';
                        } else {
                            input.value = '';
                        }
                    });

                    container.appendChild(newRow);

                    // the new row's <select> must respect whatever
                    // supplier / search filter is currently active
                    applyVariantFilter();
                }

                function removeItem(button) {
                    const container = document.getElementById('itemsContainer');
                    const rows = container.querySelectorAll('.import-item-row');

                    if (rows.length <= 1) {
                        alert('An import order must contain at least one product.');
                        return;
                    }

                    button.closest('.import-item-row').remove();

                    // removing a row may remove a product selection ->
                    // the supplier list can potentially widen again
                    filterState.selectedVariantIds = getSelectedVariantIds();
                    applySupplierFilter();
                }
                
                //load xong html thì cạy phần này
                document.addEventListener('DOMContentLoaded', function () {
                    const supplierSelect = document.getElementById('supplierSelect');
                    const productSearchInput = document.getElementById('productSearchInput');
                    const supplierSearchInput = document.getElementById('supplierSearchInput');
                    const itemsContainer = document.getElementById('itemsContainer');

                    supplierVariantMap = buildSupplierVariantMap();

                    // pick up a supplierId that was pre-selected server-side
                    // (e.g. navigated here from a supplier's page)
                    filterState.supplierId = supplierSelect ? supplierSelect.value : '';
                    filterState.selectedVariantIds = getSelectedVariantIds();

                    if (supplierSelect) {
                        supplierSelect.addEventListener('change', function () {
                            filterState.supplierId = this.value;
                            applyVariantFilter();
                        });
                    }

                    if (productSearchInput) {
                        productSearchInput.addEventListener('input', function () {
                            filterState.productSearch = this.value.trim().toLowerCase();
                            applyVariantFilter();
                        });
                    }

                    if (supplierSearchInput) {
                        supplierSearchInput.addEventListener('input', function () {
                            filterState.supplierSearch = this.value.trim().toLowerCase();
                            applySupplierFilter();
                        });
                    }

                    // event delegation: item rows are cloned dynamically by
                    // addItem(), so a single listener on the container
                    // catches "change" from every current AND future
                    // select[name="variantId"] without re-binding per row
                    if (itemsContainer) {
                        itemsContainer.addEventListener('change', function (e) {
                            if (e.target.matches('select[name="variantId"]')) {
                                filterState.selectedVariantIds = getSelectedVariantIds();
                                applySupplierFilter();
                            }
                        });
                    }

                    applyVariantFilter();
                    applySupplierFilter();
                });
            </script>
        </c:if>

    </body>
</html>
