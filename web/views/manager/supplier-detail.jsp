<%--
    Document   : supplier-detail
    Created on : Aug 19, 2026
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

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
                grid-template-columns: 2fr 1fr auto;
                gap: 12px;
                margin-bottom: 20px;
                padding: 16px;
                background: #f8f9fb;
                border-radius: 14px;
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

            .pagination a {
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
            }

            .pagination a:hover {
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
                               value="<c:out value='${keyword}'/>">

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

                        <!-- SUPPLIED -->

                        <label class="supplied-filter">
                            <input type="checkbox"
                                   id="suppliedOnly"
                                   ${suppliedOnly ? 'checked' : ''}>
                            Supplied only
                        </label>
                    </div>


                    <!-- ========================================= -->
                    <!-- PRODUCT LIST -->
                    <!-- ========================================= -->

                    <c:choose>
                        <c:when test="${empty products}">
                            <div class="empty-products">
                                <i class="bi bi-box-seam"></i>
                                No products found.
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="product-list">
                                <c:forEach var="product"
                                           items="${products}">
                                    <div class="product-card">
                                        <!-- PRODUCT HEADER -->
                                        <div class="product-header">
                                            <div>
                                                <div class="product-name">
                                                    <c:out value="${product.name}"/>
                                                </div>
                                                <div class="product-brand">
                                                    <c:out value="${product.brandName}"/>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- VARIANTS -->
                                        <div class="variant-list">
                                            <c:forEach var="variant"
                                                       items="${product.variants}">
                                                <label class="variant-row"
                                                       data-variant-id="${variant.id}">
                                                    <input
                                                        type="checkbox"
                                                        class="variant-checkbox"
                                                        value="${variant.id}"
                                                        ${suppliedVariantIds.contains(variant.id)
                                                          ? 'checked'
                                                          : ''}>
                                                    <div class="variant-info">
                                                        <span class="variant-name">
                                                            ${variant.ramGb}GB -
                                                            ${variant.storageGb}GB -
                                                            <c:out value="${variant.colorName}"/>
                                                        </span>
                                                        <span class="variant-sku">
                                                            SKU:
                                                            <c:out value="${variant.sku}"/>
                                                        </span>
                                                    </div>
                                                    <span class="variant-stock">
                                                        Stock:
                                                        ${variant.stock}
                                                    </span>
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <!-- ========================================= -->
                    <!-- PAGINATION -->
                    <!-- ========================================= -->
                    <c:if test="${totalPages > 1}">
                        <div class="pagination-wrapper">
                            <ul class="pagination">
                                <!-- PREVIOUS -->
                                <li class="${currentPage == 1 ? 'disabled' : ''}">
                                    <a href="${pageContext.request.contextPath}/manager/supplier?action=edit&id=${supplier.id}&page=${currentPage - 1}&keyword=${keyword}&brand=${selectedBrand}&suppliedOnly=${suppliedOnly}"
                                       data-page-link>
                                        ←
                                    </a>
                                </li>
                                <!-- PAGE NUMBERS -->
                                <c:forEach begin="1"
                                           end="${totalPages}"
                                           var="page">
                                    <li class="${page == currentPage ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/manager/supplier?action=edit&id=${supplier.id}&page=${page}&keyword=${keyword}&brand=${selectedBrand}&suppliedOnly=${suppliedOnly}"
                                           data-page-link>
                                            ${page}
                                        </a>
                                    </li>
                                </c:forEach>
                                <!-- NEXT -->
                                <li class="${currentPage == totalPages ? 'disabled' : ''}">
                                    <a href="${pageContext.request.contextPath}/manager/supplier?action=edit&id=${supplier.id}&page=${currentPage + 1}&keyword=${keyword}&brand=${selectedBrand}&suppliedOnly=${suppliedOnly}"
                                       data-page-link>
                                        →
                                    </a>
                                </li>
                            </ul>
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
                /*
                 * Nếu browser đã lưu selection
                 * thì lấy lại.
                 */
                const saved =
                        sessionStorage.getItem(storageKey);
                if (saved) {
                    try {
                        const ids = JSON.parse(saved);
                        if (Array.isArray(ids)) {
                            selectedVariants =
                                    new Set(ids.map(String));
                        }
                    } catch (error) {
                        console.error(
                                'Cannot restore selected variants',
                                error
                                );
                    }
                } else {

                    /*
                     * Lần đầu mở trang:
                     * lấy những variant đã có trong database.
                     */
                    document
                            .querySelectorAll('.variant-checkbox:checked')
                            .forEach(function (checkbox) {
                                selectedVariants.add(
                                        checkbox.value
                                        );
                            });
                }
                restoreCheckboxes();
                updateSelectedCount();
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
            function applyFilter() {
                const keyword =
                        document
                        .getElementById('keyword')
                        .value
                        .trim();

                const brand =
                        document
                        .getElementById('brand')
                        .value;

                const suppliedOnly =
                        document
                        .getElementById('suppliedOnly')
                        .checked;

                const url =
                        new URL(
                                '${pageContext.request.contextPath}/manager/supplier',
                                window.location.origin
                                );

                url.searchParams.set(
                        'action',
                        'edit'
                        );

                url.searchParams.set(
                        'id',
                        supplierId
                        );

                url.searchParams.set(
                        'page',
                        '1'
                        );

                if (keyword) {
                    url.searchParams.set(
                            'keyword',
                            keyword
                            );
                }


                if (brand) {
                    url.searchParams.set(
                            'brand',
                            brand
                            );
                }


                if (suppliedOnly) {
                    url.searchParams.set(
                            'suppliedOnly',
                            'true'
                            );
                }

                /*
                 * Selection vẫn nằm trong sessionStorage,
                 * nên reload/filter không mất checkbox.
                 */
                saveSelectedVariants();
                window.location.href =
                        url.toString();
            }


            /*
             * SEARCH ENTER
             */
            document
                    .getElementById('keyword')
                    .addEventListener(
                            'keydown',
                            function (event) {
                                if (event.key === 'Enter') {
                                    event.preventDefault();
                                    applyFilter();
                                }
                            }
                    );

            /*
             * BRAND CHANGE
             */
            document
                    .getElementById('brand')
                    .addEventListener(
                            'change',
                            applyFilter
                            );

            /*
             * SUPPLIED ONLY CHANGE
             */
            document
                    .getElementById('suppliedOnly')
                    .addEventListener(
                            'change',
                            applyFilter
                            );

            /*
             * =========================================================
             * PAGINATION
             * =========================================================
             *
             * Không xóa selection khi chuyển page.
             */
            document
                    .querySelectorAll('[data-page-link]')
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
            document
                    .querySelectorAll('.variant-checkbox')
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