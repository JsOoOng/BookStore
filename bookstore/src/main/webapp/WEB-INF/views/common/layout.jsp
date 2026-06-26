<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>우주 도서관 (Cosmic Library)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css?ver=1">
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>

    <c:import url="/WEB-INF/views/common/header.jsp" />

    <%-- 🌌 본문 선체 크기 제어 --%>
    <main class="main-content" style="min-height: 70vh; padding-bottom: 50px;">
        <jsp:include page="/WEB-INF/views/${pageName}.jsp" />
    </main>

    <c:import url="/WEB-INF/views/common/footer.jsp" />

    <div class="cosmic-side-panel" id="cosmicSidePanel">
        
        <c:if test="${not empty sessionScope.loginAdmin}">
            <div class="panel-admin-sidebar">
                <div class="admin-sidebar-header">
                    <h6>📡 통신 요청 대원</h6>
                </div>
                <div id="panelUserList" class="panel-user-list-vertical">
                    <div class="text-center text-muted py-4" id="panelEmptyMsg"><small>대기 대원 없음</small></div>
                </div>
            </div>
        </c:if>

        <div class="panel-chat-main">
            <div class="panel-header">
                <div class="panel-title-area">
                    <span class="panel-status-dot"></span>
                    <h5 class="panel-title" id="panelChatTitle">👑 본부 통신망</h5>
                </div>
                <button type="button" class="btn-panel-close" onclick="toggleCosmicPanel()">✕</button>
            </div>
            
            <div class="panel-chat-body" id="panelChatBox">
                <div class="text-center text-muted my-2" id="panelStatusIndicator">
                    <small>📡 통신망 연결 대기 중...</small>
                </div>
            </div>
            
            <div class="panel-chat-footer">
                <div class="panel-input-group">
                    <input type="text" id="panelMessageInput" placeholder="본부에 메시지 송신..." onkeypress="if(event.keyCode==13) sendPanelMessage();">
                    <button type="button" id="panelSendBtn" onclick="sendPanelMessage()">전송</button>
                </div>
                <c:if test="${empty sessionScope.loginAdmin}">
                    <div class="panel-helper-link text-center mt-2">
                        <a href="${pageContext.request.contextPath}/user/inquiry" id="panelInquiryBtn" style="display:none;">⏳ 부재중 시 문의 게시판 이용 📝</a>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <div class="cosmic-fab-wrapper">
        <span class="cosmic-fab-tooltip">이 페이지에 대해 채팅하기</span>
        <button type="button" class="cosmic-fab-btn" onclick="toggleCosmicPanel()">
            <span class="fab-icon">💬</span>
            <span id="panelAlarmBadge" class="panel-alarm-badge" style="display:none;"></span>
        </button>
    </div>


    <%-- 🪐 구조 안전지대: 미니멀 스퀘어 폼 스타일 클래스(cosmic-minimal-modal) 장착 완공 --%>
    <div class="modal fade cosmic-minimal-modal" id="productUpdateModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true" style="display: none;">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="modalBookTitle">도서 수정 관제</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/vendor/product/update" method="post">
                    <div class="modal-body">
                        <input type="hidden" id="modalSaleId" name="saleId">
                        <div class="mb-3">
                            <label for="modalPrice" class="form-label fw-bold">PRICE / 마켓 판매가 변경</label>
                            <div class="input-group">
                                <input type="number" class="form-control text-end" id="modalPrice" name="price" required min="0">
                                <span class="input-group-text">원</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="modalStockQty" class="form-label fw-bold">STOCK / 실시간 공급 재고 조정</label>
                            <div class="input-group">
                                <input type="number" class="form-control text-end" id="modalStockQty" name="stockQty" required min="0">
                                <span class="input-group-text">개</span>
                            </div>
                        </div>
                        <div>
                            <label for="modalSaleStatus" class="form-label fw-bold">STATUS / 마켓 노출 상태</label>
                            <select class="form-select" id="modalSaleStatus" name="saleStatus">
                                <option value="ON">ON (마켓 즉시 노출)</option>
                                <option value="OFF">OFF (마켓 노출 중지)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-close-modal" data-bs-dismiss="modal">닫기</button>
                        <button type="submit" class="btn btn-submit-modal fw-bold">변경사항 동기화</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        var loginId = "";
        var role = "GUEST";
        
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

        // 패널 개폐 제어 스위치
        function toggleCosmicPanel() {
            // 방어막: 비로그인 상태일 경우 로그인 페이지로 격리 유도
            if (loginId === "") {
                if (confirm("🔒 실시간 상담망은 로그인 후 개통 가능합니다.\n로그인 기지로 워프하시겠습니까?")) {
                    location.href = "${pageContext.request.contextPath}/member/login?error=login_required";
                }
                return;
            }
            
            var panel = document.getElementById("cosmicSidePanel");
            panel.classList.toggle("open");
            
            // 패널이 열리면 알람 배지 소독
            if (panel.classList.contains("open")) {
                document.getElementById("panelAlarmBadge").style.display = "none";
                // 2단계에서 이곳에 '패널 개방 시 웹소켓 활성화 및 히스토리 바인딩' 명령을 연동할 예정입니다.
            }
        }
    </script>
