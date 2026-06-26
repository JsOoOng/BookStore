package com.cosmic.library.member.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.member.repository.MemberDAO;

@Service // 스프링이 관리하는 서비스 빈으로 등록
public class MemberServiceImple implements MemberService {

    @Autowired
    private MemberDAO memberDAO;

    @Override
    @Transactional // 🌟 중요: 듀얼 인서트 중 하나라도 터지면 전부 가입 전으로 롤백(Rollback)시킵니다.
    public int join(MemberVO member) {
        // 중복 가입 방지 로직
        if (memberDAO.selectMemberById(member.getId()) != null) {
            return 0; // 이미 존재하는 ID
        }
        return memberDAO.insertMember(member);
    }

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
    public boolean isIdAvailable(String id) {
        // 1. DAO에게 해당 ID를 쓰는 대원이 몇 명인지 물어봅니다.
        int count = memberDAO.countMemberById(id);
        
        // 2. 결과가 0이면 사용 가능한 아이디(true), 아니면 중복(false)입니다.
        return count == 0;
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

    // ❌ [도려냄] getAllMembers() 및 changeRole() 관련 최고 관리자 기능은 
    // 새롭게 창설되는 com.cosmic.library.admin.service.AdminService 로 안전하게 이주되었습니다.
}