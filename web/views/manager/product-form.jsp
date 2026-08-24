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
                <div class="alert error">
                    <c:out value="${error}"/>
                </div>
            </c:if>
            <c:if test="${not empty brandWarning}">
                <div class="alert warning">
                    <c:out value="${brandWarning}"/>
                </div>
            </c:if>

            <form class="entity-form product-form" method="post" enctype="multipart/form-data"
                  action="${pageContext.request.contextPath}/manager/products" novalidate>
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="${product.id}">
                <input type="hidden" name="confirmBrandMismatch"
                       value="${confirmBrandMismatch ? 'true' : 'false'}">

                <div class="form-grid">
                    <label class="span-2">
                        Product name *
                        <input name="name" value="<c:out value='${product.name}'/>">
                    </label>

                    <label>
                        Brand *
                        <select name="brandId">
                            <option value="">Choose brand</option>
                            <c:forEach items="${brands}" var="brand">
                                <option value="${brand.id}" data-brand-name="<c:out value='${brand.name}'/>"
                                        ${product.brandId == brand.id ? 'selected' : ''}>
                                    <c:out value="${brand.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </label>

                    <fieldset class="span-2 category-selector">
                        <legend>Categories *</legend>
                        <p>Select every feature group that applies to this phone.</p>
                        <div class="category-options">
                            <c:forEach items="${categories}" var="category">
                                <label class="category-option">
                                    <input type="checkbox" name="categoryIds"
                                           value="${category.id}"
                                           ${selectedCategoryIds.contains(category.id) ? 'checked' : ''}>
                                    <span>
                                        <strong><c:out value="${category.name}"/></strong>
                                        <small><c:out value="${category.description}"/></small>
                                    </span>
                                </label>
                            </c:forEach>
                        </div>
                    </fieldset>

                    <label>
                        Release year
                        <input type="number" name="releaseYear" value="${product.releaseYear}">
                    </label>

                    <label>
                        Warranty period (months)
                        <input type="number" name="warrantyMonths"
                               value="${product.id == 0 && product.warrantyMonths == 0 ? 12 : product.warrantyMonths}">
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
                        <textarea name="description" rows="4"><c:out value="${product.description}"/></textarea>
                    </label>
                </div>

                <section class="variant-editor" data-variant-editor>
                    <div class="variant-editor-heading">
                        <div>
                            <h2>Product variants</h2>
                        </div>
                        <button class="btn subtle" type="button" data-add-variant>+ Add variant</button>
                    </div>

                    <div class="variant-table-wrap">
                        <table class="variant-table">
                            <thead>
                                <tr>
                                    <th>Memory and color</th>
                                    <th>Price</th>
                                    <th>Images</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody data-variant-rows>
                                <c:forEach items="${product.variants}" var="variant">
                                    <tr class="variant-row">
                                        <td>
                                            <input type="hidden" name="variantId" value="${variant.id}">
                                            <label>RAM (GB) *
                                                <select name="variantRam">
                                                    <option value="">Choose RAM</option>
                                                    <c:forEach items="${ramOptions}" var="ram">
                                                        <option value="${ram}" ${variant.ramGb == ram ? 'selected' : ''}>${ram} GB</option>
                                                    </c:forEach>
                                                </select>
                                            </label>
                                            <label>Storage (GB) *
                                                <select name="variantStorage">
                                                    <option value="">Choose storage</option>
                                                    <c:forEach items="${storageOptions}" var="storage">
                                                        <option value="${storage}" ${variant.storageGb == storage ? 'selected' : ''}>
                                                            <c:choose><c:when test="${storage == 1024}">1 TB</c:when><c:when test="${storage == 2048}">2 TB</c:when><c:otherwise>${storage} GB</c:otherwise></c:choose>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </label>
                                            <label>Color name *<input name="variantColorName" value="<c:out value='${variant.colorName}'/>" placeholder="Black Titanium"></label>
                                        </td>
                                        <td>
                                            <label>Selling price *
                                                <input type="number" name="variantSellingPrice" value="${variant.sellingPrice}">
                                            </label>
                                        </td>
                                        <td>
                                            <input type="hidden" name="existingVariantImage" value="<c:out value='${variant.image}'/>">
                                            <input type="hidden" name="existingVariantBackImage" value="<c:out value='${variant.backImage}'/>">
                                            <label>Front image *<input type="file" name="variantImageFile" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"></label>
                                            <c:if test="${not empty variant.image}"><small class="current-image"><i class="bi bi-image"></i> Current: <c:out value="${variant.image}"/></small></c:if>
                                            <label>Back image *<input type="file" name="variantBackImageFile" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"></label>
                                            <c:if test="${not empty variant.backImage}"><small class="current-image"><i class="bi bi-image"></i> Current: <c:out value="${variant.backImage}"/></small></c:if>
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
                    <button class="btn primary large">
                        ${not empty brandWarning ? 'Save anyway' : 'Save Product'}
                    </button>
                </div>
            </form>
        </main>
        <template id="variantRowTemplate">
            <tr class="variant-row">
                <td>
                    <input type="hidden" name="variantId" value="0">
                    <label>RAM (GB) *
                        <select name="variantRam">
                            <option value="">Choose RAM</option>
                            <c:forEach items="${ramOptions}" var="ram">
                                <option value="${ram}">${ram} GB</option>
                            </c:forEach>
                        </select>
                    </label>
                    <label>Storage (GB) *
                        <select name="variantStorage">
                            <option value="">Choose storage</option>
                            <c:forEach items="${storageOptions}" var="storage">
                                <option value="${storage}"><c:choose><c:when test="${storage == 1024}">1 TB</c:when><c:when test="${storage == 2048}">2 TB</c:when><c:otherwise>${storage} GB</c:otherwise></c:choose></option>
                            </c:forEach>
                        </select>
                    </label>
                    <label>Color name *<input name="variantColorName" placeholder="Black Titanium"></label>
                </td>
                <td>
                    <label>Selling price *
                        <input type="number" name="variantSellingPrice">
                    </label>
                </td>
                <td>
                    <input type="hidden" name="existingVariantImage" value="">
                    <input type="hidden" name="existingVariantBackImage" value="">
                    <label>Front image *<input type="file" name="variantImageFile" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"></label>
                    <label>Back image *<input type="file" name="variantBackImageFile" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"></label>
                </td>
                <td><button class="variant-remove" type="button" data-remove-variant aria-label="Remove variant">Remove</button></td>
            </tr>
        </template>
        <script src="${pageContext.request.contextPath}/assets/js/manager-product-form.js?v=20260824-variant-ui"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
