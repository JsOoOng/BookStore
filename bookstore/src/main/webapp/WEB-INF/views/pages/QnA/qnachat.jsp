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
        .chat-container { max-width: 800px; margin: 50px auto; background-color: #1f2833; border-radius: 15px; box-shadow: 0 0 20px rgba(0,255,255,0.1); padding: 20px; }
        .chat-box { height: 500px; overflow-y: auto; background-color: #0b0c10; padding: 15px; border-radius: 10px; border: 1px solid #45a29e; margin-bottom: 20px; }
        .msg { margin-bottom: 15px; padding: 10px 15px; border-radius: 20px; max-width: 70%; word-wrap: break-word; }
        .msg.my-msg { background-color: #45a29e; color: #0b0c10; margin-left: auto; border-bottom-right-radius: 0; }
        .msg.other-msg { background-color: #2c3e50; color: #fff; margin-right: auto; border-bottom-left-radius: 0; }
        .sender-name { font-size: 0.8rem; color: #66fcf1; margin-bottom: 5px; }
        .input-group input { background-color: #0b0c10; color: #fff; border: 1px solid #45a29e; }
        .input-group input:focus { background-color: #1f2833; color: #fff; border-color: #66fcf1; box-shadow: none; }
        .btn-send { background-color: #45a29e; color: #0b0c10; font-weight: bold; }
        .btn-send:hover { background-color: #66fcf1; }
    </style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/common/header.jsp" />
    <div class="container chat-container">
        <h3 class="text-center mb-4" style="color: #66fcf1;">🛰️ 본부 실시간 통신망</h3>
        
        <div id="chatBox" class="chat-box">
            <div class="text-center text-muted mb-3"><small>-- 보안 연결이 완료되었습니다 --</small></div>
        </div>
        
        <div class="input-group">
            <input type="text" id="messageInput" class="form-control" placeholder="메시지를 입력하여 교신하세요..." onkeypress="if(event.keyCode==13) sendMessage();">
            <button class="btn btn-send" onclick="sendMessage()">전송 (TX)</button>
        </div>
    </div>

    <script>
        var ws;
        var loginId = "${sessionScope.loginMember.id}";
        var loginName = "${sessionScope.loginMember.name}";
        var role = "${sessionScope.loginMember.role}"; 

        window.onload = function() {
            connect();
        };

        function connect() {
            // 웹소켓 연결 (포트와 컨텍스트 경로는 실제 환경에 맞게 자동 설정됨)
            var path = window.location.host + "${pageContext.request.contextPath}";
            ws = new WebSocket("ws://" + path + "/chat-ws");

            ws.onmessage = function(event) {
                var data = JSON.parse(event.data);
                displayMessage(data);
            };

            ws.onclose = function() {
                console.log("통신이 끊어졌습니다.");
            };
        }

        function sendMessage() {
            var msgInput = document.getElementById("messageInput");
            var message = msgInput.value;
            
            if(message.trim() === "") return;

            var chatVO = {
                senderId: loginId,
                senderRole: role,
                message: message
            };

            ws.send(JSON.stringify(chatVO));
            msgInput.value = "";
        }

        function displayMessage(data) {
            var chatBox = document.getElementById("chatBox");
            var msgDiv = document.createElement("div");
            var nameDiv = document.createElement("div");

            // 내가 보낸 메시지인지 다른 사람(관리자/유저)이 보낸 메시지인지 구분
            if (data.senderId === loginId) {
                msgDiv.className = "msg my-msg";
                msgDiv.innerHTML = data.message;
            } else {
                msgDiv.className = "msg other-msg";
                
                // 보낸 사람 이름/직책 표시
                nameDiv.className = "sender-name";
                if(data.senderRole === 'SUPER' || data.senderRole === 'QNAadmin') {
                    nameDiv.innerHTML = "👑 본부 관리자 (" + data.senderId + ")";
                } else {
                    nameDiv.innerHTML = "👨‍🚀 대원 (" + data.senderId + ")";
                }
                chatBox.appendChild(nameDiv);
                msgDiv.innerHTML = data.message;
            }

            chatBox.appendChild(msgDiv);
            chatBox.scrollTop = chatBox.scrollHeight; // 스크롤 맨 아래로 고정
        }
    </script>
</body>
</html>