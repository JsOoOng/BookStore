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

    // 1. 쿠키에서 장바구니 리스트 가져오기
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

    // 2. 쿠키에 장바구니 상품 추가
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

    public String executeCookieCheckout(CookieOrderVO cookieOrder, String ids) {
        System.out.println("DEBUG: 주문 시작 - 주문번호: " + cookieOrder.getOrderId());
        
        // 1. 헤더 저장
        TransactionStatus status = transactionManager.getTransaction(new DefaultTransactionDefinition());
        try {
            int headerResult = cookiePurchaseRepository.insertCookieOrder(cookieOrder);
            if (headerResult == 0) throw new RuntimeException("헤더 저장 실패");
            transactionManager.commit(status);
            System.out.println("DEBUG: 헤더 커밋 완료");
        } catch (Exception e) {
            transactionManager.rollback(status);
            throw e;
        }

        // 2. 상세 저장
        TransactionStatus detailStatus = transactionManager.getTransaction(new DefaultTransactionDefinition());
        try {
            String[] idArray = ids.split(",");
            if (cookieOrder.getItems() != null) {
                for (BasketVO item : cookieOrder.getItems()) {
                    for (String selectedId : idArray) {
                        if (String.valueOf(item.getSaleId()).equals(selectedId)) {
                            // 상세 저장 시 쿼리 파라미터를 명시적으로 넘김
                            // 여기서 order_id는 위에서 이미 커밋된 헤더의 order_id와 100% 일치해야 함
                            cookiePurchaseRepository.insertCookieOrderDetail(cookieOrder.getOrderId(), item);
                            cookiePurchaseRepository.decreaseStock(item.getSaleId(), item.getQuantity());
                            break;
                        }
                    }
                }
            }
            transactionManager.commit(detailStatus);
            System.out.println("DEBUG: 상세 저장 완료");
            return cookieOrder.getOrderId();
        } catch (Exception e) {
            transactionManager.rollback(detailStatus);
            System.err.println("DEBUG: 상세 저장 중 에러 발생: " + e.getMessage());
            throw e;
        }
    }
}