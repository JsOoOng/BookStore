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

    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    private String getNaverBookCover(String isbn) {
        if (isbn == null || isbn.trim().isEmpty()) {
            return "https://placehold.co/100x140/f8fafc/a4b0be?text=No+Cover";
        }
        try {
            Thread.sleep(150); // 💥 네이버 API 쿨타임 방어막 연동
            String apiURL = "https://openapi.naver.com/v1/search/book.json?query=" + isbn.trim() + "&display=1";
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
        } catch (Exception e) { e.printStackTrace(); }
        return "https://placehold.co/100x140/f8fafc/a4b0be?text=No+Cover";
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
                        basketList = mapper.readValue(jsonValue, mapper.getTypeFactory().constructCollectionType(List.class, BasketVO.class));
                    } catch (Exception e) { e.printStackTrace(); }
                }
            }
        }
        return basketList;
    }

    @GetMapping("/list")
    public String getCookieBasketList(HttpServletRequest request, Model model) {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        List<BookVO> purchaseList = purchaseService.getBasketDetails(basketList);
        
        if (purchaseList != null && !purchaseList.isEmpty()) {
            for (BookVO book : purchaseList) {
                if (book.getIsbn() != null) book.setImage(getNaverBookCover(book.getIsbn()));
                for (BasketVO basket : basketList) {
                    if (book.getSaleId() == basket.getSaleId()) {
                        book.setQuantity(basket.getQuantity());
                        break;
                    }
                }
            }
        }
        model.addAttribute("purchaseList", purchaseList);
        model.addAttribute("pageName", "pages/basket/cookie_basket");
        return "common/layout";
    }

    @GetMapping("/checkout")
    public String checkout(@RequestParam("ids") String ids, HttpServletRequest request, Model model) {
        List<BasketVO> allBasketList = getBasketListFromRequest(request);
        String[] targetIds = ids.split(",");
        List<BasketVO> selectedBasketList = new ArrayList<>();
        
        for (BasketVO basket : allBasketList) {
            for (String id : targetIds) {
                if (String.valueOf(basket.getSaleId()).equals(id)) {
                    selectedBasketList.add(basket);
                    break;
                }
            }
        }
        
        List<BookVO> purchaseList = purchaseService.getBasketDetails(selectedBasketList);
        if (purchaseList != null && !purchaseList.isEmpty()) {
            for (BookVO book : purchaseList) {
                if (book.getIsbn() != null) book.setImage(getNaverBookCover(book.getIsbn()));
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
        model.addAttribute("pageName", "pages/purchase/cookie_order_form"); // 실제 경로에 맞게 수정할 것
        return "common/layout";
    }

    @PostMapping("/add")
    public String addBasket(BasketVO basket, HttpServletRequest request, HttpServletResponse response) throws Exception {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        boolean exists = false;
        for (BasketVO b : basketList) {
            if (b.getSaleId() == basket.getSaleId()) {
                b.setQuantity(b.getQuantity() + basket.getQuantity());
                exists = true; break;
            }
        }
        if (!exists) basketList.add(basket);
        
        String newJsonValue = new ObjectMapper().writeValueAsString(basketList);
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
        String newJsonValue = new ObjectMapper().writeValueAsString(basketList);
        Cookie newCookie = new Cookie("cookie_basket", URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        newCookie.setMaxAge(60 * 60 * 24 * 7);
        response.addCookie(newCookie);
        return "ok";
    }
    
    @PostMapping("/delete")
    @ResponseBody
    public String deleteCookieBasket(@RequestParam("ids") String ids, HttpServletRequest request, HttpServletResponse response) throws Exception {
        List<BasketVO> basketList = getBasketListFromRequest(request);
        String[] targetIds = ids.split(",");
        List<BasketVO> updatedList = new ArrayList<>();
        
        for (BasketVO b : basketList) {
            boolean isDeleteTarget = false;
            for (String id : targetIds) {
                if (String.valueOf(b.getSaleId()).equals(id)) {
                    isDeleteTarget = true; break;
                }
            }
            if (!isDeleteTarget) updatedList.add(b);
        }
        
        String newJsonValue = new ObjectMapper().writeValueAsString(updatedList);
        Cookie newCookie = new Cookie("cookie_basket", URLEncoder.encode(newJsonValue, "UTF-8"));
        newCookie.setPath("/");
        newCookie.setMaxAge(updatedList.isEmpty() ? 0 : 60 * 60 * 24 * 7);
        response.addCookie(newCookie);
        return "ok";
    }
}