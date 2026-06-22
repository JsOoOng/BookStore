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
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.purchase.service.PurchaseService;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
@RequestMapping("/cookie/basket")
public class CookieBasketController {

    @Autowired
    private PurchaseService purchaseService;

    // [핵심] 쿠키에서 데이터를 추출하는 공통 로직 (Private 메서드)
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
                    } catch (Exception e) { e.printStackTrace(); }
                }
            }
        }
        return basketList;
    }

 // 1. 장바구니 목록 조회 (데이터 결합 로직 보완)
    @GetMapping("/list")
    public String getCookieBasketList(HttpServletRequest request, Model model) {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        
        // [수정 포인트] Service에서 받아온 리스트를 한 번 더 검증하고 값을 채웁니다.
        List<BookVO> purchaseList = purchaseService.getBasketDetails(basketList);
        
        // 쿠키에 있는 수량(quantity)과 가격을 BookVO에 명시적으로 주입
        if (purchaseList != null && !purchaseList.isEmpty()) {
            for (BookVO book : purchaseList) {
                for (BasketVO basket : basketList) {
                    if (book.getSaleId() == basket.getSaleId()) {
                        book.setQuantity(basket.getQuantity());
                        // 필요시 DB 가격 대신 쿠키 저장 당시의 가격을 사용할 수도 있음
                        // book.setPrice(basket.getPrice()); 
                        break;
                    }
                }
            }
        }
        
        model.addAttribute("purchaseList", purchaseList);
        model.addAttribute("basketList", basketList);
        model.addAttribute("pageName", "pages/basket/cookie_basket");
        return "common/layout";
    }

    // 2. 장바구니 담기
    @PostMapping("/add")
    public String addBasket(BasketVO basket, HttpServletRequest request, HttpServletResponse response) throws Exception {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        ObjectMapper mapper = new ObjectMapper();

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
        Cookie newCookie = new Cookie("cookie_basket", URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        newCookie.setMaxAge(60 * 60 * 24 * 7);
        response.addCookie(newCookie);

        return "redirect:/cookie/basket/list";
    }

    // 3. 결제 진입 (주문서 작성 페이지로 이동)
    @GetMapping("/checkout")
    public String checkout(HttpServletRequest request, Model model) {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        
        // 이 purchaseList가 null이거나 비어있으면 JSP에서 forEach가 안 돕니다!
        model.addAttribute("purchaseList", purchaseService.getBasketDetails(basketList));
        model.addAttribute("isGuest", true);
        
        return "pages/purchase/cookie_order_form"; 
    }
    
    @PostMapping("/update")
    @ResponseBody // JSON 또는 문자열 응답을 위해 필수
    public String updateQuantity(int saleId, int qty, HttpServletRequest request, HttpServletResponse response) throws Exception {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        for (BasketVO b : basketList) {
            if (b.getSaleId() == saleId) {
                b.setQuantity(qty);
                break;
            }
        }
        // 수정된 리스트를 다시 쿠키에 저장
        ObjectMapper mapper = new ObjectMapper();
        String newJsonValue = mapper.writeValueAsString(basketList);
        Cookie newCookie = new Cookie("cookie_basket", URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        newCookie.setMaxAge(60 * 60 * 24 * 7);
        response.addCookie(newCookie);
        
        return "ok";
    }
}