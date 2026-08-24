<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Store Information | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body>
        <c:set var="activePage" value="profile" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Profile Dashboard</h1>
                <p>Manage your customer information, delivery contact, and account details from one place.</p>
            </div>
        </section>

        <main class="dashboard-shell">
            <div class="container">
                <div class="dashboard-grid">

                    <c:set var="sidebarActive" value="storeinfo" scope="request"/>
                    <%@ include file="/views/common/profile-sidebar.jsp" %>

                    <section class="panel content-panel">
                        <div class="panel-heading">
                            <div>
                                <h2>Store Information</h2>
                                <p class="password-hint mb-0">
                                    This information is shown to customers in the site footer and contact page.
                                </p>
                            </div>
                            <a class="btn secondary-action" href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                        </div>

                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span><c:out value="${error}"/></span>
                            </div>
                        </c:if>
                        <c:if test="${not empty sessionScope.success}">
                            <div class="alert alert-danger">
                                <i class="bi bi-check-circle-fill"></i>
                                <span><c:out value="${sessionScope.success}"/></span>
                            </div>
                            <c:remove var="success" scope="session"/>
                        </c:if>

                        <form class="auth-form" method="post" action="${pageContext.request.contextPath}/manager/storeinfo" autocomplete="on">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label" for="address">Address</label>
                                    <input id="address" name="address"
                                           class="form-control ${not empty errors.address ? 'is-invalid' : ''}"
                                           value="${store.address}"
                                           placeholder="e.g. 123 Nguyen Trai, Ha Noi"
                                           maxlength="255" required>
                                    <c:if test="${not empty errors.address}">
                                        <div class="invalid-feedback">
                                            <c:out value="${errors.address}"/>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="phone">Phone</label>
                                    <input id="phone" name="phone"
                                           class="form-control ${not empty errors.phone ? 'is-invalid' : ''}"
                                           value="${store.phone}"
                                           placeholder="10 digits, e.g. 0912345678"
                                           maxlength="10" required>
                                    <c:if test="${not empty errors.phone}">
                                        <div class="invalid-feedback">
                                            <c:out value="${errors.phone}"/>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="email">Email</label>
                                    <input id="email" name="email" type="email"
                                           class="form-control ${not empty errors.email ? 'is-invalid' : ''}"
                                           value="${store.email}"
                                           placeholder="contact@store.com" maxlength="255" required>
                                    <c:if test="${not empty errors.email}">
                                        <div class="invalid-feedback">
                                            <c:out value="${errors.email}"/>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="col-12">
                                    <label class="form-label" for="facebookUrl">Facebook page URL</label>
                                    <input id="facebookUrl" name="facebookUrl" type="url"
                                           class="form-control ${not empty errors.facebookUrl ? 'is-invalid' : ''}"
                                           value="${store.facebookUrl}"
                                           placeholder="https://facebook.com/yourpage" maxlength="255">
                                    <c:if test="${not empty errors.facebookUrl}">
                                        <div class="invalid-feedback">
                                            <c:out value="${errors.facebookUrl}"/>
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <div class="d-flex align-items-center justify-content-end gap-2 mt-4">
                                <button class="change-password-action" type="submit">
                                    <i class="bi bi-save"></i> Update
                                </button>
                            </div>
                        </form>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>