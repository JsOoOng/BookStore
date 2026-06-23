package com.cosmic.library.qnachat.repository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.cosmic.library.qnachat.model.QnachatVO;

@Repository
public class QnaChatDAOH2 implements QnaChatDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * PARTICIPANT PK 조회
     */
    @Override
    public Integer findParticipantId(String loginId) {
        String sql =
            "SELECT p.p_id " +
            "FROM PARTICIPANT p " +
            "LEFT JOIN USER_REGISTRATION ur ON p.u_reg_num = ur.user_reg_num " +
            "LEFT JOIN BASE_ADMIN ba ON p.admin_id = ba.admin_id " +
            "WHERE ur.user_id = ? OR ba.admin_id = ? " +
            "LIMIT 1";

        List<Integer> result = jdbcTemplate.queryForList(sql, Integer.class, loginId, loginId);
        return result.isEmpty() ? null : result.get(0);
    }

    /**
     * 채팅 저장
     */
    @Override
    public void insertMessage(QnachatVO vo) {
        String sql =
            "INSERT INTO QNA_CHAT " +
            "(sender_pid, receiver_pid, message, is_read, send_time) " +
            "VALUES (?, ?, ?, 0, NOW())";

        jdbcTemplate.update(sql, vo.getSenderPid(), vo.getReceiverPid(), vo.getMessage());
    }

    /**
     * 채팅 내역 조회 (라우팅)
     */
    @Override
    public List<QnachatVO> getChatHistory(String userId, String role) {
        // 💥 [수리 완료] QNAadmin 대신 실제 계정 및 권한 기반 검증으로 정화
        if ("SUPER".equals(role) || "admin".equals(userId)) {
            return getAdminHistory();
        }
        return getUserHistory(userId);
    }

    /**
     * 관리자용 전체 채팅 내역 조회
     */
    private List<QnachatVO> getAdminHistory() {
        String sql =
            "SELECT " +
            " c.chat_id AS chatId, " +
            " COALESCE(ur1.user_id, ba1.admin_id) AS senderId, " +
            " COALESCE(ur2.user_id, ba2.admin_id) AS receiverId, " +
            " c.sender_pid AS senderPid, " +
            " c.receiver_pid AS receiverPid, " +
            " c.message AS message, " +
            " c.send_time AS sendTime, " +
            
            // 💥 [수리 완료] 하드코딩된 'ADMIN' 대신, 실제 BASE_ADMIN 테이블의 role('SUPER')을 동기화!
            " CASE " +
            "   WHEN ba1.admin_id IS NOT NULL THEN ba1.role " + 
            "   ELSE 'USER' " +
            " END AS senderRole " +

            "FROM QNA_CHAT c " +
            "JOIN PARTICIPANT p1 ON c.sender_pid = p1.p_id " +
            "LEFT JOIN USER_REGISTRATION urp1 ON p1.u_reg_num = urp1.user_reg_num " +
            "LEFT JOIN COSMIC_USER ur1 ON urp1.user_id = ur1.user_id " +
            "LEFT JOIN BASE_ADMIN ba1 ON p1.admin_id = ba1.admin_id " +
            "JOIN PARTICIPANT p2 ON c.receiver_pid = p2.p_id " +
            "LEFT JOIN USER_REGISTRATION urp2 ON p2.u_reg_num = urp2.user_reg_num " +
            "LEFT JOIN COSMIC_USER ur2 ON urp2.user_id = ur2.user_id " +
            "LEFT JOIN BASE_ADMIN ba2 ON p2.admin_id = ba2.admin_id " +
            "ORDER BY c.send_time ASC";

        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(QnachatVO.class));
    }

    /**
     * 일반 대원용 채팅 내역 조회
     */
    private List<QnachatVO> getUserHistory(String userId) {
        String sql =
            "SELECT " +
            " c.chat_id AS chatId, " +
            " COALESCE(ur1.user_id, ba1.admin_id) AS senderId, " +
            " COALESCE(ur2.user_id, ba2.admin_id) AS receiverId, " +
            " c.sender_pid AS senderPid, " +
            " c.receiver_pid AS receiverPid, " +
            " c.message AS message, " +
            " c.send_time AS sendTime, " +

            // 💥 [수리 완료] 여기서도 동일하게 실제 DB의 권한 동기화 완료!
            " CASE " +
            "   WHEN ba1.admin_id IS NOT NULL THEN ba1.role " + 
            "   ELSE 'USER' " +
            " END AS senderRole " +

            "FROM QNA_CHAT c " +
            "JOIN PARTICIPANT p1 ON c.sender_pid = p1.p_id " +
            "LEFT JOIN USER_REGISTRATION urp1 ON p1.u_reg_num = urp1.user_reg_num " +
            "LEFT JOIN COSMIC_USER ur1 ON urp1.user_id = ur1.user_id " +
            "LEFT JOIN BASE_ADMIN ba1 ON p1.admin_id = ba1.admin_id " +
            "JOIN PARTICIPANT p2 ON c.receiver_pid = p2.p_id " +
            "LEFT JOIN USER_REGISTRATION urp2 ON p2.u_reg_num = urp2.user_reg_num " +
            "LEFT JOIN COSMIC_USER ur2 ON urp2.user_id = ur2.user_id " +
            "LEFT JOIN BASE_ADMIN ba2 ON p2.admin_id = ba2.admin_id " +
            "WHERE COALESCE(ur1.user_id, ba1.admin_id) = ? OR COALESCE(ur2.user_id, ba2.admin_id) = ? " +
            "ORDER BY c.send_time ASC";

        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(QnachatVO.class), userId, userId);
    }
}