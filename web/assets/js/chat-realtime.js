/* =============================================================
   Chat Realtime Client
   -------------------------------------------------------------
   Polls the server every few seconds for new chat messages
   and appends them to the chatbox in real time.

   The backend endpoint lives in
       src/java/controller/ChatRealtimeServlet.java

   Tái sử dụng polling mechanism từ complaint-realtime.js cũ.
   ============================================================= */
(function () {
    'use strict';

    var POLL_INTERVAL_MS = 4000;
    var instance = null;

    function init(options) {
        if (!options || !options.conversationId || !options.pollUrl) {
            return;
        }
        if (instance) {
            return;
        }
        var state = {
            conversationId: options.conversationId,
            pollUrl: options.pollUrl,
            scope: options.scope || 'customer',
            since: Date.now(),
            running: false,
            lastStatus: null,
            timer: null
        };
        instance = state;
        schedule(state, 800);
    }

    function schedule(state, delay) {
        if (state.timer) {
            clearTimeout(state.timer);
        }
        state.timer = setTimeout(function () {
            tick(state);
        }, delay);
    }

    function tick(state) {
        if (state.running) {
            return;
        }
        state.running = true;
        var url = state.pollUrl
                + '?conversationId=' + encodeURIComponent(state.conversationId)
                + '&since=' + state.since;

        fetch(url, {credentials: 'same-origin', cache: 'no-store'})
                .then(function (response) {
                    if (!response.ok) {
                        throw new Error('HTTP ' + response.status);
                    }
                    return response.json();
                })
                .then(function (payload) {
                    if (!payload || payload.error) {
                        return;
                    }
                    handlePayload(state, payload);
                })
                .catch(function () {
                    // Network errors are non-fatal; we just retry.
                })
                .finally(function () {
                    state.running = false;
                    schedule(state, POLL_INTERVAL_MS);
                });
    }

    function handlePayload(state, payload) {
        if (payload.status && payload.status !== state.lastStatus) {
            state.lastStatus = payload.status;
            updateConversationStatus(payload.status);
        }
        if (payload.messages && payload.messages.length) {
            var box = document.getElementById('chatbox-messages');
            if (!box) {
                return;
            }
            payload.messages.forEach(function (msg) {
                appendMessage(box, msg, state.scope);
                if (msg.createdAt) {
                    var ts = parseInt(msg.createdAt, 10);
                    if (!isNaN(ts) && ts > state.since) {
                        state.since = ts;
                    }
                }
            });
            scrollToBottom(box);
        }
    }

    function appendMessage(box, msg, scope) {
        var wrapper = document.createElement('div');
        var fromCustomer = msg.senderRole === 'CUSTOMER';
        wrapper.className = 'chat-msg ' + (fromCustomer ? 'from-customer' : 'from-staff');

        var meta = document.createElement('div');
        meta.className = 'chat-msg-meta';
        var name = document.createElement('strong');
        name.textContent = msg.senderName || msg.senderRole;
        meta.appendChild(name);

        if (scope === 'manager') {
            var role = document.createElement('span');
            role.className = 'chat-msg-role';
            role.textContent = msg.senderRole;
            meta.appendChild(role);
        }

        var small = document.createElement('small');
        small.textContent = formatDate(msg.createdAt);
        meta.appendChild(small);

        var body = document.createElement('div');
        body.className = 'chat-msg-body';
        body.textContent = msg.content;

        wrapper.appendChild(meta);
        wrapper.appendChild(body);
        box.appendChild(wrapper);
    }

    function updateConversationStatus(status) {
        var badge = document.querySelector('.chat-conversation-status');
        if (!badge) {
            return;
        }
        badge.textContent = status;
    }

    function formatDate(value) {
        var date = value ? new Date(parseInt(value, 10)) : new Date();
        if (isNaN(date.getTime())) {
            return '';
        }
        var pad = function (n) {
            return n < 10 ? '0' + n : '' + n;
        };
        return pad(date.getDate()) + ' '
                + ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.getMonth()]
                + ' ' + pad(date.getHours()) + ':' + pad(date.getMinutes());
    }

    function scrollToBottom(box) {
        setTimeout(function () {
            box.scrollTop = box.scrollHeight;
        }, 0);
    }

    window.ChatRealtime = {init: init};
})();
