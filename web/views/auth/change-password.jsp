<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Change Password | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
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

                    <c:set var="sidebarActive" value="change-password" scope="request"/>
                    <%@ include file="/views/common/profile-sidebar.jsp" %>

                    <section class="panel content-panel">
                        <div class="panel-heading">
                            <div>
                                <h2>Change password</h2>
                                <p class="password-hint mb-0">Use 6-20 characters with uppercase, lowercase, number, and special character.</p>
                            </div>
                            <a class="btn secondary-action" href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                        </div>

                        <c:if test="${not empty error}">
                            <div class="auth-alert danger">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span>${error}</span>
                            </div>
                        </c:if>
                        <c:if test="${not empty success}">
                            <div class="auth-alert success">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>${success}</span>
                            </div>
                        </c:if>

                        <form class="auth-form" method="post" action="${pageContext.request.contextPath}/change-password" autocomplete="off">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label" for="currentPassword">Current password</label>
                                    <div class="input-group">
                                        <input id="currentPassword" name="currentPassword" type="password" class="form-control"
                                               maxlength="20" required>
                                        <button class="input-group-text btn-toggle" type="button" data-toggle-password="currentPassword" title="Show password">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="newPassword">New password</label>
                                    <div class="input-group">
                                        <input id="newPassword" name="newPassword" type="password" class="form-control"
                                               minlength="6" maxlength="20"
                                               pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9\s])\S{6,20}"
                                               title="Use 6-20 characters with at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character."
                                               required>
                                        <button class="input-group-text btn-toggle" type="button" data-toggle-password="newPassword" title="Show password">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label" for="confirmPassword">Confirm new password</label>
                                    <div class="input-group">
                                        <input id="confirmPassword" name="confirmPassword" type="password" class="form-control"
                                               minlength="6" maxlength="20"
                                               pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9\s])\S{6,20}"
                                               title="Use 6-20 characters with at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character."
                                               required>
                                        <button class="input-group-text btn-toggle" type="button" data-toggle-password="confirmPassword" title="Show password">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex align-items-center justify-content-end gap-2 mt-4">
                                <button class="change-password-action" type="submit">
                                    <i class="bi bi-shield-lock"></i> Change password
                                </button>
                            </div>
                        </form>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.querySelectorAll('[data-toggle-password]').forEach(button => {
                button.addEventListener('click', function () {
                    const input = document.getElementById(this.dataset.togglePassword);
                    if (!input)
                        return;
                    const show = input.type === 'password';
                    input.type = show ? 'text' : 'password';
                    this.innerHTML = show ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
                    this.title = show ? 'Hide password' : 'Show password';
                });
            });
        </script>
    </body>
</html>
