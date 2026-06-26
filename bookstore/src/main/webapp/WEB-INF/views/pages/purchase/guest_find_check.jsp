<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>

<div id="cosmic-guest-find-check-container" class="container mt-5 mb-5">
    <div class="success-card text-center">
        
        <c:choose>
            <c:when test="${not empty foundPurchaseIds}">
                <h2 class="form-main-title mb-3">🔍 조회 결과</h2>
                <p class="text-muted mb-4">입력하신 정보와 일치하는 주문번호 목록입니다.</p>
                
                <%-- 주문번호 리스트 출력 --%>
                <div class="purchase-id-list my-4">
                    <c:forEach var="pid" items="${foundPurchaseIds}">
                        <div class="purchase-id-item">
                            <span class="id-text">${pid}</span>
                        </div>
                    </c:forEach>
                </div>
                
                <a href="${pageContext.request.contextPath}/cookie/purchase/track" class="btn-cosmic-submit w-100 py-3">
                    🚚 주문 조회
                </a>
            </c:when>
            
            <c:otherwise>
                <h2 class="form-main-title text-danger mb-3">❌ 조회 실패</h2>
                <p class="text-muted mb-4">일치하는 주문 정보를 찾을 수 없습니다.</p>
                <a href="${pageContext.request.contextPath}/cookie/purchase/find" class="btn-cosmic-secondary w-100 py-3">
                    🔄 다시 시도하기
                </a>
            </c:otherwise>
        </c:choose>
        
    </div>
</div>