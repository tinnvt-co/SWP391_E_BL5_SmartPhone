<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Inventory Management</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
    </head>
    <body class="inventory-page">
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell">
            <div class="page-heading">
                <div>
                    <h1><i class="bi bi-box-seam"></i> Inventory Management</h1>
                    <p>${stocks.size()} variants tracked · status calculated from Min / Max thresholds</p>
                </div>
            </div>

            <c:if test="${not empty message}">
                <div class="auth-alert success mb-3"><i class="bi bi-check-circle-fill"></i><span><c:out value="${message}"/></span></div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="auth-alert danger mb-3"><i class="bi bi-exclamation-triangle-fill"></i><span><c:out value="${error}"/></span></div>
            </c:if>

            <section class="stats-grid">
                <article class="stat-blue">
                    <span>TOTAL SKU</span>
                    <strong><c:out value="${stats[0]}"/></strong>
                    <i class="bi bi-boxes stat-icon"></i>
                </article>
                <article class="stat-green">
                    <span>IN STOCK</span>
                    <strong><c:out value="${stats[1]}"/></strong>
                    <i class="bi bi-check2-circle stat-icon"></i>
                </article>
                <article class="stat-amber">
                    <span>LOW STOCK</span>
                    <strong><c:out value="${stats[2]}"/></strong>
                    <i class="bi bi-exclamation-triangle stat-icon"></i>
                </article>
                <article class="stat-pink">
                    <span>OUT OF STOCK</span>
                    <strong><c:out value="${stats[3]}"/></strong>
                    <i class="bi bi-x-octagon stat-icon"></i>
                </article>
                <article class="stat-purple">
                    <span>EXCESS INVENTORY</span>
                    <strong><c:out value="${stats[4]}"/></strong>
                    <i class="bi bi-stack stat-icon"></i>
                </article>
            </section>

            <section class="table-panel">
                <form class="search-row" method="get" action="${pageContext.request.contextPath}/manager/inventory">
                    <input name="keyword" value="<c:out value='${keyword}'/>" placeholder="Search by product name, color or brand..." maxlength="100">
                    <select name="status">
                        <option value="" ${empty param.status?'selected':''}>All Status</option>
                        <option value="OK" ${param.status=='OK'?'selected':''}>In Stock</option>
                        <option value="LOW" ${param.status=='LOW'?'selected':''}>Low Stock</option>
                        <option value="OUT" ${param.status=='OUT'?'selected':''}>Out of Stock</option>
                        <option value="EXCESS" ${param.status=='EXCESS'?'selected':''}>Excess Inventory</option>
                    </select>
                    <button class="btn primary" type="submit"><i class="bi bi-search"></i> Search</button>
                </form>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>SKU</th>
                                <th>Product</th>
                                <th>Brand</th>
                                <th class="center">Quantity</th>
                                <th class="center">Min / Max</th>
                                <th class="center">Status</th>
                                <th class="center">Adjust Thresholds</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty stocks}">
                                    <tr><td colspan="7"><div class="empty-state">No inventory items found</div></td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${stocks}" var="s">
                                        <tr>
                                            <td class="mono">
                                                ${s.productName.replaceAll("[^A-Za-z]","").length()>4?s.productName.replaceAll("[^A-Za-z]","").substring(0,4):s.productName.replaceAll("[^A-Za-z]","")}-${s.memoryLabel.replaceAll("[^0-9-]","")}-
                                                <c:choose>
                                                    <c:when test="${s.colorName!=null&&s.colorName.length()>1}">${s.colorName.replaceAll("[^A-Za-z]","").substring(0,2).toUpperCase()}</c:when>
                                                    <c:otherwise>NA</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div>
                                                    <strong><c:out value='${s.productName}'/></strong>
                                                    <small class="text-muted">${s.memoryLabel} · <c:out value='${s.colorName}'/></small>
                                                </div>
                                            </td>
                                            <td><span class="brand-tag"><c:out value='${s.brandName!=null?s.brandName:"-"}'/></span></td>
                                            <td class="center price-small"><strong><c:out value='${s.stock}'/></strong></td>
                                            <td class="center threshold-cell">
                                                <div class="threshold-readout">
                                                    <span class="threshold-min"><i class="bi bi-arrow-down-short"></i><c:out value='${s.minAmount}'/></span>
                                                    <span class="threshold-sep">/</span>
                                                    <span class="threshold-max"><i class="bi bi-arrow-up-short"></i><c:out value='${s.maxAmount}'/></span>
                                                </div>
                                            </td>
                                            <td class="center">
                                                <c:choose>
                                                    <c:when test="${s.stock<=0}">
                                                        <span class="status-pill status-out"><i class="bi bi-x-circle-fill"></i> Out of Stock</span>
                                                    </c:when>
                                                    <c:when test="${s.stock<=s.minAmount}">
                                                        <span class="status-pill status-low"><i class="bi bi-exclamation-triangle-fill"></i> Low Stock</span>
                                                    </c:when>
                                                    <c:when test="${s.maxAmount>0 && s.stock>s.maxAmount}">
                                                        <span class="status-pill status-excess"><i class="bi bi-stack"></i> Excess Inventory</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-pill status-in"><i class="bi bi-check-circle-fill"></i> In Stock</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="center">
                                                <button class="btn threshold-btn" type="button"
                                                        onclick="openThreshold(<c:out value='${s.variantId}'/>, <c:out value='${s.minAmount}'/>, <c:out value='${s.maxAmount}'/>, '<c:out value='${s.productName}'/> - ${s.memoryLabel} - <c:out value='${s.colorName}'/>')">
                                                    <i class="bi bi-sliders"></i> Set Min / Max
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>

        <!-- Adjust Threshold Modal (Min / Max) -->
        <div id="thresholdModal" class="modal-backdrop" style="display:none">
            <form method="post" action="${pageContext.request.contextPath}/manager/inventory" class="modal-card entity-form">
                <h3><i class="bi bi-sliders2"></i> Adjust Min / Max Stock</h3>
                <input type="hidden" name="action" value="updateLimits">
                <input type="hidden" name="variantId" id="thrVariantId">

                <div class="modal-field">
                    <label>Product</label>
                    <div id="thrProduct" class="modal-readout"></div>
                </div>

                <div class="modal-field">
                    <label for="thrMin">Min Stock (Low Stock threshold)</label>
                    <div class="input-with-icon">
                        <i class="bi bi-arrow-down-short"></i>
                        <input type="number" id="thrMin" name="minAmount" min="0" step="1" required>
                    </div>
                    <small class="muted-hint">Status becomes "Low Stock" when quantity &le; this value.</small>
                </div>

                <div class="modal-field">
                    <label for="thrMax">Max Stock (Excess threshold)</label>
                    <div class="input-with-icon">
                        <i class="bi bi-arrow-up-short"></i>
                        <input type="number" id="thrMax" name="maxAmount" min="0" step="1" required>
                    </div>
                    <small class="muted-hint">Status becomes "Excess Inventory" when quantity &gt; this value. Set to 0 to disable.</small>
                </div>

                <div class="threshold-preview" id="thrPreview">
                    <div class="preview-title">Status preview</div>
                    <div class="preview-row">
                        <span class="preview-label">Quantity below min</span>
                        <span class="status-pill status-low"><i class="bi bi-exclamation-triangle-fill"></i> Low Stock</span>
                    </div>
                    <div class="preview-row">
                        <span class="preview-label">Quantity within range</span>
                        <span class="status-pill status-in"><i class="bi bi-check-circle-fill"></i> In Stock</span>
                    </div>
                    <div class="preview-row">
                        <span class="preview-label">Quantity above max</span>
                        <span class="status-pill status-excess"><i class="bi bi-stack"></i> Excess Inventory</span>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn subtle" onclick="closeModals()">Cancel</button>
                    <button type="submit" class="btn primary-action">Save Thresholds</button>
                </div>
            </form>
        </div>

        <script>
            function openThreshold(variantId, minAmount, maxAmount, name) {
                document.getElementById('thrVariantId').value = variantId;
                document.getElementById('thrProduct').textContent = name;
                document.getElementById('thrMin').value = minAmount;
                document.getElementById('thrMax').value = maxAmount;
                document.getElementById('thresholdModal').style.display = 'flex';
            }
            function closeModals() {
                document.getElementById('thresholdModal').style.display = 'none';
            }
            window.onclick = function (e) {
                if (e.target.id === 'thresholdModal') {
                    closeModals();
                }
            };
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    closeModals();
                }
            });
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
