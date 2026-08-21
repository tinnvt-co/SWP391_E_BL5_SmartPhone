<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Complaint #${complaint.id} | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/complaint.css?v=4">
        <%@include file="../common/head.jsp"%>
    </head>
    <body>
        <c:set var="activePage" value="manager-complaint" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell">
            <div class="page-heading">
                <div>
                    <h1>Complaint #${complaint.id}</h1>
                    <p>
                        From <strong>${complaint.customerName}</strong>
                        (${complaint.customerUsername}) about order
                        <a href="${pageContext.request.contextPath}/manager/orders?id=${complaint.transactionId}">
                            ${complaint.orderCode}
                        </a>.
                    </p>
                </div>
                <div>
                    <a class="btn ghost"
                       href="${pageContext.request.contextPath}/manager/complaint?view=open">
                        <i class="bi bi-arrow-left"></i> Back
                    </a>
                </div>
            </div>

            <c:if test="${not empty param.message}">
                <div class="alert success"><c:out value="${param.message}"/></div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert error"><c:out value="${param.error}"/></div>
            </c:if>

            <section class="complaint-detail-grid">
                <div class="complaint-summary-card">
                    <div class="complaint-summary-header">
                        <span class="status-pill ${complaint.status.toLowerCase()}">${complaint.displayStatus}</span>
                        <span class="complaint-category-pill">
                            <i class="bi bi-tag"></i> ${complaint.displayCategory}
                        </span>
                    </div>
                    <dl class="complaint-summary-list">
                        <div><dt>Order</dt><dd>${complaint.orderCode}</dd></div>
                        <div><dt>Customer</dt><dd>${complaint.customerName}</dd></div>
                        <div><dt>Filed</dt>
                            <dd><fmt:formatDate value="${complaint.createdAt}" pattern="dd MMM yyyy HH:mm"/></dd>
                        </div>
                        <c:if test="${not empty complaint.assignedToName}">
                            <div><dt>Assigned to</dt><dd>${complaint.assignedToName}</dd></div>
                        </c:if>
                        <c:if test="${not empty complaint.customReason}">
                            <div><dt>Custom reason</dt><dd>${complaint.customReason}</dd></div>
                        </c:if>
                        <c:if test="${not empty complaint.description}">
                            <div><dt>Description</dt><dd>${complaint.description}</dd></div>
                        </c:if>
                        <c:if test="${complaint.closed && not empty complaint.resolutionNote}">
                            <div><dt>Manager note</dt><dd>${complaint.resolutionNote}</dd></div>
                        </c:if>
                    </dl>

                    <c:choose>
                        <c:when test="${complaint.closed}">
                            <div class="chatbox-closed">
                                <i class="bi bi-lock"></i>
                                The thread is closed.
                            </div>
                        </c:when>
                    </c:choose>
                </div>

                <div class="complaint-thread">
                    <%@ include file="/views/common/complaint-order-card.jspf" %>

                    <div class="complaint-thread-header">
                        <div>
                            <span class="complaint-category-pill">
                                <i class="bi bi-tag"></i> ${complaint.displayCategory}
                                <c:if test="${not empty complaint.customReason}">
                                    — ${complaint.customReason}
                                </c:if>
                            </span>
                        </div>
                        <div class="complaint-thread-meta">
                            <c:if test="${complaint.closed}">
                                <span class="complaint-closed-pill">
                                    <i class="bi bi-lock-fill"></i>
                                    Closed
                                </span>
                            </c:if>
                        </div>
                    </div>

                    <div class="chatbox" id="chatbox" data-complaint-id="${complaint.id}">
                        <c:choose>
                            <c:when test="${empty messages}">
                                <div class="chatbox-empty">
                                    <i class="bi bi-chat-square-dots"></i>
                                    No messages yet.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="m" items="${messages}">
                                    <div class="chat-msg ${m.fromCustomer ? 'from-customer' : 'from-staff'}">
                                        <div class="chat-msg-meta">
                                            <strong>${m.senderName != null ? m.senderName : m.senderRole}</strong>
                                            <span class="chat-msg-role">${m.senderRole}</span>
                                            <small>
                                                <fmt:formatDate value="${m.createdAt}" pattern="dd MMM HH:mm"/>
                                            </small>
                                        </div>
                                        <div class="chat-msg-body">
                                            <c:out value="${m.content}"/>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <c:choose>
                        <c:when test="${complaint.closed}">
                            <div class="chatbox-closed">
                                <i class="bi bi-lock"></i>
                                The thread is closed.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/manager/complaint"
                                  class="chatbox-form"
                                  id="chatboxForm">
                                <input type="hidden" name="action" value="reply">
                                <input type="hidden" name="complaintId" value="${complaint.id}">
                                <textarea name="content" id="chatboxInput"
                                          maxlength="2000" rows="3"
                                          placeholder="Reply to the customer..." required></textarea>
                                <div class="chatbox-actions">
                                    <button type="submit" class="btn primary">
                                        <i class="bi bi-send"></i> Send reply
                                    </button>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/complaint-realtime.js"></script>
        <script>
            (function () {
                var chatbox = document.getElementById('chatbox');
                if (chatbox && window.ComplaintRealtime) {
                    window.ComplaintRealtime.init({
                        complaintId: chatbox.getAttribute('data-complaint-id'),
                        pollUrl: '${pageContext.request.contextPath}/complaint-realtime',
                        scope: 'manager'
                    });
                }
            })();
        </script>
    </body>
</html>
