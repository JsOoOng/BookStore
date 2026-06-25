package com.cosmic.library.basket.controller;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.service.BasketService;
import com.cosmic.library.cookie.service.CookieService; // 쿠키 서비스 추가
import com.cosmic.library.member.model.MemberVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.util.ArrayList;
import java.util.List;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import org.json.JSONArray;
import org.json.JSONObject;

@Controller
@RequestMapping("/basket")
public class BasketController {

    @Autowired
    private BasketService basketService;
    
    @Autowired
    private CookieService cookieService; // 쿠키 로직 전담 서비스

 // 1. 장바구니 페이지 조회 (회원/비회원 통합)
    @GetMapping("")
    public String list(Model model, HttpSession session, HttpServletRequest request) {
        MemberVO member = getLoginMember(session);
        List<BasketVO> basketList = new ArrayList<>();

        // 1. 회원일 경우: DB에서 데이터 조회
        if (member != null) {
            basketList = basketService.getList(member.getUser_reg_num());
        } 
        // 2. 비회원일 경우: 쿠키에서 데이터 조회
        else {
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("cookie_basket".equals(cookie.getName())) {
                        // CookieService의 getBasketListFromCookie 메서드 활용
                        basketList = cookieService.getBasketListFromCookie(cookie.getValue());
                        break;
                    }
                }
            }
        }

        // 공통: 상품 이미지 수집 (네이버 API)
        if (basketList != null) {
            for (BasketVO vo : basketList) {
            	String query = (vo.getIsbn() != null) ? vo.getIsbn() : vo.getTitle();
                vo.setImage(getNaverBookCover(query));
            }
        }

        model.addAttribute("basketList", basketList);
        model.addAttribute("pageName", "pages/basket/basket");
        
        return "common/layout";
    }

    // 2. 장바구니 삭제
    @PostMapping("/delete")
    public String delete(@RequestParam(value = "basketId", required = false) Integer basketId,
                         @RequestParam(value = "ids", required = false) int[] ids, HttpSession session) {
        MemberVO member = getLoginMember(session);
        if (member == null) return "redirect:/member/login";

        if (basketId != null) basketService.delete(member.getUser_reg_num(), basketId);
        else if (ids != null && ids.length > 0) basketService.delete(member.getUser_reg_num(), ids);

        return "redirect:/basket";
    }

    // 3. 장바구니 선택 구매 사령탑
 // 3. 장바구니 선택 구매 사령탑
    @GetMapping("/buy")
    public String buy(@RequestParam(value = "basketIds", required = false) String basketIds, 
                      HttpSession session) {
        
        MemberVO member = getLoginMember(session);

        // [비회원일 경우] 쿠키 장바구니 결제 페이지로 이동
        if (member == null) {
            // 비회원은 선택된 ID가 아닌, 쿠키 전체를 들고 가야 하므로 
            // 별도의 쿠키 결제 확인 페이지로 리다이렉트
            return "redirect:/cookie/basket/list"; 
        }

        // [회원일 경우] 기존 결제 페이지로 이동
        return "redirect:/purchase/view?basketIds=" + basketIds;
    }

    // 4 & 5. [핵심 통합] 장바구니 담기 (회원:DB / 비회원:쿠키)
    @PostMapping("/addMarketProduct")
    @ResponseBody
    public String addMarketProduct(@RequestParam("saleId") Integer saleId, 
                                   @RequestParam(value = "qty", defaultValue = "1") int qty, 
                                   HttpSession session,
                                   HttpServletRequest request,
                                   HttpServletResponse response) {
        try {
            if (saleId == null) return "error";

            MemberVO member = getLoginMember(session);
            
            // [비회원일 경우 쿠키 처리]
            if (member == null) {
                BasketVO basket = new BasketVO();
                basket.setSaleId(saleId);
                basket.setQuantity(qty);
                // 쿠키 로직 실행 (CookieService 사용)
                cookieService.addBasketToCookie(basket, request, response);
                return "ok_cookie"; // 프론트에서 비회원 완료 알림용 신호
            }

            // [회원일 경우 DB 처리]
            boolean isSuccess = basketService.addMarketBasket(member.getUser_reg_num(), saleId, qty);
            return isSuccess ? "ok" : "fail";

        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }

    // 6. 장바구니 수량 실시간 변경
    @PostMapping("/updateQty")
    @ResponseBody
    public String updateQty(@RequestParam("basketId") int basketId,
                            @RequestParam("qty") int qty,
                            HttpSession session) {
        MemberVO member = getLoginMember(session);
        if (member == null) return "NOT_LOGIN";

        boolean isSuccess = basketService.updateBasketQty(basketId, member.getUser_reg_num(), qty);
        return isSuccess ? "ok" : "fail";
    }
    
    private MemberVO getLoginMember(HttpSession session) {
        return (MemberVO) session.getAttribute("loginMember");
    }

    // 네이버 도서 표지 API 로직 (기존과 동일)
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    private String getNaverBookCover(String query) {
        if (query == null || query.trim().isEmpty()) {
            return "https://via.placeholder.com/150x220?text=No+Img";
        }
        try {
            // 불안정한 split 조각내기 폐기, 전체 문자열을 안전하게 UTF-8 인코딩
            String encodedQuery = URLEncoder.encode(query.trim(), "UTF-8");
            String apiURL = "https://openapi.naver.com/v1/search/book.json?query=" + encodedQuery + "&display=1";
            
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
                    return bookItem.getString("image");
                }
            }
        } catch (Exception e) {
            System.out.println("🚨 장바구니 네이버 표지 통신 장애: " + e.getMessage());
        }
        return "https://via.placeholder.com/150x220?text=No+Img";
    }
}