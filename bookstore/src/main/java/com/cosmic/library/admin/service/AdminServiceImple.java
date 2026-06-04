package com.cosmic.library.admin.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.cosmic.library.admin.model.AdminVO;
import com.cosmic.library.admin.repository.AdminDAO;
import com.cosmic.library.member.model.MemberVO;

@Service // 스프링이 관리하는 서비스 빈으로 등록
public class AdminServiceImple implements AdminService {

    @Autowired
    private AdminDAO adminDAO;

    @Override
    public AdminVO login(String adminId, String adminPw) {
        AdminVO admin = adminDAO.selectAdminById(adminId);
        if (admin != null && admin.getAdminPw().equals(adminPw)) {
            return admin; // 비밀번호 일치 시 관리자 인증 객체 반환
        }
        return null;
    }

    @Override
    public List<MemberVO> getAllMembers() {
        return adminDAO.selectAllMembers();
    }

    @Override
    public int changeMemberStatus(String id, String status) {
        return adminDAO.updateMemberStatus(id, status);
    }

    @Override
    @Transactional // 🌟 중요: 활동 등록부와 원천 데이터가 동시에 안전하게 지워지도록 트랜잭션 보장
    public void kickMember(String id) {
        adminDAO.deleteMemberFromPlanet(id);
    }
    
    @Override
    public List<AdminVO> getAllAdmins() {
        return adminDAO.selectAllAdmins();
    }

    @Override
    public int changeAdminRole(String adminId, String newRole) {
        return adminDAO.updateAdminRole(adminId, newRole);
    }

    @Override
    public int fireAdmin(String adminId) {
        return adminDAO.deleteAdmin(adminId);
    }
    
    @Override
    public int registerAdmin(AdminVO admin) {
        return adminDAO.insertAdmin(admin);
    }
}