package com.cosmic.library.qnachat.repository;

import com.cosmic.library.qnachat.model.QnachatVO;
import java.util.List;

public interface QnaChatDAO {
    void insertMessage(QnachatVO vo);
    // 과거 내역 조회를 위한 메서드 추가 (권한에 따라 다르게 조회)
    List<QnachatVO> getChatHistory(String userId, String role);
}