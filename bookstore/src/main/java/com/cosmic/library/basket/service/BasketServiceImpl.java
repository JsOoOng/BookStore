package com.cosmic.library.basket.service;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.repository.BasketDAO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BasketServiceImpl implements BasketService {

    @Autowired
    private BasketDAO basketDAO;

    // 🌟 전면 개편: String memberId ➔ int userRegNum 동기화

    // 회원 활동 번호 기준 장바구니 리스트 조회
    @Override
    public List<BasketVO> getList(int userRegNum) {
        return basketDAO.findAll(userRegNum);
    }
    
    // 선택된 장바구니 리스트 조회
    @Override
    public List<BasketVO> getSelectedList(int userRegNum, int[] basketIds) {
        return basketDAO.findByIds(basketIds, userRegNum);
    }

    // 장바구니 삭제 (단일)
    @Override
    public void delete(int userRegNum, int busketId) {
        basketDAO.deleteById(busketId, userRegNum);
    }

    // 장바구니 삭제 (다중)
    @Override
    public void delete(int userRegNum, int[] basketIds) {
        basketDAO.deleteByIds(basketIds, userRegNum); 
    }

    // 구매 처리 (단일)
    @Override
    public void buy(int userRegNum, int busketId) {
        basketDAO.buy(busketId, userRegNum);
    }

    // 구매 처리 (다중)
    @Override
    public void buy(int userRegNum, int[] basketIds) {
        basketDAO.buy(basketIds, userRegNum); 
    }

    // 장바구니에 책 추가
    @Override
    public void add(int userRegNum, int bookId) {
        System.out.println("🛸 장바구니 담기 관제소 작동: userRegNum=" + userRegNum + ", book=" + bookId);
        basketDAO.insert(userRegNum, bookId);
    }

    // 🌟 [오픈마켓용 추가] 인터페이스 실현 및 DAO 호출
    @Override
    public boolean addMarketBasket(int userRegNum, int saleId, int qty) {
        
        // DAO에게 대원 번호(user_reg_num), 마켓 상품 번호(sale_id), 수량을 들고 인서트하라고 명령!
        // (성공 시 성공한 행의 개수가 1 이상이므로 true 반환하도록 세팅)
        int result = basketDAO.insertMarketBasket(userRegNum, saleId, qty);
        
        return result > 0;
    }
    
    @Override
    public boolean updateBasketQty(int basketId, int userRegNum, int qty) {
        // 하단 3단계에서 추가할 DAO 메서드를 호출해줍니다.
        return basketDAO.updateQty(basketId, userRegNum, qty) > 0;
    }
    
}