package com.cosmic.library.cookie.service;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.cookie.model.CookieOrderVO;
import com.cosmic.library.cookie.model.GuestOrderVO;
import com.cosmic.library.cookie.repository.CookiePurchaseRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class CookieService {

    @Autowired
    private CookiePurchaseRepository cookiePurchaseRepository;

    @Autowired
    private PlatformTransactionManager transactionManager;

    private static final String COOKIE_NAME = "cookie_basket";
    private final ObjectMapper mapper = new ObjectMapper();

    // 🪐 1. 쿠키에서 장바구니 리스트 가져오기 (무결성 유지)
    public List<BasketVO> getBasketListFromCookie(String cookieValue) {
        if (cookieValue == null || cookieValue.isEmpty()) {
            return new ArrayList<>();
        }
        try {
            String decodedValue = URLDecoder.decode(cookieValue, "UTF-8");
            return mapper.readValue(decodedValue, new TypeReference<List<BasketVO>>() {});
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // 🪐 2. 쿠키에 장바구니 상품 추가 (무결성 유지)
    public void addBasketToCookie(BasketVO basket, HttpServletRequest request, HttpServletResponse response) throws Exception {
        List<BasketVO> basketList = new ArrayList<>();
        Cookie[] cookies = request.getCookies();

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (COOKIE_NAME.equals(cookie.getName())) {
                    String jsonValue = URLDecoder.decode(cookie.getValue(), "UTF-8");
                    basketList = mapper.readValue(jsonValue, new TypeReference<List<BasketVO>>() {});
                    break;
                }
            }
        }

        boolean exists = false;
        for (BasketVO b : basketList) {
            if (b.getSaleId() == basket.getSaleId()) {
                b.setQuantity(b.getQuantity() + basket.getQuantity());
                exists = true;
                break;
            }
        }
        if (!exists) {
            basketList.add(basket);
        }

        String newJsonValue = mapper.writeValueAsString(basketList);
        Cookie newCookie = new Cookie(COOKIE_NAME, URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        newCookie.setMaxAge(60 * 60 * 24 * 7);
        response.addCookie(newCookie);
    }

    // 💥 3. [개조 완료] 비회원 원천 정보 + 영수증 마스터 + 품목 상세 올인원 트랜잭션 엔진
    public String executeCookieCheckout(CookieOrderVO cookieOrder, String ids) {
        System.out.println("DEBUG: [정규화 주문 기동] 주문번호: " + cookieOrder.getPurchaseId());
        
        // 하나의 거대한 트랜잭션 경계선 확립
        TransactionStatus txStatus = transactionManager.getTransaction(new DefaultTransactionDefinition());
        
        try {
            // STEP 1: 비회원 유저 원천 정보 저장 (GUEST_USER 테이블 적재)
            int userResult = cookiePurchaseRepository.insertGuestUser(cookieOrder);
            if (userResult == 0) throw new RuntimeException("비회원 원천 정보 등록 실패");
            
            // STEP 2: 비회원 영수증 헤더 발행 (GUEST_PURCHASE 테이블 적재)
            int purchaseResult = cookiePurchaseRepository.insertCookieOrder(cookieOrder);
            if (purchaseResult == 0) throw new RuntimeException("비회원 결제 마스터 발행 실패");
            
            // STEP 3: 선택한 품목별 상세 정보 및 재고 제어 (GUEST_PURCHASE_DETAIL 테이블 적재)
            String[] idArray = ids.split(",");
            if (cookieOrder.getItems() != null) {
                for (BasketVO item : cookieOrder.getItems()) {
                    for (String selectedId : idArray) {
                        if (String.valueOf(item.getSaleId()).equals(selectedId)) {
                            // 상세 내역 인서트 때려박기
                            cookiePurchaseRepository.insertCookieOrderDetail(cookieOrder.getPurchaseId(), item);
                            // 실시간 상품 재고 소모 차감
                            cookiePurchaseRepository.decreaseStock(item.getSaleId(), item.getQuantity());
                            break;
                        }
                    }
                }
            }
            
            // 3대 공정이 모두 무결하면 최종 행성 커밋 승인!
            transactionManager.commit(txStatus);
            System.out.println("DEBUG: [정규화 주문 성공] 전 조치 커밋 완료.");
            return cookieOrder.getPurchaseId();
            
        } catch (Exception e) {
            // 단 하나라도 균열이 생기면 폭파하고 롤백!
            transactionManager.rollback(txStatus);
            System.err.println("🚨 DEBUG: 비회원 주문 중 치명적 에러 발생, 전 조치 롤백 실행: " + e.getMessage());
            throw e;
        }
    }
      
    // 🪐 4. [동기화 완료] 파트너사 전용 비회원 주문 목록 추출 파이프라인
    public List<GuestOrderVO> getVendorGuestOrders(int vendorRegNum) {
        return cookiePurchaseRepository.getVendorGuestOrders(vendorRegNum);
    }
    
    // 🪐 5. [신규 레이더] 비회원 본인 주문 조회 엔진
    public List<GuestOrderVO> trackGuestOrder(String purchaseId, String name) {
        return cookiePurchaseRepository.trackGuestOrder(purchaseId, name);
    }
    
 // 🪐 6. [신규 레이더] 비회원 주문번호 찾기 (이름, 전화번호, 별명으로 조회)
    public List<String> findIdsByGuestInfo(String name, String phone, String nickname) {
        return cookiePurchaseRepository.findIdsByGuestInfo(name, phone, nickname);
    }

	public boolean startShipping(int purchaseId) {
        return cookiePurchaseRepository.updateStatus(purchaseId, "SHIPPING") > 0;
    }


}