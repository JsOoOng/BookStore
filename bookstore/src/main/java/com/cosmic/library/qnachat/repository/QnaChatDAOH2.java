package com.cosmic.library.qnachat.repository;

import com.cosmic.library.qnachat.model.QnachatVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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
    public List<QnachatVO> getChatHistory(String userId, String role) {
        String sql;
        if ("SUPER".equals(role) || "QNAadmin".equals(role)) {
            // 관리자: 전체 채팅 내역 조회 (멤버 테이블 조인하여 권한 가져오기)
            sql = "SELECT q.chatId, q.sender_id AS senderId, q.receiver_id AS receiverId, " +
                  "q.message, q.send_time AS sendTime, m.ROLE AS senderRole " +
                  "FROM qna_chat q LEFT JOIN member m ON q.sender_id = m.ID " +
                  "ORDER BY q.send_time ASC";
            return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(QnachatVO.class));
        } else {
            // 일반 유저: 본인이 보냈거나 본인에게 온 내역만 조회
            sql = "SELECT q.chatId, q.sender_id AS senderId, q.receiver_id AS receiverId, " +
                  "q.message, q.send_time AS sendTime, m.ROLE AS senderRole " +
                  "FROM qna_chat q LEFT JOIN member m ON q.sender_id = m.ID " +
                  "WHERE q.sender_id = ? OR q.receiver_id = ? " +
                  "ORDER BY q.send_time ASC";
            return jdbcTemplate.query(sql, new Object[]{userId, userId}, new BeanPropertyRowMapper<>(QnachatVO.class));
        }
    }
}