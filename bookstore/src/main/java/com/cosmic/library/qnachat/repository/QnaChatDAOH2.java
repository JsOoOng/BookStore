package com.cosmic.library.qnachat.repository;

import com.cosmic.library.qnachat.model.QnachatVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class QnaChatDAOH2 implements QnaChatDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void insertMessage(QnachatVO vo) {
        String sql = "INSERT INTO qna_chat (sender_id, receiver_id, message, send_time) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
        jdbcTemplate.update(sql, vo.getSenderId(), vo.getReceiverId(), vo.getMessage());
    }

    @Override
    public List<QnachatVO> getChatHistory(String userId) {
        // 추후 DB에서 채팅 내역을 불러오는 쿼리 작성 (현재는 구조만 잡아둠)
        return null; 
    }
}