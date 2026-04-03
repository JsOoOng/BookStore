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

                <%-- 관리자 메뉴 (드롭다운으로 그룹화) --%>
                <c:if test="${sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin'}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-warning fw-bold" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            👑 관리 메뉴
                        </a>
                        <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="adminDropdown">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/super/userControl">사령실(Admin)</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/inquiries">📨 문의 사항 확인</a></li>
                            <c:if test="${sessionScope.loginMember.role eq 'SUPER'}">
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-info" href="${pageContext.request.contextPath}/book/insert">➕ 도서 추가</a></li>
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
            
            <%-- 오른쪽 사용자 메뉴 --%>
            <ul class="navbar-nav ms-auto">
                <c:choose>
                    <c:when test="${empty sessionScope.loginMember}">
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/member/login">로그인</a></li>
                        <li class="nav-item"><a class="nav-link btn btn-primary btn-sm text-white ms-lg-2" href="${pageContext.request.contextPath}/member/join">회원가입</a></li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/basket">🛒 장바구니</a>
                        </li>
                        <%-- 사용자 정보 드롭다운 --%>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle text-primary fw-bold" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                ✨ ${loginMember.name} 대원님
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark" aria-labelledby="userDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/member/mypage">마이페이지</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/member/logout">로그아웃</a></li>
                            </ul>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<%-- 스크립트 부분 (기능 유지) --%>
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