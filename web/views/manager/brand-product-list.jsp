<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title><c:out value="${selectedBrand.name}"/> Products</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell">
            <div class="page-heading">
                <div>
                    <h1><c:out value="${selectedBrand.name}"/> Products</h1>
                    <p>${totalProducts} products belong to this brand</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager/brands">← Back to Brand Management</a>
                    <button class="btn primary large" type="button"
                            data-open-brand-product-modal
                            ${!selectedBrand.active ? 'disabled' : ''}>
                        Move Products to This Brand
                    </button>
                </div>
            </div>

            <c:if test="${not empty param.message}">
                <div class="alert success"><c:out value="${param.message}"/></div>
            </c:if>
            <c:if test="${!selectedBrand.active}">
                <div class="alert error">Activate this brand before moving products to it.</div>
            </c:if>

            <section class="manager-table-panel">
                <form class="category-picker-search" method="get">
                    <input type="hidden" name="action" value="products">
                    <input type="hidden" name="id" value="${selectedBrand.id}">
                    <input type="search" name="q" maxlength="100"
                           value="<c:out value='${keyword}'/>"
                           placeholder="Search product name...">
                    <button class="btn primary search-submit" type="submit">Search</button>
                </form>

                <div class="table-scroll">
                    <table>
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Product name</th>
                                <th>Categories</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${products}" var="product" varStatus="row">
                                <tr>
                                    <td class="mono">${pageStart + row.index}</td>
                                    <td><strong><c:out value="${product.name}"/></strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty product.categoryNames}"><span class="muted-copy">Not assigned</span></c:when>
                                            <c:otherwise><span class="category-chip"><c:out value="${product.categoryNames}"/></span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="price"><fmt:formatNumber value="${product.sellingPrice}" type="number"/>đ</td>
                                    <td>${product.stock}</td>
                                    <td><span class="status ${product.active ? 'active' : 'inactive'}">${product.status}</span></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty products}">
                                <tr><td colspan="6" class="manager-empty-row">No products found for this brand.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <c:if test="${totalProducts > 0}">
                    <c:url var="previousUrl" value="/manager/brands">
                        <c:param name="action" value="products"/><c:param name="id" value="${selectedBrand.id}"/>
                        <c:param name="page" value="${currentPage - 1}"/><c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                    </c:url>
                    <c:url var="nextUrl" value="/manager/brands">
                        <c:param name="action" value="products"/><c:param name="id" value="${selectedBrand.id}"/>
                        <c:param name="page" value="${currentPage + 1}"/><c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                    </c:url>
                    <nav class="manager-pagination">
                        <div class="manager-page-summary">Showing ${pageStart}–${pageEnd} of ${totalProducts} products</div>
                        <div class="manager-page-controls">
                            <a class="manager-page-button wide ${currentPage == 1 ? 'disabled' : ''}" href="${previousUrl}">Previous</a>
                            <span class="manager-page-current">Page ${currentPage} of ${totalPages}</span>
                            <a class="manager-page-button wide ${currentPage == totalPages ? 'disabled' : ''}" href="${nextUrl}">Next</a>
                        </div>
                    </nav>
                </c:if>
            </section>

            <div class="category-product-modal brand-product-modal" data-brand-product-modal hidden>
                <div class="category-product-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="brandProductModalTitle">
                    <div class="category-product-modal-header">
                        <div>
                            <h2 id="brandProductModalTitle">Move Products to <c:out value="${selectedBrand.name}"/></h2>
                            <p>A selected product will leave its current brand and belong to this brand.</p>
                        </div>
                        <button class="category-product-modal-close" type="button" data-close-brand-product-modal aria-label="Close">×</button>
                    </div>
                    <div class="brand-move-warning">
                        <i class="bi bi-exclamation-triangle"></i>
                        This changes the product's brand; it does not create a duplicate product.
                    </div>
                    <div class="category-product-modal-search">
                        <i class="bi bi-search"></i>
                        <input type="search" data-brand-product-search placeholder="Search product name or current brand...">
                    </div>
                    <form method="post" data-brand-product-form action="${pageContext.request.contextPath}/manager/brands">
                        <input type="hidden" name="action" value="move-products">
                        <input type="hidden" name="brandId" value="${selectedBrand.id}">
                        <div class="category-product-modal-table">
                            <table>
                                <thead><tr><th class="selection-cell">Select</th><th>No.</th><th>Product name</th><th>Current brand</th><th>Categories</th><th>Status</th></tr></thead>
                                <tbody>
                                    <c:forEach items="${movableProducts}" var="product" varStatus="row">
                                        <tr data-brand-product-row data-search-text="<c:out value='${product.name} ${product.brandName}'/>">
                                            <td class="selection-cell"><input type="checkbox" name="productIds" value="${product.id}" aria-label="Select product"></td>
                                            <td class="mono" data-visible-number>${row.index + 1}</td>
                                            <td><strong><c:out value="${product.name}"/></strong></td>
                                            <td><c:out value="${product.brandName}"/></td>
                                            <td><c:out value="${empty product.categoryNames ? 'Not assigned' : product.categoryNames}"/></td>
                                            <td><span class="status ${product.active ? 'active' : 'inactive'}">${product.status}</span></td>
                                        </tr>
                                    </c:forEach>
                                    <tr data-brand-product-empty hidden><td colspan="6" class="manager-empty-row">No products match the search.</td></tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="category-product-modal-footer">
                            <div class="category-modal-page-summary" data-brand-modal-summary></div>
                            <div class="category-modal-pagination">
                                <button class="manager-page-button wide" type="button" data-brand-modal-previous>Previous</button>
                                <span class="manager-page-current" data-brand-modal-page></span>
                                <button class="manager-page-button wide" type="button" data-brand-modal-next>Next</button>
                            </div>
                            <span class="category-selection-count" data-brand-modal-selection>0 product(s) selected</span>
                            <button class="btn subtle" type="button" data-close-brand-product-modal>Cancel</button>
                            <button class="btn primary" type="submit">Move Selected Products</button>
                        </div>
                    </form>
                </div>
            </div>
        </main>

        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/manager-brand-product-modal.js"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
