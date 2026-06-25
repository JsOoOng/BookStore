package com.cosmic.library.emailauth.repository;

import java.sql.ResultSet;
import java.sql.Timestamp;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.cosmic.library.emailauth.model.EmailAuthVO;

@Repository
public class EmailAuthDAO {

    private JdbcTemplate jdbcTemplate;

    @Autowired
    public EmailAuthDAO(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    // INSERT or UPDATE (MERGE 대신 수동 처리)
    public void saveAuth(EmailAuthVO vo) {
    	System.out.println("보내기3");
    	String sql ="INSERT INTO TB_EMAIL_AUTH (EMAIL, AUTH_CODE, AUTH_YN, EXPIRE_TIME, REG_DATE) " +
    				"VALUES (?, ?, 'N', ?, CURRENT_TIMESTAMP)";
        jdbcTemplate.update(sql,
                vo.getEmail(),
                vo.getAuthCode(),
                vo.getExpireTime()
        );
        
    }

    // 인증 확인
    public int verify(String email, String code) {

        String sql =
            "UPDATE TB_EMAIL_AUTH " +
            "SET AUTH_YN = 'Y' " +
            "WHERE EMAIL = ? " +
            "AND AUTH_CODE = ? " +
            "AND EXPIRE_TIME > CURRENT_TIMESTAMP";

        return jdbcTemplate.update(sql, email, code);
    }

    // 조회 (디버그용)
    public EmailAuthVO findByEmail(String email) {

        String sql = "SELECT * FROM TB_EMAIL_AUTH WHERE EMAIL = ?";

        return jdbcTemplate.queryForObject(sql, (ResultSet rs, int rowNum) -> {

            EmailAuthVO vo = new EmailAuthVO();

            vo.setEmail(rs.getString("EMAIL"));
            vo.setAuthCode(rs.getString("AUTH_CODE"));
            vo.setAuthYn(rs.getString("AUTH_YN"));
            vo.setExpireTime(rs.getTimestamp("EXPIRE_TIME"));
            vo.setRegDate(rs.getTimestamp("REG_DATE"));

            return vo;
        }, email);
    }
}