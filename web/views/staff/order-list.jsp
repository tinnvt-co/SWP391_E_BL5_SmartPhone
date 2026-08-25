<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Order Management</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            .order-status-option.is-locked {
                opacity: 0.45;
                cursor: not-allowed;
                background: #f5f7fb;
            }
            .order-status-option.is-locked:hover {
                border-color: #e3e7ef;
                background: #f5f7fb;
            }
            .order-status-option.is-locked .order-status-option-code {
                color: #6b7280;
                letter-spacing: 0.04em;
            }
            .order-status-option-code .bi-lock-fill {
                font-size: 0.8em;
                margin-left: 4px;
                color: #94a3b8;
            }
        </style><%@include file="../common/head.jsp"%></head><body>
        <c:set var="activePage" value="staff-orders" scope="request"/><%@ include file="/views/common/header.jsp" %>
        <main class="page-shell">
            <div class="page-heading"><div><h1>Order Management</h1><p>${orders.size()} orders shown</p></div></div>
            <c:if test="${not empty param.message}"><div class="alert success"><c:out value="${param.message}"/></div></c:if>
            <c:if test="${not empty validationError}"><div class="alert error"><c:out value="${validationError}"/></div></c:if>
                <section class="stats-grid">
                    <article><span>TODAY'S ORDERS</span><strong>${totalToday}</strong><i class=""></i></article>
                <article><span>PROCESSING</span><strong>${totalProcessing}</strong><i class="green"></i></article>
                <article><span>DELIVERED</span><strong>${totalDelivered}</strong><i class="purple"></i></article>
            </section>
            <section class="table-panel">
                <form class="search-row" method="get">
                    <input name="q" value="<c:out value='${keyword}'/>" placeholder="Search by order id, customer name or username..." maxlength="100">
                    <select name="status"><option value="">All Status</option>
                        <c:forEach items="${statuses}" var="s">
                            <c:if test="${s != 'CANCELLED' && s != 'CANCEL_REQUESTED'}">
                                <option value="${s}" ${selectedStatus==s?'selected':''}><c:out value="${s}"/></option>
                            </c:if>
                        </c:forEach>
                    </select>
                    <select name="type"><option value="ALL" ${selectedType=='ALL'?'selected':''}>All Types</option><option value="ORDER" ${selectedType=='ORDER'?'selected':''}>Customer Order</option><option value="IMPORT" ${selectedType=='IMPORT'?'selected':''}>Import</option></select>
                    <button class="btn primary">Search</button>
                </form>
                <div class="table-wrap"><table><thead><tr><th>Order ID</th><th>Customer</th><th>Type</th><th>Status</th><th>Items</th><th>Total</th><th>Method</th><th>Created</th><th>Actions</th></tr></thead><tbody>
                                    <c:forEach items="${orders}" var="o">
                                <tr>
                                    <td class="mono">${o.code}</td>
                                    <td><div class="order-customer"><span class="order-customer-avatar">${empty o.userName ? '?' : o.userName.substring(0,1).toUpperCase()}</span><div class="order-customer-info"><strong><c:out value="${o.userName}"/></strong><small>@<c:out value="${o.username}"/></small></div></div></td>
                                    <td><span class="${o.type=='IMPORT'?'order-type-import':'order-type-order'}">${o.type}</span></td>
                                    <td><span class="status status-${o.status.toLowerCase()}">${o.status}</span></td>
                                    <td>${o.itemCount}</td>
                                    <td class="price-small"><fmt:formatNumber value="${o.totalPrice}" pattern="#,##0"/>₫</td>
                                    <td><span class="order-method">${o.method}</span></td>
                                    <td><small style="font-family:monospace;color:var(--muted)"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></small></td>
                                    <td><div class="actions order-actions"><a class="btn subtle" href="${pageContext.request.contextPath}/staff/orders?action=detail&id=${o.id}">Detail</a><button class="btn primary" type="button" data-order-update data-order-id="${o.id}" data-order-code="${o.code}" data-order-status="${o.status}" data-order-customer="<c:out value='${o.userName}'/>" data-order-total="<fmt:formatNumber value='${o.totalPrice}' pattern='#,##0'/>" data-order-method="${o.method}" data-order-type="${o.type}">Update</button></div></td>
                                </tr>
                            </c:forEach>
                        </tbody></table></div>
                <c:if test="${empty orders}"><div class="order-empty"><h2>No orders found</h2><p>Try changing your filters or clearing the search keyword.</p></div></c:if>
                </section>
            </main>
            <div class="order-modal" id="orderUpdateModal" hidden>
                <div class="order-modal-overlay" data-modal-close></div>
                <div class="order-modal-card" role="dialog" aria-labelledby="orderModalTitle">
                    <header class="order-modal-header">
                        <div>
                            <h2 id="orderModalTitle">Update Order Status</h2>
                            <p class="order-modal-sub"><span id="modalOrderCode">--</span> · <span id="modalOrderCustomer">--</span></p>
                        </div>
                        <button class="order-modal-close" type="button" data-modal-close aria-label="Close">&times;</button>
                    </header>
                    <div class="order-modal-body">
                        <div class="order-stepper" id="modalStepper"></div>
                        <form method="post" action="${pageContext.request.contextPath}/staff/orders" id="modalUpdateForm">
                        <input type="hidden" name="action" value="update-status">
                        <input type="hidden" name="id" id="modalOrderId">
                        <label class="order-modal-label">Select new status</label>
                        <div class="order-status-grid" id="modalStatusGrid"></div>
                        <div class="order-modal-actions">
                            <button class="btn subtle" type="button" data-modal-close>Cancel</button>
                            <button class="btn primary" type="submit" id="modalSubmit">Confirm Update</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script><%@ include file="/views/common/footer.jsp" %><script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script></body></html>
