<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>주문 완료</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5 text-center">
    <div class="card p-5 border-primary shadow-sm" style="max-width: 600px; margin: 0 auto; border-radius: 12px;">
        <h2 class="text-primary mb-4">🎉 결제가 성공적으로 완료되었습니다!</h2>
        
        <div class="alert alert-success p-4" style="border-radius: 8px;">
            <h5 class="text-secondary mb-2">비회원 주문번호</h5>
            <%-- 📡 컨트롤러에서 넘겨받은 GPUR-... 규격의 주문 번호가 영롱하게 렌더링됨 --%>
            <h2 class="display-6 fw-bold text-dark">${orderId}</h2>
        </div>
        
        <p class="text-muted mt-3" style="font-size: 0.95rem; line-height: 1.6;">
            비회원님은 주문번호를 분실할 경우, 도서의 배송 조회가 불가능합니다.<br>
            제대로 확인 후 <strong class="text-danger">반드시 메모장에 복사 및 기입</strong>해 두시기 바랍니다.
        </p>
        
        <div class="mt-4 d-flex justify-content-center gap-3">
            <a href="${pageContext.request.contextPath}/" class="btn btn-secondary px-4 py-2">메인 화면으로</a>
            <%-- 💥 [링크 동기화] 비회원 주문조회 폼이 연동된 전역 로그인/인증 페이지로 안전하게 리다이렉팅 --%>
            <a href="${pageContext.request.contextPath}/member/login" class="btn btn-outline-primary px-4 py-2">주문 내역 조회하기</a>
        </div>
    </div>
</div>
</body>
</html>