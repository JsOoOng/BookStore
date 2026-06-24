package com.cosmic.library.purchase.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
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

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.service.BasketService;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.service.BookService;
import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.purchase.service.PurchaseService;

@Controller
@RequestMapping("/purchase")
public class PurchaseController {

    @Autowired
    private PurchaseService purchaseService;

    @Autowired
    private BookService bookService;

    @Autowired
    private BasketService basketService;

    // 1️⃣ 결제 대기 페이지 (주문서 작성 화면)
    @GetMapping("/view")
    public String purchasePage(
            @RequestParam(required = false) Integer bookId,    
            @RequestParam(required = false) Integer saleId,  
            @RequestParam(required = false, defaultValue = "0") Integer price, 
            @RequestParam(required = false) String basketIds, 
            HttpSession session,
            Model model) {

        MemberVO member = (MemberVO) session.getAttribute("loginMember");
        if (member == null) return "redirect:/member/login";

        int userRegNum = member.getUser_reg_num();
        List<BasketVO> purchaseList = new ArrayList<>();
        int totalPrice = 0;

        // Case 1: 상세페이지에서 [바로 구매]를 누른 경우
        if (bookId != null && saleId != null) {
            BookVO book = bookService.findBookById(bookId); 
            if (book != null) {
                BasketVO temp = new BasketVO();
                temp.setBookId(book.getId());
                temp.setSaleId(saleId); 
                temp.setTitle(book.getTitle());
                temp.setWriter(book.getWriter());
                temp.setQuantity(1); 
                temp.setPrice(price); 
                temp.setGenre(book.getGenre());
                temp.setPublisher(book.getPublisher());
                temp.setIsbn(book.getIsbn());
                
                // 💥 [수리 완료] ISBN을 최우선 좌표로 네이버 API 타격!
                String query = (book.getIsbn() != null) ? book.getIsbn() : book.getTitle();
                temp.setImage(getNaverBookCover(query));
                
                purchaseList.add(temp);
                totalPrice = price; 
            }
        }
        // Case 2: 장바구니에서 [선택 구매]를 누른 경우
        else if (basketIds != null && !basketIds.isEmpty()) {
            String[] arr = basketIds.split(",");
            int[] ids = new int[arr.length];
            for (int i = 0; i < arr.length; i++) ids[i] = Integer.parseInt(arr[i]);

            purchaseList = basketService.getSelectedList(userRegNum, ids);
            
            for (BasketVO vo : purchaseList) {
                // 💥 [수리 완료] ISBN을 최우선 좌표로 네이버 API 타격!
                String query = (vo.getIsbn() != null) ? vo.getIsbn() : vo.getTitle();
                vo.setImage(getNaverBookCover(query));
                totalPrice += (vo.getPrice() * vo.getQuantity());
            }
            
            model.addAttribute("basketIds", basketIds); 
        }

        model.addAttribute("purchaseList", purchaseList);
        model.addAttribute("totalPrice", totalPrice);
        model.addAttribute("pageName", "pages/purchase/purchase");
        
        return "common/layout";
    }

    // 2️⃣ 결제 승인 처리 (POST) 
    @PostMapping("/buy")
    public String processPurchase(
            @RequestParam(required = false) Integer bookId,    
            @RequestParam(required = false) Integer saleId,
            @RequestParam(required = false) Integer price,
            @RequestParam(required = false) String basketIds, 
            HttpSession session) {
        
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";

        int userRegNum = loginMember.getUser_reg_num();
        List<BasketVO> itemsToBuy = new ArrayList<>();
        int[] basketIdsToRemove = null;

        if (bookId != null && saleId != null && price != null) {
            BasketVO singleItem = new BasketVO();
            singleItem.setBookId(bookId);
            singleItem.setSaleId(saleId);
            singleItem.setQuantity(1); 
            singleItem.setPrice(price);
            itemsToBuy.add(singleItem);
        }
        else if (basketIds != null && !basketIds.isEmpty()) {
            String[] arr = basketIds.split(",");
            basketIdsToRemove = new int[arr.length];
            for (int i = 0; i < arr.length; i++) {
                basketIdsToRemove[i] = Integer.parseInt(arr[i]);
            }
            itemsToBuy = basketService.getSelectedList(userRegNum, basketIdsToRemove);
        }

        if (!itemsToBuy.isEmpty()) {
            purchaseService.executeCheckout(userRegNum, itemsToBuy, basketIdsToRemove);
        }

        return "redirect:/purchase/success";
    }
    
    // 3️⃣ 결제 완료 성공 화면 워프
    @GetMapping("/success")
    public String showSuccessPage(Model model) {
        model.addAttribute("pageName", "pages/purchase/success");
        return "common/layout"; 
    }
    
    // ==============================================================
    // 🛰️ [결제 관제탑 전용 레이더] 네이버 API (ISBN/인코딩 우선 탐색)
    // ==============================================================
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
            System.out.println("🚨 결제창 네이버 표지 통신 장애: " + e.getMessage());
        }
        return "https://via.placeholder.com/150x220?text=No+Img";
    }
}