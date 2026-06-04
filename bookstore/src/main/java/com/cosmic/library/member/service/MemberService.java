package com.cosmic.library.member.service;

import com.cosmic.library.member.model.MemberVO;

public interface MemberService {
    
    // 일반 대원 가입 프로토콜
    int join(MemberVO member);

    // 일반 대원 로그인 인증
    MemberVO login(String id, String pw);
    
    // 아이디 중복 검증
    boolean isIdAvailable(String id);

    // 개인 정보 수정
    int updateProfile(MemberVO member);

    // 회원 탈퇴 (대원 정보 말소)
    int withdraw(String id);

    // ❌ [도려냄] List<MemberVO> getAllMembers();
    // ❌ [도려냄] int changeRole(String id, String role);
    // 사령부의 대원 목록 관제 및 권한 통제 명세는 완전히 제외되었습니다.
}