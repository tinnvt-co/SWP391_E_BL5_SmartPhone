<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Product Management</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell">
            <c:url var="addProductUrl" value="/manager/products">
                <c:param name="action" value="form"/>
            </c:url>
            <c:url var="addCategoryProductsUrl" value="/manager/products">
                <c:param name="action" value="category-picker"/>
                <c:param name="category" value="${selectedCategory}"/>
            </c:url>
            <div class="page-heading">
                <div>
                    <h1><c:choose><c:when test="${fromCategory}"><c:out value="${selectedCategoryName}"/> Products</c:when><c:otherwise>Product Management</c:otherwise></c:choose></h1>
                    <p>${filteredTotal} products found</p>
                </div>
                <div class="page-heading-actions">
                    <c:choose>
                        <c:when test="${fromCategory}">
                            <a class="btn subtle" href="${pageContext.request.contextPath}/manager/categories">← Back to category management</a>
                        </c:when>
                        <c:otherwise>
                            <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Back to dashboard</a>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${fromCategory}">
                            <button class="btn primary large" type="button"
                                    data-open-category-product-modal>
                                + Add Products
                            </button>
                        </c:when>
                        <c:otherwise>
                            <a class="btn primary large" href="${addProductUrl}">
                                + Add Product
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <c:if test="${not empty param.message}">
                <div class="alert success"><c:out value="${param.message}"/></div>
            </c:if>

            <section class="table-panel">
                <form class="search-row" method="get">
                    <c:if test="${fromCategory}">
                        <input type="hidden" name="from" value="category">
                    </c:if>
                    <input name="q" value="<c:out value='${keyword}'/>"
                           placeholder="Search product name...">
                    <c:if test="${not empty selectedSort}">
                        <input type="hidden" name="sort" value="<c:out value='${selectedSort}'/>">
                    </c:if>

                    <select name="brand">
                        <option value="">Brand</option>
                        <c:forEach items="${brands}" var="brand">
                            <option value="${brand.id}"
                                    ${selectedBrand == brand.id ? 'selected' : ''}>
                                <c:out value="${brand.name}"/>
                            </option>
                        </c:forEach>
                    </select>

                    <c:choose>
                        <c:when test="${fromCategory}">
                            <input type="hidden" name="category" value="${selectedCategory}">
                            <div class="locked-filter"><c:out value="${selectedCategoryName}"/></div>
                        </c:when>
                        <c:otherwise>
                            <select name="category">
                                <option value="">Category</option>
                                <c:forEach items="${categories}" var="category">
                                    <option value="${category.id}"
                                            ${selectedCategory == category.id ? 'selected' : ''}>
                                        <c:out value="${category.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </c:otherwise>
                    </c:choose>

                    <select name="priceRange">
                        <option value="">All prices</option>
                        <option value="under-5m" ${selectedPriceRange == 'under-5m' ? 'selected' : ''}>Under 5 million</option>
                        <option value="5m-10m" ${selectedPriceRange == '5m-10m' ? 'selected' : ''}>5–under 10 million</option>
                        <option value="10m-20m" ${selectedPriceRange == '10m-20m' ? 'selected' : ''}>10–under 20 million</option>
                        <option value="over-20m" ${selectedPriceRange == 'over-20m' ? 'selected' : ''}>20 million or more</option>
                    </select>

                    <button class="btn primary search-submit">Search</button>
                </form>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Product name</th>
                                <th>Brand</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty products}">
                                <tr><td colspan="7" class="manager-empty-row">No products match the current filters.</td></tr>
                            </c:if>
                            <c:forEach items="${products}" var="product" varStatus="row">
                                <tr>
                                    <td class="mono">${pageStart + row.index}</td>
                                    <td>
                                        <strong><c:out value="${product.name}"/></strong>
                                        <small><c:out value="${product.sku}"/></small>
                                    </td>
                                    <td><c:out value="${product.brandName}"/></td>
                                    <td>
                                        <span class="category-chip">
                                            <c:out value="${product.categoryNames}"/>
                                        </span>
                                    </td>
                                    <td class="price-small">
                                        <fmt:formatNumber value="${product.finalPrice}" pattern="#,##0"/>₫
                                    </td>
                                    <td>
                                        <span class="status ${product.active ? 'active' : 'inactive'}">
                                            ${product.status}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <c:choose>
                                                <c:when test="${fromCategory}">
                                                    <form method="post"
                                                          onsubmit="return confirm('Remove this product from the category? The product will remain in Product Management.');">
                                                        <input type="hidden" name="action" value="remove-category-product">
                                                        <input type="hidden" name="categoryId" value="${selectedCategory}">
                                                        <input type="hidden" name="productId" value="${product.id}">
                                                        <button class="btn danger">Remove</button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="btn subtle"
                                                       href="${pageContext.request.contextPath}/manager/products?action=form&id=${product.id}">
                                                        Edit
                                                    </a>
                                                    <form method="post"
                                                          onsubmit="return confirmDeactivate('product')">
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <input type="hidden" name="id" value="${product.id}">
                                                        <button class="btn danger">Remove</button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <c:if test="${filteredTotal > 0}">
                    <c:url var="firstPageUrl" value="/manager/products">
                        <c:param name="page" value="1"/>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty selectedPriceRange}"><c:param name="priceRange" value="${selectedPriceRange}"/></c:if>
                        <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
                        <c:if test="${fromCategory}"><c:param name="from" value="category"/></c:if>
                    </c:url>
                    <c:url var="previousPageUrl" value="/manager/products">
                        <c:param name="page" value="${currentPage - 1}"/>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty selectedPriceRange}"><c:param name="priceRange" value="${selectedPriceRange}"/></c:if>
                        <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
                        <c:if test="${fromCategory}"><c:param name="from" value="category"/></c:if>
                    </c:url>
                    <c:url var="nextPageUrl" value="/manager/products">
                        <c:param name="page" value="${currentPage + 1}"/>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty selectedPriceRange}"><c:param name="priceRange" value="${selectedPriceRange}"/></c:if>
                        <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
                        <c:if test="${fromCategory}"><c:param name="from" value="category"/></c:if>
                    </c:url>
                    <c:url var="lastPageUrl" value="/manager/products">
                        <c:param name="page" value="${totalPages}"/>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty selectedPriceRange}"><c:param name="priceRange" value="${selectedPriceRange}"/></c:if>
                        <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
                        <c:if test="${fromCategory}"><c:param name="from" value="category"/></c:if>
                    </c:url>

                    <nav class="manager-pagination" aria-label="Product management pagination">
                        <div class="manager-page-summary">
                            Showing ${pageStart}–${pageEnd} of ${filteredTotal} products
                        </div>
                        <div class="manager-page-controls">
                            <a class="manager-page-button ${currentPage == 1 ? 'disabled' : ''}" href="${firstPageUrl}" aria-label="First page">«</a>
                            <a class="manager-page-button wide ${currentPage == 1 ? 'disabled' : ''}" href="${previousPageUrl}">Previous</a>
                            <span class="manager-page-current">Page ${currentPage} of ${totalPages}</span>
                            <a class="manager-page-button wide ${currentPage == totalPages ? 'disabled' : ''}" href="${nextPageUrl}">Next</a>
                            <a class="manager-page-button ${currentPage == totalPages ? 'disabled' : ''}" href="${lastPageUrl}" aria-label="Last page">»</a>
                        </div>
                    </nav>
                </c:if>
            </section>

            <c:if test="${fromCategory}">
                <div class="category-product-modal" data-category-product-modal hidden>
                    <div class="category-product-modal-dialog" role="dialog"
                         aria-modal="true" aria-labelledby="categoryProductModalTitle">
                        <div class="category-product-modal-header">
                            <div>
                                <h2 id="categoryProductModalTitle">
                                    Add Products to <c:out value="${selectedCategoryName}"/>
                                </h2>
                                <p>Only products that are not in this category are shown</p>
                            </div>
                            <button class="category-product-modal-close" type="button"
                                    data-close-category-product-modal aria-label="Close">×</button>
                        </div>

                        <div class="category-product-modal-search">
                            <i class="bi bi-search"></i>
                            <input type="search" data-category-product-search
                                   placeholder="Search product name...">
                        </div>

                        <form method="post" data-category-product-form
                              action="${pageContext.request.contextPath}/manager/products">
                            <input type="hidden" name="action" value="add-category-products">
                            <input type="hidden" name="categoryId" value="${selectedCategory}">

                            <div class="category-product-modal-table">
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
                                        <c:forEach items="${availableCategoryProducts}" var="availableProduct" varStatus="availableRow">
                                            <tr data-category-product-row
                                                data-product-name="<c:out value='${availableProduct.name}'/>">
                                                <td class="selection-cell">
                                                    <input type="checkbox" name="productIds"
                                                           value="${availableProduct.id}"
                                                           aria-label="Select product">
                                                </td>
                                                <td class="mono" data-visible-number>${availableRow.index + 1}</td>
                                                <td>
                                                    <strong><c:out value="${availableProduct.name}"/></strong>
                                                    <small><c:out value="${availableProduct.sku}"/></small>
                                                </td>
                                                <td><c:out value="${availableProduct.brandName}"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${empty availableProduct.categoryNames}">
                                                            <span class="muted-copy">Not assigned</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="category-chip"><c:out value="${availableProduct.categoryNames}"/></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <span class="status ${availableProduct.active ? 'active' : 'inactive'}">
                                                        ${availableProduct.status}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <tr data-category-product-empty hidden>
                                            <td colspan="6" class="manager-empty-row">No available products match the search.</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="category-product-modal-footer">
                                <div class="category-modal-page-summary" data-category-modal-summary></div>
                                <div class="category-modal-pagination">
                                    <button class="manager-page-button wide" type="button"
                                            data-category-modal-previous>Previous</button>
                                    <span class="manager-page-current" data-category-modal-page></span>
                                    <button class="manager-page-button wide" type="button"
                                            data-category-modal-next>Next</button>
                                </div>
                                <span class="category-selection-count" data-category-modal-selection>0 product(s) selected</span>
                                <button class="btn subtle" type="button" data-close-category-product-modal>Cancel</button>
                                <button class="btn primary" type="submit">Add Selected Products</button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>
        </main>

        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/manager-category-modal.js"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
