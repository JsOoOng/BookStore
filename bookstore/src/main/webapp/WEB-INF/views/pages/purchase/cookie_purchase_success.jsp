<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>주문 완료</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5 text-center">
    <div class="card p-5 border-primary">
        <h2 class="text-primary mb-4">🎉 결제가 성공적으로 완료되었습니다!</h2>
        
        <div class="alert alert-success p-4">
            <h5>주문번호</h5>
            <h2 class="display-5 fw-bold">${orderId}</h2>
        </div>
        
        <p class="text-muted mt-3">
            주문번호를 분실할 경우 조회 및 배송 확인이 어렵습니다.<br>
            <strong>꼭 메모해 두시기 바랍니다.</strong>
        </p>
        
        <div class="mt-4">
            <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">메인으로</a>
            <a href="${pageContext.request.contextPath}/cookie/order/check" class="btn btn-outline-primary">주문 내역 조회하기</a>
        </div>
    </div>
</div>
</body>
</html>