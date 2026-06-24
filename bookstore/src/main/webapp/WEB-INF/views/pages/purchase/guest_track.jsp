<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5 mb-5 d-flex justify-content-center">
    <div class="card shadow-sm border-0" style="max-width: 500px; width: 100%; border-radius: 12px; background: #f8fafc;">
        
        <div class="card-header bg-transparent border-0 text-center pt-5 pb-2">
            <div class="mb-3" style="font-size: 2.5rem;">🛰️</div>
            <h3 class="fw-bold" style="color: #0b132b; letter-spacing: -1px;">비회원 주문 조회</h3>
            <p class="text-muted small mt-2">결제 시 발급받은 <strong>사령부 주문번호</strong>와<br><strong>연락처</strong>를 정확히 입력해 주십시오.</p>
        </div>
        
        <div class="card-body px-5 pb-5">
            <%-- 💥 백엔드 추적 컨트롤러로 데이터 전송 --%>
            <form action="${pageContext.request.contextPath}/cookie/purchase/trackDetail" method="post">
                
                <div class="mb-4">
                    <label for="purchaseId" class="form-label fw-bold" style="color: #5d5fef;">주문번호 (Order ID)</label>
                    <input type="text" class="form-control form-control-lg border-0 shadow-sm" 
                           id="purchaseId" name="purchaseId" 
                           placeholder="ex) GPUR-123456789" required
                           style="border-radius: 8px;">
                </div>
                
                <div class="mb-5">
                    <label for="phone" class="form-label fw-bold" style="color: #5d5fef;">연락처 (Phone)</label>
                    <input type="text" class="form-control form-control-lg border-0 shadow-sm" 
                           id="phone" name="phone" 
                           placeholder="ex) 010-1234-5678" required
                           style="border-radius: 8px;">
                </div>
                
                <button type="submit" class="btn btn-primary w-100 fw-bold py-3" 
                        style="border-radius: 8px; background: #5d5fef; border: none; font-size: 1.1rem;">
                    레이더 추적 시작 ➔
                </button>
                
            </form>
            
            <%-- 추적 실패 시 에러 메시지 표출 구역 --%>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger mt-4 text-center" role="alert" style="border-radius: 8px; font-size: 0.9rem;">
                    🚨 ${errorMsg}
                </div>
            </c:if>
            
            <div class="text-center mt-4">
                <a href="${pageContext.request.contextPath}/member/login" class="text-decoration-none text-muted" style="font-size: 0.9rem;">
                    정규 대원이신가요? 사령부 로그인
                </a>
            </div>
        </div>
    </div>
</div>