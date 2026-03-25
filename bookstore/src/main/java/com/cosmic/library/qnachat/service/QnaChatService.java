package com.cosmic.library.qnachat.service;
import com.cosmic.library.qnachat.model.QnachatVO;
import java.util.List;

public interface QnaChatService {
    void saveMessage(QnachatVO vo);
    List<QnachatVO> getChatHistory(String userId, String role); // 추가
}