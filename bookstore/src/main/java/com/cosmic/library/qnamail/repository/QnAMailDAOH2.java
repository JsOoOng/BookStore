package com.cosmic.library.qnamail.repository;

import java.util.List;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import com.cosmic.library.qnamail.model.QnAMailVO;

@Repository
public class QnAMailDAOH2 implements QnAMailDAO {

    private final JdbcTemplate jdbcTemplate;

    public QnAMailDAOH2(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }
    
    @Override
    public List<QnAMailVO> getInquiriesByName(String name) {
        // 🛰️ 'name' 컬럼을 기준으로 해당 대원의 모든 신호를 가져옵니다.
        String sql = "SELECT * FROM qna_mail WHERE name = ? ORDER BY id DESC";
        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(QnAMailVO.class), name);
    }
    
    @Override
    public void updateAnswer(int id, String answer) {
        String sql = "UPDATE qna_mail SET answer = ? WHERE id = ?";
        jdbcTemplate.update(sql, answer, id);
    }

    @Override
    public void createInquiry(QnAMailVO qnamailvo) {
        // 🚀 컬럼명을 mail에서 name으로 변경했습니다.
        String sql = "INSERT INTO qna_mail (title, name, inquiry, detail) VALUES (?, ?, ?, ?)";
        jdbcTemplate.update(sql,
                qnamailvo.getTitle(),
                qnamailvo.getName(), // VO에서도 getName()을 호출해야 합니다.
                qnamailvo.getInquiry(),
                qnamailvo.getDetail());
    }

    @Override
    public List<QnAMailVO> getAllInquiries() {
        String sql = "SELECT * FROM qna_mail";
        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(QnAMailVO.class));
    }

    @Override
    public QnAMailVO getInquiryById(int id) {
        String sql = "SELECT * FROM qna_mail WHERE id = ?";
        return jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(QnAMailVO.class), id);
    }

    @Override
    public void deleteInquiry(int id) {
        String sql = "DELETE FROM qna_mail WHERE id = ?";
        jdbcTemplate.update(sql, id);
    }

    @Override
    public void sendInquiryMail(String title, String name, String inquiry, String detail) {
        // 시뮬레이션 로그 출력 시 name으로 표시
        System.out.println("메일 발송 시뮬레이션: [제목]" + title + ", [발신자]" + name);
    }
}