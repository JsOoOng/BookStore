package com.cosmic.library.purchase.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // 🌟 트랜잭션 추가

import com.cosmic.library.basket.repository.BasketDAOH2;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.service.BookService;
import com.cosmic.library.purchase.model.Purchase;
import com.cosmic.library.purchase.repository.PurchaseRepository;

@Service
public class PurchaseService {

    @Autowired
    private PurchaseRepository purchaseRepository;

    @Autowired
    private BookService bookService;

    @Autowired
    private BasketDAOH2 basketRepository;

    // 1. 기존 컨트롤러 연동용 기본 저장
    public void buy(Purchase purchase) {
        purchaseRepository.save(purchase);
    }

    // 2. 단일 구매 사령탑
    @Transactional // 🌟 결제 기록 저장 중 터지면 전체 롤백 안전장치
    public void buySingle(int userRegNum, int bookId) { // String memberId ➔ int userRegNum
        BookVO book = bookService.getById(bookId);

        Purchase p = new Purchase();
        p.setUserRegNum(userRegNum); // 🌟 바뀐 VO 스펙(int) 반영
        p.setBookId(bookId);
        
        // 🌟 중요: 원천 book 테이블에 price가 제거되었으므로, 
        // 3단계 오픈마켓(PRODUCT_SALE) 테이블과 조인하기 전까지 에러 방지용 임시 0원 패치
        p.setPrice(0);
        p.setQuantity(1);
        p.setTotalPrice(0);

        purchaseRepository.save(p);
    }

    // 3. 장바구니 품목 선택 구매 (다중 처리)
    @Transactional // 🌟 하나라도 구매 및 장바구니 삭제 실패 시 전부 원상복구
    public void buyFromBusket(int userRegNum, String bookIds) { // String memberId ➔ int userRegNum
        String[] ids = bookIds.split(",");

        for (String id : ids) {
            int bookId = Integer.parseInt(id.trim());
            BookVO book = bookService.getById(bookId);

            Purchase p = new Purchase();
            p.setUserRegNum(userRegNum); // 🌟 바뀐 VO 스펙(int) 반영
            p.setBookId(bookId);
            
            // 🌟 에러 방지용 임시 0원 패치 (차후 PRODUCT_SALE과 연동 예정)
            p.setPrice(0);
            p.setQuantity(1);
            p.setTotalPrice(0);

            purchaseRepository.save(p);

            // 🌟 앞서 리팩토링한 장바구니 삭제 매개변수 규격(int)에 맞춰 완벽하게 동기화!
            basketRepository.delete(userRegNum, bookId);
        }
    }
    
    // 4. 대원별 탐사(구매) 기록 호출
    public List<Purchase> getMyPurchases(int userRegNum) { // String memberId ➔ int userRegNum
        return purchaseRepository.findByMemberId(userRegNum);
    }
    
 // 🪐 [추가] 판매자별 주문서 긁어오기
    public List<Purchase> getVendorOrders(int vendorRegNum) {
        return purchaseRepository.findByVendorRegNum(vendorRegNum);
    }

    // 🪐 [추가] 배송 시작 처리 
    public boolean startShipping(int purchaseId) {
        // 상태값을 'SHIPPING'(배송 중)으로 변경하도록 지시!
        return purchaseRepository.updateStatus(purchaseId, "SHIPPING") > 0;
    }
}