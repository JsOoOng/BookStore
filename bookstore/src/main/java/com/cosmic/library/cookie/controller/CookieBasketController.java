package com.cosmic.library.cookie.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;
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

    // 🪐 [네이버 발급 토큰 장착] BookController와 완전 동기화
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    // 🛰️ [컨트롤러 이식] 네이버 실시간 도서 표지 수집 전용 통신 파이프라인
    private String getNaverBookCover(String isbn) {
        if (isbn == null || isbn.trim().isEmpty()) {
            return "https://via.placeholder.com/100x140?text=No+Cover";
        }
        try {
            String apiURL = "https://openapi.naver.com/v1/search/book.json?query=" + isbn.trim() + "&display=1";
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            
            con.setRequestMethod("GET");
            con.setRequestProperty("X-Naver-Client-Id", NAVER_CLIENT_ID);
            con.setRequestProperty("X-Naver-Client-Secret", NAVER_CLIENT_SECRET);

            int responseCode = con.getResponseCode();
            if (responseCode == 200) { 
                BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
                String inputLine;
                StringBuilder response = new StringBuilder();
                while ((inputLine = br.readLine()) != null) {
                    response.append(inputLine);
                }
                br.close();

                JSONObject jsonObject = new JSONObject(response.toString());
                JSONArray items = jsonObject.getJSONArray("items");
                
                if (items.length() > 0) {
                    JSONObject bookItem = items.getJSONObject(0);
                    return bookItem.getString("image"); // 🎯 네이버 실시간 표지 탈취 성공!
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "https://via.placeholder.com/100x140?text=No+Cover";
    }

    // 쿠키 추출 공통 로직
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

    // 1. 장바구니 목록 조회 (컨트롤러단 네이버 API 레이더 전개)
    @GetMapping("/list")
    public String getCookieBasketList(HttpServletRequest request, Model model) {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        List<BookVO> purchaseList = purchaseService.getBasketDetails(basketList);
        
        if (purchaseList != null && !purchaseList.isEmpty()) {
            for (BookVO book : purchaseList) {
                // 📡 [레이더 포격] 뷰로 던지기 직전, 확보된 isbn으로 네이버 주소를 강제 주입한다!
                if (book.getIsbn() != null) {
                    book.setImage(getNaverBookCover(book.getIsbn()));
                }
                
                for (BasketVO basket : basketList) {
                    if (book.getSaleId() == basket.getSaleId()) {
                        book.setQuantity(basket.getQuantity());
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

    // 3. 결제 진입 (주문서 작성 페이지로 이동 - 컨트롤러단 네이버 API 레이더 전개)
    @GetMapping("/checkout")
    public String checkout(HttpServletRequest request, Model model) {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        List<BookVO> purchaseList = purchaseService.getBasketDetails(basketList);
        
        if (purchaseList != null && !purchaseList.isEmpty()) {
            for (BookVO book : purchaseList) {
                // 📡 [레이더 포격] 결제 폼 이동 직전에도 네이버 표지로 완전히 덮어버린다!
                if (book.getIsbn() != null) {
                    book.setImage(getNaverBookCover(book.getIsbn()));
                }
                
                for (BasketVO basket : basketList) {
                    if (book.getSaleId() == basket.getSaleId()) {
                        book.setQuantity(basket.getQuantity());
                        break;
                    }
                }
            }
        }
        
        model.addAttribute("purchaseList", purchaseList);
        model.addAttribute("basketList", basketList);
        model.addAttribute("isGuest", true);
        
        return "pages/purchase/cookie_order_form"; 
    }

    // 2. 장바구니 담기 및 4. 수량 업데이트는 기존 로직 유지...
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
        if (!exists) { basketList.add(basket); }
        String newJsonValue = mapper.writeValueAsString(basketList);
        Cookie newCookie = new Cookie("cookie_basket", URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        newCookie.setMaxAge(60 * 60 * 24 * 7);
        response.addCookie(newCookie);
        return "redirect:/cookie/basket/list";
    }

    @PostMapping("/update")
    @ResponseBody
    public String updateQuantity(int saleId, int qty, HttpServletRequest request, HttpServletResponse response) throws Exception {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        for (BasketVO b : basketList) {
            if (b.getSaleId() == saleId) { b.setQuantity(qty); break; }
        }
        ObjectMapper mapper = new ObjectMapper();
        String newJsonValue = mapper.writeValueAsString(basketList);
        Cookie newCookie = new Cookie("cookie_basket", URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        newCookie.setMaxAge(60 * 60 * 24 * 7);
        response.addCookie(newCookie);
        return "ok";
    }
}