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
    
    @Autowired
    private CookieService cookieService;

    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    @GetMapping("/list")
    public String vendorOrderList(HttpSession session, Model model) {
        VendorVO loginVendor = (VendorVO) session.getAttribute("loginVendor");
        if (loginVendor == null) return "redirect:/vendor/login";
        
        List<Purchase> rawOrderList = purchaseService.getVendorOrders(loginVendor.getVendorRegNum());
        
        // 💥 [데이터 융합 엔진] 마스터 주문 번호(purchaseId)를 기준으로 디테일 품목들을 묶는다!
        java.util.Map<Integer, java.util.List<Purchase>> groupedOrders = new java.util.LinkedHashMap<>();
        
        if (rawOrderList != null) {
            for (Purchase order : rawOrderList) {
                // 네이버 표지 획득
                String query = order.getTitle() != null ? order.getTitle().replaceAll("\\[.*?\\]", "").split(":")[0].trim() : "";
                order.setImage(getNaverBookCover(query));
                
                // 그룹 맵에 적재
                groupedOrders.computeIfAbsent(order.getPurchaseId(), k -> new java.util.ArrayList<>()).add(order);
            }
        }
        
        // 묶인 데이터를 JSP로 전송!
        model.addAttribute("groupedOrders", groupedOrders);
        model.addAttribute("pageName", "pages/vendor/orderList");
        return "common/layout"; 
    }
    
    // 📦 [비회원] 쿠키 주문 관제탑
    @GetMapping("/cookielist")
    public String vendorGuestOrderList(HttpSession session, Model model) {
        VendorVO loginVendor = (VendorVO) session.getAttribute("loginVendor");
        if (loginVendor == null) return "redirect:/vendor/login";

        List<GuestOrderVO> guestOrderList = cookieService.getVendorGuestOrders(loginVendor.getVendorRegNum());
        
        if (guestOrderList != null) {
            for (GuestOrderVO order : guestOrderList) {
                String query = order.getTitle() != null ? order.getTitle().replaceAll("\\[.*?\\]", "").split(":")[0].trim() : "";
                order.setImage(getNaverBookCover(query));
            }
        }
        
        model.addAttribute("orderList", guestOrderList);
        model.addAttribute("pageName", "pages/vendor/cookie_orderList"); 
        return "common/layout"; 
    }

    // 🚚 배송 출발 상태 변경 통신
    @PostMapping("/ship")
    @ResponseBody
    public String shipProduct(@RequestParam("purchaseId") int purchaseId) {
        // 💥 Service 레이어에서 PurchaseRepository.updateStatus(purchaseId, "SHIPPING")을 호출하는지 확인할 것!
        boolean isSuccess = purchaseService.startShipping(purchaseId);
        return isSuccess ? "ok" : "fail";
    }

    // 📡 네이버 표지 실시간 통신 엔진
    private String getNaverBookCover(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return "https://placehold.co/150x220/f8fafc/a4b0be?text=No+Img";
        }
        try {
            Thread.sleep(150); // API 방어막 우회 쿨타임
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
            System.out.println("🚨 파트너 대시보드 네이버 표지 통신 장애: " + e.getMessage());
        }
        return "https://placehold.co/150x220/f8fafc/a4b0be?text=No+Img";
    }
}