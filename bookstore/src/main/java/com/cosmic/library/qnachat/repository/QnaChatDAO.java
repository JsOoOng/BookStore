package com.cosmic.library.qnachat.repository;

import com.cosmic.library.qnachat.model.QnachatVO;
import java.util.List;

public interface QnaChatDAO {
    void insertMessage(QnachatVO vo);
    List<QnachatVO> getChatHistory(String userId);
}