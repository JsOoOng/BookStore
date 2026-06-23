package com.cosmic.library.cookie.controller;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.cookie.model.CookieOrderVO;
import com.cosmic.library.cookie.service.CookieService;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
@RequestMapping("/cookie/purchase")
public class CookiePurchaseController {

    @Autowired
    private CookieService cookieService;

    @PostMapping("/buy")
    public String cookiePurchase(@ModelAttribute("cookieOrderVO") CookieOrderVO order, 
                                 @RequestParam("ids") String ids, 
                                 HttpServletRequest request, 
                                 HttpServletResponse response) throws Exception {
        
        // 1. 결제 처리 로직
        cookieService.executeCookieCheckout(order); 
        
        // 2. 쿠키에서 현재 장바구니 리스트 가져오기 (이제 null 안전)
        List<BasketVO> allBasketList = getBasketListFromRequest(request);
        
        // 3. 삭제할 대상 ID들을 배열로 변환
        String[] purchaseIds = ids.split(",");
        
        // 4. 구매한 ID(purchaseIds)에 포함되지 않은 놈들만 남기기
        List<BasketVO> remainingList = new ArrayList<>();
        for (BasketVO item : allBasketList) {
            boolean isPurchased = false;
            for (String id : purchaseIds) {
                if (String.valueOf(item.getSaleId()).equals(id)) {
                    isPurchased = true;
                    break;
                }
            }
            if (!isPurchased) {
                remainingList.add(item);
            }
        }
        
        // 5. 쿠키 갱신 로직
        Cookie cookie;
        if (remainingList.isEmpty()) {
            cookie = new Cookie("cookie_basket", null);
            cookie.setMaxAge(0); // 쿠키 삭제
        } else {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(remainingList);
            cookie = new Cookie("cookie_basket", URLEncoder.encode(json, "UTF-8"));
            cookie.setMaxAge(60 * 60 * 24 * 7); // 7일 유지
        }
        cookie.setPath("/");
        response.addCookie(cookie);
        
        return "redirect:/cookie/purchase/success";
    }

    // [중요] 장바구니 쿠키를 안전하게 가져오는 공통 메서드 구현
    private List<BasketVO> getBasketListFromRequest(HttpServletRequest request) {
        List<BasketVO> basketList = new ArrayList<>(); // 기본값으로 빈 리스트 생성
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("cookie_basket".equals(cookie.getName())) {
                    try {
                        String jsonValue = URLDecoder.decode(cookie.getValue(), "UTF-8");
                        ObjectMapper mapper = new ObjectMapper();
                        basketList = mapper.readValue(jsonValue, 
                                mapper.getTypeFactory().constructCollectionType(List.class, BasketVO.class));
                    } catch (Exception e) { 
                        e.printStackTrace(); 
                    }
                }
            }
        }
        return basketList;
    }
    
 // 🚀 결제 페이지 진입 (선택 상품 정보 조회)
    @RequestMapping("/checkout")
    public String checkout(@RequestParam("ids") String ids, 
                           HttpServletRequest request, 
                           org.springframework.ui.Model model) {
        
        // 1. 전체 장바구니에서 필요한 상품만 추출
        List<BasketVO> allBasketList = getBasketListFromRequest(request);
        List<BasketVO> checkoutList = new ArrayList<>();
        
        String[] targetIds = ids.split(",");
        
        for (BasketVO item : allBasketList) {
            for (String id : targetIds) {
                if (String.valueOf(item.getSaleId()).equals(id)) {
                    checkoutList.add(item);
                }
            }
        }
        
        // 2. 모델에 담아서 결제 페이지로 전달
        model.addAttribute("purchaseList", checkoutList);
        model.addAttribute("ids", ids); // 결제 완료 시 다시 전달할 ID들
        
        return "pages/purchase/cookie_purchase_form"; // 결제 폼 페이지 경로
    }

    @RequestMapping("/success")
    public String purchaseSuccess() {
        return "pages/purchase/cookie_purchase_success";
    }
}