package com.cosmic.library.basket.repository;

import java.util.List;

import com.cosmic.library.basket.model.BasketVO;

public interface BasketDAO {

    // 🌟 변경: String memberId ➔ int userRegNum
    
    // 회원 활동 번호 기준 장바구니 리스트 조회
    List<BasketVO> findAll(int userRegNum);

    // 장바구니에 도서 추가
    void insert(int userRegNum, int bookId);

    // 장바구니 항목 삭제 (단일)
    void deleteById(int basketId, int userRegNum);

    // 장바구니 항목 삭제 (다중)
    void deleteByIds(int[] basketIds, int userRegNum);

    // 구매 처리 (단일)
    void buy(int basketId, int userRegNum);

    // 구매 처리 (다중)
    void buy(int[] basketIds, int userRegNum);

    // 도서 원천 기준 삭제
    void delete(int userRegNum, int bookId);

    // 선택된 장바구니 항목들 상세 조회
    List<BasketVO> findByIds(int[] basketIds, int userRegNum);
    
    //🌟 오픈마켓용 파이프라인 설계도
    int insertMarketBasket(int userRegNum, int saleId, int qty);

	int updateQty(int basketId, int userRegNum, int qty);
	
	BasketVO findById(int basketId);
}