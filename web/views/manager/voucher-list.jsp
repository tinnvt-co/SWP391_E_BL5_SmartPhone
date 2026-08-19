<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Voucher Management - Admin</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            .status-badge {
                padding: 0.25rem 0.6rem;
                border-radius: 50rem;
                font-size: 0.85rem;
                font-weight: 500;
            }
            .status-active { background-color: #d1e7dd; color: #0f5132; }
            .status-inactive { background-color: #f8d7da; color: #842029; }
            .voucher-code {
                font-family: monospace;
                background-color: #f8f9fa;
                padding: 2px 6px;
                border-radius: 4px;
                border: 1px dashed #dee2e6;
                font-weight: bold;
                letter-spacing: 1px;
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>
        
        <main class="page-shell">
            <div class="page-heading">
                <div>
                    <h1>Voucher Management</h1>
                    <p>Manage all discount vouchers and campaigns</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Back to dashboard</a>
                    <button class="btn primary large" data-bs-toggle="modal" data-bs-target="#createVoucherModal">
                        + Create Voucher
                    </button>
                </div>
            </div>

            <c:if test="${not empty sessionScope.message}">
                <div class="alert success"><c:out value="${sessionScope.message}"/></div>
                <c:remove var="message" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert error"><c:out value="${sessionScope.error}"/></div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <section class="table-panel">
                <form class="search-row" action="${pageContext.request.contextPath}/manager/vouchers" method="get">
                    <input type="text" name="search" placeholder="Search by Voucher Code..." value="${param.search}">
                    <button type="submit" class="btn primary search-submit">Search</button>
                </form>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Discount Details</th>
                                <th>Conditions</th>
                                <th>Usage</th>
                                <th>Validity Period</th>
                                <th>Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${vouchers}">
                                <tr>
                                    <td><span class="voucher-code"><c:out value="${v.code}"/></span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${v.discountType == 'PERCENTAGE'}">
                                                <strong class="text-danger"><fmt:formatNumber value="${v.value}" pattern="#,##0"/>%</strong>
                                                <c:if test="${not empty v.maxDiscount}">
                                                    <br><small class="text-muted">Max: <fmt:formatNumber value="${v.maxDiscount}" pattern="#,##0"/> đ</small>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <strong class="text-danger"><fmt:formatNumber value="${v.value}" pattern="#,##0"/> đ</strong>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${not empty v.minOrderValue}">
                                            Min order: <fmt:formatNumber value="${v.minOrderValue}" pattern="#,##0"/> đ
                                        </c:if>
                                        <c:if test="${empty v.minOrderValue}">
                                            <span class="text-muted">No minimum</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        ${v.usedCount} 
                                        <c:if test="${not empty v.usageLimit}">
                                            / ${v.usageLimit}
                                        </c:if>
                                    </td>
                                    <td>
                                        <div><small class="text-muted">Start:</small> <fmt:formatDate value="${v.startDate}" pattern="dd/MM/yyyy HH:mm"/></div>
                                        <div><small class="text-muted">End:</small> <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy HH:mm"/></div>
                                    </td>
                                    <td>
                                        <span class="status-badge ${v.status == 'ACTIVE' ? 'status-active' : 'status-inactive'}">
                                            <c:out value="${v.status}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="actions justify-content-end">
                                            <button class="btn subtle" data-bs-toggle="modal" data-bs-target="#editModal${v.id}">
                                                Edit
                                            </button>
                                            
                                            <c:if test="${v.status == 'ACTIVE'}">
                                                <form action="${pageContext.request.contextPath}/manager/vouchers" method="post" class="d-inline">
                                                    <input type="hidden" name="action" value="toggleStatus">
                                                    <input type="hidden" name="id" value="${v.id}">
                                                    <input type="hidden" name="status" value="INACTIVE">
                                                    <button type="submit" class="btn danger" onclick="return confirm('Deactivate this voucher?')">
                                                        Deactivate
                                                    </button>
                                                </form>
                                            </c:if>
                                            <c:if test="${v.status == 'INACTIVE'}">
                                                <form action="${pageContext.request.contextPath}/manager/vouchers" method="post" class="d-inline">
                                                    <input type="hidden" name="action" value="toggleStatus">
                                                    <input type="hidden" name="id" value="${v.id}">
                                                    <input type="hidden" name="status" value="ACTIVE">
                                                    <button type="submit" class="btn primary" onclick="return confirm('Activate this voucher?')">
                                                        Activate
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                                
                                <!-- Edit Modal -->
                                <div class="modal fade" id="editModal${v.id}" tabindex="-1" aria-labelledby="editModalLabel${v.id}" aria-hidden="true">
                                    <div class="modal-dialog">
                                        <form action="${pageContext.request.contextPath}/manager/vouchers" method="post" class="modal-content">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="id" value="${v.id}">
                                            
                                            <div class="modal-header">
                                                <h5 class="modal-title" id="editModalLabel${v.id}">Edit Voucher #${v.id}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="mb-3">
                                                    <label class="form-label">Voucher Code <span class="text-danger">*</span></label>
                                                    <input type="text" class="form-control" name="code" value="${v.code}" required style="text-transform: uppercase;">
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Discount Type <span class="text-danger">*</span></label>
                                                        <select class="form-select" name="discountType" required onchange="toggleMaxDiscount(this, 'editMaxDiscount${v.id}')">
                                                            <option value="FIXED_AMOUNT" ${v.discountType == 'FIXED_AMOUNT' ? 'selected' : ''}>Fixed Amount (đ)</option>
                                                            <option value="PERCENTAGE" ${v.discountType == 'PERCENTAGE' ? 'selected' : ''}>Percentage (%)</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Value <span class="text-danger">*</span></label>
                                                        <input type="number" class="form-control" name="value" step="0.01" min="0" value="${v.value}" required>
                                                    </div>
                                                </div>
                                                <div class="mb-3" id="editMaxDiscount${v.id}" style="display: ${v.discountType == 'PERCENTAGE' ? 'block' : 'none'};">
                                                    <label class="form-label">Max Discount Amount (Optional)</label>
                                                    <input type="number" class="form-control" name="maxDiscount" step="0.01" min="0" value="${v.maxDiscount}">
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Min Order Value (Optional)</label>
                                                        <input type="number" class="form-control" name="minOrderValue" step="0.01" min="0" value="${v.minOrderValue}">
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Usage Limit (Optional)</label>
                                                        <input type="number" class="form-control" name="usageLimit" min="1" value="${v.usageLimit}">
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Start Date <span class="text-danger">*</span></label>
                                                        <input type="datetime-local" class="form-control" name="startDate" value="${fn:replace(v.startDate, ' ', 'T')}" required>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">End Date <span class="text-danger">*</span></label>
                                                        <input type="datetime-local" class="form-control" name="endDate" value="${fn:replace(v.endDate, ' ', 'T')}" required>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn subtle" data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn primary">Save Changes</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty vouchers}">
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">
                                        <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                        No vouchers found.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>

        <!-- Create Voucher Modal -->
        <div class="modal fade" id="createVoucherModal" tabindex="-1" aria-labelledby="createVoucherModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <form action="${pageContext.request.contextPath}/manager/vouchers" method="post" class="modal-content">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-header">
                        <h5 class="modal-title" id="createVoucherModalLabel">Create New Voucher</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Voucher Code <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="code" required style="text-transform: uppercase;" placeholder="e.g. SUMMER2026">
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Discount Type <span class="text-danger">*</span></label>
                                <select class="form-select" name="discountType" required onchange="toggleMaxDiscount(this, 'createMaxDiscount')">
                                    <option value="FIXED_AMOUNT">Fixed Amount (đ)</option>
                                    <option value="PERCENTAGE">Percentage (%)</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Value <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" name="value" step="0.01" min="0" required placeholder="10000 or 10">
                            </div>
                        </div>
                        <div class="mb-3" id="createMaxDiscount" style="display: none;">
                            <label class="form-label">Max Discount Amount (Optional)</label>
                            <input type="number" class="form-control" name="maxDiscount" step="0.01" min="0" placeholder="Limit for percentage discount">
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Min Order Value (Optional)</label>
                                <input type="number" class="form-control" name="minOrderValue" step="0.01" min="0" placeholder="e.g. 1000000">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Usage Limit (Optional)</label>
                                <input type="number" class="form-control" name="usageLimit" min="1" placeholder="Total available">
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Start Date <span class="text-danger">*</span></label>
                                <input type="datetime-local" class="form-control" name="startDate" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">End Date <span class="text-danger">*</span></label>
                                <input type="datetime-local" class="form-control" name="endDate" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn subtle" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn primary">Create Voucher</button>
                    </div>
                </form>
            </div>
        </div>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            function toggleMaxDiscount(selectElem, targetId) {
                const target = document.getElementById(targetId);
                if (selectElem.value === 'PERCENTAGE') {
                    target.style.display = 'block';
                } else {
                    target.style.display = 'none';
                }
            }
        </script>
    </body>
</html>
