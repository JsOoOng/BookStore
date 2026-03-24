<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>문의 상세보기</title>
    <style>
        .container { width: 600px; margin: 50px auto; padding: 20px; border: 1px solid #ccc; border-radius: 8px; }
        .row { margin-bottom: 10px; }
        .label { font-weight: bold; }
    </style>
</head>
<body>

<div class="container">
    <h2>문의 상세보기</h2>

    <% 
        com.cosmic.library.qnamail.model.QnAMailVO inquiry = (com.cosmic.library.qnamail.model.QnAMailVO) request.getAttribute("inquiry");
    %>

    <div class="row"><span class="label">ID:</span> <%= inquiry.getId() %></div>
    <div class="row"><span class="label">제목:</span> <%= inquiry.getTitle() %></div>
    <div class="row"><span class="label">작성자 이메일:</span> <%= inquiry.getMail() %></div>
    <div class="row"><span class="label">문의 종류:</span> <%= inquiry.getInquiry() %></div>
    <div class="row"><span class="label">내용:</span> <pre><%= inquiry.getDetail() %></pre></div>

    <a href="<%= request.getContextPath() %>/admin/inquiries">목록으로 돌아가기</a>
</div>

</body>
</html>