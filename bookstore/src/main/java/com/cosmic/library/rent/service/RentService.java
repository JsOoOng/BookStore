package com.cosmic.library.rent.service;

import java.util.List;

import com.cosmic.library.rent.model.RentVO;

public interface RentService {

    // 1. 도서 대여/구입: 회원 ID와 도서 ID를 받아 대여 처리를 진행
    // (성공 시 1, 실패 시 0 혹은 예외 발생)
    int rentBook(String memberId, int bookId);

    // 2. 내 대여 목록 조회: 로그인한 사용자가 빌린 도서 목록을 확인
    List<RentVO> findMyRentHistory(String memberId);

    // 3. 대여 취소/반납: 대여 번호를 이용해 해당 기록을 처리
    int cancelRent(int rentId);

    // --- 최고 관리자(SUPER) 및 관리자(ADMIN) 전용 기능 ---

    // 4. 전체 대여 현황 조회: 누가 어떤 책을 빌려갔는지 전체 리스트 확인
    List<RentVO> findAllRentHistory();

    // 5. 특정 회원 대여 제한: (필요 시) 블랙리스트 관리 등을 위한 회원별 대여 수 조회
    int getRentCount(String memberId);
}
