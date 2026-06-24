package com.cosmic.library.purchase.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;

import javax.servlet.http.HttpSession;

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

import com.cosmic.library.cookie.model.GuestOrderVO;
import com.cosmic.library.purchase.model.Purchase;
import com.cosmic.library.purchase.service.PurchaseService;
import com.cosmic.library.vendor.model.VendorVO;
import com.cosmic.library.cookie.service.CookieService;


@Controller
@RequestMapping("/vendor/purchase")
public class VendorPurchaseController {

    @Autowired
    private PurchaseService purchaseService;
    private CookieService cookieService;

    // 🪐 [네이버 발급 토큰 장착]
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    // 📦 1. 판매자 주문 관제 탑 화면
    @GetMapping("/list")
    public String vendorOrderList(HttpSession session, Model model) {
        // 사장님 로그인 세션 체크 (임시로 1번이라 가정)
        int vendorRegNum = 1; 

        List<Purchase> orderList = purchaseService.getVendorOrders(vendorRegNum);
        
        // 📡 [레이더 포격] 사장님이 보는 주문 내역에도 네이버 실시간 표지를 땡겨온다!
        // (Purchase 객체에 ISBN이 없으므로 도서 제목을 기반으로 스캔!)
        for (Purchase order : orderList) {
            order.setImage(getNaverBookCover(order.getTitle()));
        }
        
        model.addAttribute("orderList", orderList);
        model.addAttribute("pageName", "pages/vendor/orderList");
        return "common/layout"; 
    }
    
 // 📦 비회원 주문 관제탑
    @GetMapping("/cookielist")
    public String vendorGuestOrderList(HttpSession session, Model model) {
        // 1. 세션에서 로그인한 업체 정보 확인 (안전한 접근)
        VendorVO loginVendor = (VendorVO) session.getAttribute("loginVendor");
        if (loginVendor == null) {
            return "redirect:/vendor/login"; // 로그인 안 되어 있으면 로그인 페이지로
        }

        // 2. 로그인된 업체(벤더)의 고유 번호를 사용
        int vendorRegNum = loginVendor.getVendorRegNum(); 

        // 3. 서비스 호출
        List<GuestOrderVO> guestOrderList = cookieService.getVendorGuestOrders(vendorRegNum);
        
        // 4. 도서 이미지 API 연동 (데이터가 있을 때만)
        if (guestOrderList != null) {
            for (GuestOrderVO order : guestOrderList) {
                order.setImage(getNaverBookCover(order.getTitle()));
            }
        }
        
        model.addAttribute("orderList", guestOrderList);
        // JSP 파일명이 'guest_orderList.jsp'라면 아래 경로가 맞는지 확인하세요
        model.addAttribute("pageName", "pages/vendor/cookie_orderList"); 
        return "common/layout"; 
    }

    // 🚀 2. 배송 시작 버튼 클릭 시 워프 통문
    @PostMapping("/ship")
    @ResponseBody
    public String shipProduct(@RequestParam("purchaseId") int purchaseId) {
        boolean isSuccess = purchaseService.startShipping(purchaseId);
        return isSuccess ? "ok" : "fail";
    }

    // ==============================================================
    // 🛰️ [관제탑 전용 레이더] 네이버 실시간 도서 표지 수집 통신 파이프라인
    // ==============================================================
    private String getNaverBookCover(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return "https://via.placeholder.com/150x220?text=No+Img";
        }
        try {
            // 한글 제목 검색 시 통신 에러 방지를 위해 콜론(:) 앞의 순수 제목만 추출 후 인코딩!
            String pureTitle = keyword.split(":")[0].trim();
            String encodedKeyword = URLEncoder.encode(pureTitle, "UTF-8");
            
            String apiURL = "https://openapi.naver.com/v1/search/book.json?query=" + encodedKeyword + "&display=1";
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
                    return bookItem.getString("image"); // 표지 주소 확보 성공!
                }
            }
        } catch (Exception e) {
            System.out.println("🚨 파트너 대시보드 네이버 표지 통신 장애: " + e.getMessage());
        }
        return "https://via.placeholder.com/150x220?text=No+Img";
    }
}