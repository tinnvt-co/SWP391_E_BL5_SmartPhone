<%--
    Document   : supplier-detail
    Created on : Aug 19, 2026
    Author     : KhanhVNHE191788
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
            ${supplier.id == 0 ? 'Create Supplier' : 'Supplier - '}${supplier.id != 0 ? supplier.name : ''}
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

            /* =========================
               FORM
               ========================= */

            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            .form-group.full {
                grid-column: 1 / -1;
            }

            .form-label {
                display: block;
                margin-bottom: 7px;
                font-size: 13px;
                font-weight: 700;
                color: #343a40;
            }

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

            .required {
                color: #dc2626;
            }

            /* =========================
               SUMMARY
               ========================= */

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

            /* =========================
               PRODUCT FILTER
               ========================= */

            .product-section {
                margin-top: 20px;
            }

            .product-filter {
                display: grid;
                grid-template-columns: 2fr 1fr 1fr auto;
                gap: 12px;
                margin-bottom: 20px;
                padding: 16px;
                background: #f8f9fb;
                border-radius: 14px;
            }
            .variant-flat-list {
                display: flex;
                flex-direction: column;
                gap: 10px;
            }
            .filter-input,
            .filter-select {
                width: 100%;
                border: 1px solid #dfe3e8;
                border-radius: 10px;
                padding: 10px 12px;
                background: #fff;
                font-size: 14px;
            }

            .supplied-filter {
                display: flex;
                align-items: center;
                gap: 8px;
                white-space: nowrap;
                font-size: 14px;
                font-weight: 600;
            }

            /* =========================
               PRODUCT CARD
               ========================= */

            .product-list {
                display: flex;
                flex-direction: column;
                gap: 14px;
            }

            .product-card {
                border: 1px solid #e7e9ee;
                border-radius: 14px;
                padding: 18px;
                background: #fff;
            }

            .product-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 14px;
            }

            .product-name {
                font-size: 16px;
                font-weight: 750;
                color: #20242b;
            }

            .product-brand {
                color: #858c96;
                font-size: 13px;
                margin-top: 3px;
            }

            .variant-list {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
            }

            .variant-row {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 12px;
                border: 1px solid #e7e9ee;
                border-radius: 10px;
                cursor: pointer;
                transition: .15s;
            }

            .variant-row:hover {
                background: #f8fafc;
            }

            .variant-row.selected {
                background: #f8fafc;
                border-color: #94a3b8;
            }

            .variant-checkbox {
                width: 17px;
                height: 17px;
                cursor: pointer;
            }

            .variant-info {
                display: flex;
                flex-direction: column;
                gap: 3px;
                min-width: 0;
            }

            .variant-name {
                font-size: 13px;
                font-weight: 650;
            }

            .variant-sku {
                font-size: 12px;
                color: #858c96;
                font-family: monospace;
            }

            .variant-stock {
                margin-left: auto;
                font-size: 12px;
                color: #64748b;
            }

            /* =========================
               PAGINATION
               ========================= */

            .pagination-wrapper {
                display: flex;
                justify-content: center;
                margin-top: 24px;
            }

            .pagination {
                display: flex;
                gap: 6px;
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .pagination a,
            .pagination button.page-btn-nav {
                min-width: 36px;
                height: 36px;
                display: flex;
                align-items: center;
                justify-content: center;
                border: 1px solid #e1e5ea;
                border-radius: 9px;
                text-decoration: none;
                color: #475569;
                background: #fff;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
            }

            .pagination a:hover,
            .pagination button.page-btn-nav:hover{
                background: #f8fafc;
            }

            .pagination .active a {
                background: #20242b;
                color: #fff;
                border-color: #20242b;
            }

            .pagination .disabled a {
                opacity: .45;
                pointer-events: none;
            }
            .pagination li.active button.page-btn-nav {
                background: #20242b;
                color: #fff;
                border-color: #20242b;
            }

            .pagination li.disabled button.page-btn-nav {
                opacity: .45;
                pointer-events: none;
            }

            .pagination li.page-dots {
                display: flex;
                align-items: center;
                justify-content: center;
                min-width: 25px;
                color: #8b929c;
            }

            /* FIX: ô nhảy nhanh tới trang */
            .pagination-wrapper {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 16px;
                margin-top: 24px;
                flex-wrap: wrap;
            }

            .page-jump {
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .page-jump input {
                width: 70px;
                height: 36px;
                border: 1px solid #dfe3e8;
                border-radius: 9px;
                padding: 0 10px;
                font-size: 13px;
            }

            /* =========================
               ACTIONS
               ========================= */

            .detail-actions {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
                margin-top: 24px;
            }

            .empty-products {
                padding: 30px;
                text-align: center;
                color: #7b828c;
                background: #f8f9fb;
                border-radius: 12px;
            }

            /* =========================
               FORM ERRORS
               ========================= */

            .form-errors {
                display: flex;
                gap: 12px;
                align-items: flex-start;
                background: #fef2f2;
                border: 1px solid #fecaca;
                border-radius: 14px;
                padding: 16px 18px;
                margin-bottom: 20px;
                color: #991b1b;
            }

            .form-errors i {
                font-size: 18px;
                margin-top: 2px;
            }

            .form-errors-title {
                font-weight: 700;
                margin: 0 0 6px;
                font-size: 14px;
            }

            .form-errors ul {
                margin: 0;
                padding-left: 18px;
                font-size: 13.5px;
            }

            .form-errors li {
                margin-bottom: 2px;
            }

            @media (max-width: 850px) {

                .supplier-detail-grid {
                    grid-template-columns: 1fr;
                }

                .form-grid {
                    grid-template-columns: 1fr;
                }

                .form-group.full {
                    grid-column: auto;
                }

                .product-filter {
                    grid-template-columns: 1fr;
                }

                .variant-list {
                    grid-template-columns: 1fr;
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
                    <h1>
                        ${supplier.id == 0 ? 'Create Supplier' : 'Edit Supplier'}
                    </h1>
                    <p>
                        ${supplier.id == 0
                          ? 'Create a new supplier and assign supplied product variants.'
                          : 'Update supplier information and supplied product variants.'}
                    </p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle"
                       href="${pageContext.request.contextPath}/manager/supplier">
                        ← Back to suppliers
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

            <c:if test="${not empty requestScope.msgErr}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <c:out value="${requestScope.msgErr}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${not empty sessionScope.msgOk}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <c:out value="${sessionScope.msgOk}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="msgOk" scope="session"/>
            </c:if>
            <!-- ============================================= -->
            <!-- SUPPLIER FORM + SUMMARY -->
            <!-- ============================================= -->
            <form id="supplierForm"
                  method="post"
                  action="${pageContext.request.contextPath}/manager/supplier">
                <input type="hidden"
                       name="action"
                       value="save">
                <input type="hidden"
                       name="id"
                       value="${supplier.id}">

                <!--
                    JS sẽ tự động đưa toàn bộ ProductVariantID
                    đã chọn vào đây.
                -->
                <input type="hidden"
                       id="productVariantIds"
                       name="productVariantIds"
                       value="">

                <!-- ============================================= -->
                <!-- VALIDATION ERRORS -->
                <!-- ============================================= -->
                <c:if test="${not empty errors}">
                    <div class="form-errors">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <div>
                            <p class="form-errors-title">
                                Please fix the following
                                ${fn:length(errors)} error(s):
                            </p>
                            <ul>
                                <c:forEach var="err" items="${errors}">
                                    <li>
                                        <c:out value="${err}"/>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>
                    </div>
                </c:if>

                <div class="supplier-detail-grid">

                    <!-- ========================================= -->
                    <!-- SUPPLIER INFORMATION -->
                    <!-- ========================================= -->
                    <section class="supplier-card">
                        <h2>
                            Supplier Information
                        </h2>
                        <p class="supplier-card-subtitle">
                            Basic information about this supplier.
                        </p>

                        <div class="form-grid">
                            <!-- NAME -->
                            <div class="form-group">
                                <label class="form-label">
                                    Supplier Name
                                    <span class="required">*</span>
                                </label>
                                <input type="text"
                                       name="name"
                                       class="form-control-custom"
                                       maxlength="50"
                                       required
                                       value="<c:out value='${supplier.name}'/>">
                            </div>


                            <!-- PHONE -->
                            <div class="form-group">
                                <label class="form-label">
                                    Phone
                                    <span class="required">*</span>
                                </label>
                                <input type="text"
                                       name="phone"
                                       class="form-control-custom"
                                       maxlength="255"
                                       required
                                       value="<c:out value='${supplier.phone}'/>">
                            </div>


                            <!-- ADDRESS -->
                            <div class="form-group full">
                                <label class="form-label">
                                    Address
                                    <span class="required">*</span>
                                </label>
                                <input type="text"
                                       name="address"
                                       class="form-control-custom"
                                       maxlength="255"
                                       required
                                       value="<c:out value='${supplier.address}'/>">
                            </div>


                            <!-- DESCRIPTION -->
                            <div class="form-group full">
                                <label class="form-label">
                                    Description
                                </label>
                                <textarea
                                    name="description"
                                    maxlength="255"
                                    class="form-control-custom"><c:out value="${supplier.description}"/></textarea>
                            </div>

                            <!-- NOTE -->
                            <div class="form-group full">
                                <label class="form-label">
                                    Note
                                </label>
                                <textarea
                                    name="note"
                                    maxlength="255"
                                    class="form-control-custom"><c:out value="${supplier.note}"/></textarea>
                            </div>

                            <!-- STATUS -->
                            <div class="form-group">
                                <label class="form-label">
                                    Status
                                </label>
                                <select name="status"
                                        class="form-control-custom">
                                    <option value="ACTIVE"
                                            ${supplier.status == 'ACTIVE' ? 'selected' : ''}>
                                        Active
                                    </option>
                                    <option value="INACTIVE"
                                            ${supplier.status == 'INACTIVE' ? 'selected' : ''}>
                                        Inactive
                                    </option>
                                </select>
                            </div>
                        </div>
                    </section>

                    <!-- ========================================= -->
                    <!-- SUMMARY -->
                    <!-- ========================================= -->
                    <aside>
                        <section class="supplier-card">
                            <h2>
                                Supplier Summary
                            </h2>
                            <p class="supplier-card-subtitle">
                                Current supplier information.
                            </p>
                            <div class="stat-box">
                                <small>
                                    Supplier ID
                                </small>
                                <strong>
                                    ${supplier.id == 0 ? 'NEW' : supplier.id}
                                </strong>
                            </div>

                            <div class="stat-box">
                                <small>
                                    Selected Variants
                                </small>
                                <strong id="selectedVariantCount">
                                    0
                                </strong>
                            </div>

                            <div class="stat-box">
                                <small>
                                    Database Variants
                                </small>
                                <strong>
                                    ${supplier.productVariantCount}
                                </strong>
                            </div>

                            <div class="detail-actions">
                                <button type="submit"
                                        class="btn primary">
                                    <i class="bi bi-check-lg"></i>
                                    ${supplier.id == 0
                                      ? 'Create Supplier'
                                      : 'Save Changes'}
                                </button>

                                <a class="btn subtle"
                                   href="${pageContext.request.contextPath}/manager/supplier">
                                    Cancel
                                </a>
                            </div>
                        </section>
                    </aside>
                </div>

                <!-- ============================================= -->
                <!-- PRODUCT VARIANTS -->
                <!-- ============================================= -->

                <section class="supplier-card product-section">
                    <h2>
                        Supplied Product Variants
                    </h2>
                    <p class="supplier-card-subtitle">
                        Select the product variants that this supplier can provide.
                    </p>

                    <!-- ========================================= -->
                    <!-- FILTER -->
                    <!-- ========================================= -->
                    <div class="product-filter">
                        <!-- KEYWORD -->
                        <input type="text"
                               id="keyword"
                               class="filter-input"
                               placeholder="Search product..."
                               value="<c:out value='${productKeyword}'/>">

                        <!-- BRAND -->
                        <select id="brand"
                                class="filter-select">
                            <option value="">
                                All Brands
                            </option>
                            <c:forEach var="brand" items="${brands}">
                                <option value="${brand.id}"
                                        ${selectedBrand == brand.id ? 'selected' : ''}>
                                    <c:out value="${brand.name}"/>
                                </option>
                            </c:forEach>
                        </select>

                        <!--Product-->
                        <select id="product"
                                class="filter-select">
                            <option value="">
                                All Products
                            </option>
                            <c:forEach var="p" items="${productOptions}">
                                <option value="${p.id}"
                                        ${selectedProduct == p.id ? 'selected' : ''}>
                                    <c:out value="${p.name}"/>
                                </option>
                            </c:forEach>
                        </select>

                        <!-- SUPPLIED -->

                        <label class="supplied-filter">
                            <input type="checkbox"
                                   id="suppliedOnly"
                                   ${suppliedFilter == 'supplied' ? 'checked' : ''}>
                            Supplied only
                        </label>
                    </div>


                    <!-- ========================================= -->
                    <!-- PRODUCT VARIANT LIST (FLAT) -->
                    <!-- ========================================= -->

                    <!-- FIX: bỏ group theo product-card, hiển thị thẳng danh sách
                         ProductVariant (mỗi dòng tự mang tên product/brand) để trang ngắn
                         lại và số dòng mỗi trang cố định theo PAGE_SIZE. -->
                    <c:choose>
                        <c:when test="${empty variantRows}">
                            <div class="empty-products">
                                <i class="bi bi-box-seam"></i>
                                No product variants found.
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="variant-flat-list">
                                <c:forEach var="row" items="${variantRows}">
                                    <label class="variant-row"
                                           data-variant-id="${row.variantId}">
                                        <input
                                            type="checkbox"
                                            class="variant-checkbox"
                                            value="${row.variantId}"
                                            ${row.supplied ? 'checked' : ''}>
                                        <div class="variant-info">
                                            <span class="variant-name">
                                                <c:out value="${row.productName}"/> —
                                                ${row.ramGb}GB - ${row.storageGb}GB -
                                                <c:out value="${row.colorName}"/>
                                            </span>
                                            <span class="variant-sku">
                                                <c:out value="${row.brandName}"/> · SKU:
                                                <c:out value="${row.sku}"/>
                                            </span>
                                        </div>
                                        <span class="variant-stock">
                                            Stock: ${row.stock}
                                        </span>
                                    </label>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <!-- ========================================= -->
                    <!-- PAGINATION -->
                    <!-- ========================================= -->
                    <!-- FIX: đổi từ hiển thị đủ tất cả số trang sang kiểu rút gọn
                         "1 ... 4 5 6 ... 20" (tính sẵn ở server trong pageItems), dùng
                         <button data-page> thay vì <a href> để 1 hàm JS dùng chung xử lý
                         điều hướng (đọc đúng toàn bộ filter hiện tại kể cả dropdown Product
                         mới, tránh phải lặp lại query string thủ công ở từng link). Thêm ô
                         nhảy nhanh tới trang. -->
                    <c:if test="${variantTotalPages > 1}">
                        <div class="pagination-wrapper">
                            <div class="pagination-info">
                                Showing
                                <strong>${startItem}</strong>
                                -
                                <strong>${endItem}</strong>
                                of
                                <strong>${totalVariants}</strong>
                                variants
                            </div>

                            <ul class="pagination">
                                <!-- PREVIOUS -->
                                <li class="${variantCurrentPage == 1 ? 'disabled' : ''}">
                                    <button type="button"
                                            class="page-btn-nav"
                                            data-page="${variantCurrentPage - 1}">
                                        ←
                                    </button>
                                </li>

                                <!-- PAGE NUMBERS (rút gọn) -->
                                <c:forEach var="item" items="${pageItems}">
                                    <c:choose>
                                        <c:when test="${item == '...'}">
                                            <li class="page-dots">
                                                …
                                            </li>
                                        </c:when>
                                        <c:otherwise>
                                            <li class="${item == variantCurrentPage ? 'active' : ''}">
                                                <button type="button"
                                                        class="page-btn-nav"
                                                        data-page="${item}">
                                                    ${item}
                                                </button>
                                            </li>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>

                                <!-- NEXT -->
                                <li class="${variantCurrentPage == variantTotalPages ? 'disabled' : ''}">
                                    <button type="button"
                                            class="page-btn-nav"
                                            data-page="${variantCurrentPage + 1}">
                                        →
                                    </button>
                                </li>
                            </ul>

                            <!-- FIX: ô điền số để nhảy nhanh tới trang -->
                            <div class="page-jump">
                                <input type="number"
                                       id="jumpPageInput"
                                       min="1"
                                       max="${variantTotalPages}"
                                       placeholder="Page #">
                                <button type="button"
                                        id="jumpPageBtn"
                                        class="btn subtle">
                                    Go
                                </button>
                            </div>
                        </div>
                    </c:if>
                </section>
            </form>
        </main>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>

            /*
             * =========================================================
             * SUPPLIER PRODUCT VARIANT SELECTION
             * =========================================================
             *
             * Mỗi checkbox đại diện cho:
             *
             *      ProductVariantID
             *
             * Không phải ProductID.
             *
             * Ví dụ:
             *
             * iPhone 15
             *   ├── 128GB Black  -> ProductVariantID = 10
             *   ├── 128GB Blue   -> ProductVariantID = 11
             *   └── 256GB Black  -> ProductVariantID = 12
             *
             * Supplier có thể cung cấp:
             *
             *      10, 12
             *
             * Database:
             *
             * Supplier_ProductVariant
             *      SupplierID | ProductVariantID
             *      ----------------------------
             *          5      |      10
             *          5      |      12
             *
             */
            const supplierId = '${supplier.id}';
            const storageKey =
                    'supplier-selected-variants-' + supplierId;
            
            //Xóa session khi tạo xong
            if (supplierId !== '0') {
                sessionStorage.removeItem('supplier-selected-variants-0');
            }

            const initialSuppliedVariantIds = [
            <c:forEach var="vid" items="${supplier.productVariantIds}" varStatus="st">
            '${vid}'<c:if test="${!st.last}">,</c:if>
            </c:forEach>
            ];

            /*
             * Set chứa toàn bộ ProductVariantID
             * mà user đã chọn.
             */
            let selectedVariants = new Set();

            /*
             * =========================================================
             * LOAD SELECTED VARIANTS
             * =========================================================
             */
            function loadSelectedVariants() {
                const saved = sessionStorage.getItem(storageKey);

                if (saved) {
                    /*
                     * Đã có phiên làm việc trước đó (user đang tick/untick dở dang
                     * qua nhiều trang) -> dùng lại đúng những gì user đã chọn.
                     */
                    try {
                        const ids = JSON.parse(saved);
                        if (Array.isArray(ids)) {
                            selectedVariants = new Set(ids.map(String));
                        } else {
                            selectedVariants = new Set(initialSuppliedVariantIds);
                        }
                    } catch (error) {
                        console.error('Cannot restore selected variants', error);
                        selectedVariants = new Set(initialSuppliedVariantIds);
                    }
                } else {
                    /*
                     * FIX: Lần đầu vào trang (chưa có sessionStorage) -> PHẢI khởi
                     * tạo bằng TOÀN BỘ variant đã supplied thật trong DATABASE
                     * (initialSuppliedVariantIds), không phải chỉ những checkbox
                     * đang :checked trên trang/filter hiện tại. Nếu chỉ đọc DOM,
                     * mỗi lần đổi trang sẽ làm mất/nhầm dữ liệu supplied ở các
                     * trang chưa từng xem, và khi Save sẽ xóa nhầm chúng khỏi DB.
                     */
                    selectedVariants = new Set(initialSuppliedVariantIds);
                }

                restoreCheckboxes();
                updateSelectedCount();
                saveSelectedVariants();
            }

            /*
             * =========================================================
             * SAVE TO SESSION STORAGE
             * =========================================================
             */

            function saveSelectedVariants() {
                sessionStorage.setItem(
                        storageKey,
                        JSON.stringify(
                                Array.from(selectedVariants)
                                )
                        );
            }

            /*
             * =========================================================
             * RESTORE CHECKBOX
             * =========================================================
             */

            function restoreCheckboxes() {
                document
                        .querySelectorAll('.variant-checkbox')
                        .forEach(function (checkbox) {
                            checkbox.checked =
                                    selectedVariants.has(
                                            checkbox.value
                                            );
                            updateVariantRow(
                                    checkbox
                                    );
                        });
            }

            /*
             * =========================================================
             * CHECKBOX CHANGE
             * =========================================================
             */
            function handleVariantChange(checkbox) {
                const variantId =
                        checkbox.value;
                if (checkbox.checked) {
                    selectedVariants.add(
                            variantId
                            );
                } else {
                    selectedVariants.delete(
                            variantId
                            );
                }
                saveSelectedVariants();

                updateVariantRow(
                        checkbox
                        );
                updateSelectedCount();
            }


            /*
             * =========================================================
             * VISUAL STATE
             * =========================================================
             */

            function updateVariantRow(checkbox) {
                const row =
                        checkbox.closest('.variant-row');
                if (!row) {
                    return;
                }
                if (checkbox.checked) {
                    row.classList.add(
                            'selected'
                            );
                } else {
                    row.classList.remove(
                            'selected'
                            );
                }
            }

            /*
             * =========================================================
             * SELECTED COUNT
             * =========================================================
             */

            function updateSelectedCount() {
                const counter =
                        document.getElementById(
                                'selectedVariantCount'
                                );
                if (counter) {
                    counter.textContent =
                            selectedVariants.size;

                }

            }

            /*
             * =========================================================
             * BEFORE SUBMIT
             * =========================================================
             *
             * Gom toàn bộ ProductVariantID thành:
             *
             *      10,11,15,20
             *
             * rồi gửi lên Controller.
             */

            document
                    .getElementById('supplierForm')
                    .addEventListener(
                            'submit',
                            function () {
                                document
                                        .getElementById(
                                                'productVariantIds'
                                                )
                                        .value =
                                        Array
                                        .from(selectedVariants)
                                        .join(',');
                                /*
                                 * Save một lần nữa trước khi submit.
                                 */
                                saveSelectedVariants();
                            }
                    );

            /*
             * =========================================================
             * SEARCH / FILTER
             * =========================================================
             */
            function buildFilterUrl(page) {

                const keyword =
                        document.getElementById('keyword').value.trim();

                const brand =
                        document.getElementById('brand').value;

                const product =
                        document.getElementById('product').value;

                const suppliedOnly =
                        document.getElementById('suppliedOnly').checked;

                const url =
                        new URL(
                                '${pageContext.request.contextPath}/manager/supplier',
                                window.location.origin
                                );

                url.searchParams.set('action', 'detail');
                url.searchParams.set('id', supplierId);
                url.searchParams.set('page', String(page));

                if (keyword) {
                    url.searchParams.set('keyword', keyword);
                }
                if (brand) {
                    url.searchParams.set('brand', brand);
                }
                if (product) {
                    url.searchParams.set('product', product);
                }
                if (suppliedOnly) {
                    url.searchParams.set('supplied', 'supplied');
                }

                return url.toString();
            }

            function goToPage(page) {
                saveSelectedVariants();
                window.location.href = buildFilterUrl(page);
            }

            function applyFilter() {
                goToPage(1);
            }

            /* SEARCH ENTER */
            document
                    .getElementById('keyword')
                    .addEventListener('keydown', function (event) {
                        if (event.key === 'Enter') {
                            event.preventDefault();
                            applyFilter();
                        }
                    });

            /* BRAND CHANGE */
            document
                    .getElementById('brand')
                    .addEventListener('change', applyFilter);

            /* FIX: PRODUCT DROPDOWN CHANGE (mới) */
            document
                    .getElementById('product')
                    .addEventListener('change', applyFilter);

            /* SUPPLIED ONLY CHANGE */
            document
                    .getElementById('suppliedOnly')
                    .addEventListener('change', applyFilter);

            /* FIX: nút số trang / ← / → giờ là <button data-page>, không phải <a> */
            document
                    .querySelectorAll('.page-btn-nav')
                    .forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            const page = parseInt(this.dataset.page, 10);
                            if (!isNaN(page) && page >= 1) {
                                goToPage(page);
                            }
                        });
                    });

            /* FIX: ô nhảy nhanh tới trang */
            const jumpBtn = document.getElementById('jumpPageBtn');
            if (jumpBtn) {
                jumpBtn.addEventListener('click', function () {
                    const totalPages = ${variantTotalPages};
                    const input = document.getElementById('jumpPageInput');
                    let page = parseInt(input.value, 10);
                    if (isNaN(page) || page < 1) {
                        page = 1;
                    }
                    if (page > totalPages) {
                        page = totalPages;
                    }
                    goToPage(page);
                });
                document.getElementById('jumpPageInput')
                        .addEventListener('keydown', function (event) {
                            if (event.key === 'Enter') {
                                event.preventDefault();
                                jumpBtn.click();
                            }
                        });
            }
            /*
             * =========================================================
             * PAGINATION
             * =========================================================
             *
             * Không xóa selection khi chuyển page.
             */
            document.querySelectorAll('[data-page-link]')
                    .forEach(function (link) {
                        link.addEventListener(
                                'click',
                                function () {
                                    saveSelectedVariants();
                                }
                        );
                    });
            /*
             * =========================================================
             * INITIALIZE
             * =========================================================
             */
            document.querySelectorAll('.variant-checkbox')
                    .forEach(function (checkbox) {
                        checkbox.addEventListener(
                                'change',
                                function () {
                                    handleVariantChange(
                                            checkbox
                                            );
                                }
                        );
                    });

            loadSelectedVariants();
        </script>
    </body>
</html>
