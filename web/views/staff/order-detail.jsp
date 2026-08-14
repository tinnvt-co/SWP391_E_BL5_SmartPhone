<%@page contentType="text/html" pageEncoding="UTF-8"%><%@taglib prefix="c" uri="jakarta.tags.core"%><%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html><html><head><title>Order #${order.code}</title><%@include file="../common/head.jsp"%>
        <style>
            .order-detail{
                max-width:760px;
                margin:0 auto;
                display:flex;
                flex-direction:column;
                gap:18px;
                color:#fff
            }
            .order-detail *{
                color:inherit
            }
            .order-detail .pill,.order-detail .pill-status,.order-detail .pill-type,.order-detail .pill-paid,.order-detail .pill-unpaid,.order-detail .pill-pending{
                color:revert
            }
            .order-detail .back-link{
                color:var(--muted);
                font-size:14px;
                display:inline-flex;
                align-items:center;
                gap:6px;
                margin-bottom:6px
            }
            .order-detail .back-link:hover{
                color:var(--text)
            }
            .order-detail .hero{
                background:linear-gradient(135deg,#1a2030,#131927);
                border:1px solid var(--line);
                border-radius:16px;
                padding:22px 26px;
                display:flex;
                justify-content:space-between;
                align-items:center;
                flex-wrap:wrap;
                gap:16px
            }
            .order-detail .hero h1{
                margin:0;
                font-family:'Roboto Slab',serif;
                font-size:28px;
                font-weight:700;
                letter-spacing:-.5px
            }
            .order-detail .hero .meta{
                color:var(--muted);
                font-size:13px;
                margin-top:4px
            }
            .order-detail .hero .right{
                text-align:right
            }
            .order-detail .hero .badge-row{
                display:flex;
                gap:8px;
                justify-content:flex-end;
                margin-bottom:8px
            }
            .order-detail .pill{
                display:inline-block;
                padding:5px 12px;
                border-radius:999px;
                font-size:12px;
                font-weight:600;
                letter-spacing:.4px;
                text-transform:uppercase;
                border:1px solid transparent
            }
            .order-detail .pill-status{
                border-color:#2b3c73;
                background:#11162a;
                color:#cbd2e5
            }
            .order-detail .pill-type{
                border-color:#3d2b73;
                background:#1a1230;
                color:#d0bfff
            }
            .order-detail .pill-paid{
                background:rgba(67,227,173,.12);
                border-color:rgba(67,227,173,.4);
                color:var(--green)
            }
            .order-detail .pill-unpaid{
                background:rgba(236,71,126,.12);
                border-color:rgba(236,71,126,.4);
                color:var(--pink)
            }
            .order-detail .pill-pending{
                background:rgba(255,173,24,.12);
                border-color:rgba(255,173,24,.4);
                color:var(--amber)
            }
            .order-detail .summary{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:18px 22px;
                border-radius:14px;
                background:var(--surface);
                border:1px solid var(--line)
            }
            .order-detail .summary .label{
                color:var(--muted);
                font-size:13px;
                letter-spacing:.4px;
                text-transform:uppercase
            }
            .order-detail .summary .value{
                font-family:'Roboto Slab',serif;
                font-size:24px;
                font-weight:700;
                color:var(--text)
            }
            .order-detail .summary .total .value{
                color:var(--green);
                font-size:30px
            }
            .order-detail .grid2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:18px
            }
            .order-detail .card{
                background:var(--surface);
                border:1px solid var(--line);
                border-radius:14px;
                padding:22px;
                overflow:hidden
            }
            .order-detail .card h3{
                margin:0 0 14px;
                font-family:'Roboto Slab',serif;
                font-size:15px;
                color:#aab2cb;
                letter-spacing:.5px;
                text-transform:uppercase
            }
            .order-detail .person{
                display:flex;
                align-items:center;
                gap:14px;
                margin-bottom:14px
            }
            .order-detail .avatar{
                width:52px;
                height:52px;
                border-radius:50%;
                background:linear-gradient(135deg,#4c82ed,#a34be9);
                color:#fff;
                display:flex;
                align-items:center;
                justify-content:center;
                font-weight:700;
                font-size:18px;
                flex-shrink:0
            }
            .order-detail .person .info b{
                display:block;
                font-size:16px
            }
            .order-detail .person .info small{
                color:var(--muted);
                font-size:13px
            }
            .order-detail .contact{
                display:flex;
                flex-direction:column;
                gap:10px;
                font-size:14px;
                color:var(--muted)
            }
            .order-detail .contact .row{
                display:flex;
                gap:10px;
                align-items:center
            }
            .order-detail .contact .icon{
                width:28px;
                height:28px;
                border-radius:7px;
                background:#1a2030;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:14px;
                color:var(--blue);
                flex-shrink:0
            }
            .order-detail .payment-row{
                display:flex;
                justify-content:space-between;
                padding:10px 0;
                border-bottom:1px solid var(--line);
                font-size:14px
            }
            .order-detail .payment-row:last-child{
                border-bottom:none
            }
            .order-detail .payment-row .k{
                color:var(--muted)
            }
            .order-detail .payment-row .v{
                font-weight:600
            }
            .order-detail .payment-row .v.green{
                color:var(--green)
            }
            .order-detail .items-table{
                width:100%;
                border-collapse:collapse;
                font-size:13.5px;
                table-layout:fixed
            }
            .order-detail .items-table col:nth-child(1){
                width:38%
            }
            .order-detail .items-table col:nth-child(2){
                width:22%
            }
            .order-detail .items-table col:nth-child(3){
                width:8%
            }
            .order-detail .items-table col:nth-child(4){
                width:15%
            }
            .order-detail .items-table col:nth-child(5){
                width:17%
            }
            .order-detail .items-table th{
                text-align:left;
                padding:10px 10px;
                color:var(--muted);
                font-size:11.5px;
                text-transform:uppercase;
                letter-spacing:.5px;
                border-bottom:1px solid var(--line);
                font-weight:600
            }
            .order-detail .items-table th:nth-child(3),.order-detail .items-table th:nth-child(4),.order-detail .items-table th:nth-child(5){
                text-align:right
            }
            .order-detail .items-table td{
                padding:12px 10px;
                border-bottom:1px solid #1a2030;
                vertical-align:top
            }
            .order-detail .items-table tr:last-child td{
                border-bottom:none
            }
            .order-detail .item-product{
                display:flex;
                align-items:flex-start;
                gap:10px;
                min-width:0
            }
            .order-detail .item-img{
                width:40px;
                height:40px;
                border-radius:8px;
                background:#1a2030;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:16px;
                flex-shrink:0;
                overflow:hidden
            }
            .order-detail .item-img img{
                width:100%;
                height:100%;
                object-fit:cover
            }
            .order-detail .item-product .info{
                min-width:0;
                flex:1;
                overflow:hidden;
                display:-webkit-box;
                -webkit-line-clamp:2;
                -webkit-box-orient:vertical
            }
            .order-detail .item-product b{
                display:block;
                font-size:13.5px;
                line-height:1.35;
                color:var(--text);
                word-break:break-word;
                overflow-wrap:break-word
            }
            .order-detail .item-product small{
                display:block;
                color:var(--muted);
                font-size:11.5px;
                margin-top:2px;
                word-break:break-word;
                overflow-wrap:break-word
            }
            .order-detail .item-variant{
                color:var(--muted);
                font-size:12.5px;
                word-break:break-word;
                overflow-wrap:break-word
            }
            .order-detail .item-qty{
                font-weight:700;
                color:var(--blue);
                text-align:right;
                font-size:14px
            }
            .order-detail .item-price{
                text-align:right;
                line-height:1.4;
                font-size:13px
            }
            .order-detail .item-price .now{
                font-weight:600;
                display:block
            }
            .order-detail .item-price s{
                color:var(--muted);
                font-weight:400;
                font-size:11.5px;
                display:block;
                opacity:.7
            }
            .order-detail .item-total{
                text-align:right;
                font-weight:700;
                color:var(--green);
                font-size:14px
            }
            .order-detail .totals{
                margin-top:14px;
                padding-top:14px;
                border-top:1px solid var(--line)
            }
            .order-detail .totals .line{
                display:flex;
                justify-content:space-between;
                padding:5px 0;
                font-size:13.5px
            }
            .order-detail .totals .line.muted{
                color:var(--muted)
            }
            .order-detail .totals .line .v{
                font-weight:600;
                color:var(--text)
            }
            .order-detail .totals .line.muted .v{
                font-weight:500;
                color:var(--muted)
            }
            .order-detail .totals .grand{
                display:flex;
                justify-content:space-between;
                align-items:baseline;
                padding:12px 0 0;
                margin-top:8px;
                border-top:1px dashed var(--line)
            }
            .order-detail .totals .grand .lbl{
                font-size:13px;
                color:var(--muted);
                text-transform:uppercase;
                letter-spacing:.5px;
                font-weight:600
            }
            .order-detail .totals .grand .val{
                font-size:22px;
                font-weight:700;
                color:var(--green);
                font-family:'Roboto Slab',serif
            }
            .order-detail .address-box{
                background:#1a2030;
                border-radius:10px;
                padding:14px 16px;
                font-size:14px;
                line-height:1.6;
                color:#cbd2e5
            }
            .order-detail .status-actions{
                display:flex;
                gap:10px;
                align-items:center;
                flex-wrap:wrap
            }
            .order-detail .status-actions select{
                background:#0f1420;
                border:1px solid var(--line);
                color:var(--text);
                padding:9px 14px;
                border-radius:10px;
                font-size:14px;
                min-width:180px;
                cursor:pointer
            }
            .order-detail .status-actions select:focus{
                outline:none;
                border-color:var(--blue)
            }
            .order-detail .btn-primary{
                background:var(--blue);
                color:#fff;
                border:none;
                padding:10px 22px;
                border-radius:10px;
                font-weight:600;
                font-size:14px;
                cursor:pointer;
                transition:all .15s
            }
            .order-detail .btn-primary:hover{
                background:#5b8fee;
                transform:translateY(-1px)
            }
            .order-detail .timeline{
                position:relative;
                padding-left:24px
            }
            .order-detail .timeline::before{
                content:'';
                position:absolute;
                left:7px;
                top:6px;
                bottom:6px;
                width:2px;
                background:var(--line)
            }
            .order-detail .tl-item{
                position:relative;
                padding-bottom:16px
            }
            .order-detail .tl-item:last-child{
                padding-bottom:0
            }
            .order-detail .tl-item::before{
                content:'';
                position:absolute;
                left:-22px;
                top:4px;
                width:14px;
                height:14px;
                border-radius:50%;
                background:var(--surface);
                border:3px solid var(--muted)
            }
            .order-detail .tl-item.done::before{
                border-color:var(--green);
                background:var(--green)
            }
            .order-detail .tl-item.active::before{
                border-color:var(--blue);
                background:var(--blue);
                box-shadow:0 0 0 4px rgba(76,130,237,.2)
            }
            .order-detail .tl-item .tl-label{
                font-weight:600;
                font-size:14px
            }
            .order-detail .tl-item .tl-meta{
                color:var(--muted);
                font-size:12px;
                margin-top:2px
            }
            @media(max-width:680px){
                .order-detail .grid2{
                    grid-template-columns:1fr
                }
                .order-detail .hero{
                    flex-direction:column;
                    align-items:flex-start
                }
                .order-detail .hero .right{
                    text-align:left
                }
                .order-detail .hero .badge-row{
                    justify-content:flex-start
                }
            }
        </style>
    </head><body>
        <c:set var="pageRole" value="Staff"/><c:set var="pageName" value="Order Detail"/><%@include file="../common/topbar.jsp"%>
        <main class="page-shell">
            <div class="order-detail">

                <a class="back-link" href="${pageContext.request.contextPath}/staff/orders">&larr; Back to orders</a>

                <header class="hero">
                    <div>
                        <h1>Order #${order.code}</h1>
                        <div class="meta">Placed on <fmt:formatDate value="${order.createdAt}" pattern="dd MMM yyyy · HH:mm"/></div>
                    </div>
                    <div class="right">
                        <div class="badge-row">
                            <span class="pill pill-status">${order.status}</span>
                            <span class="pill pill-type">${order.type}</span>
                            <c:choose><c:when test="${order.paidAmount>=order.totalPrice}"><span class="pill pill-paid">Paid</span></c:when><c:when test="${order.paidAmount>0}"><span class="pill pill-pending">Partial</span></c:when><c:otherwise><span class="pill pill-unpaid">Unpaid</span></c:otherwise></c:choose>
                                </div>
                                        <div class="meta">Payment: <c:out value='${order.method}'/></div>
                    </div>
                </header>

                <div class="summary">
                    <div><div class="label">Customer</div><div class="value"><c:out value='${order.userName}'/></div></div>
                    <div style="text-align:right"><div class="label">Items</div><div class="value">${order.itemCount}</div></div>
                </div>

                <div class="grid2">

                    <div class="card">
                        <h3>Customer Information</h3>
                        <div class="person">
                            <div class="avatar"><c:out value="${order.userName!=null?order.userName.substring(0,1):'?'}"/></div>
                            <div class="info"><b><c:out value='${order.userName}'/></b><small>@<c:out value='${order.username}'/></small></div>
                        </div>
                        <div class="contact">
                            <div class="row"><span class="icon">✉</span><span><c:out value='${order.userEmail}'/></span></div>
                            <div class="row"><span class="icon">☎</span><span><c:out value='${order.userPhone}'/></span></div>
                        </div>
                    </div>

                    <div class="card">
                        <h3>Payment Summary</h3>
                        <div class="payment-row"><span class="k">Method</span><span class="v"><c:out value='${order.method}'/></span></div>
                        <div class="payment-row"><span class="k">Subtotal</span><span class="v"><fmt:formatNumber value="${order.totalPrice-order.shippingFee+order.totalDiscount}" pattern="#,##0"/>₫</span></div>
                        <div class="payment-row"><span class="k">Shipping</span><span class="v"><fmt:formatNumber value="${order.shippingFee}" pattern="#,##0"/>₫</span></div>
                        <div class="payment-row"><span class="k">Discount</span><span class="v" style="color:var(--pink)">−<fmt:formatNumber value="${order.totalDiscount}" pattern="#,##0"/>₫</span></div>
                        <div class="payment-row"><span class="k">Total</span><span class="v green"><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>₫</span></div>
                        <div class="payment-row"><span class="k">Paid</span><span class="v green"><fmt:formatNumber value="${order.paidAmount}" pattern="#,##0"/>₫</span></div>
                        <div class="payment-row"><span class="k">Status</span><span class="v"><c:choose><c:when test="${order.paidAmount>=order.totalPrice}"><span class="pill pill-paid">Paid</span></c:when><c:when test="${order.paidAmount>0}"><span class="pill pill-pending">Partial</span></c:when><c:otherwise><span class="pill pill-unpaid">Unpaid</span></c:otherwise></c:choose></span></div>
                            </div>
                        </div>

                <c:if test="${not empty order.recipientName}">
                    <div class="card">
                        <h3>Shipping Address</h3>
                        <div class="address-box">
                            <strong><c:out value='${order.recipientName}'/></strong> · <c:out value='${order.recipientPhone}'/><br>
                            <c:out value='${order.deliveryAddress}'/>
                        </div>
                    </div>
                </c:if>

                <c:if test="${not empty statuses && order.type != 'IMPORT'}">
                    <div class="card">
                        <h3>Update Status</h3>
                        <form method="post" action="${pageContext.request.contextPath}/staff/orders" class="status-actions">
                            <input type="hidden" name="action" value="update-status">
                            <input type="hidden" name="id" value="${order.id}">
                            <select name="status">
                                <c:forEach items="${statuses}" var="s"><option value="${s}" ${order.status==s?'selected':''}><c:out value="${s}"/></option></c:forEach>
                                </select>
                                <button class="btn-primary" type="submit">Save Changes</button>
                            </form>
                        </div>
                </c:if>
                <div class="card">
                    <h3>Items Ordered (${order.itemCount})</h3>
                    <table class="items-table">
                        <colgroup><col><col><col><col><col></colgroup>
                        <thead><tr><th>Product</th><th>Variant</th><th>Qty</th><th>Price</th><th>Total</th></tr></thead>
                        <tbody>
                            <c:forEach items="${order.items}" var="it">
                                <tr>
                                    <td><div class="item-product"><div class="item-img"><c:choose><c:when test="${not empty it.productImage}"><img src="${pageContext.request.contextPath}${it.productImage}" alt=""></c:when><c:otherwise>📦</c:otherwise></c:choose></div><div class="info"><b><c:out value='${it.productName}'/></b><small><c:out value='${it.brandName}'/></small></div></div></td>
                                    <td class="item-variant"><c:out value='${it.memoryLabel}'/> / <c:out value='${it.colorName}'/></td>
                                    <td class="item-qty">×${it.amount}</td>
                                    <td class="item-price"><c:choose><c:when test="${it.discountAmount>0}"><s class="strike"><fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/>₫</s><span class="now"><fmt:formatNumber value="${it.unitPrice-it.discountAmount}" pattern="#,##0"/>₫</span></c:when><c:otherwise><span class="now"><fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/>₫</span></c:otherwise></c:choose></td>
                                    <td class="item-total"><fmt:formatNumber value="${it.total}" pattern="#,##0"/>₫</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    <div class="totals">
                        <div class="line muted"><span>Subtotal</span><span class="v"><fmt:formatNumber value="${order.totalPrice-order.shippingFee}" pattern="#,##0"/>₫</span></div>
                        <div class="line muted"><span>Shipping</span><span class="v"><fmt:formatNumber value="${order.shippingFee}" pattern="#,##0"/>₫</span></div>
                        <div class="grand"><span class="lbl">Grand Total</span><span class="val"><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>₫</span></div>
                    </div>
                </div>

            </div>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/store.js"></script></body></html>