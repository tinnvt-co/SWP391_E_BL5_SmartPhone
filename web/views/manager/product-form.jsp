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

        <%-- Một JSP dùng chung: product.id = 0 là Add, product.id > 0 là Edit. --%>
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

            <%-- Controller forward lại form với error khi validate chưa đạt. --%>
            <c:if test="${not empty error}">
                <div class="alert error">
                    <c:out value="${error}"/>
                </div>
            </c:if>
            <%-- Các c:set ánh xạ errorFields thành class đỏ cho đúng field bị lỗi. --%>
            <c:set var="nameError" value="${not empty errorFields and errorFields.contains('name')}"/>
            <c:set var="brandError" value="${not empty errorFields and errorFields.contains('brandId')}"/>
            <c:set var="categoriesError" value="${not empty errorFields and errorFields.contains('categoryIds')}"/>
            <c:set var="releaseYearError" value="${not empty errorFields and errorFields.contains('releaseYear')}"/>
            <c:set var="warrantyError" value="${not empty errorFields and errorFields.contains('warrantyMonths')}"/>
            <c:set var="statusError" value="${not empty errorFields and errorFields.contains('status')}"/>
            <c:set var="descriptionError" value="${not empty errorFields and errorFields.contains('description')}"/>
            <c:set var="variantsError" value="${not empty errorFields and errorFields.contains('variants')}"/>

            <%-- Bắt buộc dùng multipart/form-data vì mỗi variant có thể tải lên hai file ảnh. --%>
            <%-- Form POST multipart gửi thông tin product, nhiều variant và file ảnh về Controller. --%>
            <form class="entity-form product-form" method="post" enctype="multipart/form-data"
                  action="${pageContext.request.contextPath}/manager/products" novalidate>
                <%-- Dùng chung form cho Add và Edit; ID bằng 0 là Add, ID lớn hơn 0 là Edit. --%>
                <input type="hidden" name="id" value="${product.id}">
                <div class="form-grid">
                    <label class="span-2">
                        Product name *
                        <input name="name" class="${nameError ? 'server-invalid' : ''}"
                               aria-invalid="${nameError}"
                               value="<c:out value='${product.name}'/>">
                    </label>

                    <label>
                        Brand *
                        <select name="brandId" class="${brandError ? 'server-invalid' : ''}"
                                aria-invalid="${brandError}">
                            <option value="">Choose brand</option>
                            <c:forEach items="${brands}" var="brand">
                                <option value="${brand.id}" data-brand-name="<c:out value='${brand.name}'/>"
                                        ${product.brandId == brand.id ? 'selected' : ''}>
                                    <c:out value="${brand.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </label>

                    <fieldset class="span-2 category-selector ${categoriesError ? 'server-invalid-group' : ''}">
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
                        <input type="number" name="releaseYear"
                               class="${releaseYearError ? 'server-invalid' : ''}"
                               aria-invalid="${releaseYearError}" value="${product.releaseYear}">
                    </label>

                    <label>
                        Warranty period (months)
                        <input type="number" name="warrantyMonths"
                               class="${warrantyError ? 'server-invalid' : ''}"
                               aria-invalid="${warrantyError}"
                               value="${product.id == 0 && product.warrantyMonths == 0 ? 12 : product.warrantyMonths}">
                    </label>

                    <label>
                        Status
                        <select name="status" class="${statusError ? 'server-invalid' : ''}"
                                aria-invalid="${statusError}">
                            <option value="ACTIVE" ${product.active ? 'selected' : ''}>Active</option>
                            <option value="INACTIVE" ${!product.active && product.id > 0 ? 'selected' : ''}>Inactive</option>
                        </select>
                    </label>

                    <label class="span-2">
                        Description
                        <textarea name="description" rows="4"
                                  class="${descriptionError ? 'server-invalid' : ''}"
                                  aria-invalid="${descriptionError}"><c:out value="${product.description}"/></textarea>
                    </label>
                </div>

                <%-- data-variant-editor là điểm móc để JS quản lý thêm/xóa dòng variant trong DOM. --%>
                <section class="variant-editor ${variantsError ? 'server-invalid-group' : ''}" data-variant-editor>
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
                                <%-- Mỗi dòng gửi các mảng field song song; Controller đọc dữ liệu theo cùng index. --%>
                                <%-- Edit hoặc form lỗi: render lại các variant có sẵn và giữ nguyên dữ liệu đã nhập. --%>
                                <c:forEach items="${product.variants}" var="variant" varStatus="variantRow">
                                    <c:set var="currentVariantError" value="${errorAllVariants or errorVariantIndex == variantRow.index}"/>
                                    <c:set var="ramError" value="${currentVariantError and not empty errorFields and errorFields.contains('variantRam')}"/>
                                    <c:set var="storageError" value="${currentVariantError and not empty errorFields and errorFields.contains('variantStorage')}"/>
                                    <c:set var="colorError" value="${currentVariantError and not empty errorFields and errorFields.contains('variantColorName')}"/>
                                    <c:set var="sellingPriceError" value="${currentVariantError and not empty errorFields and errorFields.contains('variantSellingPrice')}"/>
                                    <c:set var="frontImageError" value="${currentVariantError and not empty errorFields and errorFields.contains('variantImageFile')}"/>
                                    <c:set var="backImageError" value="${currentVariantError and not empty errorFields and errorFields.contains('variantBackImageFile')}"/>
                                    <tr class="variant-row">
                                        <td>
                                            <input type="hidden" name="variantId" value="${variant.id}">
                                            <label>RAM (GB) *
                                                <select name="variantRam" class="${ramError ? 'server-invalid' : ''}"
                                                        aria-invalid="${ramError}">
                                                    <option value="">Choose RAM</option>
                                                    <c:forEach items="${ramOptions}" var="ram">
                                                        <option value="${ram}" ${variant.ramGb == ram ? 'selected' : ''}>${ram} GB</option>
                                                    </c:forEach>
                                                </select>
                                            </label>
                                            <label>Storage (GB) *
                                                <select name="variantStorage" class="${storageError ? 'server-invalid' : ''}"
                                                        aria-invalid="${storageError}">
                                                    <option value="">Choose storage</option>
                                                    <c:forEach items="${storageOptions}" var="storage">
                                                        <option value="${storage}" ${variant.storageGb == storage ? 'selected' : ''}>
                                                            <c:choose><c:when test="${storage == 1024}">1 TB</c:when><c:when test="${storage == 2048}">2 TB</c:when><c:otherwise>${storage} GB</c:otherwise></c:choose>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </label>
                                            <label>Color name *
                                                <input name="variantColorName" class="${colorError ? 'server-invalid' : ''}"
                                                       aria-invalid="${colorError}"
                                                       value="<c:out value='${variant.colorName}'/>" placeholder="Black Titanium">
                                            </label>
                                        </td>
                                        <td>
                                            <label>Selling price *
                                                <input type="number" name="variantSellingPrice"
                                                       class="${sellingPriceError ? 'server-invalid' : ''}"
                                                       aria-invalid="${sellingPriceError}"
                                                       min="1" value="${variant.sellingPrice}">
                                            </label>
                                        </td>
                                        <td>
                                            <%-- Tên ảnh cũ giúp Edit giữ ảnh hiện tại khi người dùng không chọn file thay thế. --%>
                                            <input type="hidden" name="existingVariantImage" value="<c:out value='${variant.image}'/>">
                                            <input type="hidden" name="existingVariantBackImage" value="<c:out value='${variant.backImage}'/>">
                                            <label>Front image *
                                                <input type="file" name="variantImageFile"
                                                       class="${frontImageError ? 'server-invalid' : ''}"
                                                       aria-invalid="${frontImageError}"
                                                       accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp">
                                            </label>
                                            <c:if test="${not empty variant.image}"><small class="current-image"><i class="bi bi-image"></i> Current: <c:out value="${variant.image}"/></small></c:if>
                                            <label>Back image *
                                                <input type="file" name="variantBackImageFile"
                                                       class="${backImageError ? 'server-invalid' : ''}"
                                                       aria-invalid="${backImageError}"
                                                       accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp">
                                            </label>
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
                  
                    <button class="btn primary large" type="submit"
                            name="action" value="save">Save Product</button>
                </div>
            </form>
        </main>
        <%-- Mẫu insert không submit; JS clone mẫu sạch rồi chèn bản sao vào tbody trong form. --%>
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
                        <input type="number" name="variantSellingPrice" min="1">
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
        <%-- Đặt script sau form/template để các phần tử cần tìm đã tồn tại trong DOM. --%>
        <script src="${pageContext.request.contextPath}/assets/js/manager-product-form.js?v=20260824-variant-ui"></script>
        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
