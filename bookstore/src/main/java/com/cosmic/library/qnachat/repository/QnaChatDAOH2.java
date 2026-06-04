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
        // 🪐 [정화] PARTICIAPNT 스키마 락온 서브쿼리 연동
        String sql = "INSERT INTO QNA_CHAT (sender_pid, receiver_pid, message, send_time) VALUES (" +
                     "  (SELECT p.p_id FROM PARTICIPANT p LEFT JOIN USER_REGISTRATION ur ON p.u_reg_num = ur.user_reg_num WHERE ur.user_id = ? OR p.admin_id = ? LIMIT 1), " +
                     "  (SELECT p.p_id FROM PARTICIPANT p LEFT JOIN USER_REGISTRATION ur ON p.u_reg_num = ur.user_reg_num WHERE ur.user_id = ? OR p.admin_id = ? LIMIT 1), " +
                     "  ?, NOW())";
        
        jdbcTemplate.update(sql, 
                vo.getSenderId(), vo.getSenderId(), 
                vo.getReceiverId(), vo.getReceiverId(), 
                vo.getMessage());
    }

    @Override
    public List<QnachatVO> getChatHistory(String userId, String role) {
        String sql;
        
        // 🪐 [정화] 인터페이스에서 던져준 순수 String 인자값을 바인딩하여 
        // PARTICIPANT 무결성 조인 쿼리를 격발합니다.
        if ("SUPER".equals(role) || "QNAadmin".equals(role)) {
            // 사령부 관제실 마스터 스캔
            sql = "SELECT " +
                  "    c.chat_id AS chatId, " +
                  "    COALESCE(ur1.user_id, p1.admin_id) AS senderId, " +
                  "    COALESCE(ur2.user_id, p2.admin_id) AS receiverId, " +
                  "    c.message AS message, " +
                  "    c.send_time AS sendTime, " +
                  "    CASE WHEN p1.admin_id IS NOT NULL THEN 'SUPER' ELSE 'USER' END AS senderRole " +
                  "FROM QNA_CHAT c " +
                  "JOIN PARTICIPANT p1 ON c.sender_pid = p1.p_id " +
                  "LEFT JOIN USER_REGISTRATION ur1 ON p1.u_reg_num = ur1.user_reg_num " +
                  "JOIN PARTICIPANT p2 ON c.receiver_pid = p2.p_id " +
                  "LEFT JOIN USER_REGISTRATION ur2 ON p2.u_reg_num = ur2.user_reg_num " +
                  "ORDER BY c.send_time ASC";
                  
            return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(QnachatVO.class));
        } else {
            // 일반 대원 프라이빗 무전 트랙 역추적
            sql = "SELECT " +
                  "    c.chat_id AS chatId, " +
                  "    COALESCE(ur1.user_id, p1.admin_id) AS senderId, " +
                  "    COALESCE(ur2.user_id, p2.admin_id) AS receiverId, " +
                  "    c.message AS message, " +
                  "    c.send_time AS sendTime, " +
                  "    CASE WHEN p1.admin_id IS NOT NULL THEN 'SUPER' ELSE 'USER' END AS senderRole " +
                  "FROM QNA_CHAT c " +
                  "JOIN PARTICIPANT p1 ON c.sender_pid = p1.p_id " +
                  "LEFT JOIN USER_REGISTRATION ur1 ON p1.u_reg_num = ur1.user_reg_num " +
                  "JOIN PARTICIPANT p2 ON c.receiver_pid = p2.p_id " +
                  "LEFT JOIN USER_REGISTRATION ur2 ON p2.u_reg_num = ur2.user_reg_num " +
                  "WHERE COALESCE(ur1.user_id, p1.admin_id) = ? OR COALESCE(ur2.user_id, p2.admin_id) = ? " +
                  "ORDER BY c.send_time ASC";
                  
            return jdbcTemplate.query(sql, new Object[]{userId, userId}, new BeanPropertyRowMapper<>(QnachatVO.class));
        }
    }
}