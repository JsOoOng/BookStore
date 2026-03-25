<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Cosmic Library - 실시간 통신망</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #0b0c10; color: #c5c6c7; font-family: 'Malgun Gothic', sans-serif; }
        .chat-container { margin: 30px auto; max-width: 1000px; }
        .box-panel { background-color: #1f2833; border-radius: 15px; padding: 20px; box-shadow: 0 0 15px rgba(0,255,255,0.1); height: 600px; display: flex; flex-direction: column; }
        
        .chat-box { flex-grow: 1; overflow-y: auto; background-color: #0b0c10; padding: 15px; border-radius: 10px; border: 1px solid #45a29e; margin-bottom: 15px; }
        .msg-wrapper { margin-bottom: 15px; clear: both; overflow: hidden; }
        .msg { padding: 10px 15px; border-radius: 20px; max-width: 75%; word-wrap: break-word; display: inline-block; }
        .msg.my-msg { background-color: #45a29e; color: #0b0c10; float: right; border-bottom-right-radius: 0; }
        .msg.other-msg { background-color: #2c3e50; color: #fff; float: left; border-bottom-left-radius: 0; }
        .sender-name { font-size: 0.8rem; color: #66fcf1; margin-bottom: 5px; clear: both; }
        .time-stamp { font-size: 0.7rem; color: #7a7a7a; margin: 0 8px; position: relative; top: 10px; }
        
        .input-group input { background-color: #0b0c10; color: #fff; border: 1px solid #45a29e; }
        .input-group input:focus { background-color: #1f2833; color: #fff; border-color: #66fcf1; box-shadow: none; }
        .btn-send { background-color: #45a29e; color: #0b0c10; font-weight: bold; }
        
        .user-list { overflow-y: auto; background-color: #0b0c10; padding: 10px; border-radius: 10px; border: 1px solid #45a29e; flex-grow: 1; }
        .user-item { padding: 10px; border-bottom: 1px solid #1f2833; cursor: pointer; transition: 0.2s; border-radius: 5px; }
        .user-item:hover { background-color: #2c3e50; }
        .user-item.active { background-color: #45a29e; color: #0b0c10; font-weight: bold; }
        .unread-badge { background-color: #ff4d4d; color: white; border-radius: 50%; padding: 2px 8px; font-size: 0.7rem; float: right; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp" /> 

    <div class="container chat-container">
        <h3 class="text-center mb-4" style="color: #66fcf1;">🛰️ 본부 실시간 통신망</h3>
        
        <div class="row">
            <c:if test="${sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin'}">
                <div class="col-md-4 mb-3">
                    <div class="box-panel">
                        <h5 class="text-warning text-center mb-3">📡 통신 요청 대원</h5>
                        <div id="userList" class="user-list">
                            <div class="text-center text-muted mt-3" id="emptyUserMsg"><small>대기 중인 대원이 없습니다.</small></div>
                        </div>
                    </div>
                </div>
            </c:if>

            <div class="col-md-${(sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin') ? '8' : '12'}">
                <div class="box-panel">
                    <h5 id="chatRoomTitle" class="text-info text-center mb-3">
                        <c:choose>
                            <c:when test="${sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin'}">
                                좌측에서 대원을 선택하세요
                            </c:when>
                            <c:otherwise>
                                👑 본부 관리자와 연결 중...
                            </c:otherwise>
                        </c:choose>
                    </h5>
                    
                    <div id="chatBox" class="chat-box">
                        <div class="text-center text-muted mb-3"><small>-- 보안 연결이 완료되었습니다 --</small></div>
                    </div>
                    
                    <div class="input-group">
                        <input type="text" id="messageInput" class="form-control" placeholder="메시지를 입력하세요..." onkeypress="if(event.keyCode==13) sendMessage();" 
                               ${(sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin') ? 'disabled' : ''}>
                        <button class="btn btn-send" id="sendBtn" onclick="sendMessage()" 
                                ${(sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin') ? 'disabled' : ''}>전송</button>
                    </div>

                    <%-- 일반 유저 전용: 1분 타임아웃 시 나타날 문의게시판 이동 버튼 --%>
                    <c:if test="${sessionScope.loginMember.role ne 'SUPER' and sessionScope.loginMember.role ne 'QNAadmin'}">
                        <div class="text-center mt-3">
                            <button id="inquiryBtn" class="btn btn-outline-warning btn-sm" style="display:none;" onclick="location.href='${pageContext.request.contextPath}/user/inquiry'">
                                ⏳ 상담원이 바쁜가요? 문의 게시판에 남기기 📝
                            </button>
                        </div>
                    </c:if>

                </div>
            </div>
        </div>
    </div>

    <script>
        var loginId = "${sessionScope.loginMember.id}";
        var role = "${sessionScope.loginMember.role}"; 
        var isAdmin = (role === 'SUPER' || role === 'QNAadmin');

        var currentSelectedUser = ""; 
        var userRooms = {}; 
        var historyLoaded = false; // 과거 내역 로드 완료 플래그
        var replyTimeout; // 일반 유저 대기 타이머 변수

        // 시간 포맷팅 함수 (HH:mm)
        function formatTime(timestamp) {
            var d = timestamp ? new Date(timestamp) : new Date();
            var h = d.getHours();
            var m = d.getMinutes();
            return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
        }

        window.receiveMessageFromGlobal = function(data) {
            // 헤더의 글로벌 알람 끄기
            var badge = document.getElementById("chatAlarmBadge");
            if (badge) badge.style.display = "none";

            if (data.senderId === "SERVER") {
                // [수정된 부분] 과거 내역 로딩이 끝났을 때의 처리
                if (data.message === "HISTORY_DONE") {
                    historyLoaded = true;
                    
                    // 관리자라면, 각 유저별 마지막 메시지를 확인해서 '답변 대기' 상태인 방에 New 뱃지 켜기
                    if (isAdmin) {
                        for (var roomUser in userRooms) {
                            var msgs = userRooms[roomUser];
                            if (msgs.length > 0) {
                                var lastMsg = msgs[msgs.length - 1];
                                // 마지막 메시지를 보낸 사람이 해당 유저라면 (관리자가 아직 답장을 안 했다면)
                                if (lastMsg.senderId === roomUser) {
                                    var userBadge = document.getElementById("badge_" + roomUser);
                                    if(userBadge) {
                                        userBadge.style.display = "inline";
                                        userBadge.innerHTML = "New";
                                    }
                                }
                            }
                        }
                    }
                    return;
                }

                if (data.message === "ADMIN_OFFLINE") {
                    clearTimeout(replyTimeout); 
                    var inquiryBtn = document.getElementById("inquiryBtn");
                    if (inquiryBtn) {
                        inquiryBtn.innerHTML = "🚨 현재 관리자가 부재중입니다. 문의 게시판에 남겨주세요 📝";
                        inquiryBtn.style.display = "inline-block";
                    }
                    return;
                }

                if (isAdmin) {
                    var parts = data.message.split(":");
                    var cmd = parts[0];
                    var targetUser = parts[1];
                    if (cmd === "ENTER_USER" || cmd === "LEAVE_USER") {
                        updateUserList(targetUser, cmd);
                    }
                }
                return;
            }

            // 관리자가 답장을 보내면 타이머 해제 및 버튼 숨김
            if (!isAdmin && data.senderRole && (data.senderRole === 'SUPER' || data.senderRole === 'QNAadmin')) {
                clearTimeout(replyTimeout);
                var inquiryBtn = document.getElementById("inquiryBtn");
                if (inquiryBtn) {
                    inquiryBtn.style.display = "none";
                    inquiryBtn.innerHTML = "⏳ 상담원이 바쁜가요? 문의 게시판에 남기기 📝";
                }
            }

            receiveMessage(data);
        };

        function sendMessage() {
            var msgInput = document.getElementById("messageInput");
            var message = msgInput.value;
            var receiverId = "";
            
            if(message.trim() === "") return;

            if (isAdmin) {
                if(currentSelectedUser === "") {
                    alert("좌측에서 대화할 대원을 먼저 선택해주세요.");
                    return;
                }
                receiverId = currentSelectedUser; 
            } else {
                receiverId = "ADMIN";
                
                // 일반 유저가 전송 버튼을 누르면 60초 타이머 시작
                clearTimeout(replyTimeout);
                var inquiryBtn = document.getElementById("inquiryBtn");
                if (inquiryBtn) {
                    inquiryBtn.style.display = "none"; // 기존에 떠있으면 다시 숨김
                    replyTimeout = setTimeout(function() {
                        inquiryBtn.style.display = "inline-block";
                    }, 60000); // 60초 (60000ms)
                }
            }

            var chatVO = {
                senderId: loginId,
                senderRole: role,
                receiverId: receiverId,
                message: message
            };

            globalWs.send(JSON.stringify(chatVO));
            msgInput.value = "";
        }

        function updateUserList(userId, cmd) {
            var userListDiv = document.getElementById("userList");
            var emptyMsg = document.getElementById("emptyUserMsg");

            if (cmd === "ENTER_USER") {
                if(emptyMsg) emptyMsg.style.display = 'none';
                
                var existingItem = document.getElementById("user_item_" + userId);
                if(existingItem) {
                    existingItem.innerHTML = "👨‍🚀 " + userId + " <span id='badge_"+userId+"' class='unread-badge' style='display:none;'>N</span>";
                    existingItem.style.color = "#c5c6c7"; 
                    return;
                }

                if (!userRooms[userId]) userRooms[userId] = [];

                var div = document.createElement("div");
                div.id = "user_item_" + userId;
                div.className = "user-item";
                div.innerHTML = "👨‍🚀 " + userId + " <span id='badge_"+userId+"' class='unread-badge' style='display:none;'>N</span>";
                div.onclick = function() { openChatRoom(userId); };
                userListDiv.appendChild(div);

            } else if (cmd === "LEAVE_USER") {
                var item = document.getElementById("user_item_" + userId);
                if (item) {
                    item.innerHTML = "❌ " + userId + " (연결끊김)";
                    item.style.color = "gray";
                }
            }
        }

        function openChatRoom(userId) {
            currentSelectedUser = userId;
            document.getElementById("chatRoomTitle").innerHTML = "👨‍🚀 [" + userId + "] 대원과의 통신";
            
            document.getElementById("messageInput").disabled = false;
            document.getElementById("sendBtn").disabled = false;
            document.getElementById("messageInput").focus();
            
            var items = document.getElementsByClassName("user-item");
            for(var i=0; i<items.length; i++) items[i].classList.remove("active");
            document.getElementById("user_item_" + userId).classList.add("active");
            document.getElementById("badge_" + userId).style.display = "none";

            var chatBox = document.getElementById("chatBox");
            chatBox.innerHTML = "<div class='text-center text-muted mb-3'><small>-- " + userId + " 님과의 보안 연결 --</small></div>";
            
            var history = userRooms[userId] || [];
            for (var i = 0; i < history.length; i++) {
                renderMessageToBox(history[i]);
            }
        }

        function receiveMessage(data) {
            if (isAdmin) {
                var roomUser = (data.senderId === loginId) ? data.receiverId : data.senderId;
                
                if (!userRooms[roomUser]) {
                    userRooms[roomUser] = [];
                    updateUserList(roomUser, "ENTER_USER"); 
                }
                userRooms[roomUser].push(data);

                if (currentSelectedUser === roomUser) {
                    renderMessageToBox(data);
                } else {
                    // 과거 내역 데이터가 다 들어온 이후 발생하는 '진짜' 새 메시지에만 뱃지 표시
                    if (historyLoaded) {
                        var badge = document.getElementById("badge_" + roomUser);
                        if(badge) {
                            badge.style.display = "inline";
                            badge.innerHTML = "New";
                        }
                    }
                }
            } else {
                renderMessageToBox(data);
            }
        }

        function renderMessageToBox(data) {
            var chatBox = document.getElementById("chatBox");
            
            var wrapperDiv = document.createElement("div");
            wrapperDiv.className = "msg-wrapper";
            
            var msgDiv = document.createElement("div");
            var nameDiv = document.createElement("div");
            var timeHtml = "<span class='time-stamp'>" + formatTime(data.sendTime) + "</span>";

            if (data.senderId === loginId) {
                msgDiv.className = "msg my-msg";
                // 내 메시지는 타임스탬프가 왼쪽에 붙음
                msgDiv.innerHTML = timeHtml + data.message;
            } else {
                msgDiv.className = "msg other-msg";
                nameDiv.className = "sender-name";
                
                if(data.senderRole === 'SUPER' || data.senderRole === 'QNAadmin') {
                    nameDiv.innerHTML = "👑 본부 관리자";
                } else {
                    nameDiv.innerHTML = "👨‍🚀 대원 (" + data.senderId + ")";
                }
                wrapperDiv.appendChild(nameDiv);
                // 상대방 메시지는 타임스탬프가 오른쪽에 붙음
                msgDiv.innerHTML = data.message + timeHtml;
            }

            wrapperDiv.appendChild(msgDiv);
            chatBox.appendChild(wrapperDiv);
            chatBox.scrollTop = chatBox.scrollHeight; 
        }
    </script>
</body>
</html>