package com.cosmic.library.basket.service;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.repository.BasketDAO;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.repository.ProductSaleDAO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BasketServiceImpl implements BasketService {

    @Autowired
    private BasketDAO basketDAO;
    
    @Autowired
    private ProductSaleDAO productSaleDAO;

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
    
    @Override
    public boolean addMarketBasket(int userRegNum, int saleId, int qty) {
        // 1. 해당 상점 상품의 실시간 재고 스캔
        ProductSaleVO product = productSaleDAO.findById(saleId);
        
        // 2. 상품이 없거나, 담으려는 수량이 재고보다 크면 즉시 차단!
        if (product == null || product.getStockQty() < qty) {
            System.out.println("🚨 [물류 경고] 재고 한도 초과! 담기 거부됨.");
            return false; 
        }
        
        int result = basketDAO.insertMarketBasket(userRegNum, saleId, qty);
        return result > 0;
    }
    
    // 🌟 장바구니 수량 변경 전 실시간 재고 검증 로직
    @Override
    public boolean updateBasketQty(int basketId, int userRegNum, int qty) {
        // 1. 장바구니 고유 ID로 어떤 상품(saleId)이 담겨 있는지 추적
        BasketVO basket = basketDAO.findById(basketId); // ⚠️ 주의: BasketDAO에 findById 메서드가 필요함!
        
        if (basket != null && basket.getSaleId() != null && basket.getSaleId() > 0) {
            // 2. 실시간 재고 스캔 후 초과 시 차단!
            ProductSaleVO product = productSaleDAO.findById(basket.getSaleId());
            if (product == null || product.getStockQty() < qty) {
                System.out.println("🚨 [물류 경고] 변경하려는 수량이 실시간 재고를 초과함!");
                return false;
            }
        }
        return basketDAO.updateQty(basketId, userRegNum, qty) > 0;
    }
    
}