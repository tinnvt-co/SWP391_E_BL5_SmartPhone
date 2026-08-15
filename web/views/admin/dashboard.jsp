<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Dashboard | SmartPhone store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
        <style>
            body {
                background: #f6f8fb;
                color: #111827;
            }

            .profile-hero {
                background:
                    linear-gradient(120deg, rgba(17, 24, 39, 0.9), rgba(22, 101, 216, 0.78)),
                    url("${pageContext.request.contextPath}/assets/images/home/smartphone-hero.png") center right / cover no-repeat;
                color: #ffffff;
                padding: 56px 0 92px;
            }

            .profile-hero h1 {
                margin: 0 0 10px;
                font-size: clamp(2rem, 5vw, 3.2rem);
                font-weight: 900;
            }

            .profile-hero p {
                max-width: 660px;
                margin: 0;
                color: rgba(255, 255, 255, 0.78);
            }

            .dashboard-shell {
                margin-top: -58px;
                padding-bottom: 64px;
            }

            .dashboard-grid {
                display: grid;
                grid-template-columns: minmax(250px, 320px) minmax(0, 1fr);
                gap: 22px;
                align-items: start;
            }

            .panel {
                background: #ffffff;
                border: 1px solid rgba(15, 23, 42, 0.08);
                border-radius: 8px;
                box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
            }

            .profile-card {
                padding: 24px;
                position: sticky;
                top: 92px;
            }

            .avatar {
                width: 92px;
                height: 92px;
                border-radius: 50%;
                object-fit: cover;
                border: 4px solid #ffffff;
                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.14);
                background: #e2e8f0;
            }

            .avatar-fallback {
                width: 92px;
                height: 92px;
                border-radius: 50%;
                display: grid;
                place-items: center;
                color: #ffffff;
                background: linear-gradient(135deg, #1665d8, #17a673);
                font-size: 2.3rem;
                font-weight: 900;
                border: 4px solid #ffffff;
                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.14);
            }

            .role-pill {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 7px 11px;
                border-radius: 999px;
                color: #14532d;
                background: #dcfce7;
                font-size: 0.8rem;
                font-weight: 800;
            }

            .profile-menu {
                display: grid;
                gap: 8px;
                margin-top: 22px;
            }

            .profile-menu a {
                min-height: 42px;
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 0 12px;
                border-radius: 8px;
                color: #475569;
                text-decoration: none;
                font-weight: 750;
            }

            .profile-menu a.active,
            .profile-menu a:hover {
                color: #1665d8;
                background: #eff6ff;
            }

            .content-panel {
                padding: 24px;
            }

            .stat-card {
                background: #f8fafc;
                border-radius: 12px;
                padding: 24px;
                display: flex;
                align-items: center;
                gap: 20px;
                border: 1px solid rgba(15, 23, 42, 0.05);
                transition: transform 0.2s, box-shadow 0.2s;
            }

            .stat-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(15, 23, 42, 0.05);
            }

            .stat-icon {
                width: 64px;
                height: 64px;
                border-radius: 16px;
                display: grid;
                place-items: center;
                font-size: 2rem;
                flex-shrink: 0;
            }

            .stat-icon-blue {
                background: #eff6ff;
                color: #3b82f6;
            }

            .stat-icon-purple {
                background: #f5f3ff;
                color: #8b5cf6;
            }

            .stat-info h3 {
                font-size: 0.9rem;
                color: #64748b;
                margin: 0 0 5px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            .stat-info p {
                font-size: 2.2rem;
                font-weight: 900;
                color: #0f172a;
                margin: 0;
                line-height: 1;
            }

            @media (max-width: 991.98px) {
                .dashboard-grid {
                    grid-template-columns: 1fr;
                }

                .profile-card {
                    position: static;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="activePage" value="profile" scope="request"/>
        <%@ include file="/views/common/header.jsp" %>

        <section class="profile-hero">
            <div class="container">
                <h1>Admin Dashboard</h1>
                <p>Welcome back, Administrator. Here's an overview of the system.</p>
            </div>
        </section>

        <main class="dashboard-shell">
            <div class="container">
                <div class="dashboard-grid">
                    <aside class="panel profile-card">
                        <div class="d-flex align-items-center gap-3">
                            <c:choose>
                                <c:when test="${not empty currentUser.image}">
                                    <img class="avatar" src="${currentUser.image}" alt="${currentUser.name}">
                                </c:when>
                                <c:otherwise>
                                    <div class="avatar-fallback">${fn:substring(currentUser.name, 0, 1)}</div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <h2 class="h5 fw-black mb-1">${currentUser.name}</h2>
                                <div class="text-muted small">@${currentUser.username}</div>
                            </div>
                        </div>

                        <div class="mt-4">
                            <span class="role-pill">
                                <i class="bi bi-shield-check"></i> ${currentRole}
                            </span>
                        </div>

                        <nav class="profile-menu">
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person"></i> My Profile
                            </a>
                            <a class="active" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="bi bi-speedometer2"></i> Dashboard
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/users">
                                <i class="bi bi-people"></i> User Management
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/roles">
                                <i class="bi bi-shield-lock"></i> Roles
                            </a>
                            <a href="${pageContext.request.contextPath}/change-password">
                                <i class="bi bi-key"></i> Change Password
                            </a>
                            <a href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </nav>
                    </aside>

                    <section class="panel content-panel">
                        <h2 class="h4 fw-bold mb-4">System Overview</h2>
                        
                        <div class="row g-4 mb-4">
                            <div class="col-md-6">
                                <div class="stat-card">
                                    <div class="stat-icon stat-icon-blue">
                                        <i class="bi bi-people-fill"></i>
                                    </div>
                                    <div class="stat-info">
                                        <h3>Total Users</h3>
                                        <p>${totalUsers}</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="stat-card">
                                    <div class="stat-icon stat-icon-purple">
                                        <i class="bi bi-shield-lock-fill"></i>
                                    </div>
                                    <div class="stat-info">
                                        <h3>Total Roles</h3>
                                        <p>${totalRoles}</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Section -->
                        <div class="row g-4 mb-4">
                            <div class="col-md-6">
                                <div class="panel p-4 h-100">
                                    <h4 class="h5 fw-bold mb-4 text-center">Users by Role</h4>
                                    <canvas id="roleChart" style="max-height: 300px;"></canvas>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="panel p-4 h-100">
                                    <h4 class="h5 fw-bold mb-4 text-center">Users by Status</h4>
                                    <canvas id="statusChart" style="max-height: 300px;"></canvas>
                                </div>
                            </div>
                        </div>
                        
                        <div class="alert alert-info border-0 bg-opacity-10 shadow-none d-flex align-items-center gap-3">
                            <i class="bi bi-info-circle-fill fs-4 text-info"></i>
                            <div>
                                <h5 class="alert-heading fw-bold mb-1">Quick Actions</h5>
                                <p class="mb-0">Use the sidebar to manage users, assign roles, or update your account details.</p>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <%@ include file="/views/common/footer.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                // Parse the data passed from the Controller
                const roleLabels = ${roleLabels};
                const roleData = ${roleData};
                
                const statusLabels = ${statusLabels};
                const statusData = ${statusData};

                // Chart colors
                const roleColors = ['#3b82f6', '#8b5cf6', '#ef4444', '#10b981', '#f59e0b', '#64748b'];
                const statusColors = ['#10b981', '#ef4444'];

                // 1. Users by Role Pie Chart
                const roleCtx = document.getElementById('roleChart').getContext('2d');
                new Chart(roleCtx, {
                    type: 'pie',
                    data: {
                        labels: roleLabels,
                        datasets: [{
                            data: roleData,
                            backgroundColor: roleColors,
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'bottom'
                            }
                        }
                    }
                });

                // 2. Users by Status Doughnut Chart
                const statusCtx = document.getElementById('statusChart').getContext('2d');
                new Chart(statusCtx, {
                    type: 'doughnut',
                    data: {
                        labels: statusLabels,
                        datasets: [{
                            data: statusData,
                            backgroundColor: statusColors,
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'bottom'
                            }
                        }
                    }
                });
            });
        </script>
    </body>
</html>
