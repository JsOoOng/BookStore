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
import org.springframework.web.bind.annotation.RequestParam;
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

 // 1. 장바구니 목록 조회 (디버깅 로그 + 네이버 API 이미지 + 수량 매핑)
    @GetMapping("/list")
    public String getCookieBasketList(HttpServletRequest request, Model model) {
        // 쿠키에서 장바구니 정보(saleId, quantity) 가져오기
        List<BasketVO> basketList = getBasketListFromRequest(request);
        
        // [디버깅] 쿠키 데이터 확인
        for (BasketVO b : basketList) {
            System.out.println("디버깅 - 쿠키 내 saleId: " + b.getSaleId() + ", 수량: " + b.getQuantity());
        }

        // DB에서 상품 정보(제목, 가격, ISBN 등) 조회
        List<BookVO> purchaseList = purchaseService.getBasketDetails(basketList);
        
        if (purchaseList != null && !purchaseList.isEmpty()) {
            for (BookVO book : purchaseList) {
                // [디버깅] DB 데이터 확인
                System.out.println("디버깅 - DB에서 조회된 책: " + book.getTitle() + " (saleId: " + book.getSaleId() + ")");

                // 1. 네이버 도서 커버 이미지 주입
                if (book.getIsbn() != null) {
                    book.setImage(getNaverBookCover(book.getIsbn()));
                }
                
                // 2. 쿠키에 저장된 수량(quantity)을 book 객체에 매핑
                for (BasketVO basket : basketList) {
                    // 주의: saleId가 객체 타입(Integer/Long)이면 .equals()를 사용하세요
                    if (book.getSaleId() == basket.getSaleId()) {
                        book.setQuantity(basket.getQuantity());
                        break;
                    }
                }
            }
        }
        
        model.addAttribute("purchaseList", purchaseList);
        model.addAttribute("basketList", basketList); // 필요 시 사용
        model.addAttribute("pageName", "pages/basket/cookie_basket");
        
        return "common/layout";
    }

 // 3. 결제 진입 (주문서 작성 페이지로 이동 - 선택된 상품만 필터링)
    @GetMapping("/checkout")
    public String checkout(@RequestParam("ids") String ids, HttpServletRequest request, Model model) {
        // 1. 쿠키에서 모든 장바구니 데이터를 가져옴
        List<BasketVO> allBasketList = getBasketListFromRequest(request);
        
        // 2. 전달받은 체크된 ID들을 배열로 변환
        String[] targetIds = ids.split(",");
        
        // 3. 체크된 ID에 해당하는 BasketVO만 추려내기
        List<BasketVO> selectedBasketList = new ArrayList<>();
        for (BasketVO basket : allBasketList) {
            for (String id : targetIds) {
                // saleId는 DB 컬럼 타입에 따라 String.valueOf로 변환하여 비교
                if (String.valueOf(basket.getSaleId()).equals(id)) {
                    selectedBasketList.add(basket);
                    break;
                }
            }
        }
        
        // 4. 추려낸 리스트로 DB에서 상품 상세 정보 조회
        List<BookVO> purchaseList = purchaseService.getBasketDetails(selectedBasketList);
        
        // 5. 이미지 매핑 및 수량 매핑
        if (purchaseList != null && !purchaseList.isEmpty()) {
            for (BookVO book : purchaseList) {
                // 네이버 표지 로딩
                if (book.getIsbn() != null) {
                    book.setImage(getNaverBookCover(book.getIsbn()));
                }
                
                // selectedBasketList에 담긴 수량 정보 매핑
                for (BasketVO basket : selectedBasketList) {
                    if (String.valueOf(book.getSaleId()).equals(String.valueOf(basket.getSaleId()))) {
                        book.setQuantity(basket.getQuantity());
                        break;
                    }
                }
            }
        }
        
        model.addAttribute("purchaseList", purchaseList);
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
    
 // 6. 비회원 장바구니 선택 삭제 (컨트롤러 하단에 추가)
    @PostMapping("/delete")
    @ResponseBody // 👈 404/화면 전환 방지를 위해 필수!
    public String deleteCookieBasket(@RequestParam("ids") String ids, HttpServletRequest request, HttpServletResponse response) throws Exception {
        // 1. 쿠키에서 현재 장바구니 가져오기
        List<BasketVO> basketList = getBasketListFromRequest(request);
        
        // 2. 삭제할 대상 ID들을 배열로 변환
        String[] targetIds = ids.split(",");
        
        // 3. 삭제 대상이 아닌 놈들만 남기기 (새 리스트 생성)
        List<BasketVO> updatedList = new ArrayList<>();
        for (BasketVO b : basketList) {
            boolean isDeleteTarget = false;
            for (String id : targetIds) {
                if (String.valueOf(b.getSaleId()).equals(id)) {
                    isDeleteTarget = true;
                    break;
                }
            }
            if (!isDeleteTarget) {
                updatedList.add(b);
            }
        }
        
        // 4. 쿠키 갱신
        ObjectMapper mapper = new ObjectMapper();
        String newJsonValue = mapper.writeValueAsString(updatedList);
        Cookie newCookie = new Cookie("cookie_basket", URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        
        // 장바구니가 비었으면 쿠키 만료(삭제), 아니면 갱신
        if (updatedList.isEmpty()) {
            newCookie.setMaxAge(0);
        } else {
            newCookie.setMaxAge(60 * 60 * 24 * 7);
        }
        
        response.addCookie(newCookie);
        
        // 5. 프론트엔드(JS)에서 확인할 "ok" 반환
        return "ok";
    }
}