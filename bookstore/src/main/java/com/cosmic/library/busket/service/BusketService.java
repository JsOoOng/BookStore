package com.cosmic.library.busket.service;

import com.cosmic.library.busket.model.BusketVO;
import java.util.List;

public interface BusketService {

    // 회원별 장바구니 리스트 조회
    List<BusketVO> getList(String memberId);

    // 장바구니 삭제 (단일)
    void delete(String memberId, int busketId);

    // 장바구니 삭제 (복수)
    void delete(String memberId, int[] busketIds);

    // 장바구니 구매 (단일)
    void buy(String memberId, int busketId);

    // 장바구니 구매 (복수)
    void buy(String memberId, int[] busketIds);

    // 장바구니에 책 추가
    void add(String memberId, int bookId);
}