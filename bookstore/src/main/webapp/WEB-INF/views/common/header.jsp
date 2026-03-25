<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 1. sticky-top 클래스 추가로 헤더 상단 고정 --%>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🚀 Cosmic Library</a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#cosmicNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="cosmicNavbar">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/book/list">도서목록</a></li>


                <%-- 2. 실시간 상담 버튼 (알람 뱃지 포함) --%>
                <li class="nav-item">
                    <a class="nav-link text-success fw-bold" href="${pageContext.request.contextPath}/qna/chat">
                        💬 실시간 상담 <span id="chatAlarmBadge" class="badge bg-danger rounded-pill" style="display:none; font-size: 0.7rem;">New</span>
                    </a>
                </li>

                
                <%-- 로그인한 대원의 세션 정보(loginMember)에서 role을 꺼내와야 합니다 --%>
				<c:if test="${sessionScope.loginMember.role eq 'SUPER'}">
				    <li class="nav-item">
				        <a class="nav-link text-warning fw-bold" href="${pageContext.request.contextPath}/super/userControl">
				            👑 사령실(Admin)
				        </a>
				    </li>
				    <li class="nav-item">
				        <a class="nav-link text-info fw-bold" href="${pageContext.request.contextPath}/admin/inquiries">
				            📨 문의 사항 확인
				        </a>
				    </li>
				    
				    <li class="nav-item">
				        <a class="nav-link text-info fw-bold" href="${pageContext.request.contextPath}/book/insert">
				            도서 추가
				        </a>
				    </li>
				    
				</c:if>


                <c:if test="${sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin'}">
                    <li class="nav-item"><a class="nav-link text-warning fw-bold" href="${pageContext.request.contextPath}/super/userControl">👑 사령실(Admin)</a></li>
                    <li class="nav-item"><a class="nav-link text-info fw-bold" href="${pageContext.request.contextPath}/admin/inquiries">📨 문의 사항 확인</a></li>
                </c:if>
            </ul>

            <form action="${pageContext.request.contextPath}/book/find" method="get" class="d-flex mx-auto" style="width: 35%;">
                <input type="text" name="title" class="form-control rounded-pill me-2 bg-dark text-white border-secondary" placeholder="어떤 지식을 탐험할까요?" aria-label="Search">
                <button class="btn btn-search-nav" type="submit">Search</button>
            </form>
            
            <ul class="navbar-nav ms-auto">
                <c:choose>
                    <c:when test="${empty sessionScope.loginMember}">
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/member/login">🚀 로그인</a></li>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/member/join">신규 대원 등록</a></li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item"><span class="nav-link text-primary fw-bold">✨ ${loginMember.name} 대원님</span></li>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/member/edit">정보 수정</a></li>
                        <li class="nav-item"><a class="nav-link text-danger" href="${pageContext.request.contextPath}/member/logout">로그아웃</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<%-- 3. 글로벌 웹소켓 통신 스크립트 (nav 닫힌 직후 추가) --%>
<script>
    var globalWs;
    var loginId = "${sessionScope.loginMember.id}";
    var role = "${sessionScope.loginMember.role}"; 

    document.addEventListener("DOMContentLoaded", function() {
        if (loginId !== "") { 
            connectGlobalWs();
        }
    });

    function connectGlobalWs() {
        var path = window.location.host + "${pageContext.request.contextPath}";
        globalWs = new WebSocket("ws://" + path + "/chat-ws");

        globalWs.onopen = function() {
            // 핵심 수정: 현재 URL을 확인해서 채팅방이면 CHATROOM, 다른 곳이면 GLOBAL 전송
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
                // 시스템 메시지나 과거 내역 요청 신호가 아닌 '진짜 새 메시지'일 때만 알람 켬
                if (data.senderId !== "SERVER" && data.senderId !== loginId && data.message.indexOf("ENTER_") === -1) {
                    var badge = document.getElementById("chatAlarmBadge");
                    if (badge) badge.style.display = "inline-block";
                }
            }
        };
    }
</script>