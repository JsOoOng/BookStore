package com.cosmic.library.purchase.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.service.BasketService;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.repository.BookDAO;
import com.cosmic.library.cookie.repository.CookiePurchaseRepository;
import com.cosmic.library.purchase.model.Purchase;
import com.cosmic.library.purchase.repository.PurchaseRepository;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.repository.ProductSaleDAO;

@Service
public class PurchaseService {

    @Autowired
    private PurchaseRepository purchaseRepository;

    @Autowired
    private ProductSaleDAO productSaleDAO; // 재고 스캔 및 차감 레이더

    @Autowired
    private BasketService basketService; // 장바구니 멸균 처리기
    
    @Autowired
    private CookiePurchaseRepository cookiePurchaseRepository;
    
    @Autowired
    private BookDAO bookDAO; // 도서 상세 정보를 가져오기 위한 DAO

    // =========================================================================
    // 🚀 [대통합 결제 엔진] 마스터-디테일 생성 + 재고 차감 + 장바구니 비우기
    // =========================================================================
    @Transactional
    public int executeCheckout(int userRegNum, List<BasketVO> itemsToBuy, int[] basketIdsToRemove) {
        
        int grandTotal = 0;
        for (BasketVO item : itemsToBuy) {
            grandTotal += (item.getPrice() * item.getQuantity());
        }

        int purchaseId = purchaseRepository.insertMaster(userRegNum, grandTotal);
        if (purchaseId <= 0) throw new RuntimeException("🚨 마스터 영수증 발급 실패!");

        for (BasketVO item : itemsToBuy) {
            ProductSaleVO saleInfo = productSaleDAO.findById(item.getSaleId());
            if (saleInfo == null) throw new RuntimeException("🚨 마켓 상품 데이터 소실!");
            
            purchaseRepository.insertDetail(
                purchaseId, 
                item.getSaleId(), 
                saleInfo.getVRegNum(), 
                item.getQuantity(), 
                item.getPrice()
            );

            productSaleDAO.updateStock(item.getSaleId(), -item.getQuantity());
        }

        if (basketIdsToRemove != null && basketIdsToRemove.length > 0) {
            basketService.delete(userRegNum, basketIdsToRemove);
        }

        return purchaseId;
    }

    // =========================================================================
    // 📜 기타 유틸리티 및 조회 메서드
    // =========================================================================
    public List<Purchase> getMyPurchases(int userRegNum) {
        return purchaseRepository.findByMemberId(userRegNum);
    }
    
    public List<Purchase> getVendorOrders(int vendorRegNum) {
        return purchaseRepository.findByVendorRegNum(vendorRegNum);
    }

    public boolean startShipping(int purchaseId) {
        return purchaseRepository.updateStatus(purchaseId, "SHIPPING") > 0;
    }
   
    public List<BookVO> getBasketDetails(List<BasketVO> basketList) {
        List<BookVO> purchaseList = new ArrayList<>();
        
        if (basketList != null) {
            for (BasketVO basket : basketList) {
                // 1. saleId를 기준으로 DB에서 상세 정보를 조회
                BookVO book = bookDAO.selectBookBySaleId(basket.getSaleId());
                
                if (book != null) {
                    // 2. 쿠키의 수량(quantity) 주입
                    book.setQuantity(basket.getQuantity());
                    
                    // 3. 가격 보정 (중요!)
                    // DB에서 가져온 가격이 0이거나 데이터가 부족할 경우, 
                    // 쿠키에 담겨있던 가격(basket.getPrice())을 우선적으로 사용하도록 설계
                    if (book.getPrice() <= 0 && basket.getPrice() > 0) {
                        book.setPrice(basket.getPrice());
                    }
                    
                    purchaseList.add(book);
                } else {
                    // 디버깅용: 상품 정보를 찾지 못했을 경우 콘솔에 출력
                    System.out.println("⚠️ [경고] saleId " + basket.getSaleId() + "에 해당하는 도서 정보를 찾을 수 없습니다.");
                }
            }
        }
        return purchaseList;
    }
    
    public Purchase findById(int purchaseId) {
        return purchaseRepository.findById(purchaseId);
    }

	public String getMemberIdByNum(int userRegNum) {
		return purchaseRepository.findMemberId(userRegNum);
	}
    
    
}