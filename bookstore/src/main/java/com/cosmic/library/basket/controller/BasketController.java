package com.cosmic.library.basket.controller;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.service.BasketService;
import com.cosmic.library.member.model.MemberVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
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
    
    // 1. 장바구니 페이지 조회
    @GetMapping("")
    public String list(Model model, HttpSession session) {

        MemberVO member = getLoginMember(session);
        if (member == null)
            return "redirect:/member/login";

        List<BasketVO> list = basketService.getList(member.getUser_reg_num());

        // 📡 [레이더 포격 추가!] 장바구니에 담긴 책들도 제목을 기반으로 네이버 표지를 강제 매핑!
        for (BasketVO vo : list) {
            vo.setImage(getNaverBookCover(vo.getTitle()));
        }

        model.addAttribute("basketList", list);
        model.addAttribute("pageName", "pages/basket/basket");

        return "common/layout";
    }

    // 2. 장바구니 삭제 (단일 + 선택 삭제)
    @PostMapping("/delete")
    public String delete(@RequestParam(value = "basketId", required = false) Integer basketId,
            @RequestParam(value = "ids", required = false) int[] ids, HttpSession session) {

        MemberVO member = getLoginMember(session);
        if (member == null)
            return "redirect:/member/login";

        // 🌟 변경: 개별 삭제 시 user_reg_num 전달
        if (basketId != null) {
            basketService.delete(member.getUser_reg_num(), basketId);
        }

        // 🌟 변경: 선택 삭제 시 user_reg_num 전달
        else if (ids != null && ids.length > 0) {
            basketService.delete(member.getUser_reg_num(), ids);
        }

        return "redirect:/basket";
    }

    // 3. 장바구니 선택 구매 사령탑
    @GetMapping("/buy")
    public String buy(@RequestParam(value = "basketIds", required = false) String basketIds, HttpSession session) {

        MemberVO member = getLoginMember(session);
        if (member == null)
            return "redirect:/member/login";

        if (basketIds != null && !basketIds.isEmpty()) {
            String[] arr = basketIds.split(",");
            int[] ids = new int[arr.length];

            for (int i = 0; i < arr.length; i++) {
                ids[i] = Integer.parseInt(arr[i]);
            }
            
            // 💡 추후 3단계 오픈마켓 물류 연동 시 선택된 항목 검증 로직이 이 자리에 들어오게 됩니다.
        }

        // ⚓ 리다이렉트 경로는 기존 주소 체계를 유지하되 차후 결제 페이지 개편 시 함께 연동 예정
        return "redirect:/purchase/view?basketIds=" + basketIds;
    }

    // 4. 장바구니 담기 (상세 페이지 등에서 수행하는 AJAX 통신)
    @GetMapping("/add")
    @ResponseBody
    public String add(@RequestParam("id") Integer bookId, HttpSession session) {
        try {
            if (bookId == null)
                return "error";

            MemberVO member = getLoginMember(session);
            if (member == null)
                return "error"; // 비회원 상태일 경우 프론트 단에서 로그인 유도 처리 가능

            // 🌟 변경: 장바구니 원천 테이블에 대원의 활동 번호(user_reg_num)로 인서트!
            basketService.add(member.getUser_reg_num(), bookId);
            return "ok";

        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }
    
    // 5. 🪐 [추가] 오픈마켓 상품 장바구니 담기 (코스믹 마켓 전용 AJAX 통신)
    @PostMapping("/addMarketProduct")
    @ResponseBody
    public String addMarketProduct(@RequestParam("saleId") Integer saleId, 
                                   @RequestParam(value = "qty", defaultValue = "1") int qty, 
                                   HttpSession session) {
        try {
            if (saleId == null) {
                return "error";
            }

            // 1. 보안 관제: 세션에서 일반 대원 정보 획득
            MemberVO member = getLoginMember(session);
            if (member == null) {
                return "NOT_LOGIN"; // 로그인 안 되어 있으면 프론트단에 커스텀 신호 반환
            }

            // 2. 🌟 네가 설계한 정합성 반영: 대원의 활동 번호(user_reg_num)와 오픈마켓 상품 번호(saleId) 연동!
            // basketService에 오픈마켓 전용 추가 메서드(예: addMarketBasket)를 연결해 줘야 해.
            boolean isSuccess = basketService.addMarketBasket(member.getUser_reg_num(), saleId, qty);
            
            return isSuccess ? "ok" : "fail";

        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }

    // 🌟 [추가] 장바구니 수량 실시간 변경 반영 통문 (AJAX 비동기 통신)
    @PostMapping("/updateQty")
    @ResponseBody
    public String updateQty(@RequestParam("basketId") int basketId,
                            @RequestParam("qty") int qty,
                            HttpSession session) {
        try {
            MemberVO member = getLoginMember(session);
            if (member == null) return "NOT_LOGIN";

            // 서비스단에 직접 수량 업데이트 명령 하달!
            // (구조를 콤팩트하게 유지하기 위해 basketService에 메서드를 연결하거나, 내부에서 처리 가능)
            boolean isSuccess = basketService.updateBasketQty(basketId, member.getUser_reg_num(), qty);
            
            return isSuccess ? "ok" : "fail";
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }
    
    // 로그인 멤버 가져오기 도우미
    private MemberVO getLoginMember(HttpSession session) {
        return (MemberVO) session.getAttribute("loginMember");
    }
    
    // 🪐 [네이버 발급 토큰 장착] 
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    // ==============================================================
    // 🛰️ [장바구니 전용 레이더] 네이버 실시간 도서 표지 수집 통신 파이프라인
    // ==============================================================
    private String getNaverBookCover(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return "https://via.placeholder.com/100x150?text=No+Img";
        }
        try {
            // 💥 한글 제목 통신 에러 방지 (콜론 앞 순수 제목 추출 및 인코딩)
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
                    return bookItem.getString("image");
                }
            }
        } catch (Exception e) {
            System.out.println("🚨 장바구니 네이버 표지 통신 장애: " + e.getMessage());
        }
        return "https://via.placeholder.com/100x150?text=No+Img";
    }
}