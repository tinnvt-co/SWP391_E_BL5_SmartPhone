<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Complaint ${complaint != null ? '#' : ''}#${order.id} | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/complaint.css?v=4">
    </head>
    <body>
        <c:set var="activePage" value="orders" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Order Complaint</h1>
                <p>Tell us what's wrong with order <strong>#${order.id}</strong> and chat with our manager to resolve it.</p>
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
                            <a href="${pageContext.request.contextPath}/order-detail?id=${order.id}">
                                <i class="bi bi-receipt"></i> View order detail
                            </a>
                        </nav>

                        <div class="mt-4 complaint-status-card">
                            <span class="status-pill ${complaint != null ? complaint.status.toLowerCase() : 'open'}">
                                ${complaint != null ? complaint.displayStatus : 'No complaint yet'}
                            </span>
                            <p class="mt-2 mb-0 small text-muted">
                                <c:choose>
                                    <c:when test="${complaint == null}">
                                        You haven't filed a complaint for this order yet.
                                    </c:when>
                                    <c:otherwise>
                                        Complaint filed on
                                        <fmt:formatDate value="${complaint.createdAt}" pattern="dd MMM yyyy HH:mm"/>.
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </aside>

                    <section>
                        <c:if test="${not empty param.message}">
                            <div class="alert success"><c:out value="${param.message}"/></div>
                        </c:if>
                        <c:if test="${not empty param.error}">
                            <div class="alert error"><c:out value="${param.error}"/></div>
                        </c:if>

                        <div class="complaint-panel">
                            <div class="complaint-summary">
                                <div>
                                    <div class="complaint-summary-label">Order</div>
                                    <div class="complaint-summary-value">#${order.id}</div>
                                </div>
                                <div>
                                    <div class="complaint-summary-label">Total</div>
                                    <div class="complaint-summary-value">
                                        <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>₫
                                    </div>
                                </div>
                                <div>
                                    <div class="complaint-summary-label">Status</div>
                                    <div class="complaint-summary-value">
                                        <span class="status-pill ${order.status.toLowerCase()}">${order.status}</span>
                                    </div>
                                </div>
                                <div>
                                    <div class="complaint-summary-label">Delivered to</div>
                                    <div class="complaint-summary-value">${order.recipientName}</div>
                                </div>
                            </div>

                            <c:choose>
                                <c:when test="${empty complaint}">
                                    <div class="complaint-form-wrap">
                                        <%@ include file="/views/common/complaint-order-card.jspf" %>

                                        <h2 class="h5 fw-black mt-4">What happened with your delivery?</h2>
                                        <p class="text-muted small">
                                            Pick the reason that best matches why you didn't receive your order correctly.
                                        </p>
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/customer/complaint"
                                              id="complaintCreateForm">
                                            <input type="hidden" name="action" value="create">
                                            <input type="hidden" name="orderId" value="${order.id}">

                                            <div class="complaint-reasons">
                                                <c:forEach var="cat" items="${complaintCategories}">
                                                    <label class="complaint-reason">
                                                        <input type="radio" name="category" value="${cat}" required>
                                                        <span class="complaint-reason-body">
                                                            <c:choose>
                                                                <c:when test="${cat == 'NOT_RECEIVED'}">
                                                                    <i class="bi bi-truck"></i>
                                                                    <strong>Package never arrived</strong>
                                                                    <small>The shipping carrier has not delivered the package to you.</small>
                                                                </c:when>
                                                                <c:when test="${cat == 'WRONG_ITEM'}">
                                                                    <i class="bi bi-bag-x"></i>
                                                                    <strong>Wrong item delivered</strong>
                                                                    <small>A different product was delivered instead of what you ordered.</small>
                                                                </c:when>
                                                                <c:when test="${cat == 'DAMAGED'}">
                                                                    <i class="bi bi-box-seam"></i>
                                                                    <strong>Damaged on arrival</strong>
                                                                    <small>The package arrived damaged and the product inside is unusable.</small>
                                                                </c:when>
                                                                <c:when test="${cat == 'DEFECTIVE'}">
                                                                    <i class="bi bi-tools"></i>
                                                                    <strong>Defective on arrival</strong>
                                                                    <small>The product arrived but does not power on or work correctly.</small>
                                                                </c:when>
                                                                <c:when test="${cat == 'LATE_DELIVERY'}">
                                                                    <i class="bi bi-clock-history"></i>
                                                                    <strong>Delivery is too late</strong>
                                                                    <small>The package is far past the estimated delivery date.</small>
                                                                </c:when>
                                                                <c:when test="${cat == 'OTHER'}">
                                                                    <i class="bi bi-three-dots"></i>
                                                                    <strong>Other</strong>
                                                                    <small>Tell us your reason below.</small>
                                                                </c:when>
                                                            </c:choose>
                                                        </span>
                                                    </label>
                                                </c:forEach>
                                            </div>

                                            <div class="complaint-field" id="complaintOtherWrap" hidden>
                                                <label for="customReason">Describe your reason</label>
                                                <textarea name="customReason" id="customReason"
                                                          maxlength="500" rows="2"
                                                          placeholder="Short summary (max 500 characters)"></textarea>
                                            </div>

                                            <div class="complaint-form-footer">
                                                <a class="btn btn-light"
                                                   href="${pageContext.request.contextPath}/order-history">
                                                    Cancel
                                                </a>
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="bi bi-send"></i> Submit complaint
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="complaint-thread">
                                        <%@ include file="/views/common/complaint-order-card.jspf" %>

                                        <div class="complaint-thread-header">
                                            <div>
                                                <span class="complaint-category-pill">
                                                    <i class="bi bi-tag"></i>
                                                    <c:choose>
                                                        <c:when test="${not empty complaint.customReason}">
                                                            ${complaint.displayCategory} — ${complaint.customReason}
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${complaint.displayCategory}
                                                        </c:otherwise>
                                                    </c:choose>
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
                                                        No messages yet. Send the first one to start the conversation.
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="m" items="${messages}">
                                                        <div class="chat-msg ${m.fromCustomer ? 'from-customer' : 'from-staff'}">
                                                            <div class="chat-msg-meta">
                                                                <strong>${m.senderName != null ? m.senderName : m.senderRole}</strong>
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
                                                    This conversation is closed.
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/customer/complaint"
                                                      class="chatbox-form"
                                                      id="chatboxForm">
                                                    <input type="hidden" name="action" value="message">
                                                    <input type="hidden" name="complaintId" value="${complaint.id}">
                                                    <textarea name="content" id="chatboxInput"
                                                              maxlength="2000" rows="2"
                                                              placeholder="Reply to the manager..." required></textarea>
                                                    <div class="chatbox-actions">
                                                        <button type="submit" class="btn btn-primary btn-sm">
                                                            <i class="bi bi-send"></i> Send
                                                        </button>
                                                        <button type="submit" form="closeComplaintForm"
                                                                class="btn btn-outline-success btn-sm">
                                                            <i class="bi bi-check2-circle"></i> Mark as resolved
                                                        </button>
                                                    </div>
                                                </form>
                                                <form method="post" id="closeComplaintForm"
                                                      action="${pageContext.request.contextPath}/customer/complaint">
                                                    <input type="hidden" name="action" value="close">
                                                    <input type="hidden" name="complaintId" value="${complaint.id}">
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/complaint-realtime.js"></script>
        <script>
            (function () {
                var form = document.getElementById('complaintCreateForm');
                if (form) {
                    var otherWrap = document.getElementById('complaintOtherWrap');
                    var radios = form.querySelectorAll('input[name="category"]');
                    radios.forEach(function (radio) {
                        radio.addEventListener('change', function () {
                            if (radio.value === 'OTHER' && radio.checked) {
                                otherWrap.hidden = false;
                            } else if (radio.value !== 'OTHER') {
                                otherWrap.hidden = true;
                            }
                        });
                    });
                    form.addEventListener('submit', function (event) {
                        var selected = form.querySelector('input[name="category"]:checked');
                        if (!selected) {
                            event.preventDefault();
                            return;
                        }
                        if (selected.value === 'OTHER') {
                            var text = document.getElementById('customReason').value.trim();
                            if (!text) {
                                event.preventDefault();
                                document.getElementById('customReason').focus();
                            }
                        }
                    });
                }

                var chatbox = document.getElementById('chatbox');
                if (chatbox && window.ComplaintRealtime) {
                    window.ComplaintRealtime.init({
                        complaintId: chatbox.getAttribute('data-complaint-id'),
                        pollUrl: '${pageContext.request.contextPath}/complaint-realtime',
                        scope: 'customer'
                    });
                }
            })();
        </script>
    </body>
</html>
