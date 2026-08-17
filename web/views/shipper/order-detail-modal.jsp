<div class="modal fade shipper-detail-modal" id="orderDetailModal${order.id}" tabindex="-1" aria-labelledby="orderDetailModalLabel${order.id}" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content text-start">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title fw-bold" id="orderDetailModalLabel${order.id}">
                        Order #${order.id} detail
                    </h5>
                    <div class="text-muted small">
                        Created <fmt:formatDate value="${order.createdAt}" pattern="dd MMM yyyy HH:mm"/>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="detail-summary-grid mb-4">
                    <div class="detail-summary-box">
                        <span>Payment</span>
                        <strong>
                            <span class="payment-pill ${fn:toLowerCase(order.method)}">
                                <i class="bi ${fn:toLowerCase(order.method) == 'vnpay' ? 'bi-credit-card' : 'bi-cash-coin'}"></i>
                                <c:out value="${order.method}"/>
                            </span>
                        </strong>
                    </div>
                    <div class="detail-summary-box">
                        <span>Total price</span>
                        <strong><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> &#273;</strong>
                    </div>
                    <div class="detail-summary-box">
                        <span>Need collect</span>
                        <strong>
                            <c:choose>
                                <c:when test="${order.paidAmount gt 0}">0 &#273;</c:when>
                                <c:otherwise><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> &#273;</c:otherwise>
                            </c:choose>
                        </strong>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <div class="detail-summary-box h-100">
                            <span>Customer</span>
                            <strong><c:out value="${empty order.recipientName ? order.userName : order.recipientName}"/></strong>
                            <div class="text-muted mt-1">
                                <i class="bi bi-telephone-fill me-1"></i>
                                <c:out value="${empty order.recipientPhone ? order.userPhone : order.recipientPhone}"/>
                            </div>
                            <div class="text-muted">
                                <i class="bi bi-envelope me-1"></i>
                                <c:out value="${order.userEmail}"/>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="detail-summary-box h-100">
                            <span>Delivery address</span>
                            <strong><c:out value="${empty order.deliveryAddress ? 'No address provided' : order.deliveryAddress}"/></strong>
                            <div class="text-muted mt-2">
                                Status: <b><c:out value="${order.status}"/></b>
                                <c:if test="${not empty order.note}">
                                    <br>Note: <c:out value="${order.note}"/>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <h6 class="fw-bold mb-3">Products (${order.itemCount})</h6>
                <div class="shipper-modal-products">
                    <c:forEach items="${order.items}" var="it">
                        <article class="shipper-modal-product">
                            <c:set var="productImageSrc" value="${pageContext.request.contextPath}/assets/images/product-placeholder.svg"/>
                            <c:if test="${not empty it.productImage}">
                                <c:choose>
                                    <c:when test="${fn:startsWith(it.productImage, '/')}">
                                        <c:set var="productImageSrc" value="${pageContext.request.contextPath}${it.productImage}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="productImageSrc" value="${pageContext.request.contextPath}/assets/images/products/${it.productImage}"/>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:choose>
                                <c:when test="${not empty it.productImage}">
                                    <img class="modal-item-img" src="${productImageSrc}" alt="${it.productName}"
                                         onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
                                </c:when>
                                <c:otherwise>
                                    <img class="modal-item-img" src="${pageContext.request.contextPath}/assets/images/product-placeholder.svg" alt="${it.productName}">
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <h6 class="shipper-modal-product-title"><c:out value="${it.productName}"/></h6>
                                <div class="shipper-modal-product-meta">
                                    <c:out value="${it.brandName}"/> &middot;
                                    <c:out value="${it.variantLabel}"/> &middot;
                                    Quantity: <b>${it.amount}</b>
                                </div>
                            </div>
                            <div class="shipper-modal-product-money">
                                <strong><fmt:formatNumber value="${it.total}" pattern="#,##0"/> &#273;</strong>
                                <span><fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/> &#273; / item</span>
                            </div>
                        </article>
                    </c:forEach>
                    <c:if test="${empty order.items}">
                        <div class="text-center text-muted py-4 border rounded">No product detail found.</div>
                    </c:if>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
