<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header bg-secondary text-white text-center">
                    <h4 class="mb-0">🔍 주문번호 찾기</h4>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/cookie/purchase/find_check" method="POST">
                        <div class="mb-3">
                            <label class="form-label">이름</label>
                            <input type="text" name="name" class="form-control" placeholder="예: 홍길동" required>
                        </div>
                        <div class="mb-3">
	                        <label>전화번호</label>
							<input type="text" name="phone" class="form-control" 
						       pattern="[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}" 
						       title="010-0000-0000"
						       placeholder="예: 010-0000-0000" required>
                    	</div>
	                    	 <div class="mb-3">
	                        <label>별명</label>
	                        <input type="text" name="nickname" class="form-control" placeholder="예: 별명" required>
                    	</div>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-secondary btn-lg">주문번호 확인하기</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- 2. 오류 메시지 처리 스크립트 추가 --%>
<c:if test="${not empty errorMsg}">
    <script>
        window.addEventListener('DOMContentLoaded', function() {
            alert("${errorMsg}");
            document.getElementById("findForm").reset();
        });
    </script>
</c:if>