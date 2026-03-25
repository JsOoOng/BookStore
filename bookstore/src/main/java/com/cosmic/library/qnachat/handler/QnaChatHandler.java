package com.cosmic.library.qnachat.handler;

import com.cosmic.library.qnachat.model.QnachatVO;
import com.cosmic.library.qnachat.service.QnaChatService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class QnaChatHandler extends TextWebSocketHandler {

    @Autowired
    private QnaChatService qnaChatService;
    
    private List<WebSocketSession> sessions = new ArrayList<>();
    private ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessions.add(session); // 사용자가 채팅방에 들어오면 세션 추가
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        QnachatVO chatVO = objectMapper.readValue(payload, QnachatVO.class);
        
        // DB에 메시지 저장
        qnaChatService.saveMessage(chatVO);

        // 1:1 상담 통신을 위한 라우팅 (메시지 선별 전송)
        for (WebSocketSession s : sessions) {
            Map<String, Object> httpSessionAttrs = s.getAttributes();
            Object loginMember = httpSessionAttrs.get("loginMember");
            
            boolean isSessionAdmin = false;
            
            // HttpSessionHandshakeInterceptor를 통해 전달받은 로그인 정보에서 권한 확인
            if (loginMember != null) {
                String memberInfo = loginMember.toString(); 
                // 객체 정보 문자열에 해당 권한이 포함되어 있는지 확인 (가장 범용적인 체크 방식)
                if (memberInfo.contains("SUPER") || memberInfo.contains("QNAadmin")) {
                    isSessionAdmin = true;
                }
            }
            
            // 전송 조건:
            // 1. 본인이 보낸 메시지이거나 (자신 화면에 표시하기 위함)
            // 2. 메시지를 수신하는 쪽이 관리자(SUPER, QNAadmin)인 경우에만 전송
            // -> 이렇게 하면 유저들끼리는 서로의 메시지를 받지 못합니다.
            if (s.getId().equals(session.getId()) || isSessionAdmin) {
                s.sendMessage(new TextMessage(objectMapper.writeValueAsString(chatVO)));
            }
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessions.remove(session); // 채팅방을 나가면 세션 제거
    }
}