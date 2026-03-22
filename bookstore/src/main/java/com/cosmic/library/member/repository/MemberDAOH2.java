package com.cosmic.library.member.repository;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import com.cosmic.library.member.model.MemberVO;

@Repository
public class MemberDAOH2 implements MemberDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private RowMapper<MemberVO> rowMapper = new BeanPropertyRowMapper<>(MemberVO.class);

    @Override
    public MemberVO selectMemberById(String id) {
        String sql = "SELECT * FROM MEMBER WHERE id = ?";
        try {
            // 결과가 없으면 예외가 발생하므로 try-catch로 처리합니다.
            return jdbcTemplate.queryForObject(sql, rowMapper, id);
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public int insertMember(MemberVO member) {
        // 기본 권한은 USER로 설정하여 가입시킵니다.
        String sql = "INSERT INTO MEMBER (id, pw, name, role, regDate) VALUES (?, ?, ?, 'USER', NOW())";
        return jdbcTemplate.update(sql, member.getId(), member.getPw(), member.getName());
    }

    @Override
    public int updateMember(MemberVO member) {
        String sql = "UPDATE MEMBER SET pw = ?, name = ? WHERE id = ?";
        return jdbcTemplate.update(sql, member.getPw(), member.getName(), member.getId());
    }

    @Override
    public int deleteMember(String id) {
        String sql = "DELETE FROM MEMBER WHERE id = ?";
        return jdbcTemplate.update(sql, id);
    }

    @Override
    public List<MemberVO> selectAllMembers() {
        String sql = "SELECT * FROM MEMBER ORDER BY regDate DESC";
        return jdbcTemplate.query(sql, rowMapper);
    }

    @Override
    public int updateRole(String id, String role) {
        // 사령관(SUPER)만 호출할 권한 변경 기능
        String sql = "UPDATE MEMBER SET role = ? WHERE id = ?";
        return jdbcTemplate.update(sql, role, id);
    }
}