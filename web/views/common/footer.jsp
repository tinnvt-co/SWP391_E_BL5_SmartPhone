<%-- Chat widget cũ - đã chuyển sang dropdown menu trong header (link /customer/chat) --%>
<%-- <jsp:include page="/customer/chat"/> --%>

<footer class="swp-layout-footer">
    <div class="swp-layout-container">

        <div class="swp-layout-footer-grid">

            <div class="swp-layout-footer-col">
                <div class="swp-layout-footer-brand">
                    <span class="swp-layout-brand-mark">S</span>
                    SmartPhone store
                </div>
                <p>SmartPhone store management and shopping experience.</p>
                <div class="swp-layout-footer-social">
                    <a href="${store.facebookUrl}" target="_blank" rel="noopener" aria-label="Facebook">
                        <i class="bi bi-facebook"></i>
                    </a>
                </div>
            </div>

            <div class="swp-layout-footer-col">
                <h4>Contact</h4>
                <ul>
                    <li><i class="bi bi-geo-alt"></i> ${store.address}</li>
                    <li><i class="bi bi-telephone"></i> ${store.phone}</li>
                    <li><i class="bi bi-envelope"></i> ${store.email}</li>
                </ul>
            </div>

            <div class="swp-layout-footer-col">
                <h4>Quick links</h4>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/products">Products</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#categories">Categories</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#services">Services</a></li>
                </ul>
            </div>

        </div>

        <div class="swp-layout-footer-bottom">
            <span>&copy; 2026 SmartPhone store. All rights reserved.</span>
        </div>

    </div>
</footer>