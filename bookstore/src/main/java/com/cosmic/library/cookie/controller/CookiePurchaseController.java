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
import com.cosmic.library.purchase.service.PurchaseService;

@Controller
@RequestMapping("/cookie/purchase")
public class CookiePurchaseController {

    @Autowired
    private PurchaseService purchaseService; 

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
    	
        // 1. 디버깅 로그
        System.out.println("--- 🚀 결제 요청 데이터 분석 ---");
        request.getParameterMap().forEach((k, v) -> System.out.println(k + " : " + Arrays.toString(v)));

        // 2. 바인딩된 데이터 검증
        if (order.getItems() == null || order.getItems().isEmpty()) {
            System.out.println("❌ 상품 데이터 바인딩 실패 또는 비어있음");
            return "redirect:/cookie/basket/checkout?error=no_items";
        }

        // 3. 서비스 실행
        purchaseService.executeCookieCheckout(order); 
        
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