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
                <c:if test="${not empty selectedCategory}">
                    <c:param name="category" value="${selectedCategory}"/>
                </c:if>
            </c:url>
            <div class="page-heading">
                <div>
                    <h1>Product Management</h1>
                    <p>${filteredTotal} products found</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Back to dashboard</a>
                    <a class="btn primary large"
                       href="${addProductUrl}">
                        + Add Product
                    </a>
                </div>
            </div>

            <c:if test="${not empty param.message}">
                <div class="alert success"><c:out value="${param.message}"/></div>
            </c:if>

            <section class="stats-grid">
                <article>
                    <span>TOTAL PRODUCTS</span>
                    <strong>${total}</strong>
                    <i></i>
                </article>
                <article>
                    <span>ACTIVE</span>
                    <strong>${active}</strong>
                    <i class="green"></i>
                </article>
                <article>
                    <span>BRANDS</span>
                    <strong>${brands.size()}</strong>
                    <i class="pink"></i>
                </article>
                <article>
                    <span>CATEGORIES</span>
                    <strong>${categories.size()}</strong>
                    <i class="purple"></i>
                </article>
            </section>

            <section class="table-panel">
                <form class="search-row" method="get">
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

                    <select name="category">
                        <option value="">Category</option>
                        <c:forEach items="${categories}" var="category">
                            <option value="${category.id}"
                                    ${selectedCategory == category.id ? 'selected' : ''}>
                                <c:out value="${category.name}"/>
                            </option>
                        </c:forEach>
                    </select>

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
                                <th>ID</th>
                                <th>Product name</th>
                                <th>Brand</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty products}">
                                <tr><td colspan="8" class="manager-empty-row">No products match the current filters.</td></tr>
                            </c:if>
                            <c:forEach items="${products}" var="product">
                                <tr>
                                    <td class="mono">${product.id}</td>
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
                                    <td class="${product.stock == 0 ? 'danger' : 'stock'}">
                                        ${product.stock}
                                    </td>
                                    <td>
                                        <span class="status ${product.active ? 'active' : 'inactive'}">
                                            ${product.status}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="actions">
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
                    </c:url>
                    <c:url var="previousPageUrl" value="/manager/products">
                        <c:param name="page" value="${currentPage - 1}"/>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty selectedPriceRange}"><c:param name="priceRange" value="${selectedPriceRange}"/></c:if>
                        <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
                    </c:url>
                    <c:url var="nextPageUrl" value="/manager/products">
                        <c:param name="page" value="${currentPage + 1}"/>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty selectedPriceRange}"><c:param name="priceRange" value="${selectedPriceRange}"/></c:if>
                        <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
                    </c:url>
                    <c:url var="lastPageUrl" value="/manager/products">
                        <c:param name="page" value="${totalPages}"/>
                        <c:if test="${not empty keyword}"><c:param name="q" value="${keyword}"/></c:if>
                        <c:if test="${not empty selectedBrand}"><c:param name="brand" value="${selectedBrand}"/></c:if>
                        <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
                        <c:if test="${not empty selectedPriceRange}"><c:param name="priceRange" value="${selectedPriceRange}"/></c:if>
                        <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
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
        </main>

        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
