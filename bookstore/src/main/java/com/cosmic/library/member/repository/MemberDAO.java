package com.cosmic.library.member.repository;

import java.util.List;

import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.qnamail.model.QnAMailVO;

public interface MemberDAO {
    
    // ID로 특정 회원 정보 조회 (로그인 및 중복 체크용)
	MemberVO selectMemberById(String id);

	// 아이디 중복 체크를 위한 개수 조회
    int countMemberById(String id);
	
    // 회원 데이터 삽입 (INSERT)
    int insertMember(MemberVO member);

    // 회원 데이터 수정 (UPDATE)
    int updateMember(MemberVO member);

    // 회원 삭제 (DELETE)
    int deleteMember(String id);

    // 전체 회원 리스트 조회 (SELECT ALL)
    List<MemberVO> selectAllMembers();

    // 권한(M_ROLE)만 수정 (UPDATE ROLE)
    int updateRole(String id, String role);
}
