<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="admin-wide-container mt-5 mb-5">
    <div class="cosmic-login-wrapper mx-auto">
        
        <%-- 🌌 통합 헤더 로고 구역 --%>
        <div class="cosmic-login-header text-center mb-5">
            <span class="cosmic-logo-icon">🚀</span>
            <h2 class="cosmic-login-brand">cosmic gateway</h2>
            <p class="cosmic-login-desc">지식의 은하계에 접속하기 위해 인증 방식을 선택해 주세요.</p>
        </div>

        <%-- 🪐 3단 통합 인터페이스 탭 버튼 --%>
        <ul class="login-tabs">
            <li class="login-tab-item active" onclick="switchLoginTab('member')">
                <span class="login-tab-link tab-member">👨‍🚀 일반 대원</span>
            </li>
            <li class="login-tab-item" onclick="switchLoginTab('vendor')">
                <span class="login-tab-link tab-vendor">🏢 파트너사</span>
            </li>
            <li class="login-tab-item" onclick="switchLoginTab('admin')">
                <span class="login-tab-link tab-admin">👑 사령부</span>
            </li>
        </ul>

        <%-- 🚨 로그인 실패 시 에러 프로토콜 배너 (인라인 스타일 완전 소독) --%>
        <c:if test="${not empty param.error}">
            <div class="cosmic-alert-banner alert-danger-cosmic mb-4 text-center">
                <c:choose>
                    <c:when test="${param.error eq 'login_required'}">
                        🔒 보안 프로토콜: 기지 진입을 위해 먼저 로그인을 완료해 주세요.
                    </c:when>
                    <c:otherwise>
                        🚀 신호 오류: 아이디 또는 보안 코드가 일치하지 않습니다.
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <%-- 🎉 신규 대원 가입 성공 배너 (인라인 스타일 완전 소독) --%>
        <c:if test="${param.joinSuccess == 'true'}">
            <div class="cosmic-alert-banner alert-success-cosmic mb-4 text-center">
                🎉 신규 대원 등록 완료! 임무 조율을 위해 로그인을 진행해 주세요.
            </div>
        </c:if>

        <%-- 👨‍🚀 일반 대원 폼 패널 --%>
        <div id="form-panel-member" class="login-form-panel active">
            <form action="${pageContext.request.contextPath}/member/login" method="POST" autocomplete="off">
                <div class="input-group-cosmic">
                    <label for="id">대원 식별 ID</label>
                    <input type="text" id="id" name="id" placeholder="ID를 입력하세요" required autofocus>
                </div>
                <div class="input-group-cosmic">
                    <label for="pw">보안 코드 (PW)</label>
                    <input type="password" id="pw" name="pw" placeholder="Password를 입력하세요" required>
                </div>
                <div class="form-actions-login">

                    <button type="submit" class="btn-confirm-cosmic btn-member-submit">login (회원 입성)</button>
                </div>
                <div class="cosmic-kakao-wrap mt-3">
				    <%-- 💥 [수리 완료] 로컬 주소를 ngrok 도메인으로 긴급 교체! --%>
				    <a href="https://kauth.kakao.com/oauth/authorize?client_id=5704fcbe13d27f9fb045d4e38a2feab2&redirect_uri=https://trace-discount-appraisal.ngrok-free.dev/login/kakao&response_type=code&prompt=login" class="btn-kakao-css">
				        <svg class="kakao-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
				            <path fill="#000000" d="M16 4.64c-6.96 0-12.64 4.48-12.64 10.08 0 3.52 2.32 6.64 5.76 8.48l-1.44 5.44c-.16.48.4.88.8.56l6.8-4.48c.24 0 .48.08.72.08 6.96 0 12.64-4.48 12.64-10.08S22.96 4.64 16 4.64z"/>
				        </svg>
				        카카오 로그인
				    </a>
				</div>
                <div class="login-footer-links text-center">
                    <p class="login-footer-text">아직 탐사대원이 아니신가요?</p>
                    <a href="${pageContext.request.contextPath}/member/join" class="login-redirect-link link-member-color">신규 대원 등록 (Sign Up) &rarr;</a>
                </div>
                
                
            </form>
        </div>

        <%-- 🏢 파트너사 폼 패널 --%>
        <div id="form-panel-vendor" class="login-form-panel">
            <form action="${pageContext.request.contextPath}/vendor/login" method="POST" autocomplete="off">
                <div class="input-group-cosmic">
                    <label for="vendorId">🏢 파트너사 고유 ID</label>
                    <input type="text" id="vendorId" name="vendorId" placeholder="Vendor ID를 입력하세요" required>
                </div>
                <div class="input-group-cosmic">
                    <label for="vendorPw">🔒 물류 암호 보안 코드</label>
                    <input type="password" id="vendorPw" name="vendorPw" placeholder="Vendor Password를 입력하세요" required>
                </div>
                <div class="form-actions-login">
                    <button type="submit" class="btn-confirm-cosmic btn-vendor-submit">Access (파트너 로그인)</button>
                </div>
                <div class="login-footer-links text-center">
                    <p class="login-footer-text">코스믹 라이브러리에 입점하고 싶으신가요?</p>
                    <a href="${pageContext.request.contextPath}/vendor/join" class="login-redirect-link link-vendor-color">파트너 제휴 신청 &rarr;</a>
                </div>
            </form>
        </div>

        <%-- 👑 사령부 폼 패널 --%>
        <div id="form-panel-admin" class="login-form-panel">
            <form action="${pageContext.request.contextPath}/admin/login" method="POST" autocomplete="off">
                <div class="input-group-cosmic">
                    <label for="adminId">🛰️ 사령부 관리자 ID</label>
                    <input type="text" id="adminId" name="adminId" placeholder="Admin ID를 입력하세요" required>
                </div>
                <div class="input-group-cosmic">
                    <label for="adminPw">🔒 사령부 보안 코드 (PW)</label>
                    <input type="password" id="adminPw" name="adminPw" placeholder="Security Code를 입력하세요" required>
                </div>
                <div class="form-actions-login">
                    <button type="submit" class="btn-confirm-cosmic btn-admin-submit">Command (사령부 승인)</button>
                </div>
                <div class="login-footer-links text-center">
                    <p class="login-footer-text">총괄 제어 권한을 소지한 관리자만 접속을 제한 승인합니다.</p>
                </div>
            </form>
        </div>

    </div>
</div>

<%-- 🪐 탭 패널 스위칭 제어 스크립트 (무결성 보존) --%>
<script>
    function switchLoginTab(tabName) {
        const tabItems = document.querySelectorAll('.login-tab-item');
        tabItems.forEach(item => item.classList.remove('active'));
        
        const panels = document.querySelectorAll('.login-form-panel');
        panels.forEach(panel => panel.classList.remove('active'));
        
        if(tabName === 'member') {
            tabItems[0].classList.add('active');
            document.getElementById('form-panel-member').classList.add('active');
        } else if(tabName === 'vendor') {
            tabItems[1].classList.add('active');
            document.getElementById('form-panel-vendor').classList.add('active');
        } else if(tabName === 'admin') {
            tabItems[2].classList.add('active');
            document.getElementById('form-panel-admin').classList.add('active');
        }
    }
</script>