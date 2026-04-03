<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Cosmic Library - 실시간 통신망</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
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
        
        /* 타임스탬프 CSS 수정: 말풍선 밖으로 꺼내기 위해 relative와 top 속성 제거 */
        .time-stamp { font-size: 0.7rem; color: #7a7a7a; margin: 0 8px; }
        
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
        var historyLoaded = false;
        var replyTimeout; 

        function formatTime(timestamp) {
            var d = timestamp ? new Date(timestamp) : new Date();
            var h = d.getHours();
            var m = d.getMinutes();
            return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
        }

        window.receiveMessageFromGlobal = function(data) {
            var badge = document.getElementById("chatAlarmBadge");
            if (badge) badge.style.display = "none";

            if (data.senderId === "SERVER") {
                if (data.message === "HISTORY_DONE") {
                    historyLoaded = true;
                    if (isAdmin) {
                        for (var roomUser in userRooms) {
                            var msgs = userRooms[roomUser];
                            if (msgs.length > 0) {
                                var lastMsg = msgs[msgs.length - 1];
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
                clearTimeout(replyTimeout);
                var inquiryBtn = document.getElementById("inquiryBtn");
                if (inquiryBtn) {
                    inquiryBtn.style.display = "none"; 
                    replyTimeout = setTimeout(function() {
                        inquiryBtn.style.display = "inline-block";
                    }, 60000); 
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

        // 말풍선 밖으로 시간을 분리하여 배치하도록 DOM 구조 수정
        function renderMessageToBox(data) {
            var chatBox = document.getElementById("chatBox");
            
            var wrapperDiv = document.createElement("div");
            wrapperDiv.className = "msg-wrapper";
            
            var msgDiv = document.createElement("div");
            var nameDiv = document.createElement("div");
            
            var timeSpan = document.createElement("span");
            timeSpan.className = "time-stamp";
            timeSpan.innerHTML = formatTime(data.sendTime);

            if (data.senderId === loginId) {
                // 내 메시지 (우측 정렬)
                msgDiv.className = "msg my-msg";
                msgDiv.innerHTML = data.message;
                
                timeSpan.style.float = "right";
                timeSpan.style.marginTop = "15px"; // 말풍선 높이와 시각적으로 맞추기 위한 여백
                
                // float 특성상 wrapper에 추가하는 순서가 중요합니다.
                // 먼저 msgDiv를 우측 끝에 붙이고, 그 다음에 timeSpan을 우측에 붙여 메시지 왼쪽에 표시되게 합니다.
                wrapperDiv.appendChild(msgDiv);
                wrapperDiv.appendChild(timeSpan);
            } else {
                // 상대방 메시지 (좌측 정렬)
                msgDiv.className = "msg other-msg";
                nameDiv.className = "sender-name";
                
                if(data.senderRole === 'SUPER' || data.senderRole === 'QNAadmin') {
                    nameDiv.innerHTML = "👑 본부 관리자";
                } else {
                    nameDiv.innerHTML = "👨‍🚀 대원 (" + data.senderId + ")";
                }
                
                msgDiv.innerHTML = data.message;
                
                timeSpan.style.float = "left";
                timeSpan.style.marginTop = "15px";

                wrapperDiv.appendChild(nameDiv); // 이름은 block 요소로 위에 배치
                // 먼저 msgDiv를 좌측 끝에 붙이고, 그 다음에 timeSpan을 좌측에 붙여 메시지 오른쪽에 표시되게 합니다.
                wrapperDiv.appendChild(msgDiv);
                wrapperDiv.appendChild(timeSpan);
            }

            chatBox.appendChild(wrapperDiv);
            chatBox.scrollTop = chatBox.scrollHeight; 
        }
    </script>
</body>
</html>