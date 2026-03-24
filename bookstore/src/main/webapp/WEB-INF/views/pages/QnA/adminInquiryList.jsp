<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.cosmic.library.qnamail.model.QnAMailVO" %>
<html>
<head>
    <title>관리자 문의 목록</title>
    <style>
        table { width: 80%; margin: 50px auto; border-collapse: collapse; }
        th, td { border: 1px solid #ccc; padding: 10px; text-align: left; }
        th { background-color: #f4f4f4; }
        a { color: #c0392b; text-decoration: none; }
    </style>
</head>
<body>

<h2 style="text-align:center;">관리자 문의 목록</h2>

<table>
    <tr>
        <th>ID</th>
        <th>제목</th>
        <th>작성자</th>
        <th>메일</th>
        <th>삭제</th>
    </tr>

    <%-- adminController에서 전달한 List<QnAMailVO>를 이용 --%>
    <% 
        List<com.cosmic.library.qnamail.model.QnAMailVO> inquiries = (List<com.cosmic.library.qnamail.model.QnAMailVO>) request.getAttribute("inquiries");
        for (com.cosmic.library.qnamail.model.QnAMailVO inquiry : inquiries) {
    %>
        <tr>
            <td><%= inquiry.getId() %></td>
            <td><a href="<%= request.getContextPath() %>/admin/inquiryDetail?id=<%= inquiry.getId() %>"><%= inquiry.getTitle() %></a></td>
            <td><%= inquiry.getMail() %></td>
            <td><%= inquiry.getMail() %></td>
            <td>
                <form action="<%= request.getContextPath() %>/admin/deleteInquiry" method="post" style="margin:0;">
                    <input type="hidden" name="id" value="<%= inquiry.getId() %>"/>
                    <button type="submit">삭제</button>
                </form>
            </td>
        </tr>
    <% } %>

</table>

</body>
</html>