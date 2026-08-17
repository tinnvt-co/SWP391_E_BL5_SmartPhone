<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Delivery Orders | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body {
                background: #f6f8fb;
                color: #111827;
            }

            .profile-hero {
                background:
                    linear-gradient(120deg, rgba(17, 24, 39, 0.9), rgba(22, 101, 216, 0.78)),
                    url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center right / cover no-repeat;
                color: #ffffff;
                padding: 56px 0 92px;
            }

            .profile-hero h1 {
                margin: 0 0 10px;
                font-size: clamp(2rem, 5vw, 3.2rem);
                font-weight: 900;
            }

            .profile-hero p {
                max-width: 660px;
                margin: 0;
                color: rgba(255, 255, 255, 0.78);
            }

            .dashboard-shell {
                margin-top: -58px;
                padding-bottom: 64px;
            }

            .dashboard-grid {
                display: grid;
                grid-template-columns: minmax(250px, 320px) minmax(0, 1fr);
                gap: 22px;
                align-items: start;
            }

            .panel {
                background: #ffffff;
                border: 1px solid rgba(15, 23, 42, 0.08);
                border-radius: 8px;
                box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
            }

            .profile-card {
                padding: 24px;
                position: sticky;
                top: 92px;
            }

            .avatar {
                width: 92px;
                height: 92px;
                border-radius: 50%;
                object-fit: cover;
                border: 4px solid #ffffff;
                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.14);
                background: #e2e8f0;
            }

            .avatar-fallback {
                width: 92px;
                height: 92px;
                border-radius: 50%;
                display: grid;
                place-items: center;
                color: #ffffff;
                background: linear-gradient(135deg, #1665d8, #17a673);
                font-size: 2.3rem;
                font-weight: 900;
                border: 4px solid #ffffff;
                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.14);
            }

            .role-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 7px 11px;
                border-radius: 999px;
                color: #14532d;
                background: #dcfce7;
                font-size: 0.8rem;
                font-weight: 800;
            }

            .profile-menu {
                display: grid;
                gap: 8px;
                margin-top: 22px;
            }

            .profile-menu a {
                min-height: 42px;
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 0 12px;
                border-radius: 8px;
                color: #475569;
                text-decoration: none;
                font-weight: 750;
            }

            .profile-menu a.active,
            .profile-menu a:hover {
                color: #1665d8;
                background: #eff6ff;
            }

            .content-panel {
                padding: 24px;
            }

            .table-panel {
                margin-top: 18px;
                overflow: hidden;
                border: 1px solid rgba(15, 23, 42, 0.08);
                border-radius: 8px;
                background: #fff;
            }

            .table {
                margin-bottom: 0;
            }

            .table > :not(caption) > * > * {
                padding: 1rem 1.15rem;
                border-bottom-color: #eef2f7;
            }

            .table-light th {
                background: #f8fafc;
                color: #64748b;
                font-size: 0.75rem;
                font-weight: 800;
                letter-spacing: 0.07em;
                text-transform: uppercase;
            }

            .badge-soft-warning {
                background: #fffbeb;
                color: #d97706;
                font-weight: 800;
                padding: 0.42em 0.75em;
            }

            .shipper-order-row {
                cursor: pointer;
            }

            .shipper-order-row:hover td {
                background: #f8fbff;
            }

            .payment-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 0.42em 0.75em;
                border-radius: 999px;
                font-size: 0.78rem;
                font-weight: 900;
                letter-spacing: .02em;
                text-transform: uppercase;
                white-space: nowrap;
            }

            .payment-pill.cod {
                background: #fef3c7;
                color: #92400e;
            }

            .payment-pill.vnpay,
            .payment-pill.online {
                background: #dbeafe;
                color: #1d4ed8;
            }

            .payment-note {
                margin-top: 6px;
                color: #64748b;
                font-size: .78rem;
            }

            .detail-summary-grid {
                display: grid;
                grid-template-columns: repeat(3, minmax(0, 1fr));
                gap: 12px;
            }

            .detail-summary-box {
                padding: 12px;
                border: 1px solid #e5e7eb;
                border-radius: 8px;
                background: #f8fafc;
            }

            .detail-summary-box span {
                display: block;
                color: #64748b;
                font-size: .75rem;
                font-weight: 800;
                text-transform: uppercase;
            }

            .detail-summary-box strong {
                display: block;
                margin-top: 4px;
                color: #0f172a;
            }

            .modal-item-img {
                width: 92px;
                height: 92px;
                border-radius: 10px;
                object-fit: cover;
                background: #f1f5f9;
                border: 1px solid #e5e7eb;
            }

            .shipper-detail-modal .modal-dialog {
                max-width: min(1080px, calc(100vw - 32px));
            }

            .shipper-detail-modal .modal-content {
                border: 0;
                border-radius: 14px;
                overflow: hidden;
                box-shadow: 0 24px 70px rgba(15, 23, 42, .22);
            }

            .shipper-detail-modal .modal-header {
                padding: 20px 24px;
                background: linear-gradient(180deg, #ffffff, #f8fafc);
            }

            .shipper-detail-modal .modal-body {
                padding: 22px 24px;
            }

            .shipper-modal-products {
                display: grid;
                gap: 12px;
            }

            .shipper-modal-product {
                display: grid;
                grid-template-columns: 92px minmax(0, 1fr) auto;
                gap: 14px;
                align-items: center;
                padding: 12px;
                border: 1px solid #e5e7eb;
                border-radius: 10px;
                background: #ffffff;
            }

            .shipper-modal-product-title {
                margin: 0 0 4px;
                color: #0f172a;
                font-weight: 900;
            }

            .shipper-modal-product-meta {
                color: #64748b;
                font-size: .88rem;
            }

            .shipper-modal-product-money {
                min-width: 150px;
                text-align: right;
            }

            .shipper-modal-product-money strong {
                display: block;
                color: #0f172a;
                font-size: 1rem;
            }

            .shipper-modal-product-money span {
                display: block;
                color: #64748b;
                font-size: .82rem;
            }

            @media (max-width: 991.98px) {
                .dashboard-grid {
                    grid-template-columns: 1fr;
                }

            .profile-card {
                    position: static;
                }

                .detail-summary-grid {
                    grid-template-columns: 1fr;
                }

                .shipper-modal-product {
                    grid-template-columns: 72px minmax(0, 1fr);
                }

                .modal-item-img {
                    width: 72px;
                    height: 72px;
                }

                .shipper-modal-product-money {
                    grid-column: 1 / -1;
                    text-align: left;
                    min-width: 0;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="profile" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Delivery Orders</h1>
                <p>Manage and track orders assigned for delivery.</p>
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
                                <i class="bi bi-truck"></i> ${currentRole}
                            </span>
                        </div>

                        <nav class="profile-menu">
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                            <a class="active" href="${pageContext.request.contextPath}/shipper/orders">
                                <i class="bi bi-box-seam"></i> Delivery Orders
                            </a>
                            <a href="${pageContext.request.contextPath}/change-password">
                                <i class="bi bi-key"></i> Change Password
                            </a>
                            <a href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </nav>
                    </aside>

                    <section class="panel content-panel">
                        <div class="d-flex align-items-end justify-content-between gap-3 flex-wrap">
                            <div>
                                <h2 class="h4 fw-bold mb-1 text-primary">Available Orders</h2>
                                <p class="text-muted mb-0">${availableOrders.size()} orders waiting to be claimed</p>
                            </div>
                            
                            <c:if test="${not empty message}">
                                <div class="alert alert-success py-2 mb-0"><i class="bi bi-check-circle me-2"></i>${message}</div>
                                <c:remove var="message" scope="session"/>
                            </c:if>
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger py-2 mb-0"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
                                <c:remove var="error" scope="session"/>
                            </c:if>
                        </div>
                        
                        <div class="table-panel table-responsive mb-5">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th class="text-nowrap">Customer Info</th>
                                        <th class="text-nowrap">Total Price</th>
                                        <th class="text-nowrap">Payment</th>
                                        <th class="text-nowrap">Status</th>
                                        <th class="text-nowrap">Note</th>
                                        <th class="text-end text-nowrap">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${availableOrders}" var="order">
                                        <tr class="shipper-order-row" data-order-modal="#orderDetailModal${order.id}">
                                            <td>
                                                <div class="fw-bold">${empty order.recipientName ? order.userName : order.recipientName}</div>
                                                <div class="text-muted small"><i class="bi bi-telephone-fill me-1"></i>${empty order.recipientPhone ? order.userPhone : order.recipientPhone}</div>
                                                <div class="text-muted small mt-1"><i class="bi bi-geo-alt-fill me-1"></i>${empty order.deliveryAddress ? 'No address provided' : order.deliveryAddress}</div>
                                            </td>
                                            <td class="text-nowrap fw-bold text-primary">
                                                <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> &#273;
                                            </td>
                                            <td class="text-nowrap">
                                                <span class="payment-pill ${fn:toLowerCase(order.method)}">
                                                    <i class="bi ${fn:toLowerCase(order.method) == 'vnpay' ? 'bi-credit-card' : 'bi-cash-coin'}"></i>
                                                    <c:out value="${order.method}"/>
                                                </span>
                                                <div class="payment-note">
                                                    <c:choose>
                                                        <c:when test="${order.paidAmount gt 0}">Paid</c:when>
                                                        <c:otherwise>Collect on delivery</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                            <td class="text-nowrap">
                                                <span class="badge rounded-pill badge-soft-warning">
                                                    <c:out value="${order.status}"/>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="text-muted small text-wrap" style="max-width: 150px;">
                                                    <c:out value="${empty order.note ? '' : order.note}"/>
                                                </div>
                                            </td>
                                            <td class="text-end text-nowrap">
                                                <form action="${pageContext.request.contextPath}/shipper/orders" method="post" class="m-0 p-0">
                                                    <input type="hidden" name="action" value="claim">
                                                    <input type="hidden" name="orderId" value="${order.id}">
                                                    <button type="submit" class="btn btn-sm btn-primary shadow-sm">
                                                        <i class="bi bi-box-arrow-in-down me-1"></i> Claim Order
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                        <%@ include file="/views/shipper/order-detail-modal.jsp" %>
                                    </c:forEach>
                                    <c:if test="${empty availableOrders}">
                                        <tr>
                                            <td colspan="6" class="text-center py-4 text-muted">No available orders at the moment.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>

                        <div class="d-flex align-items-end justify-content-between gap-3 flex-wrap">
                            <div>
                                <h2 class="h4 fw-bold mb-1">My Assigned Orders</h2>
                                <p class="text-muted mb-0">${orders.size()} orders currently assigned to you</p>
                            </div>
                            
                            <c:if test="${not empty message}">
                                <div class="alert alert-success py-2 mb-0"><i class="bi bi-check-circle me-2"></i>${message}</div>
                                <c:remove var="message" scope="session"/>
                            </c:if>
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger py-2 mb-0"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
                                <c:remove var="error" scope="session"/>
                            </c:if>
                        </div>

                        <div class="table-panel table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th class="text-nowrap">Customer Info</th>
                                        <th class="text-nowrap">Total Price</th>
                                        <th class="text-nowrap">Payment</th>
                                        <th class="text-nowrap">Status</th>
                                        <th class="text-nowrap">Note</th>
                                        <th class="text-end text-nowrap">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${orders}" var="order">
                                        <tr class="shipper-order-row" data-order-modal="#orderDetailModal${order.id}">
                                            <td>
                                                <div class="fw-bold">${empty order.recipientName ? order.userName : order.recipientName}</div>
                                                <div class="text-muted small"><i class="bi bi-telephone-fill me-1"></i>${empty order.recipientPhone ? order.userPhone : order.recipientPhone}</div>
                                                <div class="text-muted small mt-1"><i class="bi bi-geo-alt-fill me-1"></i>${empty order.deliveryAddress ? 'No address provided' : order.deliveryAddress}</div>
                                            </td>
                                            <td class="text-nowrap fw-bold text-primary">
                                                <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> &#273;
                                            </td>
                                            <td class="text-nowrap">
                                                <span class="payment-pill ${fn:toLowerCase(order.method)}">
                                                    <i class="bi ${fn:toLowerCase(order.method) == 'vnpay' ? 'bi-credit-card' : 'bi-cash-coin'}"></i>
                                                    <c:out value="${order.method}"/>
                                                </span>
                                                <div class="payment-note">
                                                    <c:choose>
                                                        <c:when test="${order.paidAmount gt 0}">Paid</c:when>
                                                        <c:otherwise>Collect on delivery</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                            <td class="text-nowrap">
                                                <span class="badge rounded-pill badge-soft-warning">
                                                    <c:out value="${order.status}"/>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="text-muted small text-wrap" style="max-width: 150px;">
                                                    <c:out value="${empty order.note ? '' : order.note}"/>
                                                </div>
                                            </td>
                                            <td class="text-end text-nowrap">
                                                <c:set var="addrLower" value="${fn:toLowerCase(order.deliveryAddress)}" />
                                                <c:set var="isHanoi" value="${fn:contains(addrLower, 'hà nội') or fn:contains(addrLower, 'ha noi')}" />
                                                
                                                <c:if test="${order.status eq 'SHIPPING'}">
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-light border dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                            Actions
                                                        </button>
                                                        <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                                            <c:choose>
                                                                <c:when test="${isHanoi}">
                                                                    <li>
                                                                        <form action="${pageContext.request.contextPath}/shipper/orders" method="post" class="m-0 p-0">
                                                                            <input type="hidden" name="action" value="updateStatus">
                                                                            <input type="hidden" name="orderId" value="${order.id}">
                                                                            <input type="hidden" name="status" value="DELIVERED">
                                                                            <button type="submit" class="dropdown-item text-success">
                                                                                <i class="bi bi-check-circle me-2"></i> Mark as Delivered
                                                                            </button>
                                                                        </form>
                                                                    </li>
                                                                    <li>
                                                                        <form action="${pageContext.request.contextPath}/shipper/orders" method="post" class="m-0 p-0">
                                                                            <input type="hidden" name="action" value="updateStatus">
                                                                            <input type="hidden" name="orderId" value="${order.id}">
                                                                            <input type="hidden" name="status" value="COMPLETED">
                                                                            <button type="submit" class="dropdown-item text-primary">
                                                                                <i class="bi bi-check2-all me-2"></i> Mark as Completed
                                                                            </button>
                                                                        </form>
                                                                    </li>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <li>
                                                                        <button type="button" class="dropdown-item text-warning" data-bs-toggle="modal" data-bs-target="#noteModal${order.id}">
                                                                            <i class="bi bi-pencil-square me-2"></i> Add Note
                                                                        </button>
                                                                    </li>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </ul>
                                                    </div>
                                                </c:if>
                                                
                                                <c:if test="${not isHanoi}">
                                                <!-- Note Modal -->
                                                <div class="modal fade" id="noteModal${order.id}" tabindex="-1" aria-labelledby="noteModalLabel${order.id}" aria-hidden="true">
                                                    <div class="modal-dialog">
                                                        <form action="${pageContext.request.contextPath}/shipper/orders" method="post">
                                                            <div class="modal-content text-start">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title" id="noteModalLabel${order.id}">Add Note for Order #${order.id}</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <p class="small text-muted mb-3">This order is outside Hanoi. Please add a note about the shipping method.</p>
                                                                    <input type="hidden" name="action" value="addNote">
                                                                    <input type="hidden" name="orderId" value="${order.id}">
                                                                    <div class="mb-3">
                                                                        <label for="noteText${order.id}" class="form-label">Note</label>
                                                                        <textarea class="form-control" id="noteText${order.id}" name="note" rows="3" required placeholder="e.g. Sent via Viettel Post..."></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                                    <button type="submit" class="btn btn-warning">Save Note</button>
                                                                </div>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                                </c:if>
                                            </td>
                                        </tr>
                                        <%@ include file="/views/shipper/order-detail-modal.jsp" %>
                                    </c:forEach>
                                    <c:if test="${empty orders}">
                                        <tr>
                                            <td colspan="6" class="text-center py-4 text-muted">No active deliveries at the moment.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.querySelectorAll('[data-order-modal]').forEach(function (row) {
                row.addEventListener('click', function (event) {
                    if (event.target.closest('a, button, input, textarea, select, form, .dropdown-menu')) {
                        return;
                    }
                    var modalSelector = row.getAttribute('data-order-modal');
                    var modalElement = document.querySelector(modalSelector);
                    if (modalElement && window.bootstrap) {
                        bootstrap.Modal.getOrCreateInstance(modalElement).show();
                    }
                });
            });
        </script>
    </body>
</html>
