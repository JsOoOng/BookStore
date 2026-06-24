package com.cosmic.library.qnachat.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cosmic.library.qnachat.model.QnachatVO;
import com.cosmic.library.qnachat.repository.QnaChatDAO;

@Service
public class QnaChatServiceImple implements QnaChatService {

    @Autowired
    private QnaChatDAO qnaChatDAO;

    @Override
    public void saveMessage(QnachatVO vo) {

        //----------------------------------
        // 💥 [수리 완료] ADMIN 별칭 처리
        // 유령 계정(QNAadmin) 대신 DB에 존재하는 실제 사령부 ID('admin')로 락온!
        //----------------------------------
        if ("ADMIN".equals(vo.getReceiverId())) {
            vo.setReceiverId("admin"); 
        }

        //----------------------------------
        // PARTICIPANT 존재 확인
        //----------------------------------
        Integer senderPid = qnaChatDAO.findParticipantId(vo.getSenderId());
        Integer receiverPid = qnaChatDAO.findParticipantId(vo.getReceiverId());

        if (senderPid == null) {
            throw new RuntimeException("발신 PARTICIPANT 데이터 소실 : " + vo.getSenderId());
        }

        if (receiverPid == null) {
            throw new RuntimeException("수신 PARTICIPANT 데이터 소실 : " + vo.getReceiverId());
        }

        //----------------------------------
        // PID 세팅 및 저장
        //----------------------------------
        vo.setSenderPid(senderPid);
        vo.setReceiverPid(receiverPid);

        qnaChatDAO.insertMessage(vo);
    }

    @Override
    public List<QnachatVO> getChatHistory(String userId, String role) {
        return qnaChatDAO.getChatHistory(userId, role);
    }
}