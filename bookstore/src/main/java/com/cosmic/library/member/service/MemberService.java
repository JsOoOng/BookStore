package com.cosmic.library.member.service;

import java.util.List;

import com.cosmic.library.member.model.MemberVO;

public interface MemberService {
    
    // 1. 로그인: 아이디와 비밀번호를 확인하여 회원 정보를 반환
    MemberVO login(String id, String pw);

    // 2. 회원가입: 새로운 회원 정보를 등록 (성공 시 1, 실패 시 0 반환)
    int join(MemberVO member);

    // 3. 정보수정: 내 닉네임이나 비밀번호를 변경
    int updateProfile(MemberVO member);

    // 4. 회원탈퇴: 계정 삭제
    int withdraw(String id);

    // --- 최고 관리자(SUPER) 전용 기능 ---
    
    // 5. 전체 회원 목록 조회: 관리자 페이지용
    List<MemberVO> getAllMembers();

    // 6. 권한 변경: 특정 유저를 ADMIN으로 승격하거나 USER로 강등
    int changeRole(String id, String role);
}
