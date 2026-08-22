<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Shipper Delivery History</title><link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css"></head><body><c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>
        <main class="page-shell">
            <div class="page-heading"><div><h1>Shipper Delivery History</h1><p>View successfully delivered orders by shipper</p></div></div>
            <c:if test="${not empty param.message}"><div class="alert success"><c:out value="${param.message}"/></div></c:if>
            <c:if test="${not empty param.error}"><div class="alert error"><c:out value="${param.error}"/></div></c:if>
            <section class="table-panel">
                <form class="search-row" method="get" action="${pageContext.request.contextPath}/manager/shipper-deliveries">
                    <select name="shipperId" required onchange="this.form.submit()">
                        <option value="">-- Select Shipper --</option>
                        <c:forEach items="${shippers}" var="s">
                            <option value="${s.id}" ${selectedShipperId == s.id ? 'selected' : ''}><c:out value="${s.name}"/> (<c:out value="${s.username}"/>)</option>
                        </c:forEach>
                    </select>
                    <button class="btn primary">View History</button>
                </form>

                <c:if test="${selectedShipperId != null}">
                    <div class="table-wrap"><table><thead><tr><th>Order ID</th><th>Customer</th><th>Status</th><th>Items</th><th>Total</th><th>Method</th><th>Created</th><th>Delivered At</th><th>Actions</th></tr></thead><tbody>
                                        <c:forEach items="${orders}" var="o">
                                    <tr>
                                        <td class="mono">${o.code}</td>
                                        <td><div class="order-customer"><span class="order-customer-avatar">${empty o.userName ? '?' : o.userName.substring(0,1).toUpperCase()}</span><div class="order-customer-info"><strong><c:out value="${o.userName}"/></strong><small>@<c:out value="${o.username}"/></small></div></div></td>
                                        <td><span class="status status-${o.status.toLowerCase()}">${o.status}</span></td>
                                        <td>${o.itemCount}</td>
                                        <td class="price-small"><fmt:formatNumber value="${o.totalPrice}" pattern="#,##0"/>₫</td>
                                        <td><span class="order-method">${o.method}</span></td>
                                        <td><small style="font-family:monospace;color:var(--muted)"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></small></td>
                                        <td><small style="font-family:monospace;color:var(--muted)"><fmt:formatDate value="${o.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></small></td>
                                        <td><div class="actions order-actions"><a class="btn subtle" href="${pageContext.request.contextPath}/manager/orders?action=detail&id=${o.id}">Detail</a></div></td>
                                    </tr>
                                </c:forEach>
                            </tbody></table></div>
                    <c:if test="${empty orders}"><div class="order-empty"><h2>No deliveries found</h2><p>This shipper hasn't delivered any orders yet.</p></div></c:if>
                </c:if>
                <c:if test="${selectedShipperId == null}">
                    <div class="order-empty"><h2>Select a shipper</h2><p>Please select a shipper from the dropdown above to view their delivery history.</p></div>
                </c:if>
            </section>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script><%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body></html>
