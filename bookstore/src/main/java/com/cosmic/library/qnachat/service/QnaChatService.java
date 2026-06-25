package com.cosmic.library.qnachat.service;

import java.util.List;

import com.cosmic.library.qnachat.model.QnachatVO;

public interface QnaChatService {

    void saveMessage(QnachatVO vo);

    List<QnachatVO> getChatHistory(String userId, String role);

}