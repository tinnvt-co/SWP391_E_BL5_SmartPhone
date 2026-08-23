<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cart | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body>
        <c:set var="activePage" value="cart" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Profile Dashboard</h1>
                <p>Manage your cart, wishlist, order history, and account information from one place.</p>
            </div>
        </section>

        <main class="dashboard-shell">
            <div class="container">
                <div class="dashboard-grid">
                    <aside class="panel profile-card">
                        <div class="d-flex align-items-center gap-3">
                            <c:choose>
                                <c:when test="${not empty currentUser.image}">
                                    <img class="avatar" src="${currentUser.image}" alt="${currentUser.name}">
                                </c:when>
                                <c:otherwise>
                                    <div class="avatar-fallback">${fn:substring(currentUser.name, 0, 1)}</div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <h2 class="h5 fw-black mb-1">${currentUser.name}</h2>
                                <div class="text-muted small">@${currentUser.username}</div>
                            </div>
                        </div>

                        <div class="mt-4">
                            <span class="role-pill">
                                <i class="bi bi-shield-check"></i> ${currentRole}
                            </span>
                        </div>

                        <nav class="profile-menu">
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                            <a href="${pageContext.request.contextPath}/order-history">
                                <i class="bi bi-receipt"></i> Order History
                            </a>
                            <a href="${pageContext.request.contextPath}/wishlist">
                                <i class="bi bi-heart"></i> Wishlist
                            </a>
                            <a class="active" href="${pageContext.request.contextPath}/cart">
                                <i class="bi bi-bag"></i> Cart
                            </a>
                            <a href="${pageContext.request.contextPath}/change-password">
                                <i class="bi bi-shield-lock"></i> Change Password
                            </a>
                            <a href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </nav>
                    </aside>

                    <section>
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
                            <form id="cartCheckoutForm" action="${pageContext.request.contextPath}/cart" method="get"></form>
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
                        <form id="checkoutDeliveryForm" action="${pageContext.request.contextPath}/cart" method="post">
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
                                            <div class="checkout-summary-line text-success" id="checkoutDiscountRow" style="display:none;">
                                                <span>Voucher Discount</span>
                                                <strong data-checkout-discount>-0 đ</strong>
                                            </div>
                                            <div class="checkout-summary-total">
                                                <span>Total Cost</span>
                                                <span data-checkout-grand-total>0 đ</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <c:if test="${not empty savedVouchers}">
                                <div class="checkout-voucher-block mt-4 mb-4">
                                    <div class="d-flex align-items-center mb-3">
                                        <i class="bi bi-ticket-perforated fs-5 text-primary me-2"></i>
                                        <h4 class="h6 fw-bold mb-0 text-uppercase" style="letter-spacing: 0.5px; color: #475569;">Apply Voucher</h4>
                                    </div>
                                    <div class="position-relative">
                                        <select class="form-select form-select-lg shadow-sm" name="voucherId" id="voucherSelect" style="font-size: 0.95rem; border-radius: 10px; border-color: #cbd5e1; padding: 12px 16px;">
                                            <option value="">-- No Voucher Selected --</option>
                                                <c:forEach var="uv" items="${savedVouchers}">
                                                    <option value="${uv.voucher.id}" 
                                                        data-min-order="${uv.voucher.minOrderValue != null ? uv.voucher.minOrderValue : 0}"
                                                        data-discount-type="${uv.voucher.discountType}"
                                                        data-value="${uv.voucher.value}"
                                                        data-max-discount="${uv.voucher.maxDiscount != null ? uv.voucher.maxDiscount : 0}">
                                                        ${uv.voucher.code} - 
                                                        <c:choose>
                                                            <c:when test="${uv.voucher.discountType == 'PERCENTAGE'}">
                                                                <fmt:formatNumber value="${uv.voucher.value}" pattern="#,##0"/>% OFF
                                                            </c:when>
                                                            <c:otherwise>
                                                                <fmt:formatNumber value="${uv.voucher.value}" pattern="#,##0"/>đ OFF
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${uv.voucher.minOrderValue != null}">
                                                            (Min: <fmt:formatNumber value="${uv.voucher.minOrderValue}" pattern="#,##0"/>đ)
                                                        </c:if>
                                                        <c:if test="${not empty uv.voucher.maxUsesPerUser && uv.voucher.maxUsesPerUser > 1}">
                                                            - Bạn còn ${uv.voucher.maxUsesPerUser - uv.usedCount} lượt
                                                        </c:if>
                                                    </option>
                                                </c:forEach>
                                            </select>
                                            <div id="voucherError" class="text-danger small mt-1" style="display:none;"></div>
                                        </div>
                                </div>
                            </c:if>
                            
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
                    </section>
                </div>
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
                    updateVoucherDiscount(subtotal);
                    
                    checkoutDetails.hidden = false;
                    if (shouldScroll) {
                        checkoutDetails.scrollIntoView({behavior: 'smooth', block: 'start'});
                    }
                }
                
                function updateVoucherDiscount(subtotal) {
                    if (subtotal === undefined) {
                        subtotal = 0;
                        selectedRows().forEach(row => {
                            const quantity = clampQuantity(row.querySelector('[data-cart-qty]'));
                            const unitPrice = Number(row.dataset.unitPrice || 0);
                            subtotal += (unitPrice * quantity);
                        });
                    }
                    
                    let discountAmount = 0;
                    const voucherSelect = document.getElementById('voucherSelect');
                    const errorDiv = document.getElementById('voucherError');
                    const discountRow = document.getElementById('checkoutDiscountRow');
                    const discountText = document.querySelector('[data-checkout-discount]');
                    
                    if (voucherSelect && voucherSelect.selectedIndex > 0) {
                        const option = voucherSelect.options[voucherSelect.selectedIndex];
                        const minOrder = Number(option.dataset.minOrder || 0);
                        const discountType = option.dataset.discountType;
                        const value = Number(option.dataset.value || 0);
                        const maxDiscount = Number(option.dataset.maxDiscount || 0);
                        
                        if (subtotal >= minOrder) {
                            errorDiv.style.display = 'none';
                            if (discountType === 'PERCENTAGE') {
                                discountAmount = Math.floor(subtotal * (value / 100.0));
                                if (maxDiscount > 0 && discountAmount > maxDiscount) {
                                    discountAmount = maxDiscount;
                                }
                            } else {
                                discountAmount = value;
                            }
                        } else {
                            errorDiv.textContent = 'Minimum order value of ' + money.format(minOrder) + 'đ is required.';
                            errorDiv.style.display = 'block';
                            voucherSelect.selectedIndex = 0; // Reset
                        }
                    } else if (errorDiv) {
                        errorDiv.style.display = 'none';
                    }
                    
                    if (discountAmount > subtotal) {
                        discountAmount = subtotal;
                    }
                    
                    if (discountRow) {
                        if (discountAmount > 0) {
                            discountText.textContent = '-' + money.format(discountAmount) + ' đ';
                            discountRow.style.display = 'flex';
                        } else {
                            discountRow.style.display = 'none';
                        }
                    }
                    
                    checkoutGrandTotal.textContent = money.format(subtotal + shippingFee - discountAmount) + ' đ';
                }
                
                const voucherSelectEl = document.getElementById('voucherSelect');
                if (voucherSelectEl) {
                    voucherSelectEl.addEventListener('change', () => updateVoucherDiscount());
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
