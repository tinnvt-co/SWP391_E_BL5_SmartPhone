<footer class="swp-layout-footer">
    <div class="swp-layout-container swp-layout-footer-inner">
        <div>
            <strong>SmartPhone store</strong><br>
            <span>SmartPhone store management and shopping experience.</span>
        </div>
        <p>${store.address}</p>
        <p>${store.phone}</p>
        <p>${store.email}</p>
        <a href="${store.facebookUrl}">
            Facebook
        </a>
        <div class="swp-layout-footer-links">
            <a href="${pageContext.request.contextPath}/products">Products</a>
            <a href="${pageContext.request.contextPath}/home#categories">Categories</a>
            <a href="${pageContext.request.contextPath}/home#services">Services</a>
        </div>
    </div>
</footer>

