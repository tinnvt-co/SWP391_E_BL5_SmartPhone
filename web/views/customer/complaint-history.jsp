<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>My Complaints | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/complaint.css">
    </head>
    <body>
        <c:set var="activePage" value="orders" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>My Complaints</h1>
                <p>All complaints you've filed against your orders.</p>
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

                        <nav class="profile-menu mt-4">
                            <a href="${pageContext.request.contextPath}/order-history">
                                <i class="bi bi-arrow-left"></i> Back to orders
                            </a>
                            <a class="active" href="${pageContext.request.contextPath}/customer/complaint">
                                <i class="bi bi-flag"></i> All complaints
                            </a>
                        </nav>
                    </aside>

                    <section>
                        <c:if test="${not empty param.message}">
                            <div class="alert success"><c:out value="${param.message}"/></div>
                        </c:if>
                        <c:if test="${not empty param.error}">
                            <div class="alert error"><c:out value="${param.error}"/></div>
                        </c:if>

                        <div class="complaint-panel">
                            <c:choose>
                                <c:when test="${empty complaints}">
                                    <div class="empty-state">
                                        <i class="bi bi-inboxes"></i>
                                        <p>You haven't filed any complaints yet.</p>
                                        <a class="btn btn-primary"
                                           href="${pageContext.request.contextPath}/order-history">
                                            View your orders
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table class="data-table">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Order</th>
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
                                                    <td>${c.messageCount}</td>
                                                    <td>
                                                        <fmt:formatDate value="${c.createdAt}" pattern="dd MMM yyyy HH:mm"/>
                                                    </td>
                                                    <td>
                                                        <a class="btn primary"
                                                           href="${pageContext.request.contextPath}/customer/complaint?orderId=${c.transactionId}">
                                                            <i class="bi bi-eye"></i> Open
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
