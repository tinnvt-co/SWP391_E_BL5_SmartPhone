<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cart | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body {
                background:#f6f8fb;
                color:#111827;
            }
            .cart-shell {
                padding: 42px 0 70px;
            }
            .cart-panel {
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                overflow:hidden;
            }
            .cart-header {
                padding:24px;
                border-bottom:1px solid #eef2f7;
                display:flex;
                justify-content:space-between;
                gap:16px;
                flex-wrap:wrap;
            }
            .cart-header h1 {
                margin:0;
                font-weight:900;
            }
            .cart-select-row {
                padding:16px 24px;
                border-bottom:1px solid #eef2f7;
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:16px;
                flex-wrap:wrap;
            }
            .cart-check-label {
                display:inline-flex;
                align-items:center;
                gap:10px;
                color:#334155;
                font-weight:800;
                cursor:pointer;
            }
            .cart-check {
                width:20px;
                height:20px;
                accent-color:#16a34a;
                cursor:pointer;
            }
            .cart-item {
                display:grid;
                grid-template-columns:24px 88px minmax(0,1fr) auto;
                gap:18px;
                padding:20px 24px;
                border-bottom:1px solid #eef2f7;
                align-items:center;
            }
            .cart-item img {
                width:88px;
                height:88px;
                object-fit:cover;
                border-radius:8px;
                background:#f1f5f9;
            }
            .cart-item h3 {
                margin:0 0 4px;
                font-size:1rem;
                font-weight:900;
            }
            .cart-meta {
                color:#64748b;
                font-size:.9rem;
            }
            .cart-actions {
                display:flex;
                align-items:center;
                gap:10px;
                justify-content:flex-end;
                flex-wrap:wrap;
            }
            .cart-qty-wrap {
                display:inline-flex;
                align-items:center;
                border:1px solid #dbe3ec;
                border-radius:8px;
                overflow:hidden;
                background:#fff;
            }
            .cart-qty-btn {
                width:36px;
                height:38px;
                border:0;
                background:#f8fafc;
                color:#0f172a;
                font-weight:900;
            }
            .cart-qty-btn:hover {
                background:#eaf2ff;
                color:#1665d8;
            }
            .cart-qty {
                width:58px;
                min-height:38px;
                border:0;
                border-inline:1px solid #dbe3ec;
                padding:0 8px;
                text-align:center;
                outline:0;
            }
            .cart-price {
                min-width:130px;
                text-align:right;
                color:#b91c1c;
                font-weight:900;
            }
            .cart-price-discount {
                margin-top:6px;
                display:flex;
                align-items:center;
                gap:8px;
            }
            .cart-price-discount del {
                color:#8b97aa;
                font-weight:600;
                font-size:.92rem;
            }
            .cart-discount-pill {
                background:#fdecec;
                color:#d90000;
                border-radius:6px;
                padding:3px 8px;
                font-size:.82rem;
                font-weight:700;
            }
            .cart-summary {
                padding:22px 24px;
                display:flex;
                align-items:center;
                justify-content:flex-end;
                gap:22px;
                flex-wrap:wrap;
            }
            .cart-summary-info {
                margin-right:auto;
                color:#64748b;
                font-weight:700;
            }
            .cart-total {
                font-size:1.35rem;
                font-weight:900;
                color:#111827;
            }
            .cart-empty {
                padding:54px 24px;
                text-align:center;
                color:#64748b;
            }
            .primary-action {
                min-height:44px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                padding:0 18px;
                border:1px solid #16a34a;
                border-radius:8px;
                background:#16a34a;
                color:#fff;
                font-weight:800;
                text-decoration:none;
            }
            .primary-action:hover {
                background:#15803d;
                border-color:#15803d;
                color:#fff;
            }
            .primary-action:disabled {
                opacity:.48;
                cursor:not-allowed;
            }
            .secondary-action {
                min-height:44px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                padding:0 18px;
                border:1px solid #dbe3ec;
                border-radius:8px;
                background:#fff;
                color:#111827;
                font-weight:800;
                text-decoration:none;
            }
            .secondary-action:hover {
                color:#1665d8;
                border-color:#b9c9ef;
            }
            .checkout-inline {
                margin-top:0;
                background:#fff;
                border-top:1px solid #eef2f7;
                overflow:hidden;
            }
            .checkout-inline[hidden] {
                display:none;
            }
            .checkout-inline-header {
                display:none;
            }
            .checkout-inline-body {
                padding:24px;
            }
            .checkout-inline-footer {
                padding:18px 24px;
                border-top:1px solid #eef2f7;
                display:flex;
                justify-content:flex-end;
                gap:12px;
                flex-wrap:wrap;
            }
            .checkout-table-wrap {
                display:none;
            }
            .checkout-table {
                width:100%;
                min-width:760px;
                margin:0;
                border-collapse:collapse;
            }
            .checkout-table th {
                background:#eef1f5;
                color:#111827;
                font-size:.9rem;
                padding:12px;
                border-bottom:1px solid #d7dde6;
            }
            .checkout-table td {
                padding:12px;
                border-bottom:1px solid #eef2f7;
                vertical-align:middle;
            }
            .checkout-table tr:last-child td {
                border-bottom:0;
            }
            .checkout-thumb {
                width:58px;
                height:58px;
                object-fit:cover;
                border-radius:8px;
                background:#f1f5f9;
            }
            .checkout-product-name {
                font-weight:900;
                color:#111827;
            }
            .checkout-small {
                color:#64748b;
                font-size:.86rem;
            }
            .checkout-amount {
                color:#111827;
                font-weight:900;
                text-align:right;
                white-space:nowrap;
            }
            .checkout-delivery {
                margin-top:22px;
            }
            .checkout-delivery h3 {
                font-size:1.1rem;
                font-weight:900;
                margin:0 0 14px;
            }
            .checkout-summary-box {
                background:#f8fafc;
                border:1px solid #e5eaf0;
                border-radius:8px;
                padding:16px;
            }
            .checkout-summary-line {
                display:flex;
                justify-content:space-between;
                gap:16px;
                margin-bottom:8px;
                color:#475569;
            }
            .checkout-summary-line strong {
                color:#111827;
            }
            .checkout-summary-total {
                display:flex;
                justify-content:space-between;
                gap:16px;
                padding-top:10px;
                border-top:1px solid #dbe3ec;
                color:#111827;
                font-size:1.15rem;
                font-weight:900;
            }
            .checkout-payment-block {
                padding:0 24px 18px;
            }
            .payment-methods {
                margin-top:20px;
                display:grid;
                gap:10px;
            }
            .payment-option {
                display:flex;
                align-items:flex-start;
                gap:12px;
                padding:14px;
                border:1px solid #dbe3ec;
                border-radius:8px;
                background:#fff;
                cursor:pointer;
            }
            .payment-option.is-selected {
                border-color:#16a34a;
                background:#f0fdf4;
            }
            .payment-option input {
                margin-top:4px;
                accent-color:#16a34a;
            }
            .payment-option strong {
                display:block;
                color:#111827;
            }
            .payment-option span span {
                display:block;
                color:#64748b;
                font-size:.88rem;
                margin-top:2px;
            }
            .sandbox-box {
                margin-top:14px;
                padding:14px;
                border:1px dashed #94a3b8;
                border-radius:8px;
                background:#f8fafc;
            }
            .sandbox-box[hidden] {
                display:none;
            }
            .sandbox-code {
                display:inline-flex;
                align-items:center;
                gap:8px;
                margin-top:8px;
                padding:8px 10px;
                border-radius:8px;
                background:#111827;
                color:#fff;
                font-weight:800;
                letter-spacing:.04em;
            }
            @media(max-width:700px){
                .cart-item{
                    grid-template-columns:24px 72px minmax(0,1fr)
                }
                .cart-item img{
                    width:72px;
                    height:72px
                }
                .cart-actions{
                    grid-column:2 / -1;
                    justify-content:flex-start
                }
                .cart-price{
                    text-align:left
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="cart" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="cart-shell">
            <div class="container">
                <section class="cart-panel">
                    <div class="cart-header">
                        <div>
                            <h1>Shopping Cart</h1>
                            <p class="text-muted mb-0">${cartItems.size()} item groups in your cart</p>
                        </div>
                        <a class="primary-action" href="${pageContext.request.contextPath}/products">
                            <i class="bi bi-grid"></i> Continue shopping
                        </a>
                    </div>

                    <c:if test="${param.status == 'added'}">
                        <div class="alert alert-success m-3 mb-0">Product added to cart.</div>
                    </c:if>
                    <c:if test="${not empty param.cartError}">
                        <div class="alert alert-danger m-3 mb-0"><c:out value="${param.cartError}"/></div>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty cartItems}">
                            <div class="cart-empty">
                                <i class="bi bi-cart3 d-block mb-3" style="font-size:3rem;"></i>
                                Your cart is empty.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="cart-select-row">
                                <label class="cart-check-label">
                                    <input class="cart-check" type="checkbox" id="selectAllCart" checked>
                                    Chọn tất cả sản phẩm
                                </label>
                                <span class="text-muted" data-selected-count>${cartItems.size()} sản phẩm đã chọn</span>
                            </div>
                            <form id="cartCheckoutForm" action="${pageContext.request.contextPath}/checkout" method="get"></form>
                            <c:forEach items="${cartItems}" var="item">
                                <div class="cart-item" data-cart-row data-unit-price="${item.finalPrice}" data-original-price="${item.sellingPrice}" data-discount="${item.discount}">
                                    <input class="cart-check cart-item-check" type="checkbox" name="variantId" value="${item.productVariantId}" checked form="cartCheckoutForm" aria-label="Select ${item.productName}">
                                    <a href="${pageContext.request.contextPath}/products?action=detail&id=${item.productId}">
                                        <img src="${pageContext.request.contextPath}${item.imageUrl}" alt="${item.productName}"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
                                    </a>
                                    <div>
                                        <div class="cart-meta"><c:out value="${item.brandName}"/></div>
                                        <h3><c:out value="${item.productName}"/></h3>
                                        <div class="cart-meta"><c:out value="${item.variantLabel}"/> · Stock ${item.stock}</div>
                                        <c:if test="${item.hasDiscount()}">
                                            <div class="cart-price-discount">
                                                <del><fmt:formatNumber value="${item.sellingPrice}" pattern="#,##0"/> &#273;</del>
                                                <span class="cart-discount-pill">-${item.discountPercent}%</span>
                                            </div>
                                        </c:if>
                                    </div>
                                    <div class="cart-actions">
                                        <form method="post" action="${pageContext.request.contextPath}/cart" class="d-flex align-items-center gap-2" data-cart-update-form>
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="variantId" value="${item.productVariantId}">
                                            <div class="cart-qty-wrap">
                                                <button class="cart-qty-btn" type="button" data-cart-qty-step="-1" aria-label="Decrease quantity">-</button>
                                                <input class="cart-qty" type="number" name="amount" min="1" max="${item.stock}" value="${item.amount}" data-cart-qty>
                                                <button class="cart-qty-btn" type="button" data-cart-qty-step="1" aria-label="Increase quantity">+</button>
                                            </div>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/cart">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="variantId" value="${item.productVariantId}">
                                            <button class="btn btn-sm btn-outline-danger" type="submit"><i class="bi bi-trash"></i></button>
                                        </form>
                                        <div class="cart-price" data-line-total>
                                            <fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/> &#273;
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            <div class="cart-summary">
                                <span class="cart-summary-info" data-selected-summary>${cartItems.size()} sản phẩm đã chọn</span>
                                <span class="text-muted">Total</span>
                                <span class="cart-total" data-cart-total><fmt:formatNumber value="${cartTotal}" pattern="#,##0"/> &#273;</span>
                                <button class="secondary-action" type="button" data-buy-all>
                                    <i class="bi bi-check2-all"></i> Mua tất cả
                                </button>
                                <button class="primary-action" type="button" data-checkout-selected>
                                    <i class="bi bi-bag-check"></i> Mua đã chọn
                                </button>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <section class="checkout-inline" id="cartCheckoutDetails" hidden>
                        <form id="checkoutDeliveryForm" action="${pageContext.request.contextPath}/checkout" method="get">
                            <input type="hidden" name="checkoutAction" value="placeOrder">
                            <div class="checkout-inline-header">
                                <div>
                                    <h2 class="h4 fw-black mb-1">Cart Checkout</h2>
                                    <div class="text-muted">Selected Products</div>
                                </div>
                                <button type="button" class="secondary-action" data-hide-checkout>Hide</button>
                            </div>
                            <div class="checkout-inline-body">
                                <div id="checkoutHiddenFields"></div>
                                <div class="checkout-table-wrap">
                                    <table class="checkout-table">
                                        <thead>
                                            <tr>
                                                <th>Picture</th>
                                                <th>Product</th>
                                                <th>Price</th>
                                                <th>Quantity</th>
                                                <th class="text-end">Amount</th>
                                            </tr>
                                        </thead>
                                        <tbody data-checkout-items></tbody>
                                    </table>
                                </div>

                                <div class="row g-4 checkout-delivery">
                                    <div class="col-lg-8">
                                        <h3>Delivery Details</h3>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <label class="form-label" for="checkoutName">Full name*</label>
                                                <input id="checkoutName" name="fullName" class="form-control" value="${currentUser.name}" maxlength="255" required>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="checkoutEmail">Email</label>
                                                <input id="checkoutEmail" name="email" type="email" class="form-control" value="${currentUser.email}" maxlength="255">
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="checkoutPhone">Mobile*</label>
                                                <input id="checkoutPhone" name="phone" class="form-control" value="${currentUser.phone}" maxlength="15" required>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="checkoutCity">City/Province*</label>
                                                <select id="checkoutCity" name="city" class="form-select" required>
                                                    <option value="Ha Noi">Ha Noi</option>
                                                    <option value="Ho Chi Minh City">Ho Chi Minh City</option>
                                                    <option value="Da Nang">Da Nang</option>
                                                </select>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="checkoutDistrict">District*</label>
                                                <input id="checkoutDistrict" name="district" class="form-control" placeholder="District" maxlength="120" required>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="checkoutWard">Ward*</label>
                                                <input id="checkoutWard" name="ward" class="form-control" placeholder="Ward" maxlength="120" required>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="checkoutAddress">Address*</label>
                                                <input id="checkoutAddress" name="address" class="form-control" value="${currentUser.address}" maxlength="255" required>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="checkoutNotes">Delivery Notes</label>
                                                <textarea id="checkoutNotes" name="notes" class="form-control" rows="3" maxlength="500" placeholder="Giao trong giờ hành chính"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-4">
                                        <div class="checkout-summary-box">
                                            <div class="checkout-summary-line">
                                                <span>Sub Total</span>
                                                <strong data-checkout-subtotal>0 đ</strong>
                                            </div>
                                            <div class="checkout-summary-line">
                                                <span>Shipping Fee</span>
                                                <strong data-checkout-shipping>Free</strong>
                                            </div>
                                            <div class="checkout-summary-total">
                                                <span>Total Cost</span>
                                                <span data-checkout-grand-total>0 đ</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="checkout-payment-block">
                                <div class="payment-methods">
                                    <label class="payment-option is-selected">
                                        <input type="radio" name="paymentMethod" value="COD" checked>
                                        <span>
                                            <strong>Thanh toán khi nhận hàng</strong>
                                            <span>Không cần thanh toán trước, trả tiền sau khi nhận hàng.</span>
                                        </span>
                                    </label>
                                    <label class="payment-option">
                                        <input type="radio" name="paymentMethod" value="ONLINE">
                                        <span>
                                            <strong>Thanh toán online sandbox</strong>
                                            <span>Mô phỏng thanh toán online bằng môi trường sandbox.</span>
                                        </span>
                                    </label>
                                </div>
                                <div class="sandbox-box" data-sandbox-box hidden>
                                    <strong>Sandbox payment</strong>
                                    <div class="checkout-small">Đây là thanh toán mô phỏng. Không trừ tiền thật.</div>
                                    <div class="sandbox-code"><i class="bi bi-credit-card-2-front"></i> TEST-PAYMENT</div>
                                </div>
                            </div>
                            <div class="checkout-inline-footer">
                                <button type="button" class="secondary-action" data-hide-checkout>Cancel</button>
                                <button type="submit" class="primary-action" data-submit-payment><i class="bi bi-check2-circle"></i> Đặt hàng</button>
                            </div>
                        </form>
                    </section>
                </section>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (() => {
                const cartPanel = document.querySelector('.cart-panel');
                if (!cartPanel)
                    return;

                const money = new Intl.NumberFormat('vi-VN');
                const rows = Array.from(cartPanel.querySelectorAll('[data-cart-row]'));
                const selectAll = document.getElementById('selectAllCart');
                const selectedCount = cartPanel.querySelector('[data-selected-count]');
                const selectedSummary = cartPanel.querySelector('[data-selected-summary]');
                const cartTotal = cartPanel.querySelector('[data-cart-total]');
                const checkoutButton = cartPanel.querySelector('[data-checkout-selected]');
                const buyAllButton = cartPanel.querySelector('[data-buy-all]');
                const checkoutDetails = document.getElementById('cartCheckoutDetails');
                const checkoutItemsBody = document.querySelector('[data-checkout-items]');
                const checkoutHiddenFields = document.getElementById('checkoutHiddenFields');
                const checkoutSubtotal = document.querySelector('[data-checkout-subtotal]');
                const checkoutGrandTotal = document.querySelector('[data-checkout-grand-total]');
                const sandboxBox = document.querySelector('[data-sandbox-box]');
                const submitPaymentButton = document.querySelector('[data-submit-payment]');
                const shippingFee = 0;
                const updateTimers = new Map();

                function clampQuantity(input) {
                    const min = Number(input.min || 1);
                    const max = Number(input.max || min);
                    let value = Number(input.value || min);
                    if (!Number.isFinite(value))
                        value = min;
                    value = Math.max(min, Math.min(max, Math.round(value)));
                    input.value = String(value);
                    return value;
                }

                function updateTotals() {
                    let total = 0;
                    let checked = 0;

                    rows.forEach(row => {
                        const checkbox = row.querySelector('.cart-item-check');
                        const qtyInput = row.querySelector('[data-cart-qty]');
                        const lineTotal = row.querySelector('[data-line-total]');
                        const quantity = clampQuantity(qtyInput);
                        const unitPrice = Number(row.dataset.unitPrice || 0);
                        const rowTotal = unitPrice * quantity;

                        lineTotal.textContent = money.format(rowTotal) + ' đ';
                        if (checkbox.checked) {
                            checked += 1;
                            total += rowTotal;
                        }
                    });

                    cartTotal.textContent = money.format(total) + ' đ';
                    selectedCount.textContent = checked + ' sản phẩm đã chọn';
                    selectedSummary.textContent = checked + ' sản phẩm đã chọn';
                    checkoutButton.disabled = checked === 0;

                    if (selectAll) {
                        selectAll.checked = checked === rows.length;
                        selectAll.indeterminate = checked > 0 && checked < rows.length;
                    }
                }

                function saveQuantity(form) {
                    const key = form.querySelector('input[name="variantId"]').value;
                    clearTimeout(updateTimers.get(key));
                    updateTimers.set(key, setTimeout(() => {
                        const data = new FormData(form);
                        fetch(form.action, {
                            method: 'POST',
                            body: data,
                            credentials: 'same-origin'
                        }).catch(() => {
                            form.submit();
                        });
                    }, 350));
                }

                function selectedRows() {
                    return rows.filter(row => row.querySelector('.cart-item-check').checked);
                }

                function textOf(element) {
                    return element ? element.textContent.trim() : '';
                }

                function refreshCheckoutIfOpen() {
                    if (checkoutDetails && !checkoutDetails.hidden) {
                        showCheckoutDetails(false, false);
                    }
                }

                function showCheckoutDetails(selectEveryItem, shouldScroll = true) {
                    if (selectEveryItem) {
                        rows.forEach(row => {
                            row.querySelector('.cart-item-check').checked = true;
                        });
                        updateTotals();
                    }

                    const chosenRows = selectedRows();
                    if (!chosenRows.length || !checkoutDetails) {
                        if (checkoutDetails) {
                            checkoutDetails.hidden = true;
                        }
                        return;
                    }

                    checkoutItemsBody.innerHTML = '';
                    checkoutHiddenFields.innerHTML = '';
                    let subtotal = 0;

                    chosenRows.forEach(row => {
                        const checkbox = row.querySelector('.cart-item-check');
                        const image = row.querySelector('img');
                        const brand = textOf(row.querySelector('.cart-meta'));
                        const productName = textOf(row.querySelector('h3'));
                        const metaItems = row.querySelectorAll('.cart-meta');
                        const variant = metaItems.length > 1 ? textOf(metaItems[1]) : '';
                        const quantity = clampQuantity(row.querySelector('[data-cart-qty]'));
                        const unitPrice = Number(row.dataset.unitPrice || 0);
                        const amount = unitPrice * quantity;
                        subtotal += amount;

                        const hidden = document.createElement('input');
                        hidden.type = 'hidden';
                        hidden.name = 'variantId';
                        hidden.value = checkbox.value;
                        checkoutHiddenFields.appendChild(hidden);

                        const tr = document.createElement('tr');
                        tr.innerHTML =
                                '<td><img class="checkout-thumb" src="' + image.src + '" alt=""></td>' +
                                '<td><div class="checkout-product-name"></div><div class="checkout-small"></div></td>' +
                                '<td>' + money.format(unitPrice) + ' đ</td>' +
                                '<td>' + quantity + '</td>' +
                                '<td class="checkout-amount">' + money.format(amount) + ' đ</td>';
                        tr.querySelector('.checkout-product-name').textContent = productName;
                        tr.querySelector('.checkout-small').textContent = brand + ' · ' + variant;
                        checkoutItemsBody.appendChild(tr);
                    });

                    checkoutSubtotal.textContent = money.format(subtotal) + ' đ';
                    checkoutGrandTotal.textContent = money.format(subtotal + shippingFee) + ' đ';
                    checkoutDetails.hidden = false;
                    if (shouldScroll) {
                        checkoutDetails.scrollIntoView({behavior: 'smooth', block: 'start'});
                }
                }

                cartPanel.addEventListener('click', event => {
                    const stepButton = event.target.closest('[data-cart-qty-step]');
                    if (!stepButton)
                        return;

                    const form = stepButton.closest('[data-cart-update-form]');
                    const input = form.querySelector('[data-cart-qty]');
                    input.value = String(Number(input.value || 1) + Number(stepButton.dataset.cartQtyStep));
                    clampQuantity(input);
                    updateTotals();
                    refreshCheckoutIfOpen();
                    saveQuantity(form);
                });

                cartPanel.addEventListener('input', event => {
                    const input = event.target.closest('[data-cart-qty]');
                    if (!input)
                        return;

                    clampQuantity(input);
                    updateTotals();
                    refreshCheckoutIfOpen();
                    saveQuantity(input.closest('[data-cart-update-form]'));
                });

                cartPanel.addEventListener('change', event => {
                    if (event.target.matches('.cart-item-check')) {
                        updateTotals();
                        refreshCheckoutIfOpen();
                    }
                });

                if (selectAll) {
                    selectAll.addEventListener('change', () => {
                        rows.forEach(row => {
                            row.querySelector('.cart-item-check').checked = selectAll.checked;
                        });
                        updateTotals();
                        refreshCheckoutIfOpen();
                    });
                }

                if (buyAllButton) {
                    buyAllButton.addEventListener('click', () => {
                        showCheckoutDetails(true);
                    });
                }

                if (checkoutButton) {
                    checkoutButton.addEventListener('click', () => {
                        showCheckoutDetails(false);
                    });
                }

                document.querySelectorAll('[data-hide-checkout]').forEach(button => {
                    button.addEventListener('click', () => {
                        if (checkoutDetails) {
                            checkoutDetails.hidden = true;
                        }
                    });
                });

                function syncPaymentMethod() {
                    const selected = document.querySelector('input[name="paymentMethod"]:checked');
                    const isOnline = selected && selected.value === 'ONLINE';
                    document.querySelectorAll('.payment-option').forEach(option => {
                        const radio = option.querySelector('input[name="paymentMethod"]');
                        option.classList.toggle('is-selected', radio && radio.checked);
                    });
                    if (sandboxBox) {
                        sandboxBox.hidden = !isOnline;
                    }
                    if (submitPaymentButton) {
                        submitPaymentButton.innerHTML = isOnline
                                ? '<i class="bi bi-credit-card"></i> Thanh toán sandbox'
                                : '<i class="bi bi-check2-circle"></i> Đặt hàng';
                    }
                }

                document.querySelectorAll('input[name="paymentMethod"]').forEach(radio => {
                    radio.addEventListener('change', syncPaymentMethod);
                });

                syncPaymentMethod();
                updateTotals();
            })();
        </script>
    </body>
</html>
