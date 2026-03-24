<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>문의하기</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .form-container { width: 500px; margin: 50px auto; padding: 20px; border: 1px solid #ccc; border-radius: 8px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input, select, textarea { width: 100%; padding: 8px; box-sizing: border-box; }
        button { background-color: #c0392b; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
    </style>
</head>
<body>

<div class="form-container">
    <h2>문의</h2>
    <p>물건에 관한 질문, 내건의 예약 등 부담없이 문의해 주세요.</p>

    <form action="<%= request.getContextPath() %>/user/submitInquiry" method="post">
        <div class="form-group">
            <label>문의 제목 <span style="color:red;">필수</span></label>
            <input type="text" name="title" placeholder="예: 문의합니다." required />
        </div>

        <div class="form-group">
            <label>이메일 주소</label>
            <input type="email" name="mail" placeholder="예: info@example.com" />
        </div>

        <div class="form-group">
            <label>문의 종류</label>
            <select name="inquiry">
                <option value="책에 대해서">책에 대해서</option>
                <option value="배달 관련">배달 관련</option>
                <option value="기타">기타</option>
            </select>
        </div>

        <div class="form-group">
            <label>문의 내용 <span style="color:red;">필수</span></label>
            <textarea name="detail" rows="5" placeholder="자유롭게 기입해 주십시오." required></textarea>
        </div>

        <button type="submit">보내기</button>
    </form>
</div>

</body>
</html>