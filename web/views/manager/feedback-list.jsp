<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Customer reviews | Manager | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
        <style>
            body {
                background:#f6f8fb;
                color:#111827;
            }
            .review-shell {
                padding:32px 0 70px;
            }
            .review-panel {
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                padding:24px;
                margin-bottom:18px;
            }
            .review-title {
                font-weight:900;
                margin:0 0 4px;
            }
            .review-sub {
                color:#64748b;
                font-size:.9rem;
            }
            .review-toolbar {
                display:flex;
                gap:8px;
                flex-wrap:wrap;
                align-items:center;
            }
            .review-toolbar .form-select, .review-toolbar .form-control {
                min-width:180px;
            }
            .review-table {
                width:100%;
                border-collapse:collapse;
            }
            .review-table th, .review-table td {
                padding:12px 10px;
                border-bottom:1px solid #eef2f7;
                vertical-align:top;
                font-size:.92rem;
            }
            .review-table th {
                background:#f8fafc;
                color:#475569;
                font-weight:700;
                font-size:.78rem;
                text-transform:uppercase;
                letter-spacing:.4px;
                text-align:left;
            }
            .review-table tr:last-child td {
                border-bottom:none;
            }
            .badge-rating {
                display:inline-block;
                padding:3px 9px;
                background:#fef3c7;
                color:#92400e;
                border-radius:999px;
                font-weight:800;
                font-size:.78rem;
            }
            .badge-status {
                padding:3px 9px;
                border-radius:999px;
                font-weight:700;
                font-size:.72rem;
            }
            .badge-status.answered {
                background:#dcfce7;
                color:#166534;
            }
            .badge-status.unanswered {
                background:#fee2e2;
                color:#991b1b;
            }
            .badge-status.pending-update {
                background:#e0f2fe;
                color:#075985;
            }
            .badge-status.ready-reply {
                background:#fef3c7;
                color:#92400e;
            }
            .review-content {
                color:#0f172a;
                white-space:pre-wrap;
                max-width:420px;
            }
            .review-actions a {
                color:#1665d8;
                text-decoration:none;
                font-weight:700;
            }
            .review-actions a:hover {
                text-decoration:underline;
            }

            .thread {
                background:#fff;
                border:1px solid rgba(15,23,42,.08);
                border-radius:8px;
                box-shadow:0 18px 45px rgba(15,23,42,.08);
                padding:24px;
            }
            .thread h2 {
                margin:0 0 6px;
                font-weight:900;
            }
            .thread-meta {
                color:#64748b;
                font-size:.9rem;
                margin-bottom:18px;
            }
            .thread-bubble {
                border:1px solid #e2e8f0;
                border-radius:10px;
                padding:14px 16px;
                margin-bottom:14px;
                background:#f8fafc;
            }
            .thread-bubble.manager {
                background:#eef2ff;
                border-color:#c7d2fe;
            }
            .thread-bubble-head {
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                gap:8px;
                margin-bottom:6px;
            }
            .thread-bubble-author {
                font-weight:800;
                color:#0f172a;
            }
            .thread-bubble-role {
                font-size:.72rem;
                text-transform:uppercase;
                letter-spacing:.4px;
                color:#475569;
                margin-left:6px;
            }
            .thread-bubble-time {
                color:#64748b;
                font-size:.8rem;
            }
            .thread-bubble-content {
                white-space:pre-wrap;
                color:#0f172a;
            }
            .flash-message {
                padding:12px 14px;
                background:#ecfdf5;
                border:1px solid #bbf7d0;
                border-radius:8px;
                color:#166534;
                margin-bottom:14px;
            }
            .flash-message.error {
                background:#fef2f2;
                border-color:#fecaca;
                color:#991b1b;
            }

            @media(max-width:760px){
                .review-table thead {
                    display:none;
                }
                .review-table, .review-table tbody, .review-table tr, .review-table td {
                    display:block;
                    width:100%;
                }
                .review-table tr {
                    padding:12px 0;
                }
                .review-table td {
                    padding:6px 0;
                    border:none;
                }
                .review-content {
                    max-width:none;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="feedback" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="review-shell">
            <div class="container">

                <c:choose>
                    <c:when test="${not empty item}">
                        <div class="review-panel">
                            <h1 class="review-title"><i class="bi bi-chat-square-quote"></i> Review thread</h1>
                            <p class="review-sub">Reading and replying to one customer review.</p>
                            <a href="${pageContext.request.contextPath}/manager/feedback" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-arrow-left"></i> Back to queue
                            </a>
                        </div>

                        <c:if test="${not empty param.flash}">
                            <div class="flash-message ${param.flash.contains('characters') ? 'error' : ''}">
                                <c:out value="${param.flash}"/>
                            </div>
                        </c:if>

                        <div class="thread">
                            <h2>${item.feedback.productName}</h2>
                            <div class="thread-meta">
                                <c:out value="${item.feedback.variantLabel}"/> &middot;
                                Order #${item.feedback.transactionId} &middot;
                                Posted <fmt:formatDate value="${item.feedback.createdAt}" pattern="dd MMM yyyy HH:mm"/>
                                <c:if test="${item.feedback.edited}">
                                    &middot; edited <fmt:formatDate value="${item.feedback.updatedAt}" pattern="dd MMM yyyy HH:mm"/>
                                </c:if>
                            </div>

                            <div class="thread-bubble">
                                <div class="thread-bubble-head">
                                    <div>
                                        <span class="thread-bubble-author"><c:out value="${item.feedback.userName}"/></span>
                                        <span class="thread-bubble-role">Customer</span>
                                        <span class="badge-rating ms-2">${item.feedback.rating}/5</span>
                                    </div>
                                    <div class="thread-bubble-time">
                                        <fmt:formatDate value="${item.feedback.createdAt}" pattern="dd MMM yyyy HH:mm"/>
                                    </div>
                                </div>
                                <div class="thread-bubble-content"><c:out value="${item.feedback.content}"/></div>
                            </div>

                            <c:forEach var="r" items="${item.replies}">
                                <div class="thread-bubble ${r.manager ? 'manager' : ''}">
                                    <div class="thread-bubble-head">
                                        <div>
                                            <span class="thread-bubble-author"><c:out value="${r.userName}"/></span>
                                            <span class="thread-bubble-role">${r.manager ? 'Manager' : 'Customer'}</span>
                                        </div>
                                        <div class="thread-bubble-time">
                                            <fmt:formatDate value="${r.createdAt}" pattern="dd MMM yyyy HH:mm"/>
                                            <c:if test="${r.edited}">
                                                (edited <fmt:formatDate value="${r.updatedAt}" pattern="dd MMM HH:mm"/>)
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="thread-bubble-content"><c:out value="${r.content}"/></div>
                                </div>
                            </c:forEach>

                            <c:choose>
                                <c:when test="${item.feedback.managerReplyAllowed}">
                                    <form method="post" action="${pageContext.request.contextPath}/manager/feedback" class="mt-3">
                                        <input type="hidden" name="action" value="reply">
                                        <input type="hidden" name="id" value="${item.feedback.id}">
                                        <label class="form-label" style="font-weight:700;">Reply as manager</label>
                                        <textarea name="content" class="form-control" maxlength="255" minlength="3" required
                                                  placeholder="Thank the customer, address concerns, share follow-up next steps..."></textarea>
                                        <div class="form-text">Up to 255 characters. Manager can reply only after the customer updates this review.</div>
                                        <div class="d-flex justify-content-end mt-3">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="bi bi-send"></i> Post reply
                                            </button>
                                        </div>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-info mt-3 mb-0">
                                        <i class="bi bi-info-circle"></i>
                                        Manager reply is available only after the customer updates this review.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="review-panel">
                            <h1 class="review-title"><i class="bi bi-chat-square-quote"></i> Customer reviews</h1>
                            <p class="review-sub">Read every customer review and respond to keep trust high.</p>

                            <form method="get" action="${pageContext.request.contextPath}/manager/feedback" class="review-toolbar mt-3">
                                <input type="text" name="keyword" class="form-control" placeholder="Search product, customer, content"
                                       value="<c:out value='${filter.keyword}'/>">
                                <select name="rating" class="form-select">
                                    <option value="">All ratings</option>
                                    <c:forEach begin="1" end="5" var="r">
                                        <option value="${r}" ${filter.rating == r ? 'selected' : ''}>${r} star<c:if test="${r > 1}">s</c:if></option>
                                    </c:forEach>
                                </select>
                                <select name="onlyUnanswered" class="form-select">
                                    <option value="" ${empty filter.onlyUnanswered ? 'selected' : ''}>All reviews</option>
                                    <option value="1" ${filter.onlyUnanswered == '1' ? 'selected' : ''}>Unanswered only</option>
                                </select>
                                <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Filter</button>
                                <a href="${pageContext.request.contextPath}/manager/feedback" class="btn btn-outline-secondary">Reset</a>
                            </form>
                        </div>

                        <div class="review-panel">
                            <c:choose>
                                <c:when test="${empty reviews}">
                                    <div style="text-align:center; padding:40px 20px; color:#64748b;">
                                        <i class="bi bi-inbox" style="font-size:3rem; color:#cbd5e1;"></i>
                                        <h4 style="margin:12px 0 4px; font-weight:900;">No reviews match</h4>
                                        <p style="margin:0;">Try clearing the filters or check back after customers leave new reviews.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table class="review-table">
                                        <thead>
                                            <tr>
                                                <th>Product</th>
                                                <th>Customer</th>
                                                <th>Rating</th>
                                                <th>Content</th>
                                                <th>Replies</th>
                                                <th>Posted</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="rv" items="${reviews}">
                                                <tr>
                                                    <td>
                                                        <div style="font-weight:800; color:#0f172a;">${rv.productName}</div>
                                                        <div style="color:#64748b; font-size:.82rem;">${rv.variantLabel}</div>
                                                    </td>
                                                    <td><c:out value="${rv.userName}"/></td>
                                                    <td><span class="badge-rating">${rv.rating}/5</span></td>
                                                    <td><div class="review-content"><c:out value="${rv.content}"/></div></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${rv.managerReplyAllowed}">
                                                                <span class="badge-status ready-reply">Ready to reply</span>
                                                            </c:when>
                                                            <c:when test="${rv.replyCount > 0}">
                                                                <span class="badge-status answered">${rv.replyCount} reply<c:if test="${rv.replyCount > 1}">s</c:if></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-status pending-update">Waiting update</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${rv.createdAt}" pattern="dd MMM yyyy"/>
                                                        <div style="color:#64748b; font-size:.82rem;"><fmt:formatDate value="${rv.createdAt}" pattern="HH:mm"/></div>
                                                    </td>
                                                    <td class="review-actions">
                                                        <a href="${pageContext.request.contextPath}/manager/feedback?action=view&id=${rv.id}">
                                                            <i class="bi bi-reply"></i> Open
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:otherwise>
                </c:choose>

            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
    </body>
</html>
