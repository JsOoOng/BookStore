package com.cosmic.library.member.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.member.repository.MemberDAO;

@Service // 스프링이 관리하는 서비스 빈으로 등록
public class MemberServiceImple implements MemberService {

    @Autowired
    private MemberDAO memberDAO;

    @Override
    public MemberVO login(String id, String pw) {
        // 1. 먼저 ID로 대원 정보를 가져옵니다.
        MemberVO member = memberDAO.selectMemberById(id);
        
        // 2. 정보가 존재하고, 비밀번호가 일치하는지 확인합니다.
        if (member != null && member.getPw().equals(pw)) {
            return member; // 인증 성공: 회원 정보 반환
        }
        
        return null; // 인증 실패: 침입자 또는 정보 불일치
    }

    @Override
    public int join(MemberVO member) {
        // 중복 가입 방지 로직을 여기에 추가할 수 있습니다.
        if (memberDAO.selectMemberById(member.getId()) != null) {
            return 0; // 이미 존재하는 ID
        }
        return memberDAO.insertMember(member);
    }

    @Override
    public int updateProfile(MemberVO member) {
        // 닉네임이나 비밀번호 등 프로필 정보를 동기화합니다.
        return memberDAO.updateMember(member);
    }

    @Override
    public int withdraw(String id) {
        // 기지에서 대원 정보를 말소(삭제)합니다.
        return memberDAO.deleteMember(id);
    }

    // --- 👑 최고 관리자(SUPER) 전용 기능 구현 ---

    @Override
    public List<MemberVO> getAllMembers() {
        // 모든 대원의 명단을 호출합니다.
        return memberDAO.selectAllMembers();
    }

    @Override
    public int changeRole(String id, String role) {
        // 특정 대원의 계급(USER < ADMIN < SUPER)을 조정합니다.
        return memberDAO.updateRole(id, role);
    }
}