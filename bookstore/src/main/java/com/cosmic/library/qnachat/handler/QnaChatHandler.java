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
import java.util.concurrent.ConcurrentHashMap;

public class QnaChatHandler extends TextWebSocketHandler {

    @Autowired
    private QnaChatService qnaChatService;
    
    private List<WebSocketSession> sessions = new ArrayList<>();
    private Map<String, String> sessionUserMap = new ConcurrentHashMap<>();
    private Map<String, String> sessionRoleMap = new ConcurrentHashMap<>();
    
    private ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessions.add(session);
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        QnachatVO chatVO = objectMapper.readValue(payload, QnachatVO.class);
        
        // 1. 최초 접속 시 (글로벌과 채팅방 분리)
        if ("ENTER_CHATROOM".equals(chatVO.getMessage()) || "ENTER_GLOBAL".equals(chatVO.getMessage())) {
            sessionUserMap.put(session.getId(), chatVO.getSenderId());
            sessionRoleMap.put(session.getId(), chatVO.getSenderRole());
            
            // 사용자가 진짜로 '채팅방 화면'을 열었을 때만 과거 내역을 긁어다 줌
            if ("ENTER_CHATROOM".equals(chatVO.getMessage())) {
                List<QnachatVO> historyList = qnaChatService.getChatHistory(chatVO.getSenderId(), chatVO.getSenderRole());
                for (QnachatVO historyMsg : historyList) {
                    session.sendMessage(new TextMessage(objectMapper.writeValueAsString(historyMsg)));
                }
                
                // [추가] 과거 내역 전송이 끝났음을 프론트엔드에 알리는 시스템 메시지
                QnachatVO doneMsg = new QnachatVO();
                doneMsg.setSenderId("SERVER");
                doneMsg.setMessage("HISTORY_DONE");
                session.sendMessage(new TextMessage(objectMapper.writeValueAsString(doneMsg)));
            }
            
            // 관리자에게 일반 유저 접속 알림 뿌리기
            if (!"SUPER".equals(chatVO.getSenderRole()) && !"QNAadmin".equals(chatVO.getSenderRole())) {
                QnachatVO enterNotice = new QnachatVO();
                enterNotice.setSenderId("SERVER");
                enterNotice.setMessage("ENTER_USER:" + chatVO.getSenderId());
                broadcastToAdmins(enterNotice);
            }
            return; 
        }

        // DB 저장 및 타겟팅 전송 로직 (기존 유지)
try { qnaChatService.saveMessage(chatVO); } catch (Exception e) {}
        
        String senderId = chatVO.getSenderId();
        String senderRole = chatVO.getSenderRole();
        String targetId = chatVO.getReceiverId(); 

        // [추가] 현재 접속 중인 관리자가 있는지 확인
        boolean isAdminOnline = false;
        for (String role : sessionRoleMap.values()) {
            if ("SUPER".equals(role) || "QNAadmin".equals(role)) {
                isAdminOnline = true;
                break;
            }
        }

        // 일반 유저가 보냈는데 접속 중인 관리자가 0명일 경우, 오프라인 시스템 알림을 유저에게 반환
        if (!isAdminOnline && !"SUPER".equals(senderRole) && !"QNAadmin".equals(senderRole)) {
            QnachatVO offlineNotice = new QnachatVO();
            offlineNotice.setSenderId("SERVER");
            offlineNotice.setMessage("ADMIN_OFFLINE");
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(offlineNotice)));
        }

        // 기존 타겟팅 전송 로직
        for (WebSocketSession s : sessions) {
            String sId = s.getId();
            String connectedUserId = sessionUserMap.get(sId);
            String connectedUserRole = sessionRoleMap.get(sId);

            if (connectedUserId == null) continue;

            if ("SUPER".equals(senderRole) || "QNAadmin".equals(senderRole)) {
                if (connectedUserId.equals(targetId) || "SUPER".equals(connectedUserRole) || "QNAadmin".equals(connectedUserRole)) {
                    s.sendMessage(new TextMessage(objectMapper.writeValueAsString(chatVO)));
                }
            } else {
                if (connectedUserId.equals(senderId) || "SUPER".equals(connectedUserRole) || "QNAadmin".equals(connectedUserRole)) {
                    s.sendMessage(new TextMessage(objectMapper.writeValueAsString(chatVO)));
                }
            }
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        String disconnectedUserId = sessionUserMap.get(session.getId());
        String disconnectedUserRole = sessionRoleMap.get(session.getId());
        
        sessions.remove(session);
        sessionUserMap.remove(session.getId());
        sessionRoleMap.remove(session.getId());

        // 유저가 나갔을 때 관리자에게 알림 전송
        if (disconnectedUserId != null && !"SUPER".equals(disconnectedUserRole) && !"QNAadmin".equals(disconnectedUserRole)) {
            QnachatVO leaveNotice = new QnachatVO();
            leaveNotice.setSenderId("SERVER");
            leaveNotice.setMessage("LEAVE_USER:" + disconnectedUserId);
            broadcastToAdmins(leaveNotice);
        }
    }

    // 관리자들에게만 시스템 메시지를 뿌리는 편의 메서드
    private void broadcastToAdmins(QnachatVO vo) throws Exception {
        for (WebSocketSession s : sessions) {
            String role = sessionRoleMap.get(s.getId());
            if ("SUPER".equals(role) || "QNAadmin".equals(role)) {
                s.sendMessage(new TextMessage(objectMapper.writeValueAsString(vo)));
            }
        }
    }
}
