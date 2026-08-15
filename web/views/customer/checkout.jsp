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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
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
