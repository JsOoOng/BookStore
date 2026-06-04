<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow-sm">
    <div class="container">
        <%-- 브랜드 로고 --%>
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">🚀 Cosmic Library</a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#cosmicNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="cosmicNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <%-- 일반 메뉴 --%>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/book/list">도서목록</a></li>

                <%-- 상담 메뉴 (알람 유지) --%>
                <li class="nav-item">
                    <a class="nav-link text-success fw-bold" href="${pageContext.request.contextPath}/qna/chat">
                        💬 실시간 상담 <span id="chatAlarmBadge" class="badge bg-danger rounded-pill" style="display:none; font-size: 0.6rem;">New</span>
                    </a>
                </li>

                <%-- 👑 [독립 사령부 연동] 오직 관리자 세션(loginAdmin)이 존재할 때만 드롭다운 관리 메뉴 오픈 --%>
                <c:if test="${not empty sessionScope.loginAdmin}">
				    <li class="nav-item dropdown">
				        <a class="nav-link dropdown-toggle text-warning fw-bold" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
				            👑 사령부 메뉴
				        </a>
				        <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="adminDropdown">
				            
				            <%-- 🛡️ [권한 격리 1] 오직 최고 사령관(SUPER)에게만 총괄 통제 기능 오픈 --%>
				            <c:if test="${sessionScope.loginAdmin.role eq 'SUPER'}">
				                <li><a class="dropdown-item fw-bold text-danger" href="${pageContext.request.contextPath}/admin/userControl">Destroyer 🛰️ 대원 통제 센터</a></li>
				                <li><a class="dropdown-item fw-bold text-warning" href="${pageContext.request.contextPath}/admin/adminControl">Command 👑 사령부 관리 패널</a></li>
				                <li><hr class="dropdown-divider"></li>
				            </c:if>
				            
				            <%-- 📨 [공통 직무] 모든 관리자 직급이 관제할 수 있는 문의 사항 메뉴 --%>
				            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/inquiries">📨 문의 사항 확인</a></li>
				            
				            <%-- 📚 [권한 격리 2] 오직 최고 사령관(SUPER)과 도서 관리자(BOOK_ADMIN)에게만 도서 추가 권한 부여 --%>
				            <c:if test="${sessionScope.loginAdmin.role eq 'SUPER' or sessionScope.loginAdmin.role eq 'BOOK_ADMIN'}">
				                <li><hr class="dropdown-divider"></li>
				                <li><a class="dropdown-item text-info fw-bold" href="${pageContext.request.contextPath}/book/insert">➕ 신규 도서 추가 (Insert)</a></li>
				            </c:if>
				            
				        </ul>
				    </li>
				</c:if>
            </ul>

            <%-- 중앙 검색바 --%>
            <form action="${pageContext.request.contextPath}/book/find" method="get" class="d-flex mx-auto my-2 my-lg-0" style="width: 30%;">
                <input type="text" name="title" class="form-control rounded-pill me-2 bg-dark text-white border-secondary" placeholder="지식 탐험..." aria-label="Search">
                <button class="btn btn-outline-light rounded-pill" type="submit">Search</button>
            </form>
            
            <%-- 오른쪽 사용자 인증 관제 메뉴 --%>
            <ul class="navbar-nav ms-auto align-items-center">
			    <c:choose>
			        <%-- 👑 CASE 1: 사령부 관리자(Admin) 세션이 활성화되어 있는 경우 --%>
			        <c:when test="${not empty sessionScope.loginAdmin}">
			            <li class="nav-item dropdown">
			                <a class="nav-link dropdown-toggle fw-bold" href="#" id="adminProfileDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false" style="color: #ff4757;">
			                    🛡️ ${sessionScope.loginAdmin.adminName} [${sessionScope.loginAdmin.role}]
			                </a>
			                <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark" aria-labelledby="adminProfileDropdown">
			                    <c:if test="${sessionScope.loginAdmin.role eq 'SUPER'}">
			                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/userControl">통제 패널</a></li>
			                    </c:if>
			                    <li><hr class="dropdown-divider"></li>
			                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/member/logout">사령부 로그아웃</a></li>
			                </ul>
			            </li>
			        </c:when>
			
			        <%-- 👨‍🚀 CASE 2: 일반 대원(회원) 세션이 활성화되어 있는 경우 --%>
			        <c:when test="${not empty sessionScope.loginMember}">
			            <li class="nav-item">
			                <a class="nav-link" href="${pageContext.request.contextPath}/basket">🛒 장바구니</a>
			            </li>
			            <li class="nav-item dropdown">
			                <a class="nav-link dropdown-toggle text-primary fw-bold" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
			                    ✨ ${sessionScope.loginMember.name} 대원님
			                </a>
			                <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark" aria-labelledby="userDropdown">
			                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/member/mypage">마이페이지</a></li>
			                    <li><hr class="dropdown-divider"></li>
			                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/member/logout">로그아웃</a></li>
			                </ul>
			            </li>
			        </c:when>
			
			        <%-- 🏢 CASE 3: 입점 기업(벤더) 세션이 활성화되어 있는 경우 --%>
			        <c:when test="${not empty sessionScope.loginVendor}">
			            <li class="nav-item">
			                <a class="btn btn-info btn-sm text-dark fw-bold rounded-pill px-3 me-2" href="${pageContext.request.contextPath}/vendor/dashboard">
			                    🛰️ 파트너 대시보드
			                </a>
			            </li>
			            <li class="nav-item dropdown">
			                <a class="nav-link dropdown-toggle text-warning fw-bold" href="#" id="vendorDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
			                    🏢 ${sessionScope.loginVendor.bizName} 파트너님
			                </a>
			                <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark" aria-labelledby="vendorDropdown">
			                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vendor/dashboard">물류 관리소</a></li>
			                    <li><hr class="dropdown-divider"></li>
			                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/vendor/logout">로그아웃</a></li>
			                </ul>
			            </li>
			        </c:when>
			
			        <%-- 🌌 CASE 4: 둘 다 로그인하지 않은 완전 비회원 상태일 때 --%>
					<c:otherwise>
					    <li class="nav-item">
					        <a class="nav-link" href="${pageContext.request.contextPath}/member/login">로그인</a>
					    </li>
					    <%-- 👥 회원가입 선택 드롭다운 (관리자 가입 통로 원천 봉쇄) --%>
					    <li class="nav-item dropdown">
					        <a class="nav-link btn btn-primary btn-sm text-white ms-lg-2 px-3 dropdown-toggle" href="#" id="joinDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
					            회원가입
					        </a>
					        <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark" aria-labelledby="joinDropdown">
					            <li><a class="dropdown-item fw-bold text-primary" href="${pageContext.request.contextPath}/member/join">👨‍🚀 일반 대원 가입</a></li>
					            <li><hr class="dropdown-divider"></li>
					            <li><a class="dropdown-item fw-bold text-info" href="${pageContext.request.contextPath}/vendor/join">🏢 파트너사 입점 신청</a></li>
					        </ul>
					    </li>
					</c:otherwise>
			    </c:choose>
			</ul>
        </div>
    </div>
