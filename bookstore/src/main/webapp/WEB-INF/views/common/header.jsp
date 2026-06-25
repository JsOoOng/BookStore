<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 🌟 부트스트랩 다크 테마 원천 차단: bg-white navbar-light 강제 주입 --%>
<nav class="navbar navbar-expand-lg navbar-light bg-white navbar-cosmic sticky-top">
    <div class="container-fluid px-4">
        <%-- 브랜드 로고 --%>
        <a class="logo-text" href="${pageContext.request.contextPath}/">cosmic library</a>
        
        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#cosmicNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="cosmicNavbar">
            <%-- 좌측 기본 메뉴 --%>
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 align-items-center">
                <li class="nav-item">
                    <a class="nav-link fw-bold text-dark" href="${pageContext.request.contextPath}/book/list">도서목록</a>
                </li>
                <li class="nav-item">
                    <%-- 💥 [수리 완료] 파괴된 qna/chat 경로 대신 우측 오버레이 패널을 호출하도록 자바스크립트 락온! --%>
                    <a class="nav-link fw-bold text-dark" href="#" onclick="toggleCosmicPanel(); return false;">
                        실시간 상담 <span id="chatAlarmBadge" class="badge bg-danger ms-1" style="display:none; font-size: 0.65rem;">New</span>
                    </a>
                </li>

                <%-- 👑 관리자 권한 드롭다운 --%>
                <c:if test="${not empty sessionScope.loginAdmin}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle fw-bold text-dark" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            사령부 메뉴
                        </a>
                        <ul class="dropdown-menu shadow-sm border-0" aria-labelledby="adminDropdown">
                            <c:if test="${sessionScope.loginAdmin.role eq 'SUPER'}">
                                <li><a class="dropdown-item fw-bold text-danger" href="${pageContext.request.contextPath}/admin/userControl">대원 통제 센터</a></li>
                                <li><a class="dropdown-item fw-bold text-secondary" href="${pageContext.request.contextPath}/admin/adminControl">사령부 관리 패널</a></li>
                                <li><hr class="dropdown-divider"></li>
                            </c:if>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/inquiries">📨 문의 사항 확인</a></li>
                            <c:if test="${sessionScope.loginAdmin.role eq 'SUPER' or sessionScope.loginAdmin.role eq 'BOOK_ADMIN'}">
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item fw-bold text-primary" href="${pageContext.request.contextPath}/book/insert">➕ 신규 도서 추가</a></li>
                            </c:if>
                        </ul>
                    </li>
                </c:if>
            </ul>

            <%-- 🎯 검색창 래퍼: 부트스트랩 form-control 방해 차단 --%>
            <div class="search-naver-wrapper mx-auto">
                <form action="${pageContext.request.contextPath}/book/find" method="get" class="search-frame-naver">
                    <input type="text" name="title" class="input-naver shadow-none" placeholder="지식 탐험..." autocomplete="off" aria-label="Search">
                    <button class="btn-search-nav" type="submit">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>
                    </button>
                </form>
            </div>
            
            <%-- 오른쪽 사용자 인증 관제 메뉴 --%>
            <ul class="navbar-nav ms-auto align-items-center">
                <c:choose>
                    <c:when test="${not empty sessionScope.loginAdmin}">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold" href="#" id="adminProfileDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false" style="color: #ff4757;">
                                🛡️ ${sessionScope.loginAdmin.adminName} [${sessionScope.loginAdmin.role}]
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="adminProfileDropdown">
                                <c:if test="${sessionScope.loginAdmin.role eq 'SUPER'}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/userControl">통제 패널</a></li>
                                </c:if>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger fw-bold" href="${pageContext.request.contextPath}/member/logout">사령부 로그아웃</a></li>
                            </ul>
                        </li>
                    </c:when>
            
                    <c:when test="${not empty sessionScope.loginMember}">
                        <li class="nav-item me-2">
                            <a class="nav-link fw-bold text-dark" href="${pageContext.request.contextPath}/basket">장바구니</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold text-dark" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                ${sessionScope.loginMember.name} 대원님
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="userDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/member/mypage">마이페이지</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger fw-bold" href="${pageContext.request.contextPath}/member/logout">로그아웃</a></li>
                            </ul>
                        </li>
                    </c:when>
            
                    <c:when test="${not empty sessionScope.loginVendor}">
                        <li class="nav-item me-2">
                            <a class="nav-link fw-bold text-primary" href="${pageContext.request.contextPath}/vendor/dashboard">🚀 파트너 대시보드</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold text-dark" href="#" id="vendorDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                ${sessionScope.loginVendor.bizName}
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="vendorDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vendor/dashboard">물류 관리소</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger fw-bold" href="${pageContext.request.contextPath}/vendor/logout">로그아웃</a></li>
                            </ul>
                        </li>
                    </c:when>
            
                    <c:otherwise>
                        <%-- 💥 [수리 완료] 불필요한 내부 로그인 검증(데드코드) 제거 및 비회원 쿠키 장바구니로 다이렉트 연결 --%>
						<li class="nav-item">
						    <a class="nav-link fw-bold text-dark px-3" href="${pageContext.request.contextPath}/cookie/basket/list">장바구니</a>
						</li>
						<li class="nav-item dropdown">
						    <a class="nav-link dropdown-toggle fw-bold text-dark px-3" href="#" id="guestTrackDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
						        비회원 주문조회
						    </a>
						    
						    <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="guestTrackDropdown">
						        <li>
						            <a class="dropdown-item" href="${pageContext.request.contextPath}/cookie/purchase/track">
						                비회원 주문조회
						            </a>
						        </li>
						        <li><hr class="dropdown-divider"></li>
						        <li>
						            <a class="dropdown-item" href="${pageContext.request.contextPath}/cookie/purchase/find">
						                비회원 주문조회 찾기
						            </a>
						        </li>
						    </ul>
						</li>
                        <li class="nav-item">
                            <a class="nav-link fw-bold text-dark px-3" href="${pageContext.request.contextPath}/member/login">로그인</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold text-dark px-3" href="#" id="joinDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">회원가입</a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="joinDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/member/join">👨‍🚀 일반 대원 가입</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vendor/join">🏢 파트너사 입점 신청</a></li>
                            </ul>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<%-- 💥 드롭다운 작동을 위한 부트스트랩 JS 엔진 강제 주입 --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<%-- 웹소켓 스크립트 무결성 유지 --%>
