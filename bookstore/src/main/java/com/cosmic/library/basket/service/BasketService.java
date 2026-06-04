package com.cosmic.library.basket.service;

import java.util.List;
import com.cosmic.library.basket.model.BasketVO;

public interface BasketService {

    // 🌟 전면 개편: String memberId ➔ int userRegNum 동기화

    // 회원 활동 번호 기준 장바구니 리스트 조회
    List<BasketVO> getList(int userRegNum);

    // 장바구니 삭제 (단일)
    void delete(int userRegNum, int busketId);

    // 장바구니 삭제 (복수)
    void delete(int userRegNum, int[] busketIds);

    // 장바구니 구매 (단일)
    void buy(int userRegNum, int busketId);

    // 장바구니 구매 (복수)
    void buy(int userRegNum, int[] busketIds);

    // 장바구니에 책 추가
    void add(int userRegNum, int bookId);

    // 선택된 장바구니 리스트 조회
    List<BasketVO> getSelectedList(int userRegNum, int[] basketIds);
    
    //🌟 [오픈마켓용 추가] 대원 활동 번호, 마켓 상품 번호, 담을 수량을 받는 설계도 선언
    boolean addMarketBasket(int userRegNum, int saleId, int qty);
    
    boolean updateBasketQty(int basketId, int userRegNum, int qty);
}