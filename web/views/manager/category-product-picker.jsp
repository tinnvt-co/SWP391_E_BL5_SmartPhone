<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Add Products to Category</title>
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
                    <h1>Add Products to <c:out value="${category.name}"/></h1>
                    <p>Only products that are not in this category are shown</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle"
                       data-clear-category-selection
                       href="${pageContext.request.contextPath}/manager/products?category=${category.id}&from=category">
                        ← Back to category products
                    </a>
                </div>
            </div>

            <c:if test="${not empty param.error}">
                <div class="alert error"><c:out value="${param.error}"/></div>
            </c:if>

            <section class="table-panel category-picker-panel">
                <form class="category-picker-search" method="get">
                    <input type="hidden" name="action" value="category-picker">
                    <input type="hidden" name="category" value="${category.id}">
                    <input name="q" value="<c:out value='${keyword}'/>"
                           placeholder="Search product name...">
                    <button class="btn primary search-submit">Search</button>
                </form>

                <form id="categoryProductForm" method="post"
                      data-category-id="${category.id}"
                      action="${pageContext.request.contextPath}/manager/products">
                    <input type="hidden" name="action" value="add-category-products">
                    <input type="hidden" name="categoryId" value="${category.id}">

                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th class="selection-cell">Select</th>
                                    <th>No.</th>
                                    <th>Product name</th>
                                    <th>Brand</th>
                                    <th>Current categories</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty availableProducts}">
                                    <tr>
                                        <td colspan="6" class="manager-empty-row">
                                            No available products match the search.
                                        </td>
                                    </tr>
                                </c:if>
                                <c:forEach items="${availableProducts}" var="product" varStatus="row">
                                    <tr>
                                        <td class="selection-cell">
                                            <input type="checkbox" name="productIds" value="${product.id}"
                                                   aria-label="Select ${product.name}">
                                        </td>
                                        <td class="mono">${pageStart + row.index}</td>
                                        <td>
                                            <strong><c:out value="${product.name}"/></strong>
                                            <small><c:out value="${product.sku}"/></small>
                                        </td>
                                        <td><c:out value="${product.brandName}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${empty product.categoryNames}">
                                                    <span class="muted-copy">Not assigned</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="category-chip">
                                                        <c:out value="${product.categoryNames}"/>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="status ${product.active ? 'active' : 'inactive'}">
                                                ${product.status}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <c:if test="${filteredTotal > 0}">
                        <c:url var="firstPageUrl" value="/manager/products">
                            <c:param name="action" value="category-picker"/>
                            <c:param name="category" value="${category.id}"/>
                            <c:param name="page" value="1"/>
                            <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        </c:url>
                        <c:url var="previousPageUrl" value="/manager/products">
                            <c:param name="action" value="category-picker"/>
                            <c:param name="category" value="${category.id}"/>
                            <c:param name="page" value="${currentPage - 1}"/>
                            <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        </c:url>
                        <c:url var="nextPageUrl" value="/manager/products">
                            <c:param name="action" value="category-picker"/>
                            <c:param name="category" value="${category.id}"/>
                            <c:param name="page" value="${currentPage + 1}"/>
                            <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        </c:url>
                        <c:url var="lastPageUrl" value="/manager/products">
                            <c:param name="action" value="category-picker"/>
                            <c:param name="category" value="${category.id}"/>
                            <c:param name="page" value="${totalPages}"/>
                            <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        </c:url>

                        <nav class="manager-pagination" aria-label="Available product pagination">
                            <div class="manager-page-summary">
                                Showing ${pageStart}–${pageEnd} of ${filteredTotal} products
                            </div>
                            <div class="manager-page-controls">
                                <a class="manager-page-button ${currentPage == 1 ? 'disabled' : ''}"
                                   href="${firstPageUrl}" aria-label="First page">«</a>
                                <a class="manager-page-button wide ${currentPage == 1 ? 'disabled' : ''}"
                                   href="${previousPageUrl}">Previous</a>
                                <span class="manager-page-current">Page ${currentPage} of ${totalPages}</span>
                                <a class="manager-page-button wide ${currentPage == totalPages ? 'disabled' : ''}"
                                   href="${nextPageUrl}">Next</a>
                                <a class="manager-page-button ${currentPage == totalPages ? 'disabled' : ''}"
                                   href="${lastPageUrl}" aria-label="Last page">»</a>
                            </div>
                        </nav>
                    </c:if>

                    <c:if test="${not empty availableProducts}">
                        <div class="category-picker-actions">
                            <a class="btn subtle"
                               data-clear-category-selection
                               href="${pageContext.request.contextPath}/manager/products?category=${category.id}&from=category">
                                Cancel
                            </a>
                            <span class="category-selection-count" id="categorySelectionCount">0 products selected</span>
                            <button class="btn primary large" type="submit">
                                Add Selected Products
                            </button>
                        </div>
                    </c:if>
                </form>
            </section>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="${pageContext.request.contextPath}/assets/js/manager-category-picker.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
