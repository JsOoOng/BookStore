package com.cosmic.library.qnachat.handler;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.cosmic.library.qnachat.model.QnachatVO;
import com.cosmic.library.qnachat.service.QnaChatService;
import com.fasterxml.jackson.databind.ObjectMapper;

public class QnaChatHandler extends TextWebSocketHandler {

    @Autowired
    private QnaChatService qnaChatService;

    private final List<WebSocketSession> sessions =
            new CopyOnWriteArrayList<>();

    private final Map<String,String> sessionUserMap =
            new ConcurrentHashMap<>();

    private final Map<String,String> sessionRoleMap =
            new ConcurrentHashMap<>();

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(
            WebSocketSession session) throws Exception {

        sessions.add(session);
    }

    @Override
    protected void handleTextMessage(
            WebSocketSession session,
            TextMessage message) throws Exception {

        QnachatVO chatVO =
                mapper.readValue(
                        message.getPayload(),
                        QnachatVO.class);

        //----------------------------------
        // 최초 입장
        //----------------------------------

        if ("ENTER_CHATROOM".equals(chatVO.getMessage())
                || "ENTER_GLOBAL".equals(chatVO.getMessage())) {

            sessionUserMap.put(
                    session.getId(),
                    chatVO.getSenderId());

            sessionRoleMap.put(
                    session.getId(),
                    chatVO.getSenderRole());

            if ("ENTER_CHATROOM".equals(chatVO.getMessage())) {

                List<QnachatVO> history =
                        qnaChatService.getChatHistory(
                                chatVO.getSenderId(),
                                chatVO.getSenderRole());

                for (QnachatVO msg : history) {

                    session.sendMessage(
                            new TextMessage(
                                    mapper.writeValueAsString(msg)));
                }

                QnachatVO done = new QnachatVO();

                done.setSenderId("SERVER");
                done.setMessage("HISTORY_DONE");

                session.sendMessage(
                        new TextMessage(
                                mapper.writeValueAsString(done)));
            }

            notifyUserEnter(chatVO);

            return;
        }

        //----------------------------------
        // 채팅 저장
        //----------------------------------

        try {

            qnaChatService.saveMessage(chatVO);

        } catch (Exception e) {

            e.printStackTrace();
        }

        //----------------------------------
        // 관리자 접속 여부 확인
        //----------------------------------

        boolean adminOnline =
                sessionRoleMap.values()
                        .stream()
                        .anyMatch(role ->
                                "SUPER".equals(role)
                                        || "MEMBER_ADMIN".equals(role));

        if (!adminOnline
                && !"SUPER".equals(chatVO.getSenderRole())
                && !"MEMBER_ADMIN".equals(chatVO.getSenderRole())) {

            QnachatVO offline = new QnachatVO();

            offline.setSenderId("SERVER");
            offline.setMessage("ADMIN_OFFLINE");

            session.sendMessage(
                    new TextMessage(
                            mapper.writeValueAsString(offline)));
        }

        //----------------------------------
        // 대상 전송
        //----------------------------------

        sendTargetMessage(chatVO);
    }

    private void sendTargetMessage(QnachatVO chatVO)
            throws Exception {

        String senderRole = chatVO.getSenderRole();

        for (WebSocketSession ws : sessions) {

            String connectedId =
                    sessionUserMap.get(ws.getId());

            String connectedRole =
                    sessionRoleMap.get(ws.getId());

            if (connectedId == null)
                continue;

            //------------------------------------------------
            // 관리자 발송
            //------------------------------------------------

            if ("SUPER".equals(senderRole)
                    || "MEMBER_ADMIN".equals(senderRole)) {

                if (connectedId.equals(chatVO.getReceiverId())
                        || "SUPER".equals(connectedRole)
                        || "MEMBER_ADMIN".equals(connectedRole)) {

                    ws.sendMessage(
                            new TextMessage(
                                    mapper.writeValueAsString(chatVO)));
                }
            }

            //------------------------------------------------
            // 일반 유저 발송
            //------------------------------------------------

            else {

                if (connectedId.equals(chatVO.getSenderId())
                        || "SUPER".equals(connectedRole)
                        || "MEMBER_ADMIN".equals(connectedRole)) {

                    ws.sendMessage(
                            new TextMessage(
                                    mapper.writeValueAsString(chatVO)));
                }
            }
        }
    }

    private void notifyUserEnter(QnachatVO chatVO)
            throws Exception {

        if ("SUPER".equals(chatVO.getSenderRole())
                || "MEMBER_ADMIN".equals(chatVO.getSenderRole())) {
            return;
        }

        QnachatVO notice = new QnachatVO();

        notice.setSenderId("SERVER");
        notice.setMessage(
                "ENTER_USER:" + chatVO.getSenderId());

        broadcastToAdmins(notice);
    }

    @Override
    public void afterConnectionClosed(
            WebSocketSession session,
            CloseStatus status) throws Exception {

        String userId =
                sessionUserMap.get(session.getId());

        String role =
                sessionRoleMap.get(session.getId());

        sessions.remove(session);

        sessionUserMap.remove(session.getId());
        sessionRoleMap.remove(session.getId());

        if (userId != null
                && !"SUPER".equals(role)
                && !"MEMBER_ADMIN".equals(role)) {

            QnachatVO notice = new QnachatVO();

            notice.setSenderId("SERVER");
            notice.setMessage(
                    "LEAVE_USER:" + userId);

            broadcastToAdmins(notice);
        }
    }

    private void broadcastToAdmins(QnachatVO vo)
            throws Exception {

        for (WebSocketSession ws : sessions) {

            String role =
                    sessionRoleMap.get(ws.getId());

            if ("SUPER".equals(role)
                    || "MEMBER_ADMIN".equals(role)) {

                ws.sendMessage(
                        new TextMessage(
                                mapper.writeValueAsString(vo)));
            }
        }
    }
}