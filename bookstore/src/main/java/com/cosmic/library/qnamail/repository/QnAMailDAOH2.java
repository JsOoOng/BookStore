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
    public List<QnAMailVO> getInquiriesByMail(String mail) {
        // 🛰️ 특정 이메일로 발신된 모든 신호를 역순(최신순)으로 긁어옵니다.
        String sql = "SELECT * FROM qna_mail WHERE mail = ? ORDER BY id DESC";
        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(QnAMailVO.class), mail);
    }
    
    @Override
    public void updateAnswer(int id, String answer) {
        // 🛰️ 문의 사항에 관리자의 답변을 새깁니다.
        String sql = "UPDATE qna_mail SET answer = ? WHERE id = ?";
        jdbcTemplate.update(sql, answer, id);
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