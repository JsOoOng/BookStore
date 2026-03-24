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
    public void createInquiry(QnAMailVO qnamailvo) {
        String sql = "INSERT INTO qna_mail (title, mail, inquiry, detail) VALUES (?, ?, ?, ?)";
        jdbcTemplate.update(sql,
                qnamailvo.getTitle(),
                qnamailvo.getMail(),
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
    public void sendInquiryMail(String title, String mail, String inquiry, String detail) {
        // 실제 메일 발송 로직은 여기서 구현
        // 예: JavaMailSender 사용
        System.out.println("메일 발송 시뮬레이션: " + title + ", " + mail);
    }
}