<%-- 
    Document   : import-detail
    Created on : Aug 20, 2026, 10:44:18 PM
    Author     : KhanhVNHE191788
    Description:
           - Create import order
           - View import order detail
--%>



<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>

    <head>

        <meta charset="UTF-8">

        <title>
            ${mode == 'create'
              ? 'Create Import Order'
              : 'Import Order Detail'}
        </title>

        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/style.css">

        <style>

            .import-detail-page {
                max-width: 1200px;
                margin: 0 auto;
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
                font-size: 18px;
                font-weight: 700;
                margin-bottom: 5px;
            }

            .detail-card-subtitle {
                color: #64748b;
                font-size: 14px;
                margin-bottom: 22px;
            }

            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 18px;
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

            .status-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                width: fit-content;
                padding: 6px 11px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 700;
            }

            .status-order {
                background: #fff7ed;
                color: #c2410c;
            }

            .status-complete {
                background: #ecfdf5;
                color: #047857;
            }

            /* =================================================
               HISTORY
               ================================================= */

            .history-card {
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 14px;
                padding: 24px;
                margin-bottom: 20px;
            }

            .history-title {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 22px;
            }

            .history-title h2 {
                font-size: 18px;
                font-weight: 700;
                margin: 0;
            }

            .history-list {
                position: relative;
                margin: 0;
                padding: 0;
                list-style: none;
            }

            .history-list::before {
                content: "";
                position: absolute;
                top: 8px;
                bottom: 8px;
                left: 8px;
                width: 2px;
                background: #e5e7eb;
            }

            .history-item {
                position: relative;
                display: flex;
                gap: 16px;
                padding-bottom: 20px;
            }

            .history-item:last-child {
                padding-bottom: 0;
            }

            .history-dot {
                position: relative;
                z-index: 2;
                width: 18px;
                height: 18px;
                flex: 0 0 18px;
                border-radius: 50%;
                background: #fff;
                border: 4px solid #94a3b8;
            }

            .history-dot.order {
                border-color: #f97316;
            }

            .history-dot.complete {
                border-color: #10b981;
            }

            .history-content {
                flex: 1;
                padding-top: 0;
            }

            .history-status {
                font-weight: 700;
                color: #111827;
                margin-bottom: 3px;
            }

            .history-meta {
                color: #64748b;
                font-size: 13px;
            }

            /* =================================================
               ITEMS
               ================================================= */

            .item-table {
                width: 100%;
                border-collapse: collapse;
            }

            .item-table th {
                background: #f8fafc;
                color: #64748b;
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: .04em;
                padding: 13px 14px;
                border-bottom: 1px solid #e5e7eb;
            }

            .item-table td {
                padding: 14px;
                border-bottom: 1px solid #f1f5f9;
                vertical-align: middle;
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
            }

            .total-row td {
                font-weight: 700;
                font-size: 16px;
                border-bottom: none;
                padding-top: 18px;
            }

            /* =================================================
               FORM
               ================================================= */

            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 18px;
            }

            .form-group.full {
                grid-column: 1 / -1;
            }

            .required {
                color: #dc2626;
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

            .form-actions {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                margin-top: 24px;
            }

            .complete-form {
                display: inline;
            }

            @media (max-width: 800px) {

                .detail-grid {
                    grid-template-columns: 1fr;
                }

                .detail-card.full {
                    grid-column: auto;
                }

                .info-grid,
                .form-grid {
                    grid-template-columns: 1fr;
                }

                .form-group.full {
                    grid-column: auto;
                }

                .import-item-row {
                    grid-template-columns: 1fr;
                }

                .item-table {
                    min-width: 800px;
                }

                .item-table-wrapper {
                    overflow-x: auto;
                }
            }

        </style>

    </head>


    <body>

        <c:set var="activePage"
               value="manager"
               scope="request"/>

        <%@ include file="/views/common/header.jsp" %>


        <main class="page-shell import-detail-page">


            <!-- =================================================
                 HEADING
                 ================================================= -->

            <div class="page-heading">

                <div>

                    <span class="manager-kicker">
                        PROCUREMENT
                    </span>

                    <c:choose>

                        <c:when test="${mode == 'create'}">

                            <h1>
                                Create Import Order
                            </h1>

                            <p>
                                Create a new import order from a supplier.
                            </p>

                        </c:when>

                        <c:otherwise>

                            <h1>
                                Import Order #${order.id}
                            </h1>

                            <p>
                                View import order information,
                                products and status history.
                            </p>

                        </c:otherwise>

                    </c:choose>

                </div>


                <div class="page-heading-actions">

                    <a class="btn subtle"
                       href="${pageContext.request.contextPath}/manager/import-orders">

                        ← Back to import orders

                    </a>

                </div>

            </div>


            <!-- =================================================
                 DETAIL MODE
                 HISTORY
                 ================================================= -->

            <c:if test="${mode == 'detail'}">

                <section class="history-card">

                    <div class="history-title">

                        <h2>
                            Order History
                        </h2>

                        <c:choose>

                            <c:when test="${order.status == 'COMPLETE'}">

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

                    </div>


                    <ul class="history-list">

                        <c:forEach var="entry"
                                   items="${history}">

                            <li class="history-item">

                                <c:choose>

                                    <c:when test="${entry.startsWith('ORDER')}">

                                        <span class="history-dot order"></span>

                                    </c:when>

                                    <c:otherwise>

                                        <span class="history-dot complete"></span>

                                    </c:otherwise>

                                </c:choose>


                                <div class="history-content">

                                    <div class="history-status">

                                        <c:choose>

                                            <c:when test="${entry.startsWith('ORDER')}">

                                                Order created

                                            </c:when>

                                            <c:when test="${entry.startsWith('COMPLETE')}">

                                                Order completed

                                            </c:when>

                                            <c:otherwise>

                                                <c:out value="${entry}"/>

                                            </c:otherwise>

                                        </c:choose>

                                    </div>


                                    <div class="history-meta">

                                        <c:out value="${entry}"/>

                                    </div>

                                </div>

                            </li>

                        </c:forEach>

                    </ul>

                </section>

            </c:if>


            <!-- =================================================
                 CREATE MODE
                 ================================================= -->

            <c:if test="${mode == 'create'}">

                <form method="post"
                      action="${pageContext.request.contextPath}/manager/import-orders">

                    <input type="hidden"
                           name="action"
                           value="create">


                    <div class="detail-grid">


                        <!-- SUPPLIER -->

                        <section class="detail-card">

                            <h2>
                                Supplier
                            </h2>

                            <p class="detail-card-subtitle">
                                Select the supplier for this import order.
                            </p>


                            <div class="form-group">

                                <label class="form-label">
                                    Supplier
                                    <span class="required">*</span>
                                </label>

                                <select name="supplierId"
                                        class="form-control-custom"
                                        required
                                        onchange="this.form.submit()">

                                    <option value="">
                                        -- Select supplier --
                                    </option>

                                    <c:forEach var="supplier"
                                               items="${suppliers}">

                                        <option value="${supplier.id}"
                                                ${selectedSupplierId == supplier.id
                                                  ? 'selected'
                                                  : ''}>

                                            <c:out
                                                value="${supplier.name}"/>

                                        </option>

                                    </c:forEach>

                                </select>

                                <small class="text-muted">
                                    Selecting a supplier filters the
                                    available product variants.
                                </small>

                            </div>

                        </section>


                        <!-- BASIC INFORMATION -->

                        <section class="detail-card">

                            <h2>
                                Order Information
                            </h2>

                            <p class="detail-card-subtitle">
                                Additional information for this import order.
                            </p>


                            <div class="form-group">

                                <label class="form-label">
                                    Payment Method
                                </label>

                                <select name="method"
                                        class="form-control-custom">

                                    <option value="CASH">
                                        Cash
                                    </option>

                                    <option value="BANK_TRANSFER">
                                        Bank transfer
                                    </option>

                                </select>

                            </div>


                            <div class="form-group"
                                 style="margin-top: 16px;">

                                <label class="form-label">
                                    Note
                                </label>

                                <textarea name="note"
                                          class="form-control-custom"
                                          rows="4"
                                          maxlength="500"
                                          placeholder="Optional note..."></textarea>

                            </div>

                        </section>


                        <!-- PRODUCTS -->

                        <section class="detail-card full">

                            <h2>
                                Import Products
                            </h2>

                            <p class="detail-card-subtitle">
                                Add products, quantities and import prices.
                            </p>


                            <div id="itemsContainer">

                                <div class="import-item-row">

                                    <div class="form-group">
                                        <label class="form-label">
                                            Product Variant
                                            <span class="required">*</span>
                                        </label>
                                        <select name="variantId"
                                                class="form-control-custom"
                                                required>

                                            <option value="">
                                                -- Select product --
                                            </option>

                                            <c:forEach var="product"
                                                       items="${products}">
                                                <c:forEach
                                                    var="variant"
                                                    items="${product.variants}">
                                                    <option
                                                        value="${variant.id}"
                                                        ${selectedVariantId == variant.id
                                                          ? 'selected'
                                                          : ''}>
                                                        <c:out
                                                            value="${product.name}"/>
                                                        -
                                                        ${variant.ramGb}GB /

                                                        ${variant.storageGb}GB /
                                                        <c:out
                                                            value="${variant.colorName}"/>
                                                    </option>
                                                </c:forEach>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label">
                                            Quantity
                                        </label>
                                        <input type="number"
                                               name="quantity"
                                               class="form-control-custom"
                                               min="1"
                                               value="1"
                                               required>

                                    </div>

                                    <div class="form-group">
                                        <label class="form-label">
                                            Unit Price
                                        </label>
                                        <input type="number"
                                               name="unitPrice"
                                               class="form-control-custom"
                                               min="1"
                                               step="1"
                                               required>

                                    </div>

                                    <div class="form-group">
                                        <button type="button"
                                                class="btn subtle"
                                                onclick="removeItem(this)">
                                            Remove
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <button type="button"
                                    class="btn subtle"
                                    onclick="addItem()">
                                <i class="bi bi-plus-lg"></i>
                                Add product
                            </button>

                            <div class="form-actions">
                                <a class="btn subtle"
                                   href="${pageContext.request.contextPath}/manager/import-orders">
                                    Cancel
                                </a>
                                <button type="submit"
                                        class="btn primary-action">
                                    Create Import Order
                                </button>
                            </div>
                        </section>
                    </div>
                </form>
            </c:if>

            <!-- =================================================
                 DETAIL MODE
                 ORDER INFORMATION
                 ================================================= -->
            <c:if test="${mode == 'detail'}">
                <div class="detail-grid">
                    <section class="detail-card">
                        <h2>
                            Order Information
                        </h2>
                        <p class="detail-card-subtitle">
                            Basic information about this import order.
                        </p>

                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">
                                    Order ID
                                </span>
                                <span class="info-value">
                                    #${order.id}
                                </span>

                            </div>

                            <div class="info-item">
                                <span class="info-label">
                                    Status
                                </span>
                                <span class="info-value">
                                    <c:choose>
                                        <c:when test="${order.status == 'COMPLETE'}">
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
                                <span class="info-label">
                                    Supplier
                                </span>
                                <span class="info-value">

                                    <c:out
                                        value="${order.supplierName}"/>
                                </span>
                            </div>

                            <div class="info-item">
                                <span class="info-label">
                                    Created By
                                </span>
                                <span class="info-value">
                                    <c:out
                                        value="${order.userName}"/>
                                </span>
                            </div>

                            <div class="info-item">
                                <span class="info-label">
                                    Created At
                                </span>
                                <span class="info-value">
                                    <fmt:formatDate
                                        value="${order.createdAt}"
                                        pattern="dd/MM/yyyy HH:mm:ss"/>
                                </span>
                            </div>

                            <div class="info-item">

                                <span class="info-label">
                                    Last Updated
                                </span>

                                <span class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty order.updatedAt}">
                                            <fmt:formatDate
                                                value="${order.updatedAt}"
                                                pattern="dd/MM/yyyy HH:mm:ss"/>
                                        </c:when>
                                        <c:otherwise>
                                            -
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="info-item">
                                <span class="info-label">
                                    Payment Method
                                </span>
                                <span class="info-value">
                                    <c:out
                                        value="${order.method}"/>
                                </span>
                            </div>

                            <div class="info-item">
                                <span class="info-label">
                                    Total
                                </span>
                                <span class="info-value">
                                    <fmt:formatNumber
                                        value="${order.totalPrice}"
                                        type="number"
                                        groupingUsed="true"
                                        maxFractionDigits="0"/>

                                    ₫
                                </span>
                            </div>
                        </div>

                        <c:if test="${not empty order.note}">
                            <div style="margin-top: 20px;">
                                <span class="info-label">
                                    Note
                                </span>
                                <div style="margin-top: 6px;">
                                    <c:out
                                        value="${order.note}"/>
                                </div>
                            </div>
                        </c:if>
                    </section>

                    <!-- STATUS ACTION -->
                    <section class="detail-card">
                        <h2>
                            Order Status
                        </h2>
                        <p class="detail-card-subtitle">
                            Available action for this order.
                        </p>

                        <c:choose>
                            <c:when test="${order.status == 'ORDER'}">
                                <p>
                                    This order has been created but the
                                    imported products have not been added
                                    to inventory yet.
                                </p>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/manager/import-orders"
                                      class="complete-form">
                                    <input type="hidden"
                                           name="action"
                                           value="complete">
                                    <input type="hidden"
                                           name="id"
                                           value="${order.id}">
                                    <button type="submit"
                                            class="btn primary-action"
                                            onclick="return confirm('Complete this import order? Inventory will be increased.');">
                                        <i class="bi bi-check-circle"></i>
                                        Complete Import Order
                                    </button>
                                </form>
                            </c:when>

                            <c:otherwise>
                                <div class="alert alert-success">
                                    <i class="bi bi-check-circle"></i>
                                    This import order has been completed.
                                    Inventory has been updated.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </section>

                    <!-- PRODUCTS -->
                    <section class="detail-card full">
                        <h2>
                            Imported Products
                        </h2>
                        <p class="detail-card-subtitle">
                            Products included in this import order.
                        </p>

                        <div class="item-table-wrapper">
                            <table class="item-table">
                                <thead>
                                    <tr>
                                        <th>
                                            Product
                                        </th>
                                        <th>
                                            Variant
                                        </th>
                                        <th>
                                            Quantity
                                        </th>
                                        <th>
                                            Unit Price
                                        </th>
                                        <th>
                                            Total
                                        </th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:forEach var="item"
                                               items="${order.items}">
                                        <tr>
                                            <td>
                                                <c:if test="${not empty item.productImage}">
                                                    <img class="item-image"
                                                         src="${pageContext.request.contextPath}/${item.productImage}"
                                                         alt="Product">

                                                </c:if>
                                                <div class="product-name">
                                                    <c:out
                                                        value="${item.productName}"/>
                                                </div>
                                            </td>

                                            <td>
                                                <div class="variant-info">
                                                    <c:out
                                                        value="${item.memoryLabel}"/>
                                                </div>

                                                <div class="variant-info">
                                                    <c:out
                                                        value="${item.colorName}"/>
                                                </div>
                                            </td>

                                            <td>
                                                ${item.amount}
                                            </td>

                                            <td>
                                                <fmt:formatNumber
                                                    value="${item.unitPrice}"
                                                    type="number"
                                                    groupingUsed="true"
                                                    maxFractionDigits="0"/>

                                                ₫
                                            </td>

                                            <td>
                                                <fmt:formatNumber
                                                    value="${item.total}"
                                                    type="number"
                                                    groupingUsed="true"
                                                    maxFractionDigits="0"/>

                                                ₫
                                            </td>
                                        </tr>
                                    </c:forEach>

                                    <tr class="total-row">
                                        <td colspan="4"
                                            style="text-align: right;">

                                            Total
                                        </td>

                                        <td>
                                            <fmt:formatNumber
                                                value="${order.totalPrice}"
                                                type="number"
                                                groupingUsed="true"
                                                maxFractionDigits="0"/>

                                            ₫
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>
            </c:if>
        </main>
        <%@ include file="/views/common/footer.jsp" %>

        <c:if test="${mode == 'create'}">
            <script>
                function addItem() {
                    const container =
                            document.getElementById(
                                    'itemsContainer'
                                    );
                    const firstRow =
                            container.querySelector(
                                    '.import-item-row'
                                    );
                    const newRow =
                            firstRow.cloneNode(true);
                    newRow
                            .querySelectorAll('input')
                            .forEach(function (input) {
                                if (input.name === 'quantity') {
                                    input.value = '1';
                                } else {
                                    input.value = '';
                                }
                            });
                    newRow
                            .querySelector('select')
                            .selectedIndex = 0;
                    container.appendChild(newRow);
                }

                function removeItem(button) {
                    const container =
                            document.getElementById(
                                    'itemsContainer'
                                    );
                    const rows =
                            container.querySelectorAll(
                                    '.import-item-row'
                                    );
                    if (rows.length <= 1) {
                        alert(
                                'An import order must contain at least one product.'
                                );

                        return;
                    }
                    button
                            .closest('.import-item-row')
                            .remove();
                }
            </script>
        </c:if>
    </body>
</html>
