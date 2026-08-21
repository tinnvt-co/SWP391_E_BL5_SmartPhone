<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Complaints | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/complaint.css">
        <%@include file="../common/head.jsp"%>
    </head>
    <body>
        <c:set var="activePage" value="manager-complaint" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell">
            <div class="page-heading">
                <div>
                    <h1>Customer Complaints</h1>
                    <p>Resolve customer complaints for delivered orders via the chatbox thread.</p>
                </div>
            </div>

            <c:if test="${not empty param.message}">
                <div class="alert success"><c:out value="${param.message}"/></div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert error"><c:out value="${param.error}"/></div>
            </c:if>

            <section class="stats-grid">
                <article><span>OPEN</span><strong>${totalOpen}</strong><i class="amber"></i></article>
                <article><span>RESOLVED</span><strong>${totalResolved}</strong><i class="green"></i></article>
                <article><span>REJECTED</span><strong>${totalRejected}</strong><i class="pink"></i></article>
            </section>

            <section class="table-panel">
                <div class="cancel-tabs">
                    <a class="cancel-tab ${selectedView == 'open' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/manager/complaint?view=open">
                        <i class="bi bi-inbox"></i> Open
                    </a>
                    <a class="cancel-tab ${selectedView == 'closed' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/manager/complaint?view=closed">
                        <i class="bi bi-archive"></i> History
                    </a>
                </div>

                <form class="search-row" method="get">
                    <input type="hidden" name="view" value="${selectedView}">
                    <input name="q" value="<c:out value='${keyword}'/>"
                           placeholder="Search by order id, customer name or username..." maxlength="100">
                    <button class="btn primary">Search</button>
                </form>

                <c:choose>
                    <c:when test="${empty complaints}">
                        <div class="empty-state">
                            <i class="bi bi-inboxes"></i>
                            <p>No complaints to show.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Order</th>
                                    <th>Customer</th>
                                    <th>Category</th>
                                    <th>Status</th>
                                    <th>Messages</th>
                                    <th>Filed</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${complaints}">
                                    <tr>
                                        <td>#${c.id}</td>
                                        <td>
                                            <strong>${c.orderCode}</strong>
                                            <div class="muted small">
                                                <fmt:formatNumber value="${c.orderTotal}" pattern="#,##0"/>₫
                                            </div>
                                        </td>
                                        <td>
                                            <strong>${c.customerName}</strong>
                                            <div class="muted small">@${c.customerUsername}</div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty c.customReason}">
                                                    ${c.displayCategory}
                                                    <div class="muted small">${c.customReason}</div>
                                                </c:when>
                                                <c:otherwise>
                                                    ${c.displayCategory}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="status-pill ${c.status.toLowerCase()}">${c.displayStatus}</span>
                                        </td>
                                        <td>
                                            <span class="message-count-pill">
                                                <i class="bi bi-chat-dots"></i> ${c.messageCount}
                                            </span>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${c.createdAt}" pattern="dd MMM HH:mm"/>
                                        </td>
                                        <td>
                                            <a class="btn primary"
                                               href="${pageContext.request.contextPath}/manager/complaint?id=${c.id}">
                                                <i class="bi bi-eye"></i> Open
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
