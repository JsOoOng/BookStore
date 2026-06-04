package com.cosmic.library.admin.service;

import java.util.List;
import com.cosmic.library.admin.model.AdminVO;
import com.cosmic.library.member.model.MemberVO;

public interface AdminService {

    // 🔑 1. 관리자 로그인 인증 프로토콜
    AdminVO login(String adminId, String adminPw);

    // 👥 2. 전체 일반 대원 목록 관제
    List<MemberVO> getAllMembers();

    // ⚙️ 3. 대원 상태(ACTIVE, BLOCK) 변경 하달
    int changeMemberStatus(String id, String status);

    // ❌ 4. 불량 대원 강제 강등 및 추방
    void kickMember(String id);
    
    List<AdminVO> getAllAdmins();
    int changeAdminRole(String adminId, String newRole);
    int fireAdmin(String adminId);
    
    int registerAdmin(AdminVO admin);
}