</nav>

<%-- 웹소켓 실시간 알람 통신 관제 스크립트 --%>
<script>
    var globalWs;
    var loginId = "";
    var role = "GUEST";

    // 🌟 [스크립트 보안 정화] 세션 분리에 맞게 변수 매핑 갱신
    <c:choose>
        <c:when test="${not empty sessionScope.loginAdmin}">
            loginId = "${sessionScope.loginAdmin.adminId}";
            role = "${sessionScope.loginAdmin.role}";
        </c:when>
        <c:when test="${not empty sessionScope.loginMember}">
            loginId = "${sessionScope.loginMember.id}";
            role = "MEMBER";
        </c:when>
        <c:when test="${not empty sessionScope.loginVendor}">
            loginId = "${sessionScope.loginVendor.vendorId}";
            role = "VENDOR";
        </c:when>
    </c:choose>

    document.addEventListener("DOMContentLoaded", function() {
        if (loginId !== "") { 
            connectGlobalWs();
        }
    });

    function connectGlobalWs() {
        var path = window.location.host + "${pageContext.request.contextPath}";
        globalWs = new WebSocket("ws://" + path + "/chat-ws");

        globalWs.onopen = function() {
            var currentUrl = window.location.href;
            var isChatRoom = currentUrl.indexOf("/qna/chat") !== -1;
            var enterType = isChatRoom ? "ENTER_CHATROOM" : "ENTER_GLOBAL";
            var initMsg = { senderId: loginId, senderRole: role, message: enterType, receiverId: "SERVER" };
            globalWs.send(JSON.stringify(initMsg));
        };

        globalWs.onmessage = function(event) {
            var data = JSON.parse(event.data);
            if (typeof window.receiveMessageFromGlobal === "function") {
                window.receiveMessageFromGlobal(data);
            } else {
                if (data.senderId !== "SERVER" && data.senderId !== loginId && data.message.indexOf("ENTER_") === -1) {
                    var badge = document.getElementById("chatAlarmBadge");
                    if (badge) badge.style.display = "inline-block";
                }
            }
        };
    }
</script>