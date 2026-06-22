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
import org.springframework.transaction.annotation.Transactional;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.cookie.model.CookieOrderVO;
import com.cosmic.library.cookie.repository.CookiePurchaseRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class CookieService {

    @Autowired
    private CookiePurchaseRepository cookiePurchaseRepository;

    private static final String COOKIE_NAME = "cookie_basket";
    private final ObjectMapper mapper = new ObjectMapper();

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

    /**
     * 주문 저장 로직: 헤더와 상세 정보를 트랜잭션으로 처리
     */
    @Transactional // 💡 여러 테이블에 저장하므로 트랜잭션 필수
    public void executeCookieCheckout(CookieOrderVO cookieOrder) {
        // 1. 주문 헤더 저장 후 생성된 ID 반환
        int orderId = cookiePurchaseRepository.insertCookieOrder(cookieOrder);
        
        // 2. 💡 상세 내역(items) 저장 로직 추가 (DB 테이블 구조에 맞춰 수정하세요)
        if (cookieOrder.getItems() != null) {
            for (BasketVO item : cookieOrder.getItems()) {
                // 예시: cookiePurchaseRepository.insertOrderDetail(orderId, item);
                // 이 메서드가 없으면 리포지토리에 추가해야 합니다.
                System.out.println("주문 상세 저장 - OrderID: " + orderId + ", 상품ID: " + item.getSaleId());
            }
        }
    }
}