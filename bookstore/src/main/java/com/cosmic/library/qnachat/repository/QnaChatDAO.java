package com.cosmic.library.qnachat.repository;

import java.util.List;

import com.cosmic.library.qnachat.model.QnachatVO;

public interface QnaChatDAO {

    void insertMessage(QnachatVO vo);

    List<QnachatVO> getChatHistory(
            String userId,
            String role);

    Integer findParticipantId(String userId);
}