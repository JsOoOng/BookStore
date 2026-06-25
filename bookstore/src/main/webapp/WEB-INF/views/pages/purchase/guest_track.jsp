<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white text-center">
                    <h4 class="mb-0">📦 비회원 주문 조회</h4>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted text-center mb-4">주문 번호와 수령인 이름을 입력하여 주문 내역을 확인하세요.</p>
                    
                    <%-- id="trackForm" 추가 --%>
                    <form id="trackForm" action="${pageContext.request.contextPath}/cookie/purchase/trackDetail" method="POST">
                        <div class="mb-3">
                            <label class="form-label">주문 번호 (Purchase ID)</label>
                            <input type="text" name="purchaseId" class="form-control" placeholder="주문 번호를 입력하세요" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">수령인 이름 (Guest Name)</label>
                            <input type="text" name="name" class="form-control" placeholder="이름을 입력하세요" required>
                        </div>
                        
                        <div class="d-grid mt-4">
                            <button type="submit" class="btn btn-primary btn-lg">조회하기</button>
                        </div>
                    </form>
                </div>
                <div class="card-footer text-center">
                    <small class="text-muted">회원 주문 내역은 마이페이지에서 확인 가능합니다.</small>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- 오류 메시지가 있을 경우 알림창 출력 및 폼 초기화 --%>
<c:if test="${not empty errorMsg}">
    <script>
        window.addEventListener('DOMContentLoaded', function() {
            // 1. 서버에서 전달된 오류 메시지 출력
            alert("${errorMsg}");
            
            // 2. 입력된 값 모두 지우기
            document.getElementById("trackForm").reset();
        });
    </script>
</c:if>