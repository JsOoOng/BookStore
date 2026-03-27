package com.cosmic.library.basket.service;

import java.util.List;

import com.cosmic.library.basket.model.BasketVO;

public interface BasketService {

    // 회원별 장바구니 리스트 조회
    List<BasketVO> getList(String memberId);

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

	List<BasketVO> getSelectedList(String memberId, int[] basketIds);
}