package com.cosmic.library.basket.repository;

import java.util.List;

import com.cosmic.library.basket.model.BasketVO;

public interface BasketDAO {

    // 회원 기준 장바구니 리스트 조회
    List<BasketVO> findAll(String memberId);

    // 장바구니에 도서 추가 (회원 기준)
    void insert(String memberId, int bookId);

    // 장바구니 항목 삭제 (단일)
    void deleteById(int busketId, String memberId);

    // 장바구니 항목 삭제 (다중)
    void deleteByIds(int[] busketIds, String memberId);

    // 구매 처리 (단일)
    void buy(int busketId, String memberId);

    // 구매 처리 (다중)
    void buy(int[] busketIds, String memberId);
}