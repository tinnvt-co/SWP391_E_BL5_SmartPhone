<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
    <title>Product Management</title>
    <%@include file="../common/head.jsp"%>
</head>
<body>
    <c:set var="pageRole" value="Manager"/>
    <c:set var="pageName" value="Manage Products"/>
    <%@include file="../common/topbar.jsp"%>

    <main class="page-shell">
        <div class="page-heading">
            <div>
                <h1>Product Management</h1>
                <p>${total} products listed</p>
            </div>
            <div class="page-heading-actions">
                <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Back to dashboard</a>
                <a class="btn primary large"
                   href="${pageContext.request.contextPath}/manager/products?action=form">
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
                <input name="q" value="<c:out value='${param.q}'/>"
                       placeholder="Search product name...">

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
                    <option value="">Price segment</option>
                    <c:forEach items="${categories}" var="category">
                        <option value="${category.id}"
                                ${selectedCategory == category.id ? 'selected' : ''}>
                            <c:out value="${category.name}"/>
                        </option>
                    </c:forEach>
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
                                        <c:out value="${product.categoryName}"/>
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
        </section>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/store.js"></script>
</body>
</html>
