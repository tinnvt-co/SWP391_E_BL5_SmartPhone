<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Cancel Requests</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
        <%@include file="../common/head.jsp"%>
    </head>
    <body>
        <c:set var="activePage" value="staff-cancel-request" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>
        <main class="page-shell">
            <div class="page-heading">
                <div>
                    <h1>Cancel Order Requests</h1>
                    <p>Review and approve / reject customer cancellation requests.</p>
                </div>
            </div>

            <c:if test="${not empty param.message}">
                <div class="alert success">
                    <c:out value="${param.message}"/>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert error">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>

            <section class="stats-grid">
                <article><span>PENDING</span><strong>${totalPending}</strong><i class="amber"></i></article>
                <article><span>APPROVED</span><strong>${totalApproved}</strong><i class="green"></i></article>
                <article><span>REJECTED</span><strong>${totalRejected}</strong><i class="pink"></i></article>
            </section>

            <section class="table-panel">
                <div class="cancel-tabs">
                    <a class="cancel-tab ${selectedView == 'pending' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/staff/cancel-request?view=pending">
                        <i class="bi bi-clock-history"></i> Pending
                    </a>
                    <a class="cancel-tab ${selectedView == 'history' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/staff/cancel-request?view=history">
                        <i class="bi bi-archive"></i> History
                    </a>
                </div>

                <form class="search-row" method="get">
                    <input type="hidden" name="view" value="${selectedView}">
                    <input name="q" value="<c:out value='${keyword}'/>" placeholder="Search by order id, customer name or username..." maxlength="100">
                    <select name="sort">
                        <option value="newest" ${selectedSort == 'newest' ? 'selected' : ''}>Newest first</option>
                        <option value="oldest" ${selectedSort == 'oldest' ? 'selected' : ''}>Oldest first</option>
                    </select>
                    <button class="btn primary">Search</button>
                </form>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Request</th>
                                <th>Order</th>
                                <th>Customer</th>
                                <th>Reason</th>
                                <th>Submitted</th>
                                <th>Status</th>
                                <c:if test="${selectedView == 'history'}">
                                    <th>Processed by</th>
                                </c:if>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requests}" var="r">
                                <tr>
                                    <td class="mono">#${r.id}</td>
                                    <td>
                                        <a class="mono" href="${pageContext.request.contextPath}/staff/orders?action=detail&id=${r.transactionId}">
                                            ORD${r.transactionId}
                                        </a>
                                    </td>
                                    <td>
                                        <div class="order-customer">
                                            <span class="order-customer-avatar">
                                                <c:choose>
                                                    <c:when test="${not empty r.processedByName}">${r.processedByName.substring(0,1).toUpperCase()}</c:when>
                                                    <c:otherwise>?</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <div class="order-customer-info">
                                                <strong>Customer #${r.userId}</strong>
                                                <small>Request #${r.id}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <c:set var="reasonLabel" value="${r.reason}"/>
                                        <c:choose>
                                            <c:when test="${r.reason == 'CHANGED_MIND'}">Changed my mind</c:when>
                                            <c:when test="${r.reason == 'WRONG_PRODUCT'}">Ordered wrong product</c:when>
                                            <c:when test="${r.reason == 'FOUND_CHEAPER'}">Found a cheaper price</c:when>
                                            <c:when test="${r.reason == 'LONG_DELIVERY'}">Delivery takes too long</c:when>
                                            <c:when test="${r.reason == 'OTHER'}">Other</c:when>
                                            <c:otherwise>${r.reason}</c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty r.customReason}">
                                            <div class="cancel-reason-custom">"${r.customReason}"</div>
                                        </c:if>
                                    </td>
                                    <td><small style="font-family:monospace;color:var(--muted)"><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/></small></td>
                                    <td>
                                        <span class="status-pill ${r.status.toLowerCase()}">${r.status}</span>
                                    </td>
                                    <c:if test="${selectedView == 'history'}">
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty r.processedByName}">
                                                    <strong>${r.processedByName}</strong>
                                                    <div><small style="color:var(--muted)"><fmt:formatDate value="${r.processedAt}" pattern="dd/MM/yyyy HH:mm"/></small></div>
                                                </c:when>
                                                <c:otherwise>--</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </c:if>
                                    <td>
                                        <div class="actions order-actions">
                                            <c:choose>
                                                <c:when test="${r.status == 'PENDING'}">
                                                    <button type="button" class="btn primary"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#approveCancelModal"
                                                            data-request-id="${r.id}"
                                                            data-request-code="REQ#${r.id}"
                                                            data-action="approve">
                                                        <i class="bi bi-check-circle"></i> Approve
                                                    </button>
                                                    <button type="button" class="btn subtle"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#rejectCancelModal"
                                                            data-request-id="${r.id}"
                                                            data-request-code="REQ#${r.id}"
                                                            data-action="reject">
                                                        <i class="bi bi-x-circle"></i> Reject
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:if test="${not empty r.staffNote}">
                                                        <span class="staff-note-pill" title="${r.staffNote}">
                                                            <i class="bi bi-chat-left-text"></i> Note
                                                        </span>
                                                    </c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <c:if test="${empty requests}">
                    <div class="order-empty">
                        <h2>No cancel requests</h2>
                        <p>There are no ${selectedView == 'history' ? 'processed' : 'pending'} cancel requests at the moment.</p>
                    </div>
                </c:if>
            </section>
        </main>

        <div class="modal fade" id="approveCancelModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <form method="post" action="${pageContext.request.contextPath}/staff/cancel-request">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="bi bi-check-circle"></i> Approve cancellation</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <p>Approve cancellation for <strong id="approveModalCode">--</strong>?</p>
                            <p class="text-muted small">The order status will be moved to <strong>CANCELLED</strong>.</p>
                            <label class="form-label" for="approveStaffNote">Internal note (optional)</label>
                            <textarea class="form-control" name="staffNote" id="approveStaffNote" maxlength="500" rows="3"
                                      placeholder="Optional note for the customer / internal record"></textarea>
                            <input type="hidden" name="action" value="approve">
                            <input type="hidden" name="id" id="approveModalId" value="">
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-success">
                                <i class="bi bi-check-circle"></i> Confirm approval
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="modal fade" id="rejectCancelModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <form method="post" action="${pageContext.request.contextPath}/staff/cancel-request">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="bi bi-x-circle"></i> Reject cancellation</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <p>Reject cancellation for <strong id="rejectModalCode">--</strong>?</p>
                            <p class="text-muted small">The order status will return to <strong>PENDING</strong> for further review.</p>
                            <label class="form-label" for="rejectStaffNote">Reason for rejection (optional)</label>
                            <textarea class="form-control" name="staffNote" id="rejectStaffNote" maxlength="500" rows="3"
                                      placeholder="Optional reason / note for the customer"></textarea>
                            <input type="hidden" name="action" value="reject">
                            <input type="hidden" name="id" id="rejectModalId" value="">
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-danger">
                                <i class="bi bi-x-circle"></i> Confirm reject
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (function () {
                function wireUp(modalId, codeId, idId) {
                    var modal = document.getElementById(modalId);
                    if (!modal) return;
                    modal.addEventListener('show.bs.modal', function (event) {
                        var button = event.relatedTarget;
                        if (!button) return;
                        document.getElementById(codeId).textContent = button.getAttribute('data-request-code') || '';
                        document.getElementById(idId).value = button.getAttribute('data-request-id') || '';
                    });
                }
                wireUp('approveCancelModal', 'approveModalCode', 'approveModalId');
                wireUp('rejectCancelModal', 'rejectModalCode', 'rejectModalId');
            })();
        </script>
    </body>
</html>