<script>
    var globalWs; var loginId = ""; var role = "GUEST";
    <c:choose>
        <c:when test="${not empty sessionScope.loginAdmin}">loginId = "${sessionScope.loginAdmin.adminId}"; role = "${sessionScope.loginAdmin.role}";</c:when>
        <c:when test="${not empty sessionScope.loginMember}">loginId = "${sessionScope.loginMember.id}"; role = "MEMBER";</c:when>
        <c:when test="${not empty sessionScope.loginVendor}">loginId = "${sessionScope.loginVendor.vendorId}"; role = "VENDOR";</c:when>
    </c:choose>
    
    document.addEventListener("DOMContentLoaded", function() { if (loginId !== "") { connectGlobalWs(); } });
    
    function connectGlobalWs() {
        var path = window.location.host + "${pageContext.request.contextPath}";
        globalWs = new WebSocket("ws://" + path + "/chat-ws");
        globalWs.onopen = function() {
            var enterType = "ENTER_GLOBAL";
            var initMsg = { senderId: loginId, senderRole: role, message: enterType, receiverId: "SERVER" };
            globalWs.send(JSON.stringify(initMsg));
        };
        globalWs.onmessage = function(event) {
            var data = JSON.parse(event.data);
            if (typeof window.receiveMessageFromGlobal === "function") { window.receiveMessageFromGlobal(data); } 
            else { 
                // 통신 패널이 닫혀있을 때 알림 배지 켜기
                if (data.senderId !== "SERVER" && data.senderId !== loginId && data.message.indexOf("ENTER_") === -1) { 
                    var badge = document.getElementById("chatAlarmBadge"); 
                    if (badge) badge.style.display = "inline-block"; 
                } 
            }
        };
    }
</script>

<%-- ==========================================================================
     🚀 [드롭다운 강제 개방 엔진] 부트스트랩 충돌을 무시하고 해치를 엽니다.
     ========================================================================== --%>
<style>
    /* 강제 개방 시 적용될 애니메이션과 디스플레이 속성 */
    .dropdown-menu.cosmic-force-show {
        display: block !important;
        animation: cosmicDrop 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    
    @keyframes cosmicDrop {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 모든 드롭다운 토글 버튼 색출
        const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
        
        dropdownToggles.forEach(toggle => {
            toggle.addEventListener('click', function(e) {
                e.preventDefault(); // 기본 링크 이동 차단
                e.stopPropagation(); // 부모 요소로의 이벤트 전파 차단 (충돌 방지)
                
                const menu = this.nextElementSibling;
                
                if (menu && menu.classList.contains('dropdown-menu')) {
                    const isShowing = menu.classList.contains('cosmic-force-show');
                    
                    // 1. 현재 열려있는 모든 해치를 강제 폐쇄
                    document.querySelectorAll('.dropdown-menu.cosmic-force-show').forEach(m => {
                        m.classList.remove('cosmic-force-show');
                    });
                    
                    // 2. 내가 클릭한 해치가 닫혀있었다면 즉시 개방
                    if (!isShowing) {
                        menu.classList.add('cosmic-force-show');
                    }
                }
            });
        });

        // 3. 화면의 빈 공간(우주 배경)을 클릭하면 열려있던 해치 자동 폐쇄
        document.addEventListener('click', function(e) {
            if (!e.target.matches('.dropdown-toggle')) {
                document.querySelectorAll('.dropdown-menu.cosmic-force-show').forEach(m => {
                    m.classList.remove('cosmic-force-show');
                });
            }
        });
    });
</script>