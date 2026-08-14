<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout | SmartPhone store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <style>
        body { background:#f6f8fb; color:#111827; }
        .checkout-shell { padding:42px 0 70px; }
        .checkout-panel { background:#fff; border:1px solid rgba(15,23,42,.08); border-radius:8px; box-shadow:0 18px 45px rgba(15,23,42,.08); overflow:hidden; }
        .checkout-header { padding:24px; border-bottom:1px solid #eef2f7; display:flex; justify-content:space-between; gap:16px; flex-wrap:wrap; }
        .checkout-header h1 { margin:0; font-weight:900; }
        .checkout-item { display:grid; grid-template-columns:78px minmax(0,1fr) auto; gap:16px; align-items:center; padding:18px 24px; border-bottom:1px solid #eef2f7; }
        .checkout-item img { width:78px; height:78px; object-fit:cover; border-radius:8px; background:#f1f5f9; }
        .checkout-item h3 { margin:0 0 4px; font-size:1rem; font-weight:900; }
        .checkout-meta { color:#64748b; font-size:.9rem; }
        .checkout-price { color:#b91c1c; font-weight:900; text-align:right; min-width:130px; }
        .checkout-summary { padding:22px 24px; display:flex; justify-content:flex-end; align-items:center; gap:18px; flex-wrap:wrap; }
        .checkout-total { color:#111827; font-size:1.4rem; font-weight:900; }
        .payment-result { margin:18px 24px 0; padding:14px 16px; border-radius:8px; font-weight:800; }
        .payment-result.cod { background:#f0fdf4; color:#166534; border:1px solid #bbf7d0; }
        .payment-result.online { background:#eef6ff; color:#1d4ed8; border:1px solid #bfdbfe; }
        .primary-action,.secondary-action { min-height:44px; display:inline-flex; align-items:center; justify-content:center; gap:8px; padding:0 18px; border-radius:8px; font-weight:800; text-decoration:none; }
        .primary-action { border:1px solid #16a34a; background:#16a34a; color:#fff; }
        .primary-action:hover { background:#15803d; border-color:#15803d; color:#fff; }
        .secondary-action { border:1px solid #dbe3ec; background:#fff; color:#111827; }
        .secondary-action:hover { color:#1665d8; border-color:#b9c9ef; }
        .checkout-empty { padding:54px 24px; color:#64748b; text-align:center; }
    </style>
</head>
<body>
<c:set var="activePage" value="cart" scope="request"/>
<%@ include file="/views/common/header.jsp" %>

<main class="checkout-shell">
    <div class="container">
        <section class="checkout-panel">
            <div class="checkout-header">
                <div>
                    <h1>Checkout</h1>
                    <p class="text-muted mb-0">${checkoutItems.size()} selected products</p>
                </div>
                <a class="secondary-action" href="${pageContext.request.contextPath}/cart">
                    <i class="bi bi-arrow-left"></i> Back to cart
                </a>
            </div>

            <c:choose>
                <c:when test="${empty checkoutItems}">
                    <div class="checkout-empty">
                        <i class="bi bi-bag-x d-block mb-3" style="font-size:3rem;"></i>
                        No products selected for checkout.
                    </div>
                </c:when>
                <c:otherwise>
                    <c:choose>
                        <c:when test="${paymentMethod == 'ONLINE'}">
                            <div class="payment-result online">
                                <i class="bi bi-credit-card"></i> Sandbox payment simulated successfully.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="payment-result cod">
                                <i class="bi bi-cash-coin"></i>
                                <c:choose>
                                    <c:when test="${orderCreated}">
                                        Order #${orderId} has been saved. Payment method: pay after receiving the order.
                                    </c:when>
                                    <c:otherwise>
                                        Payment method: pay after receiving the order.
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <c:forEach items="${checkoutItems}" var="item">
                        <div class="checkout-item">
                            <img src="${pageContext.request.contextPath}${item.imageUrl}" alt="${item.productName}"
                                 onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
                            <div>
                                <div class="checkout-meta"><c:out value="${item.brandName}"/></div>
                                <h3><c:out value="${item.productName}"/></h3>
                                <div class="checkout-meta"><c:out value="${item.variantLabel}"/> &middot; Quantity ${item.amount}</div>
                            </div>
                            <div class="checkout-price">
                                <fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/> &#273;
                            </div>
                        </div>
                    </c:forEach>
                    <div class="checkout-summary">
                        <span class="text-muted">Total</span>
                        <span class="checkout-total"><fmt:formatNumber value="${checkoutTotal}" pattern="#,##0"/> &#273;</span>
                        <a class="primary-action" href="${pageContext.request.contextPath}/products">
                            <i class="bi bi-grid"></i> Continue shopping
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<%@ include file="/views/common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
