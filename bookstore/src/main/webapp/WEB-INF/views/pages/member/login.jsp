<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container admin-theme" style="max-width: 480px; margin-top: 50px;">
    
    <%-- 🌌 통합 헤더 로고 (기존 감성 유지) --%>
    <div class="text-center mb-4">
        <h1 style="font-size: 3rem; margin-bottom: 5px;">🚀</h1>
        <h2 class="fw-bold" style="color: #5d5fef; letter-spacing: -1px;">Cosmic Gateway</h2>
        <p class="text-muted">지식의 은하계에 접속하기 위해 인증 방식을 선택해 주세요.</p>
    </div>

    <%-- 🪐 3단 통합 인터페이스 탭 버튼 (style.css 연동) --%>
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

    <%-- 🚨 [기존 로직 유지] 로그인 실패 시 에러 프로토콜 배너 --%>
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger border-0 mb-4 text-center" 
             style="background: rgba(255, 71, 87, 0.1); color: #ff4757; border-radius: 15px; font-weight: bold;">
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

    <%-- 🎉 [기존 로직 유지] 신규 대원 가입 성공 배너 --%>
    <c:if test="${param.joinSuccess == 'true'}">
        <div class="alert alert-success border-0 mb-4 text-center" 
             style="background: rgba(46, 213, 115, 0.1); color: #2ed573; border-radius: 15px; font-weight: bold;">
            🎉 신규 대원 등록 완료! 임무 조율을 위해 로그인을 진행해 주세요.
        </div>
    </c:if>

    <div id="form-panel-member" class="login-form-panel active">
        <form action="${pageContext.request.contextPath}/member/login" method="POST" autocomplete="off">
            <div class="input-group-cosmic">
                <label for="id">대원 식별 ID</label>
                <input type="text" id="id" name="id" placeholder="ID를 입력하세요" required autofocus>
            </div>
            <div class="input-group-cosmic mt-3">
                <label for="pw">보안 코드 (PW)</label>
                <input type="password" id="pw" name="pw" placeholder="Password를 입력하세요" required>
            </div>
            <div class="mt-4">
                <button type="submit" class="btn-confirm w-100 shadow-lg">Login (대원 입성)</button>
            </div>
            <div class="text-center mt-4 pt-3 border-top border-light">
                <p class="text-muted small">아직 탐사대원이 아니신가요?</p>
                <a href="${pageContext.request.contextPath}/member/join" class="text-decoration-none fw-bold" style="color: #5d5fef;">신규 대원 등록 (Sign Up) →</a>
            </div>
        </form>
    </div>

    <div id="form-panel-vendor" class="login-form-panel">
        <form action="${pageContext.request.contextPath}/vendor/login" method="POST" autocomplete="off">
            <div class="input-group-cosmic">
                <label for="vendorId">🏢 파트너사 고유 ID</label>
                <input type="text" id="vendorId" name="vendorId" placeholder="Vendor ID를 입력하세요" required>
            </div>
            <div class="input-group-cosmic mt-3">
                <label for="vendorPw">🔒 물류 암호 보안 코드</label>
                <input type="password" id="vendorPw" name="vendorPw" placeholder="Vendor Password를 입력하세요" required>
            </div>
            <div class="mt-4">
                <button type="submit" class="btn-confirm w-100 shadow-lg" style="background: linear-gradient(135deg, #17a2b8 0%, #117a8b 100%) !important;">
                    Access (파트너 로그인)
                </button>
            </div>
            <div class="text-center mt-4 pt-3 border-top border-light">
                <p class="text-muted small">코스믹 라이브러리에 입점하고 싶으신가요?</p>
                <a href="${pageContext.request.contextPath}/vendor/join" class="text-decoration-none fw-bold" style="color: #17a2b8;">파트너 제휴 신청 →</a>
            </div>
        </form>
    </div>

    <div id="form-panel-admin" class="login-form-panel">
        <form action="${pageContext.request.contextPath}/admin/login" method="POST" autocomplete="off">
            <div class="input-group-cosmic">
                <label for="adminId">🛰️ 사령부 관리자 ID</label>
                <input type="text" id="adminId" name="adminId" placeholder="Admin ID를 입력하세요" required>
            </div>
            <div class="input-group-cosmic mt-3">
                <label for="adminPw">🔒 사령부 보안 코드 (PW)</label>
                <input type="password" id="adminPw" name="adminPw" placeholder="Security Code를 입력하세요" required>
            </div>
            <div class="mt-4">
                <button type="submit" class="btn-admin-access w-100 shadow-lg">
                    Command (사령부 승인)
                </button>
            </div>
            <div class="text-center mt-4 pt-3 border-top border-light">
                <p class="text-muted small">총괄 제어 권한을 소지한 관리자만 접속을 제한 승인합니다.</p>
            </div>
        </form>
    </div>

</div>

<%-- 🪐 탭 패널 스위칭 제어 스크립트 --%>
<script>
    function switchLoginTab(tabName) {
        // 1. 모든 탭 링크에서 active 클래스 제거
        const tabItems = document.querySelectorAll('.login-tab-item');
        tabItems.forEach(item => item.classList.remove('active'));
        
        // 2. 모든 폼 패널 숨김 처리
        const panels = document.querySelectorAll('.login-form-panel');
        panels.forEach(panel => panel.classList.remove('active'));
        
        // 3. 선택한 탭 및 패널에 active 클래스 부여
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