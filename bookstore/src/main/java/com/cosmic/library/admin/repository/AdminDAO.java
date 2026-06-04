package com.cosmic.library.admin.repository;

import java.util.List;
import com.cosmic.library.admin.model.AdminVO;
import com.cosmic.library.member.model.MemberVO;

public interface AdminDAO {
    
    // 🔑 1. 관리자 ID로 정보 조회 (로그인 및 권한 검증용)
    AdminVO selectAdminById(String adminId);

    // 👥 2. 총괄 사령실용 전체 일반 대원 명단 관제
    List<MemberVO> selectAllMembers();

    // ⚙️ 3. 일반 대원의 활동 상태 통제 (ACTIVE, BLOCK 등 변경)
    int updateMemberStatus(String id, String status);

    // ❌ 4. 불량 대원 기지 영구 말소 (강제 추방)
    int deleteMemberFromPlanet(String id);
    
    // 👑 [최고 관리자 전용] 하위 관리자 명단 관제
    List<AdminVO> selectAllAdmins();

    // 👑 [최고 관리자 전용] 하위 관리자 권한 변경 (SUPER, BOOK_ADMIN 등)
    int updateAdminRole(String adminId, String newRole);

    // 👑 [최고 관리자 전용] 하위 관리자 해임 (삭제)
    int deleteAdmin(String adminId);
    
    int insertAdmin(AdminVO admin);
}