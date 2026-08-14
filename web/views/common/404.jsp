<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Not found</title>
        <%@include file="head.jsp"%>
    </head>
    <body>
        <main class="empty-page">
            <h1>404</h1>
            <p>The requested product or page was not found.</p>
            <a class="btn primary" href="${pageContext.request.contextPath}/products">Back to products</a>
        </main>
    </body>
</html>
