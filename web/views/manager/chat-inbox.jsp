<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Inbox | SmartPhone store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app-layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/chat-widget.css">
    <%@include file="../common/head.jsp"%>
</head>
<body>
    <c:set var="activePage" value="manager-chat" scope="request"/>
    <%@ include file="/views/common/header.jsp" %>

    <main class="page-shell">
        <div class="page-heading">
            <div>
                <h1>Chat Inbox</h1>
                <p>Reply to customer support conversations.</p>
            </div>
        </div>

        <c:if test="${not empty param.flash}">
            <div class="alert success"><c:out value="${param.flash}"/></div>
        </c:if>

        <!-- Two-column layout: list + detail -->
        <div class="chat-inbox-layout chat-view-manager">
            <!-- Left: conversation list -->
            <aside class="chat-inbox-list">
                <c:choose>
                    <c:when test="${empty conversations}">
                        <div class="empty-state" style="padding:32px 16px">
                            <i class="bi bi-chat-dots" style="font-size:36px;color:#cbd5e1"></i>
                            <p style="margin-top:12px">No conversations yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="conversation-list">
                            <c:forEach var="conv" items="${conversations}">
                                <a class="conv-item ${selectedConversation != null && selectedConversation.id == conv.id ? 'active' : ''}"
                                   href="${pageContext.request.contextPath}/manager/chat?conversationId=${conv.id}">
                                    <div class="conv-avatar">
                                        <i class="bi bi-person-fill"></i>
                                    </div>
                                    <div class="conv-info">
                                        <div class="conv-top">
                                            <strong>${conv.userName != null ? conv.userName : 'Customer #' += conv.userId}</strong>
                                            <small>
                                                <fmt:formatDate value="${conv.lastMessageAt}" pattern="dd MMM HH:mm"/>
                                            </small>
                                        </div>
                                        <div class="conv-preview">
                                            <c:choose>
                                                <c:when test="${not empty conv.lastMessage}">
                                                    <c:out value="${conv.lastMessage}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <em class="muted">No messages yet</em>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </a>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav class="pagination-row">
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/manager/chat?page=${currentPage - 1}">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </c:if>
                        <span>Page ${currentPage} of ${totalPages}</span>
                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/manager/chat?page=${currentPage + 1}">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </c:if>
                    </nav>
                </c:if>
            </aside>

            <!-- Right: conversation detail -->
            <section class="chat-detail-panel">
                <c:choose>
                    <c:when test="${selectedConversation != null}">
                        <!-- Chat header -->
                        <div class="chat-detail-header">
                            <div>
                                <h5>${selectedConversation.userName}</h5>
                                <small class="muted">@customer · <fmt:formatDate value="${selectedConversation.createdAt}" pattern="dd MMM yyyy HH:mm"/></small>
                            </div>
                            <div class="chat-detail-actions">
                                <span class="status-pill ${selectedConversation.status.toLowerCase()}">${selectedConversation.status}</span>
                                <!-- Close button removed: chat is always open -->
                            </div>
                        </div>

                        <!-- Messages -->
                        <div class="chat-detail-messages" id="chatbox-messages">
                            <c:choose>
                                <c:when test="${empty messages}">
                                    <div class="chat-empty">
                                        <i class="bi bi-chat-dots"></i>
                                        <h6>No messages yet</h6>
                                        <p>Start the conversation!</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="msg" items="${messages}">
                                        <div class="chat-msg ${msg.isFromCustomer() ? 'from-customer' : 'from-staff'}">
                                            <div class="chat-msg-meta">
                                                <strong>${msg.senderName != null ? msg.senderName : msg.senderRole}</strong>
                                                <c:if test="${msg.senderRole == 'MANAGER' || msg.senderRole == 'STAFF'}">
                                                    <span class="chat-msg-role">${msg.senderRole}</span>
                                                </c:if>
                                                <small><fmt:formatDate value="${msg.createdAt}" pattern="dd MMM HH:mm:ss"/></small>
                                            </div>
                                            <div class="chat-msg-body">${msg.content}</div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Reply form -->
                        <c:choose>
                            <c:when test="${selectedConversation.status == 'CLOSED'}">
                                <div class="chat-notice" style="padding:16px;text-align:center">
                                    This conversation is closed.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form class="chat-detail-reply" method="post">
                                    <input type="hidden" name="action" value="reply"/>
                                    <input type="hidden" name="conversationId" value="${selectedConversation.id}"/>
                                    <textarea name="content" rows="3"
                                              placeholder="Reply to customer..."
                                              maxlength="2000"
                                              required></textarea>
                                    <button type="submit" class="btn primary">
                                        <i class="bi bi-send"></i> Send Reply
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <div class="chat-empty" style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center">
                            <i class="bi bi-chat-dots" style="font-size:56px;color:#cbd5e1"></i>
                            <h6 style="margin-top:16px;color:#64748b">Select a conversation</h6>
                            <p style="color:#94a3b8;font-size:13px">Choose a conversation from the list to view and reply.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </main>

    <!-- Realtime polling for selected conversation -->
    <c:if test="${selectedConversation != null && selectedConversation.isOpen()}">
        <script src="${pageContext.request.contextPath}/assets/js/chat-realtime.js"></script>
        <script>
            window.addEventListener('DOMContentLoaded', function() {
                if (window.ChatRealtime) {
                    window.ChatRealtime.init({
                        conversationId: ${selectedConversation.id},
                        pollUrl: '${pageContext.request.contextPath}/chat-realtime',
                        scope: 'manager'
                    });
                }
            });
        </script>
    </c:if>

    <script>
    // Auto-scroll messages to bottom
    document.addEventListener('DOMContentLoaded', function() {
        var msgBox = document.getElementById('chatbox-messages');
        if (msgBox) {
            msgBox.scrollTop = msgBox.scrollHeight;
        }
    });
    </script>

    <style>
    /* Inbox layout */
    .chat-inbox-layout {
        display: grid;
        grid-template-columns: 340px 1fr;
        gap: 0;
        height: calc(100vh - 200px);
        min-height: 500px;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        overflow: hidden;
        background: #fff;
    }
    /* Conversation list sidebar */
    .chat-inbox-list {
        border-right: 1px solid #e2e8f0;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        background: #f8fafc;
    }
    .chat-inbox-list::-webkit-scrollbar { width: 4px; }
    .chat-inbox-list::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 2px; }
    .conversation-list { flex: 1; overflow-y: auto; }
    .conv-item {
        display: flex;
        gap: 10px;
        padding: 14px 16px;
        text-decoration: none;
        color: inherit;
        border-bottom: 1px solid #f1f5f9;
        transition: background 0.15s;
        align-items: flex-start;
    }
    .conv-item:hover { background: #f1f5f9; }
    .conv-item.active { background: #eff6ff; border-left: 3px solid #2563eb; }
    .conv-avatar {
        width: 40px; height: 40px;
        border-radius: 50%;
        background: #e2e8f0;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
        font-size: 18px;
        color: #64748b;
    }
    .conv-info { flex: 1; min-width: 0; }
    .conv-top {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 3px;
    }
    .conv-top strong { font-size: 14px; color: #1e293b; }
    .conv-top small { color: #94a3b8; font-size: 11px; }
    .conv-preview {
        font-size: 12px;
        color: #64748b;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        margin-bottom: 5px;
    }
    .conv-meta { display: flex; align-items: center; gap: 6px; }
    .conv-unread {
        background: #ef4444; color: white;
        border-radius: 10px;
        font-size: 11px; font-weight: 700;
        padding: 1px 6px;
    }
    /* Detail panel */
    .chat-detail-panel {
        display: flex; flex-direction: column;
        background: #f8fafc;
    }
    .chat-detail-header {
        padding: 14px 20px;
        border-bottom: 1px solid #e2e8f0;
        background: #fff;
        display: flex; justify-content: space-between; align-items: center;
    }
    .chat-detail-header h5 { margin: 0; font-size: 15px; }
    .chat-detail-actions { display: flex; align-items: center; gap: 8px; }
    .chat-detail-messages {
        flex: 1; overflow-y: auto; padding: 16px 20px;
        display: flex; flex-direction: column; gap: 12px;
    }
    .chat-detail-messages::-webkit-scrollbar { width: 6px; }
    .chat-detail-messages::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
    /* Empty state in detail */
    .chat-empty {
        display: flex; flex-direction: column; align-items: center;
        justify-content: center; padding: 40px 20px;
        text-align: center; color: #64748b;
    }
    .chat-empty i { font-size: 48px; color: #cbd5e1; margin-bottom: 12px; }
    .chat-empty h6 { margin: 0 0 6px; font-size: 16px; color: #334155; }
    .chat-empty p { margin: 0; font-size: 13px; }
    /* Reply form */
    .chat-detail-reply {
        padding: 14px 20px;
        border-top: 1px solid #e2e8f0;
        background: #fff;
        display: flex; gap: 10px; align-items: flex-end;
    }
    .chat-detail-reply textarea {
        flex: 1;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        padding: 10px 12px;
        font-size: 14px;
        font-family: inherit;
        resize: none;
        outline: none;
        transition: border-color 0.15s;
        min-height: 60px;
        max-height: 120px;
    }
    .chat-detail-reply textarea:focus { border-color: #2563eb; }
    /* Pagination */
    .pagination-row {
        display: flex; align-items: center; justify-content: center; gap: 12px;
        padding: 12px 16px;
        border-top: 1px solid #f1f5f9;
        font-size: 13px; color: #64748b;
        background: #fff;
    }
    .pagination-row a { color: #2563eb; text-decoration: none; padding: 4px 8px; }
    .pagination-row a:hover { text-decoration: underline; }
    /* Status pills reused from complaint.css */
    .status-pill { padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
    .status-pill.open { background: #fee2e2; color: #dc2626; }
    .status-pill.in_progress { background: #fef3c7; color: #d97706; }
    .status-pill.closed { background: #d1fae5; color: #059669; }
    /* Alert */
    .alert { padding: 10px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
    .alert.success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
    .alert.error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
    .muted { color: #94a3b8; }
    /* Responsive */
    @media (max-width: 768px) {
        .chat-inbox-layout { grid-template-columns: 1fr; }
        .chat-inbox-list { max-height: 300px; }
    }
    </style>
</body>
</html>
