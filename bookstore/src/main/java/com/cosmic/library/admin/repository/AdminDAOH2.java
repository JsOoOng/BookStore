package com.cosmic.library.admin.repository;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import com.cosmic.library.admin.model.AdminVO;
import com.cosmic.library.member.model.MemberVO;

@Repository
public class AdminDAOH2 implements AdminDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public AdminVO selectAdminById(String adminId) {
        String sql = "SELECT admin_id, admin_pw, admin_name, role, regDate FROM BASE_ADMIN WHERE admin_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(AdminVO.class), adminId);
        } catch (Exception e) {
            return null; 
        }
    }

    @Override
    public List<MemberVO> selectAllMembers() {
        String sql = "SELECT u.user_id AS id, u.user_pw AS pw, u.user_name AS name, " +
                     "u.is_member, u.points, u.email, u.regDate, " +
                     "r.user_reg_num, r.reg_status " +
                     "FROM COSMIC_USER u " +
                     "JOIN USER_REGISTRATION r ON u.user_id = r.user_id " +
                     "ORDER BY u.regDate DESC";
        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(MemberVO.class));
    }

    @Override
    public int updateMemberStatus(String id, String status) {
        String sql = "UPDATE USER_REGISTRATION SET reg_status = ? WHERE user_id = ?";
        return jdbcTemplate.update(sql, status, id);
    }

    @Override
    public int deleteMemberFromPlanet(String id) {
        // 외래키 제약조건 방어로 자식(REGISTRATION) -> 부모(USER) 순격파
        String sqlReg = "DELETE FROM USER_REGISTRATION WHERE user_id = ?";
        jdbcTemplate.update(sqlReg, id);
        
        String sqlUser = "DELETE FROM COSMIC_USER WHERE user_id = ?";
        return jdbcTemplate.update(sqlUser, id);
    }
    
    @Override
    public List<AdminVO> selectAllAdmins() {
        String sql = "SELECT admin_id, admin_pw, admin_name, role, regDate FROM BASE_ADMIN ORDER BY regDate DESC";
        return jdbcTemplate.query(sql, new org.springframework.jdbc.core.BeanPropertyRowMapper<>(AdminVO.class));
    }

    @Override
    public int updateAdminRole(String adminId, String newRole) {
        String sql = "UPDATE BASE_ADMIN SET role = ? WHERE admin_id = ?";
        return jdbcTemplate.update(sql, newRole, adminId);
    }

    @Override
    public int deleteAdmin(String adminId) {
        String sql = "DELETE FROM BASE_ADMIN WHERE admin_id = ?";
        return jdbcTemplate.update(sql, adminId);
    }
    
    @Override
    public int insertAdmin(AdminVO admin) {
        String sql = "INSERT INTO BASE_ADMIN (admin_id, admin_pw, admin_name, role, regDate) VALUES (?, ?, ?, ?, NOW())";
        return jdbcTemplate.update(sql, admin.getAdminId(), admin.getAdminPw(), admin.getAdminName(), admin.getRole());
    }
}