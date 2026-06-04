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

    // DB 컬럼의 별칭(AS)과 MemberVO 필드명이 일치하면 자동으로 바인딩해 주는 RowMapper
    private RowMapper<MemberVO> rowMapper = new BeanPropertyRowMapper<>(MemberVO.class);
    
    @Override
    public MemberVO selectMemberById(String id) {
        // 🪐 [정화] u.address 컬럼을 조회 대상에 추가하여 BeanPropertyRowMapper가 자동으로 바인딩하도록 유도
        String sql = "SELECT u.user_id AS id, u.user_pw AS pw, u.user_name AS name, " +
                     "u.is_member, u.points, u.email, u.address, u.regDate, " + // ◀️ u.address 탑재!
                     "r.user_reg_num, r.reg_status " +
                     "FROM COSMIC_USER u " +
                     "JOIN USER_REGISTRATION r ON u.user_id = r.user_id " +
                     "WHERE u.user_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, id);
        } catch (Exception e) {
            return null;
        }
    }
    
    @Override
    public int countMemberById(String id) {
        String sql = "SELECT COUNT(*) FROM COSMIC_USER WHERE user_id = ?";
        return jdbcTemplate.queryForObject(sql, Integer.class, id);
    }

    @Override
    public int insertMember(MemberVO member) {
        // 🪐 [정화] 회원가입 시 기입한 주소 정보(address)도 함께 영구 보존구역에 인서트하도록 설정
        String sqlUser = "INSERT INTO COSMIC_USER (user_id, user_pw, user_name, is_member, points, email, address, regDate) " +
                         "VALUES (?, ?, ?, 1, 0, ?, ?, NOW())"; // ◀️ 매핑 물방울 하나 더 추가
        int resultUser = jdbcTemplate.update(sqlUser, 
                member.getId(), 
                member.getPw(), 
                member.getName(), 
                member.getEmail(),
                member.getAddress()); // ◀️ member.getAddress() 장착 완료!
        
        // 2. USER_REGISTRATION 활동 등록부에 ACTIVE 상태로 동시 인서트
        String sqlReg = "INSERT INTO USER_REGISTRATION (user_id, reg_status, regDate) VALUES (?, 'ACTIVE', NOW())";
        int resultReg = jdbcTemplate.update(sqlReg, member.getId());
        
        return (resultUser > 0 && resultReg > 0) ? 1 : 0;
    }

    @Override
    public int updateMember(MemberVO member) {
        // 🪐 [정화] 대원이 마이페이지에서 수정한 신규 배송지 주소 정보까지 한 번에 반영되도록 쿼리 전면 수정
        String sql = "UPDATE COSMIC_USER SET user_pw = ?, user_name = ?, email = ?, address = ? WHERE user_id = ?";
        return jdbcTemplate.update(sql, 
                member.getPw(), 
                member.getName(), 
                member.getEmail(), 
                member.getAddress(), // ◀️ 수정한 주소 실탄 장전
                member.getId());
    }

    @Override
    public int deleteMember(String id) {
        String sqlReg = "DELETE FROM USER_REGISTRATION WHERE user_id = ?";
        jdbcTemplate.update(sqlReg, id);
        
        String sqlUser = "DELETE FROM COSMIC_USER WHERE user_id = ?";
        return jdbcTemplate.update(sqlUser, id);
    }

    @Override
    public List<MemberVO> selectAllMembers() {
        // 🪐 [정화] 전체 대원 정보 관제 목록에서도 주소 정보를 완벽 수집하도록 유도
        String sql = "SELECT u.user_id AS id, u.user_pw AS pw, u.user_name AS name, " +
                     "u.is_member, u.points, u.email, u.address, u.regDate, " + // ◀️ u.address 탑재!
                     "r.user_reg_num, r.reg_status " +
                     "FROM COSMIC_USER u " +
                     "JOIN USER_REGISTRATION r ON u.user_id = r.user_id " +
                     "ORDER BY u.regDate DESC";
        return jdbcTemplate.query(sql, rowMapper);
    }
}