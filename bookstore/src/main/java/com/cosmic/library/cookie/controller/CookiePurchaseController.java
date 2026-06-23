package com.cosmic.library.cookie.controller;

import java.util.ArrayList;
import java.util.Arrays;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.cosmic.library.cookie.model.CookieOrderVO;
import com.cosmic.library.cookie.service.CookieService; // 💥 [수정] 완벽하게 빌드된 비회원 서비스 임포트!

@Controller
@RequestMapping("/cookie/purchase")
public class CookiePurchaseController {

    @Autowired
    private CookieService cookieService; // 💥 [수정] PurchaseService 라인을 끊고 CookieService로 교체 주입!

    @PostMapping("/buy")
    public String cookiePurchase(@ModelAttribute("cookieOrderVO") CookieOrderVO order, 
                                 HttpServletRequest request, 
                                 HttpServletResponse response) {
        
        System.out.println("--- 🔎 [디버깅] 실제 넘어온 모든 파라미터 이름 ---");
        java.util.Enumeration<String> params = request.getParameterNames();
        while (params.hasMoreElements()) {
            String paramName = params.nextElement();
            String paramValue = request.getParameter(paramName);
            System.out.println("파라미터 이름: " + paramName + " / 값: " + paramValue);
        }
        System.out.println("-------------------------------------------");
        
        System.out.println("--- 🚀 결제 요청 데이터 분석 ---");
        request.getParameterMap().forEach((k, v) -> System.out.println(k + " : " + Arrays.toString(v)));

        if (order.getItems() == null || order.getItems().isEmpty()) {
            System.out.println("❌ 상품 데이터 바인딩 실패 또는 비어있음");
            return "redirect:/cookie/basket/checkout?error=no_items";
        }

        // 3. 💥 [수정 완료] 사령관이 만든 무결성 비회원 결제 엔진 다이렉트 가동!
        cookieService.executeCookieCheckout(order); 
        
        // 4. 장바구니 쿠키 삭제
        Cookie cookie = new Cookie("cookie_basket", null);
        cookie.setMaxAge(0);
        cookie.setPath("/");
        response.addCookie(cookie);
        
        return "redirect:/cookie/purchase/success";
    }

    @RequestMapping("/success")
    public String purchaseSuccess() {
        return "pages/purchase/cookie_purchase_success";
    }
}