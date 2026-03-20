package com.cosmic.library.rent.repository;

import java.util.List;

import com.cosmic.library.rent.model.RentVO;

public interface RentDAO {

    // 대여 정보 삽입 (INSERT INTO RENT)
    int insertRent(RentVO rent);

    // 회원 ID로 대여 기록 검색 (SELECT WHERE id = ?)
    List<RentVO> selectByMemberId(String memberId);

    // 전체 대여 기록 조회 (SELECT ALL)
    List<RentVO> selectAll();

    // 대여 ID로 기록 삭제 또는 상태 변경 (DELETE FROM RENT WHERE id = ?)
    int deleteRent(int rentId);
    
    // 특정 도서가 현재 대여 중인지 확인 (중복 대여 방지용)
    int countByBookId(int bookId);
}
