<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>${product.id == 0 ? 'Add' : 'Edit'} Product</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <%@include file="../common/head.jsp"%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    </head>
    <body>
        <c:set var="activePage" value="manager" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <main class="page-shell product-form-page">
            <div class="page-heading">
                <div>
                    <h1>${product.id == 0 ? 'Add Product' : 'Edit Product'}</h1>
                    <p>Fields marked * are required</p>
                </div>
                <div class="page-heading-actions">
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager">← Dashboard</a>
                    <a class="btn subtle" href="${pageContext.request.contextPath}/manager/products">Back to products</a>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alert error"><c:out value="${error}"/></div>
            </c:if>

            <form class="entity-form product-form" method="post">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="${product.id}">

                <div class="form-grid">
                    <label class="span-2">
                        Product name *
                        <input name="name" maxlength="50"
                               value="<c:out value='${product.name}'/>" required>
                    </label>

                    <label>
                        Brand *
                        <select name="brandId" required>
                            <option value="">Choose brand</option>
                            <c:forEach items="${brands}" var="brand">
                                <option value="${brand.id}"
                                        ${product.brandId == brand.id ? 'selected' : ''}>
                                    <c:out value="${brand.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </label>

                    <label>
                        Price segment *
                        <select name="categoryId" required>
                            <option value="">Choose price segment</option>
                            <c:forEach items="${categories}" var="category">
                                <option value="${category.id}"
                                        ${product.categoryId == category.id ? 'selected' : ''}>
                                    <c:out value="${category.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </label>

                    <label>
                        Release year
                        <input type="number" name="releaseYear" min="2000" max="2100"
                               value="${product.releaseYear}">
                    </label>

                    <label>
                        Warranty period (months)
                        <input type="number" name="warrantyMonths" min="0"
                               value="${product.warrantyMonths == 0 ? 12 : product.warrantyMonths}">
                    </label>

                    <label>
                        Rating
                        <select name="rating">
                            <c:forEach begin="0" end="5" var="rating">
                                <option value="${rating}"
                                        ${product.rating == rating ? 'selected' : ''}>
                                    ${rating}
                                </option>
                            </c:forEach>
                        </select>
                    </label>

                    <label>
                        Status
                        <select name="status">
                            <option value="ACTIVE" ${product.active ? 'selected' : ''}>Active</option>
                            <option value="INACTIVE" ${!product.active && product.id > 0 ? 'selected' : ''}>Inactive</option>
                        </select>
                    </label>

                    <label class="span-2">
                        Description
                        <textarea name="description" maxlength="255" rows="4"><c:out value="${product.description}"/></textarea>
                    </label>
                </div>

                <section class="variant-editor" data-variant-editor>
                    <div class="variant-editor-heading">
                        <div>
                            <h2>Product variants</h2>
                            <p>Add only the RAM, storage and colors that this phone actually has.</p>
                        </div>
                        <button class="btn subtle" type="button" data-add-variant>+ Add variant</button>
                    </div>

                    <div class="variant-table-wrap">
                        <table class="variant-table">
                            <thead>
                                <tr>
                                    <th>Memory and color</th>
                                    <th>Identification</th>
                                    <th>Price and stock</th>
                                    <th>Images</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody data-variant-rows>
                                <c:forEach items="${product.variants}" var="variant">
                                    <tr class="variant-row">
                                        <td>
                                            <input type="hidden" name="variantId" value="${variant.id}">
                                            <label>RAM (GB) *<input type="number" name="variantRam" min="1" value="${variant.ramGb}" required></label>
                                            <label>Storage (GB) *<input type="number" name="variantStorage" min="1" value="${variant.storageGb}" required></label>
                                            <label>Color name *<input name="variantColorName" maxlength="50" value="<c:out value='${variant.colorName}'/>" placeholder="Black Titanium" required></label>
                                        </td>
                                        <td>
                                            <label>SKU *<input name="variantSku" maxlength="255" value="<c:out value='${variant.sku}'/>" required></label>
                                            <label>Barcode *<input name="variantBarcode" maxlength="255" value="<c:out value='${variant.barcode}'/>" required></label>
                                        </td>
                                        <td>
                                            <label>Selling price *<input type="number" name="variantSellingPrice" min="0" value="${variant.sellingPrice}" required></label>
                                            <label>Latest cost *<input type="number" name="variantLatestCost" min="0" value="${variant.latestCost}" required></label>
                                            <label>Stock *<input type="number" name="variantStock" min="0" value="${variant.stock}" required></label>
                                        </td>
                                        <td>
                                            <label>Front image *<input name="variantImage" maxlength="255" value="<c:out value='${variant.image}'/>" pattern="[A-Za-z0-9][A-Za-z0-9._-]*\.(webp|png|jpg|jpeg|WEBP|PNG|JPG|JPEG)" required></label>
                                            <label>Back image *<input name="variantBackImage" maxlength="255" value="<c:out value='${variant.backImage}'/>" pattern="[A-Za-z0-9][A-Za-z0-9._-]*\.(webp|png|jpg|jpeg|WEBP|PNG|JPG|JPEG)" required></label>
                                            <small>File names inside assets/images/products</small>
                                        </td>
                                        <td><button class="variant-remove" type="button" data-remove-variant aria-label="Remove variant">Remove</button></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </section>

                <div class="form-actions">
                    <a class="btn subtle"
                       href="${pageContext.request.contextPath}/manager/products">
                        Cancel
                    </a>
                    <button class="btn primary large">Save Product</button>
                </div>
            </form>
        </main>
        <template id="variantRowTemplate">
            <tr class="variant-row">
                <td>
                    <input type="hidden" name="variantId" value="0">
                    <label>RAM (GB) *<input type="number" name="variantRam" min="1" required></label>
                    <label>Storage (GB) *<input type="number" name="variantStorage" min="1" required></label>
                    <label>Color name *<input name="variantColorName" maxlength="50" placeholder="Black Titanium" required></label>
                </td>
                <td>
                    <label>SKU *<input name="variantSku" maxlength="255" required></label>
                    <label>Barcode *<input name="variantBarcode" maxlength="255" required></label>
                </td>
                <td>
                    <label>Selling price *<input type="number" name="variantSellingPrice" min="0" required></label>
                    <label>Latest cost *<input type="number" name="variantLatestCost" min="0" required></label>
                    <label>Stock *<input type="number" name="variantStock" min="0" required></label>
                </td>
                <td>
                    <label>Front image *<input name="variantImage" maxlength="255" pattern="[A-Za-z0-9][A-Za-z0-9._-]*\.(webp|png|jpg|jpeg|WEBP|PNG|JPG|JPEG)" required></label>
                    <label>Back image *<input name="variantBackImage" maxlength="255" pattern="[A-Za-z0-9][A-Za-z0-9._-]*\.(webp|png|jpg|jpeg|WEBP|PNG|JPG|JPEG)" required></label>
                    <small>File names inside assets/images/products</small>
                </td>
                <td><button class="variant-remove" type="button" data-remove-variant aria-label="Remove variant">Remove</button></td>
            </tr>
        </template>
        <script src="${pageContext.request.contextPath}/assets/js/manager-product-form.js"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
