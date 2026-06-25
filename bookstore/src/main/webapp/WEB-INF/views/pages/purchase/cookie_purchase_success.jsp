<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 🎨 하단에 정의된 CSS가 자동으로 적용됩니다 --%>
<div class="cosmic-success-wrapper">
    <div class="cosmic-success-card">
        
        <%-- 성공을 알리는 에메랄드 발광 아이콘 --%>
        <div class="success-icon-circle">
            <span class="success-icon">🚀</span>
        </div>
        
        <%-- 타이틀 & 설명 --%>
        <h1 class="cosmic-success-title">지식 베이스 전송 완료!</h1>
        <p class="cosmic-success-desc">
            대원님의 주문이 우주 연합 물류 센터에 정상적으로 접수되었습니다.<br>
            선택하신 지식 데이터가 곧 지정된 좌표로 보급될 예정입니다.
        </p>
        
        <%-- 워프(이동) 액션 버튼 --%>
        <div class="cosmic-success-actions">
            <a href="${pageContext.request.contextPath}/" class="btn-cosmic-secondary">
                🌌 사령부 메인으로 귀환
            </a>
            <%-- 정규 회원일 경우 내역 확인 버튼 추가, 비회원은 주문번호 확인 등으로 대체 가능 --%>
            <a href="${pageContext.request.contextPath}/purchase/history" class="btn-cosmic-primary">
                📜 전송 내역 확인
            </a>
        </div>

    </div>
</div>