<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Review your order | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        <style>
            .star-picker {
                display:inline-flex;
                gap:4px;
                font-size:1.8rem;
                color:#e2e8f0;
                line-height:1;
            }
            .star-picker .star {
                cursor:pointer;
                transition:transform .15s;
            }
            .star-picker .star:hover {
                transform:scale(1.1);
            }
            .star-picker .star.active {
                color:#f59e0b;
            }
            .star-picker.readonly .star {
                cursor:default;
            }
            .star-picker.readonly .star:hover {
                transform:none;
            }
            .star-display {
                font-size:1rem;
                color:#f59e0b;
                letter-spacing:1px;
            }

            .review-form .form-control {
                min-height:120px;
                resize:vertical;
            }
            .review-status {
                font-size:.85rem;
                color:#16a34a;
                font-weight:700;
            }
            .review-status.expired {
                color:#b91c1c;
            }
            .review-status.edited {
                color:#0369a1;
            }

            .review-exists {
                background:#f8fafc;
                border:1px solid #e2e8f0;
                border-radius:8px;
                padding:14px;
                margin-bottom:12px;
            }
            .review-exists .review-exists-head {
                display:flex;
                justify-content:space-between;
                align-items:center;
                gap:8px;
                margin-bottom:8px;
            }
            .review-exists .review-exists-content {
                white-space:pre-wrap;
                color:#0f172a;
            }

            .btn-submit {
                background:#16a34a;
                color:#fff;
                border:none;
                padding:10px 22px;
                border-radius:8px;
                font-weight:700;
            }
            .btn-submit:hover {
                background:#15803d;
                color:#fff;
            }
            .btn-danger-link {
                color:#b91c1c;
                background:none;
                border:none;
                font-weight:700;
                cursor:pointer;
            }
            .btn-danger-link:hover {
                text-decoration:underline;
            }

            .review-shell {
                padding:40px 0 64px;
            }
            .review-panel {
                max-width:860px;
                margin:0 auto;
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:16px;
                box-shadow:0 4px 12px rgba(15,23,42,0.06);
                overflow:hidden;
            }
            .review-header {
                padding:24px;
                border-bottom:1px solid #e5e7eb;
            }
            .review-header h1 {
                margin:0;
                font-weight:800;
            }
            .review-header p {
                color:#64748b;
                margin:6px 0 0;
            }
            .review-item {
                padding:24px;
                border-bottom:1px solid #e5e7eb;
            }
            .review-item:last-child {
                border-bottom:none;
            }
            .review-item-head {
                display:flex;
                gap:14px;
                align-items:center;
                margin-bottom:12px;
            }
            .review-item-thumb {
                width:64px;
                height:64px;
                border-radius:8px;
                background:#f8fafc;
                flex:0 0 64px;
                display:flex;
                align-items:center;
                justify-content:center;
                overflow:hidden;
            }
            .review-item-thumb img {
                max-width:100%;
                max-height:100%;
            }
            .review-item-title {
                font-weight:800;
                color:#0f172a;
            }
            .review-item-meta {
                color:#64748b;
                font-size:.85rem;
            }

            .flash-message {
                padding:14px 18px;
                background:#ecfdf5;
                border:1px solid #bbf7d0;
                border-radius:10px;
                color:#166534;
                margin-bottom:18px;
            }
            .flash-message.error {
                background:#fef2f2;
                border-color:#fecaca;
                color:#991b1b;
            }

            @media(max-width:600px){
                .review-item-head {
                    flex-direction:column;
                    align-items:flex-start;
                }
                .review-item-thumb {
                    width:80px;
                    height:80px;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="orders" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="review-shell">
            <div class="container">
                <div class="review-panel">
                    <div class="review-header">
                        <h1><i class="bi bi-star"></i> Review your order #${order.id}</h1>
                        <p>Placed on <fmt:formatDate value="${order.createdAt}" pattern="dd MMM yyyy '&#183;' HH:mm"/>.
                            Rating and content can be edited within <b>15 days</b> of posting.</p>
                        <p style="margin:4px 0 0; font-size:.85rem; color:#475569;">
                            Status: <b>${order.status}</b>
                            &middot; Type: <b>${order.type}</b>
                            &middot; Line items in DB: <b>${lineItemCount}</b>
                            &middot; Items passed to view: <b>${items == null ? 0 : items.size()}</b>
                        </p>
                    </div>

                    <c:if test="${not empty flash}">
                        <div class="review-item">
                            <div class="flash-message ${flash.contains('expired') || flash.contains('characters') ? 'error' : ''}">
                                <c:out value="${flash}"/>
                            </div>
                        </div>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty items}">
                            <div class="review-item" style="text-align:center; color:#64748b;">
                                <i class="bi bi-bag-x" style="font-size:3rem; color:#cbd5e1;"></i>
                                <h4 style="margin:14px 0 4px;">No items to review</h4>
                                <p style="margin:0;">This order does not contain any items eligible for review.</p>
                                <a href="${pageContext.request.contextPath}/order-detail?id=${order.id}" class="btn btn-outline-secondary mt-3">
                                    <i class="bi bi-arrow-left"></i> Back to order
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="it" items="${items}">
                                <c:set var="hasFeedback" value="${not empty it.feedbackId}"/>
                                <c:set var="isFocus" value="${focusVariantId == it.variantId}"/>
                                <c:set var="showForm" value="${!hasFeedback || isFocus}"/>

                                <div class="review-item" id="item-${it.variantId}">
                                    <div class="review-item-head">
                                        <div class="review-item-thumb">
                                            <c:set var="imgSrc" value="${not empty it.variantImage ? it.variantImage : it.productImage}"/>
                                            <c:if test="${not empty imgSrc}">
                                                <img src="${pageContext.request.contextPath}/assets/images/products/${imgSrc}" alt="${it.productName}"
                                                     onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
                                            </c:if>
                                            <c:if test="${empty imgSrc}">
                                                <i class="bi bi-phone" style="font-size:1.6rem; color:#cbd5e1;"></i>
                                            </c:if>
                                        </div>
                                        <div>
                                            <div class="review-item-title">${it.productName}</div>
                                            <div class="review-item-meta">${it.memoryLabel} &middot; ${it.colorName} &middot; x${it.amount}</div>
                                            <c:if test="${hasFeedback}">
                                                <div class="review-status edited mt-1">
                                                    <i class="bi bi-check-circle-fill"></i> Reviewed
                                                    <c:if test="${it.updatedAt != null}">
                                                        &middot; updated <fmt:formatDate value="${it.updatedAt}" pattern="dd MMM yyyy HH:mm"/>
                                                    </c:if>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <c:if test="${hasFeedback}">
                                        <div class="review-exists">
                                            <div class="review-exists-head">
                                                <div>
                                                    <span class="star-display">
                                                        <c:forEach begin="1" end="5" var="s">
                                                            <c:choose>
                                                                <c:when test="${s <= it.rating}">&#9733;</c:when>
                                                                <c:otherwise>&#9734;</c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                    </span>
                                                </div>
                                                <c:set var="reviewAgeDays" value="0"/>
                                                <c:if test="${it.updatedAt != null}">
                                                    <jsp:useBean id="nowBean" class="java.util.Date" scope="page"/>
                                                    <c:set var="diffMs" value="${nowBean.time - it.updatedAt.time}"/>
                                                    <c:set var="reviewAgeDays" value="${diffMs / (1000 * 60 * 60 * 24)}"/>
                                                </c:if>
                                                <c:if test="${reviewAgeDays <= 15}">
                                                    <span class="review-status">
                                                        <i class="bi bi-clock"></i> Edit window: 15 days from posting
                                                    </span>
                                                </c:if>
                                                <c:if test="${reviewAgeDays > 15}">
                                                    <span class="review-status expired">
                                                        <i class="bi bi-lock"></i> Edit window expired
                                                    </span>
                                                </c:if>
                                            </div>
                                            <div class="review-exists-content"><c:out value="${it.content}"/></div>
                                        </div>
                                    </c:if>

                                    <c:choose>
                                        <c:when test="${showForm && (!hasFeedback || reviewAgeDays <= 15)}">
                                            <form class="review-form" method="post" action="${pageContext.request.contextPath}/feedback">
                                                <input type="hidden" name="orderId" value="${order.id}">
                                                <input type="hidden" name="variantId" value="${it.variantId}">
                                                <c:if test="${hasFeedback}">
                                                    <input type="hidden" name="feedbackId" value="${it.feedbackId}">
                                                </c:if>

                                                <div class="mb-3">
                                                    <label class="form-label" style="font-weight:700;">Your rating</label>
                                                    <div class="star-picker" data-star-picker>
                                                        <c:forEach begin="1" end="5" var="s">
                                                            <span class="star ${hasFeedback && s <= it.rating ? 'active' : ''}" data-value="${s}">&#9733;</span>
                                                        </c:forEach>
                                                    </div>
                                                    <input type="hidden" name="rating" value="${hasFeedback ? it.rating : 5}" data-rating-input>
                                                </div>

                                                <div class="mb-3">
                                                    <label class="form-label" style="font-weight:700;" for="content-${it.variantId}">Your review</label>
                                                    <textarea id="content-${it.variantId}" name="content" class="form-control" maxlength="255"
                                                              placeholder="Tell others what you liked or what could be better..."
                                                              ><c:out value="${hasFeedback ? it.content : ''}"/></textarea>
                                                    <div class="form-text">Up to 255 characters.</div>
                                                </div>

                                                <div class="d-flex justify-content-between align-items-center">
                                                    <c:choose>
                                                        <c:when test="${hasFeedback}">
                                                            <div class="review-status">
                                                                <i class="bi bi-clock"></i>
                                                                You can still edit this review.
                                                            </div>
                                                            <button type="submit" class="btn-submit"><i class="bi bi-check2"></i> Save changes</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="review-status">Share your honest experience to help other shoppers.</div>
                                                            <button type="submit" class="btn-submit"><i class="bi bi-send"></i> Submit review</button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </form>
                                        </c:when>
                                        <c:when test="${hasFeedback && reviewAgeDays > 15}">
                                            <div class="review-status expired">
                                                <i class="bi bi-lock"></i> This review can no longer be edited (15-day window has passed).
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/feedback?orderId=${order.id}&variantId=${it.variantId}#item-${it.variantId}"
                                               class="btn btn-outline-primary">
                                                <i class="bi bi-pencil"></i> Edit review
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div style="text-align:center; margin-top:18px;">
                    <a href="${pageContext.request.contextPath}/order-detail?id=${order.id}">
                        <i class="bi bi-arrow-left"></i> Back to order #${order.id}
                    </a>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script>
            document.querySelectorAll('[data-star-picker]').forEach(function (picker) {
                var stars = picker.querySelectorAll('.star');
                var input = picker.parentElement.querySelector('[data-rating-input]');
                function paint(value) {
                    stars.forEach(function (s) {
                        if (parseInt(s.getAttribute('data-value'), 10) <= value) {
                            s.classList.add('active');
                        } else {
                            s.classList.remove('active');
                        }
                    });
                }
                stars.forEach(function (s) {
                    s.addEventListener('mouseenter', function () {
                        paint(parseInt(s.getAttribute('data-value'), 10));
                    });
                    s.addEventListener('mouseleave', function () {
                        paint(parseInt(input.value, 10));
                    });
                    s.addEventListener('click', function () {
                        input.value = s.getAttribute('data-value');
                        paint(parseInt(input.value, 10));
                    });
                });
                paint(parseInt(input.value, 10));
            });
        </script>
    </body>
</html>