</body>

<style>
        /* 💬 사이드 패널 전용 채팅 말풍선 코스믹 테마 */
        .panel-msg-wrapper { display: flex; flex-direction: column; margin-bottom: 12px; width: 100%; }
        .panel-msg { padding: 8px 14px; border-radius: 14px; max-width: 85%; font-size: 13px; line-height: 1.4; word-wrap: break-word; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .panel-my-msg { background-color: #5d5fef; color: #ffffff; align-self: flex-end; border-bottom-right-radius: 4px; }
        .panel-other-msg { background-color: #ffffff; color: #0b132b; align-self: flex-start; border-bottom-left-radius: 4px; border: 1px solid #dfe4ea; }
        .panel-sender-name { font-size: 11px; color: #747d8c; margin-bottom: 4px; font-weight: 700; align-self: flex-start; }
        .panel-time-stamp { font-size: 10px; color: #a4b0be; margin-top: 4px; }
        .panel-my-msg + .panel-time-stamp { align-self: flex-end; }
        .panel-other-msg + .panel-time-stamp { align-self: flex-start; }
    </style>

    <script>
        // 1. 전역 관제 변수 세팅
        var loginId = "";
        var role = "GUEST";
        
        <c:choose>
            <c:when test="${not empty sessionScope.loginAdmin}">
                loginId = "${sessionScope.loginAdmin.adminId}";
                role = "${sessionScope.loginAdmin.role}"; // 'SUPER' or 'BOOK_ADMIN'
            </c:when>
            <c:when test="${not empty sessionScope.loginMember}">
                loginId = "${sessionScope.loginMember.id}";
                role = "MEMBER";
            </c:when>
        </c:choose>

        var isAdmin = (role === "SUPER" || role === "MEMBER_ADMIN" || role === "ADMIN");
        var currentSelectedUser = ""; 
        var userRooms = {}; 
        var historyLoaded = false;
        var replyTimeout; 
        var globalWs = null;

     	// 2. 화면 로드 시 로그인 상태면 통신망 즉시 은닉 개통
        document.addEventListener("DOMContentLoaded", function() {
            // 💥 [Phase 4 추가] 관리자일 경우 패널 프레임 확장!
            if (isAdmin) {
                document.getElementById("cosmicSidePanel").classList.add("admin-mode");
            }
            
            // 로그인 상태면 웹소켓 백그라운드 개통
            if (loginId !== "") {
                initCosmicWebSocket();
            }
        });

        // 3. 웹소켓 파이프라인 개통식
        function initCosmicWebSocket() {
            var wsProtocol = window.location.protocol === "https:" ? "wss://" : "ws://";
            var wsUrl = wsProtocol + window.location.host + "${pageContext.request.contextPath}/chat-ws";
            
            globalWs = new WebSocket(wsUrl);

            globalWs.onopen = function() {
                document.getElementById("panelStatusIndicator").innerHTML = "<small style='color: #2ed573;'>🟢 보안 연결이 완료되었습니다</small>";
                
                var enterSignal = {
                    senderId: loginId,
                    senderRole: role,
                    receiverId: isAdmin ? "" : "admin",
                    message: isAdmin ? "ENTER_GLOBAL" : "ENTER_CHATROOM"
                };
                globalWs.send(JSON.stringify(enterSignal));
            };

            globalWs.onmessage = function(event) {
                var rawData = JSON.parse(event.data);
                receiveMessageFromGlobal(rawData);
            };

            globalWs.onclose = function() {
                document.getElementById("panelStatusIndicator").innerHTML = "<small style='color: #ff4757;'>🔴 통신망 두절 (3초 후 재접속 시도)</small>";
                setTimeout(function() { initCosmicWebSocket(); }, 3000);
            };
        }

        // 4. 패널 개폐 스위치 (알람 뱃지 소독 포함)
        function toggleCosmicPanel() {
            if (loginId === "") {
                if (confirm("🔒 실시간 상담망은 로그인 후 개통 가능합니다.\n로그인 기지로 워프하시겠습니까?")) {
                    location.href = "${pageContext.request.contextPath}/member/login?error=login_required";
                }
                return;
            }
            
            var panel = document.getElementById("cosmicSidePanel");
            panel.classList.toggle("open");
            
            if (panel.classList.contains("open")) {
                document.getElementById("panelAlarmBadge").style.display = "none";
                scrollPanelToBottom();
            }
        }

        // 5. 서버 수신 신호 분배기
        function receiveMessageFromGlobal(data) {
            // 패널이 닫혀있고, 내가 보낸 메시지가 아니며, 시스템 메시지가 아니면 알람 표출
            var panel = document.getElementById("cosmicSidePanel");
            if (!panel.classList.contains("open") && data.senderId !== "SERVER" && data.senderId !== loginId) {
                document.getElementById("panelAlarmBadge").style.display = "block";
            }

            if (data.senderId === "SERVER") {
                if (data.message === "HISTORY_DONE") {
                    historyLoaded = true;
                    return;
                }
                if (data.message === "ADMIN_OFFLINE") {
                    clearTimeout(replyTimeout); 
                    var inquiryBtn = document.getElementById("panelInquiryBtn");
                    if (inquiryBtn) {
                        inquiryBtn.innerHTML = "🚨 관리자 부재중. 문의 게시판 이용 📝";
                        inquiryBtn.style.display = "inline-block";
                    }
                    return;
                }
                if (isAdmin) {
                    var parts = data.message.split(":");
                    if(parts.length > 1) {
                        updateUserList(parts[1], parts[0]);
                    }
                }
                return;
            }

            if (!isAdmin && data.senderRole && (data.senderRole === 'SUPER' || data.senderRole === 'ADMIN')) {
                clearTimeout(replyTimeout);
                var inquiryBtn = document.getElementById("panelInquiryBtn");
                if (inquiryBtn) {
                    inquiryBtn.style.display = "none";
                }
            }

            routeMessageToPanel(data);
        }

        // 6. 패널 말풍선 렌더링 엔진
        function routeMessageToPanel(data) {
            if (isAdmin) {
                var roomUser = (data.senderId === loginId) ? data.receiverId : data.senderId;
                if (!userRooms[roomUser]) {
                    userRooms[roomUser] = [];
                    updateUserList(roomUser, "ENTER_USER"); 
                }
                userRooms[roomUser].push(data);

                if (currentSelectedUser === roomUser) {
                    drawBubble(data);
                } else {
                    var userItem = document.getElementById("user_item_" + roomUser);
                    if(userItem) userItem.style.borderLeft = "4px solid #ff4757"; // 안 읽은 대원 붉은 띠 표시
                }
            } else {
                drawBubble(data);
            }
        }

        function drawBubble(data) {
            var chatBox = document.getElementById("panelChatBox");
            var wrapperDiv = document.createElement("div");
            wrapperDiv.className = "panel-msg-wrapper";
            
            var msgDiv = document.createElement("div");
            var timeSpan = document.createElement("span");
            timeSpan.className = "panel-time-stamp";
            timeSpan.innerHTML = formatTime(data.sendTime);

            if (data.senderId === loginId) {
                msgDiv.className = "panel-msg panel-my-msg";
                msgDiv.innerHTML = data.message;
                wrapperDiv.appendChild(msgDiv);
                wrapperDiv.appendChild(timeSpan);
            } else {
                msgDiv.className = "panel-msg panel-other-msg";
                var nameDiv = document.createElement("div");
                nameDiv.className = "panel-sender-name";
                nameDiv.innerHTML = (data.senderRole === 'SUPER' || data.senderRole === 'ADMIN') ? "👑 본부 관리자" : "👨‍🚀 " + data.senderId;
                msgDiv.innerHTML = data.message;
                
                wrapperDiv.appendChild(nameDiv); 
                wrapperDiv.appendChild(msgDiv);
                wrapperDiv.appendChild(timeSpan);
            }

            chatBox.appendChild(wrapperDiv);
            scrollPanelToBottom();
        }

        // 7. 메시지 발사 엔진
        function sendPanelMessage() {
            var msgInput = document.getElementById("panelMessageInput");
            var message = msgInput.value;
            var receiverId = "";
            
            if(message.trim() === "") return;

            if (isAdmin) {
                if(currentSelectedUser === "") {
                    alert("상단 목록에서 응답할 대원을 먼저 선택하십시오.");
                    return;
                }
                receiverId = currentSelectedUser; 
            } else {
                receiverId = "admin"; // 💥 수리 완료된 DB 타겟 ID 매핑
                clearTimeout(replyTimeout);
                var inquiryBtn = document.getElementById("panelInquiryBtn");
                if (inquiryBtn) {
                    inquiryBtn.style.display = "none"; 
                    replyTimeout = setTimeout(function() {
                        inquiryBtn.style.display = "inline-block";
                    }, 60000); 
                }
            }

            var chatVO = { senderId: loginId, senderRole: role, receiverId: receiverId, message: message };

            if(globalWs && globalWs.readyState === WebSocket.OPEN) {
                globalWs.send(JSON.stringify(chatVO));
            }
            msgInput.value = "";
        }

        // 8. 관리자용 대원 목록 제어 엔진
        function updateUserList(userId, cmd) {
            var userListDiv = document.getElementById("panelUserList");
            var emptyMsg = document.getElementById("panelEmptyMsg");

            if (cmd === "ENTER_USER") {
                if(emptyMsg) emptyMsg.style.display = 'none';
                var existingItem = document.getElementById("user_item_" + userId);
                if(existingItem) {
                    existingItem.innerHTML = "👨‍🚀 " + userId;
                    existingItem.style.color = "#0b132b"; 
                    return;
                }
                if (!userRooms[userId]) userRooms[userId] = [];
                var div = document.createElement("div");
                div.id = "user_item_" + userId;
                div.className = "user-item";
                div.innerHTML = "👨‍🚀 " + userId;
                div.onclick = function() { openPanelChatRoom(userId); };
                userListDiv.appendChild(div);
            } else if (cmd === "LEAVE_USER") {
                var item = document.getElementById("user_item_" + userId);
                if (item) {
                    item.innerHTML = "❌ " + userId + " <small>(이탈)</small>";
                    item.style.color = "#a4b0be";
                }
            }
        }

        function openPanelChatRoom(userId) {
            currentSelectedUser = userId;
            document.getElementById("panelChatTitle").innerHTML = "👨‍🚀 " + userId;
            document.getElementById("panelMessageInput").focus();
            
            var items = document.getElementsByClassName("user-item");
            for(var i=0; i<items.length; i++) {
                items[i].classList.remove("active");
                items[i].style.borderLeft = "1px solid #e2e8f0"; // 붉은 알람 띠 초기화
            }
            
            var userItem = document.getElementById("user_item_" + userId);
            if(userItem) userItem.classList.add("active");

            var chatBox = document.getElementById("panelChatBox");
            chatBox.innerHTML = "<div class='text-center text-muted my-2'><small>-- " + userId + " 대원 통신 기록 --</small></div>";
            
            var history = userRooms[userId] || [];
            for (var i = 0; i < history.length; i++) {
                drawBubble(history[i]);
            }
        }

        // 유틸: 스크롤 최하단 고정 및 시간 포맷
        function scrollPanelToBottom() {
            var chatBox = document.getElementById("panelChatBox");
            chatBox.scrollTop = chatBox.scrollHeight;
        }
        function formatTime(timestamp) {
            var d = timestamp ? new Date(timestamp) : new Date();
            var h = d.getHours(); var m = d.getMinutes();
            return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
        }
    </script>

</html>