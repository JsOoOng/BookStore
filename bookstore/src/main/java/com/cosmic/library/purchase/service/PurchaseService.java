package com.cosmic.library.purchase.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.service.BasketService;
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

    // =========================================================================
    // 🚀 [대통합 결제 엔진] 마스터-디테일 생성 + 재고 차감 + 장바구니 비우기
    // =========================================================================
    @Transactional // 단 하나의 에러라도 발생하면 100% 원상복구(Rollback) 시키는 절대 방어막!
    public void executeCheckout(int userRegNum, List<BasketVO> itemsToBuy, int[] basketIdsToRemove) {
        
        // 1. 장바구니 리스트를 스캔하여 총 결제 금액(total_price) 산출
        int grandTotal = 0;
        for (BasketVO item : itemsToBuy) {
            grandTotal += (item.getPrice() * item.getQuantity());
        }

        // 2. 마스터(PURCHASE) 테이블에 '영수증 헤더' 발급 및 번호 가로채기
        int purchaseId = purchaseRepository.insertMaster(userRegNum, grandTotal);
        if (purchaseId <= 0) throw new RuntimeException("🚨 마스터 영수증 발급 실패!");

        // 3. 구매한 품목들을 순회하며 '세부 품목(DETAIL)' 기록 및 재고 차감
        for (BasketVO item : itemsToBuy) {
            // 해당 마켓 상품의 파트너사 정보(v_reg_num)를 스캔
            ProductSaleVO saleInfo = productSaleDAO.findById(item.getSaleId());
            if (saleInfo == null) throw new RuntimeException("🚨 마켓 상품 데이터 소실!");
            
            // 디테일 기록 저장
            purchaseRepository.insertDetail(
                purchaseId, 
                item.getSaleId(), 
                saleInfo.getVRegNum(), 
                item.getQuantity(), 
                item.getPrice()
            );

            // 💥 구매한 수량만큼 마켓의 실시간 창고 재고 자동 차감!
            productSaleDAO.updateStock(item.getSaleId(), -item.getQuantity());
        }

        // 4. 결제가 무사히 끝났다면, 장바구니에 담겨있던 흔적을 완전히 소각!
        if (basketIdsToRemove != null && basketIdsToRemove.length > 0) {
            basketService.delete(userRegNum, basketIdsToRemove);
        }
    }

    // =========================================================================
    // 📜 대원별 마이페이지 탐사(구매) 기록 호출
    // =========================================================================
    public List<Purchase> getMyPurchases(int userRegNum) {
        return purchaseRepository.findByMemberId(userRegNum);
    }
    
    // =========================================================================
    // 🏢 파트너 대시보드용 주문서 스캔
    // =========================================================================
    public List<Purchase> getVendorOrders(int vendorRegNum) {
        return purchaseRepository.findByVendorRegNum(vendorRegNum);
    }

    // =========================================================================
    // 🚚 [배송하기] 파트너사 배송 상태 워프 엔진 (READY ➔ SHIPPING)
    // =========================================================================
    public boolean startShipping(int purchaseId) {
        return purchaseRepository.updateStatus(purchaseId, "SHIPPING") > 0;
    }
}