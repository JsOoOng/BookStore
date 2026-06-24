package com.cosmic.library.cookie.controller;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
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
                                 HttpServletResponse response,
                                 HttpSession session) throws Exception {
        
        // 1. 주문번호 생성 및 주문 정보 저장
        String orderId = "G" + System.currentTimeMillis() + (int)(Math.random() * 900 + 100);
        order.setOrderId(orderId);
        
        cookieService.executeCookieCheckout(order, ids); 
        
        // 성공 페이지에서 보여주기 위해 세션에 저장
        session.setAttribute("guestOrderId", orderId);

        // 2. 쿠키에서 현재 장바구니 리스트 가져오기
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
            cookie.setMaxAge(0);
        } else {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(remainingList);
            cookie = new Cookie("cookie_basket", URLEncoder.encode(json, "UTF-8"));
            cookie.setMaxAge(60 * 60 * 24 * 7);
        }
        cookie.setPath("/");
        response.addCookie(cookie);
        
        // 리다이렉트하여 success 메서드 타게 함
        return "redirect:/cookie/purchase/success";
    }

    private List<BasketVO> getBasketListFromRequest(HttpServletRequest request) {
        List<BasketVO> basketList = new ArrayList<>();
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
    
    @PostMapping("/checkout")
    public String processCheckout(CookieOrderVO cookieOrder, 
                                 @RequestParam("ids") String ids, 
                                 HttpSession session) {
        
        String orderId = cookieService.executeCookieCheckout(cookieOrder, ids);
        session.setAttribute("guestOrderId", orderId);
        
        // 경로 수정: 리다이렉트 경로를 전체 경로로 명시
        return "redirect:/cookie/purchase/success";
    }
    
    @GetMapping("/success")
    public String showSuccess(HttpSession session, Model model) {
        String orderId = (String) session.getAttribute("guestOrderId");
        
        if (orderId == null) {
            return "redirect:/";
        }
        
        model.addAttribute("orderId", orderId);
        session.removeAttribute("guestOrderId"); 
        
        return "pages/purchase/cookie_purchase_success";
    }
}