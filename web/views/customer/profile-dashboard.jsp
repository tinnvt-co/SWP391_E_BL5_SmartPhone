<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>My Profile | SmartPhone store</title>
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

                    <c:set var="sidebarActive" value="profile" scope="request"/>
                    <%@ include file="/views/common/profile-sidebar.jsp" %>

                    <section>
                        <div class="stat-grid">
                            <div class="stat-box">
                                <span>Account status</span>
                                <strong>${profile.status}</strong>
                            </div>
                            <div class="stat-box">
                                <span>Role</span>
                                <strong>${profile.roleName}</strong>
                            </div>
                            <div class="stat-box">
                                <span>Age</span>
                                <strong><c:out value="${empty profile.age ? '-' : profile.age}"/></strong>
                            </div>
                        </div>

                        <div class="panel content-panel">
                            <div class="d-flex align-items-center justify-content-between gap-3 flex-wrap mb-3">
                                <div>
                                    <h2 class="h4 fw-bold mb-1">Personal Information</h2>
                                    <p class="text-muted mb-0">Keep your contact information ready for checkout and delivery.</p>
                                </div>
                                <a class="btn secondary-action" href="${pageContext.request.contextPath}/products">
                                    <i class="bi bi-grid"></i> Continue shopping
                                </a>
                            </div>

                            <c:if test="${not empty error}">
                                <div class="alert alert-danger d-flex align-items-center gap-2">
                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                    <span>${error}</span>
                                </div>
                            </c:if>
                            <c:if test="${not empty success}">
                                <div class="alert alert-success d-flex align-items-center gap-2">
                                    <i class="bi bi-check-circle-fill"></i>
                                    <span>${success}</span>
                                </div>
                            </c:if>

                            <form method="post" action="${pageContext.request.contextPath}/profile" autocomplete="on">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label" for="username">Username</label>
                                        <input id="username" class="form-control readonly-field" value="${profile.username}" readonly>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label" for="email">Email</label>
                                        <input id="email" class="form-control readonly-field" value="${profile.email}" readonly>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label" for="name">Full name</label>
                                        <input id="name" name="name" class="form-control" value="${profile.name}"
                                               maxlength="255" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label" for="phone">Phone</label>
                                        <input id="phone" name="phone" class="form-control" value="${profile.phone}"
                                               placeholder="9-15 digits" maxlength="15">
                                    </div>

                                    <div class="col-md-4">
                                        <label class="form-label" for="age">Age</label>
                                        <input id="age" name="age" type="number" class="form-control"
                                               value="${profile.age}" min="13" max="100">
                                    </div>

                                    <div class="col-md-8">
                                        <label class="form-label" for="image">Avatar URL</label>
                                        <input id="image" name="image" class="form-control" value="${profile.image}"
                                               placeholder="https://..." maxlength="255">
                                    </div>

                                    <div class="col-12">
                                        <label class="form-label" for="address">Delivery address</label>
                                        <input id="address" name="address" class="form-control" value="${profile.address}"
                                               placeholder="Your delivery address" maxlength="255">
                                    </div>
                                </div>

                                <div class="d-flex align-items-center justify-content-end gap-2 mt-4">
                                    <button class="btn primary-action" type="submit">
                                        <i class="bi bi-save"></i> Save changes
                                    </button>
                                </div>
                            </form>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
