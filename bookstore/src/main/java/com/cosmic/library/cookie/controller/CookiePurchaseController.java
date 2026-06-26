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
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.cookie.model.CookieOrderVO;
import com.cosmic.library.cookie.model.GuestOrderVO;
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
        
        // 💥 1. 정규화 3대장 테이블에 꽂아 넣을 식별자(ID) 이중 발급 엔진 기동!
        String purchaseId = "GPUR-" + System.currentTimeMillis() + (int)(Math.random() * 900 + 100); // 영수증 번호
        String guestId = "GST-" + session.getId().substring(0, 8) + System.currentTimeMillis();      // 비회원 원천 식별자

        order.setPurchaseId(purchaseId);
        order.setGuestId(guestId);
        
        // 2. 서비스로 트랜잭션 전개
        cookieService.executeCookieCheckout(order, ids); 
        
        // 기존 JSP 화면들과의 호환성을 위해 세션 이름은 guestOrderId 로 유지
        session.setAttribute("guestOrderId", purchaseId);

        // 3. 결제 완료된 상품들만 쿠키(장바구니)에서 폭파(제거)
        List<BasketVO> allBasketList = getBasketListFromRequest(request);
        String[] purchaseIds = ids.split(",");
        List<BasketVO> remainingList = new ArrayList<>();
        
        for (BasketVO item : allBasketList) {
            boolean isPurchased = false;
            for (String id : purchaseIds) {
                if (String.valueOf(item.getSaleId()).equals(id)) {
                    isPurchased = true; break;
                }
            }
            if (!isPurchased) remainingList.add(item);
        }
        
        // 4. 쿠키 잔해 갱신
        Cookie cookie;
        if (remainingList.isEmpty()) {
            cookie = new Cookie("cookie_basket", null);
            cookie.setMaxAge(0);
        } else {
            String json = new ObjectMapper().writeValueAsString(remainingList);
            cookie = new Cookie("cookie_basket", URLEncoder.encode(json, "UTF-8"));
            cookie.setMaxAge(60 * 60 * 24 * 7);
        }
        cookie.setPath("/");
        response.addCookie(cookie);
        
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
                        basketList = new ObjectMapper().readValue(jsonValue, 
                            new ObjectMapper().getTypeFactory().constructCollectionType(List.class, BasketVO.class));
                    } catch (Exception e) { e.printStackTrace(); }
                }
            }
        }
        return basketList;
    }
    
    @GetMapping("/success")
    public String showSuccess(HttpSession session, Model model) {
        String orderId = (String) session.getAttribute("guestOrderId");
        if (orderId == null) return "redirect:/";
        
        model.addAttribute("orderId", orderId);
        session.removeAttribute("guestOrderId"); 
        return "pages/purchase/cookie_purchase_success";
    }
    
 // 🪐 [추적 레이더 전용] 네이버 발급 토큰 장착
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    // ==============================================================
    // 🔍 비회원 주문 조회 (TRACKING) 파이프라인
    // ==============================================================

    // 1. 조회 폼 화면 띄우기 (GET)
    @GetMapping("/track")
    public String trackForm(Model model) {
        model.addAttribute("pageName", "pages/purchase/guest_track");
        return "common/layout";
    }

    
    @GetMapping("/guest/track/check")
    public String directAccessCheck() {
        return "redirect:/cookie/purchase/track";
    }
    
    @PostMapping("/trackDetail")
    public String trackProcess(@RequestParam("purchaseId") String purchaseId,
                               @RequestParam("name") String name,
                               Model model) {
        
        // 1. 서비스 호출
        List<GuestOrderVO> trackList = cookieService.trackGuestOrder(purchaseId, name);
        
        // 2. 결과 검증 (데이터가 없으면 폼으로 다시 보냄)
        if (trackList == null || trackList.isEmpty()) {
            // JSP에서 알림을 띄우기 위해 errorMsg를 전달
            model.addAttribute("errorMsg", "일치하는 주문 정보가 없습니다. 다시 확인해 주세요.");
            model.addAttribute("pageName", "pages/purchase/guest_track");
            return "common/layout";
        }
        
        // 3. 성공 시 데이터 처리 및 이동
        for (GuestOrderVO order : trackList) {
            String query = order.getTitle() != null ? order.getTitle().replaceAll("\\[.*?\\]", "").split(":")[0].trim() : "";
            order.setImage(getNaverBookCover(query));
        }
        
        model.addAttribute("trackList", trackList);
        model.addAttribute("pageName", "pages/purchase/guest_track_check"); 
        return "common/layout";
    }

    // 📡 조회 결과 표지 전용 네이버 수집 엔진
    private String getNaverBookCover(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return "https://placehold.co/150x220/f8fafc/a4b0be?text=No+Img";
        }
        try {
            Thread.sleep(150); // API 방어막 우회
            String encodedKeyword = URLEncoder.encode(keyword, "UTF-8");
            String apiURL = "https://openapi.naver.com/v1/search/book.json?query=" + encodedKeyword + "&display=1";
            
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("X-Naver-Client-Id", NAVER_CLIENT_ID);
            con.setRequestProperty("X-Naver-Client-Secret", NAVER_CLIENT_SECRET);

            if (con.getResponseCode() == 200) { 
                BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
                StringBuilder response = new StringBuilder();
                String inputLine;
                while ((inputLine = br.readLine()) != null) response.append(inputLine);
                br.close();

                JSONObject jsonObject = new JSONObject(response.toString());
                JSONArray items = jsonObject.getJSONArray("items");
                if (items.length() > 0) return items.getJSONObject(0).getString("image");
            }
        } catch (Exception e) {
            System.out.println("🚨 비회원 조회 네이버 통신 장애: " + e.getMessage());
        }
        return "https://placehold.co/150x220/f8fafc/a4b0be?text=No+Img";
    }
    
    @GetMapping("/find")
    public String findForm() {
        return "pages/purchase/guest_find"; // /WEB-INF/views/pages/purchase/guest_find.jsp
    }
    
    @PostMapping("/find_check")
    public String findCheckProcess(@RequestParam("name") String name,
                                   @RequestParam("phone") String phone,
                                   @RequestParam("nickname") String nickname, // 별명 추가
                                   Model model,
                                   RedirectAttributes rttr) {
        
        String cleanPhone = phone.replaceAll("-", "");
        
        // 서비스에서 별명까지 검증하도록 호출 (아래 3번 참고)
        List<String> foundPurchaseIds = cookieService.findIdsByGuestInfo(name, cleanPhone, nickname);
        
        if (foundPurchaseIds == null || foundPurchaseIds.isEmpty()) {
            rttr.addFlashAttribute("errorMsg", "일치하는 주문 정보가 없습니다. 이름, 전화번호, 별명을 다시 확인해 주세요.");
            return "redirect:/cookie/purchase/find";
        }
        
        model.addAttribute("foundPurchaseIds", foundPurchaseIds);
        model.addAttribute("pageName", "pages/purchase/guest_find_check");
        return "common/layout";
    }
}