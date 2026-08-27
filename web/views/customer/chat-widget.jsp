<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Chat Widget - Customer floating chatbox -->
<!-- Tự động hiện ở góc phải mọi trang customer khi include vào layout -->

<!-- Link CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/chat-widget.css">

<!-- ===== Launcher Button ===== -->
<button class="chat-launcher" id="chatLauncherBtn" aria-label="Chat with Manager">
    <!-- Chat bubble icon -->
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H5.17L4 17.17V4h16v12z"/>
        <path d="M7 9h10v2H7zm0-3h7v2H7z"/>
    </svg>
    <span class="chat-launcher-label">Chat Manager</span>
</button>

<!-- ===== Chat Panel ===== -->
<div class="chat-panel chat-view-customer" id="chatPanel" style="display:none;">

    <!-- Header -->
    <div class="chat-header">
        <div class="chat-header-avatar">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
            </svg>
        </div>
        <div class="chat-header-info">
            <h5>Support</h5>
            <small>SmartPhone Store</small>
        </div>
        <div class="chat-header-actions">
            <c:if test="${chatConversation != null && chatConversation.isOpen()}">
                <span class="chat-conversation-status">${chatConversation.status}</span>
            </c:if>
            <button class="chat-header-btn" id="chatMinimizeBtn" title="Minimize">
                <svg viewBox="0 0 24 24"><path d="M19 13H5v-2h14v2z"/></svg>
            </button>
        </div>
    </div>

    <!-- Messages area -->
    <div class="chat-messages" id="chatbox-messages">
        <c:choose>
            <c:when test="${not empty chatMessages}">
                <c:forEach var="msg" items="${chatMessages}">
                    <div class="chat-msg ${msg.isFromCustomer() ? 'from-customer' : 'from-staff'}">
                        <div class="chat-msg-meta">
                            <strong>${msg.senderName != null ? msg.senderName : msg.senderRole}</strong>
                            <small><fmt:formatDate value="${msg.createdAt}" pattern="dd MMM HH:mm"/></small>
                        </div>
                        <div class="chat-msg-body">${msg.content}</div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="chat-empty">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H5.17L4 17.17V4h16v12z"/>
                    </svg>
                    <h6>Chat with Support</h6>
                    <p>Have questions about your order, products, or anything else? We're here to help!</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Notice for closed conversations -->
    <c:if test="${chatConversation != null && chatConversation.isClosed()}">
        <div class="chat-notice">
            This conversation is closed. Start a new one to chat with us again.
        </div>
    </c:if>

    <!-- Input area -->
    <div class="chat-input-area" id="chatInputArea">
        <form method="post" action="${pageContext.request.contextPath}/customer/chat" id="chatForm">
            <input type="hidden" name="action" value="send"/>
            <div class="chat-input-row">
                <textarea name="content" id="chatInput" rows="1"
                          placeholder="Type a message..."
                          maxlength="2000"
                          ${chatConversation != null && chatConversation.isClosed() ? 'disabled' : ''}></textarea>
                <button type="submit" class="chat-send-btn" title="Send" ${chatConversation != null && chatConversation.isClosed() ? 'disabled' : ''}>
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                    </svg>
                </button>
            </div>
            <c:if test="${chatConversation == null || chatConversation.isClosed()}">
                <p class="chat-close-hint">Start a new conversation by sending a message</p>
            </c:if>
        </form>
    </div>
</div>

<!-- ===== Chat Widget JS ===== -->
<script>
(function() {
    'use strict';

    // ---- Toggle panel ----
    var launcher = document.getElementById('chatLauncherBtn');
    var panel = document.getElementById('chatPanel');
    var minimizeBtn = document.getElementById('chatMinimizeBtn');

    if (!launcher || !panel) return;

    launcher.addEventListener('click', function() {
        var isHidden = panel.style.display === 'none';
        panel.style.display = isHidden ? 'flex' : 'none';
        if (isHidden) {
            // Scroll messages to bottom
            var messagesEl = document.getElementById('chatbox-messages');
            if (messagesEl) {
                messagesEl.scrollTop = messagesEl.scrollHeight;
            }
            // Focus input
            var input = document.getElementById('chatInput');
            if (input && !input.disabled) {
                setTimeout(function() { input.focus(); }, 100);
            }
        }
    });

    if (minimizeBtn) {
        minimizeBtn.addEventListener('click', function() {
            panel.style.display = 'none';
        });
    }

    // ---- Auto-resize textarea ----
    var chatInput = document.getElementById('chatInput');
    if (chatInput) {
        chatInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 100) + 'px';
        });
        // Enter to send (Shift+Enter for newline)
        chatInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                var form = document.getElementById('chatForm');
                if (form) form.submit();
            }
        });
    }

    // ---- Auto-scroll on form submit (non-AJAX) ----
    var chatForm = document.getElementById('chatForm');
    if (chatForm) {
        chatForm.addEventListener('submit', function() {
            // Reload page will re-render messages, scroll handled on panel open
        });
    }

    // ---- Realtime polling (if conversation exists and is open) ----
    <c:if test="${chatConversation != null && chatConversation.isOpen()}">
    var ctxPath = '${pageContext.request.contextPath}';
    if (window.ChatRealtime && typeof window.ChatRealtime.init === 'function') {
        window.ChatRealtime.init({
            conversationId: ${chatConversation.id},
            pollUrl: ctxPath + '/chat-realtime',
            scope: 'customer'
        });
    }
    </c:if>

    // ---- Flash message handling ----
    var urlParams = new URLSearchParams(window.location.search);
    var flash = urlParams.get('flash');
    if (flash) {
        // Remove flash param from URL without reload
        var newUrl = window.location.pathname;
        window.history.replaceState({}, '', newUrl);
    }
})();
</script>
