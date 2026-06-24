package com.cosmic.library.vendor.controller;

import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.cosmic.library.vendor.model.VendorVO;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.model.SalesVolumeVO;
import com.cosmic.library.vendor.service.VendorService;
import com.cosmic.library.vendor.service.ProductSaleService;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import org.json.JSONArray;
import org.json.JSONObject;

@Controller
@RequestMapping("/vendor")
public class VendorController {

    @Autowired
    private VendorService vendorService;
    
    @Autowired
    private com.cosmic.library.book.repository.BookDAO bookDAO;

    @Autowired
    private ProductSaleService productSaleService;

    /**
     * 🔒 1. 업체 로그인 페이지 이동 ➔ 3단 통합 로그인 창으로 워프
     * (정화 포인트: vendor/login.jsp 폐기에 따른 리다이렉트 궤도 수정)
     */
    @GetMapping("/login")
    public String loginForm() {
        // 🚀 기존 뷰 포워딩을 파괴하고, 3단 탭이 내장된 대통합 로그인 창으로 리다이렉트 하달!
        return "redirect:/member/login";
    }

    /**
     * 🔑 2. 업체 로그인 처리 (세션 바인딩 및 실패 주소 정화)
     */
    @PostMapping("/login")
    public String loginProcess(
            @RequestParam("vendorId") String vendorId, 
            @RequestParam("vendorPw") String vendorPw, 
            HttpSession session) {
        
        VendorVO loginVendor = vendorService.login(vendorId, vendorPw);
        
        if (loginVendor != null) {
            session.setAttribute("loginVendor", loginVendor);
            
            // 🚀 [가상 스펙 유지]: 관리자 승인 기능 완공 전까지 테스트 흐름용 1번 강제 부여
            session.setAttribute("vRegNum", 1); 
            
            return "redirect:/vendor/dashboard";
        }
        
        // 🌟 정화: 로그인 실패 시 통합 로그인 창으로 에러 파라미터를 들고 리다이렉트
        return "redirect:/member/login?error=true";
    }

    /**
     * 🏢 3. 입점 신청 페이지 이동
     */
    @GetMapping("/join")
    public String joinForm(Model model) {
        model.addAttribute("pageName", "pages/vendor/join");
        return "common/layout";
    }

    /**
     * 🏢 4. 입점 신청 처리 (POST)
     */
    @PostMapping("/join")
    public String joinProcess(@ModelAttribute VendorVO vendor) {
        boolean isSuccess = vendorService.register(vendor);
        if (isSuccess) {
            // 🌟 정화: 신청 완료 후 통합 로그인 창으로 워프시켜 파트너사 탭을 누르도록 유도!
            return "redirect:/member/login?joinSuccess=true";
        }
        return "redirect:/vendor/join?error=fail";
    }

    /**
     * 🔍 5. 업체 아이디 중복 확인 (AJAX)
     */
    @ResponseBody
    @GetMapping("/checkId")
    public String checkId(@RequestParam("vendorId") String vendorId) {
        boolean isAvailable = vendorService.checkIdAvailability(vendorId);
        return isAvailable ? "Y" : "N";
    }

    /**
     * 📊 6. 업체 전용 관제 대시보드
     */
    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        VendorVO loginVendor = (VendorVO) session.getAttribute("loginVendor");
        Integer vRegNum = (Integer) session.getAttribute("vRegNum");
        
        if (loginVendor == null || vRegNum == null) {
            return "redirect:/member/login";
        }

        List<ProductSaleVO> myProducts = productSaleService.getProductsByVendor(vRegNum);
        
        // 📡 [레이더 포격 추가!] 대시보드 리스트에도 도서 제목을 기반으로 네이버 표지 실시간 매핑!
        for (ProductSaleVO product : myProducts) {
            product.setImage(getNaverBookCover(product.getTitle()));
        }
        
        model.addAttribute("vendorInfo", loginVendor);
        model.addAttribute("productList", myProducts); 
        model.addAttribute("pageName", "pages/vendor/dashboard");
        return "common/layout";
    }

    /**
     * 🚪 7. 업체 로그아웃 (주소 정화)
     */
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.removeAttribute("loginVendor");
        session.removeAttribute("vRegNum"); 
        
        // 🌟 정화: 로그아웃 완료 시 통합 로그인 창으로 송환
        return "redirect:/member/login";
    }
    
    /**
     * 📦 8. 신규 판매 상품 등록 폼 이동 (숨어있던 세션 바인딩 오타 격파 완료!)
     */
    @GetMapping("/product/register")
    public String registerProductForm(HttpSession session, Model model) {
        // 🛠️ 버그 격파: 기존의 loginMember 오타를 지우고 loginVendor로 정밀 교정!
        VendorVO loginVendor = (VendorVO) session.getAttribute("loginVendor"); 
        
        if (loginVendor == null || session.getAttribute("vRegNum") == null) {
            return "redirect:/member/login";
        }
        
        model.addAttribute("pageName", "pages/vendor/product_register");
        return "common/layout";
    }

    /**
     * ✍️ 9. 신규 판매 상품 등록 처리 (POST)
     */
    @PostMapping("/product/register")
    public String registerProductProcess(
            @ModelAttribute ProductSaleVO productSale, 
            HttpSession session) {
        
        Integer vRegNum = (Integer) session.getAttribute("vRegNum");
        if (vRegNum == null) {
            return "redirect:/member/login";
        }

        // 1. 해당 업체가 이 책을 이전에 입고(STOCK_IN)한 기록이 있는지 교차 검증 스캔
        int stockId = productSaleService.findStockIdByBookIdAndVendor(productSale.getBookId(), vRegNum);
        
        // 2. 💥 데이터 파편이 없다면 즉시 무결성 제약조건 프리패스용 안전 입고 데이터 수동 선행 발사!
        if (stockId <= 0) {
            int initialQty = productSale.getStockQty(); // 입력한 초기 재고 수량을 입고 수량으로 인정
            int calculatedCost = (int)(productSale.getPrice() * 0.7); // 원가는 소비자 판매가의 70% 수준 가상 처리 (또는 0원 처리 가능)
            
            // 입고 기지 가동 및 자동 발급된 진짜 식별 키(stockId) 가로채기
            stockId = productSaleService.insertStockIn(productSale.getBookId(), vRegNum, initialQty, calculatedCost);
        }
        
        // 3. 확보된 진짜 무결성 보증 수표(stockId)와 업체 일련번호를 전술 인코딩
        productSale.setVRegNum(vRegNum);
        productSale.setStockId(stockId);
        
        // 4. 대통합 실시간 상점 매대 등록 개시
        boolean isSuccess = productSaleService.registerProduct(productSale);
        if (isSuccess) {
            return "redirect:/vendor/dashboard?regSuccess=true";
        }
        
        return "redirect:/vendor/product/register?error=fail";
    }
    
    /**
     * 🛒 10. 소비자가 이용하는 오픈마켓 상점 뷰
     */
    @GetMapping("/shop")
    public String consumerShop(Model model) {
        List<ProductSaleVO> marketProducts = productSaleService.getAllMarketProducts();
        
        // 📡 [레이더 포격 추가!] 상점 리스트에도 도서 제목을 기반으로 네이버 표지 실시간 매핑!
        for (ProductSaleVO product : marketProducts) {
            product.setImage(getNaverBookCover(product.getTitle()));
        }
        
        model.addAttribute("marketProducts", marketProducts);
        model.addAttribute("pageName", "pages/vendor/market_shop"); 
        return "common/layout";
    }
    
    /**
     * ❌ 11. 오픈마켓 판매 상품 완전 삭제
     */
    @GetMapping("/product/delete")
    public String deleteProduct(@RequestParam("saleId") int saleId, HttpSession session) {
        if (session.getAttribute("loginVendor") == null || session.getAttribute("vRegNum") == null) {
            return "redirect:/member/login";
        }
        
        boolean isSuccess = productSaleService.removeProduct(saleId);
        if (isSuccess) {
            return "redirect:/vendor/dashboard?delSuccess=true";
        }
        return "redirect:/vendor/dashboard?error=delFail";
    }
    
    /**
     * ⚙️ 12. 오픈마켓 판매 상품 정보 수정 처리
     */
    @PostMapping("/product/update")
    public String updateProduct(@ModelAttribute ProductSaleVO productSale, HttpSession session) {
        if (session.getAttribute("loginVendor") == null || session.getAttribute("vRegNum") == null) {
            return "redirect:/member/login";
        }
        
        boolean isSuccess = productSaleService.modifyProduct(productSale);
        if (isSuccess) {
            return "redirect:/vendor/dashboard?updateSuccess=true";
        }
        return "redirect:/vendor/dashboard?error=updateFail";
    }
    
    /**
     * 🔍 13. 모달 창 전용 원천 도서 실시간 비동기 검색 API (JSON 반환)
     */
    @ResponseBody
    @GetMapping("/product/searchBook")
    public List<com.cosmic.library.book.model.BookVO> searchBookApi(@RequestParam("keyword") String keyword) {
        
        // 1. DB에서 키워드로 원천 도서 스캔
        List<com.cosmic.library.book.model.BookVO> searchResult = bookDAO.selectByKeyword(keyword);
        
        // 2. 📡 [레이더 포격] 스캔된 결과 리스트에 네이버 실시간 표지를 싹 다 매핑한다!
        for (com.cosmic.library.book.model.BookVO book : searchResult) {
            book.setImage(getNaverBookCover(book.getIsbn()));
        }
        
        return searchResult;
    }
    
    // 🪐 [네이버 발급 토큰 장착] 
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    // ==============================================================
    // 🛰️ [모달/상점 통합 레이더] 네이버 실시간 도서 표지 수집 통신 파이프라인
    // ==============================================================
    private String getNaverBookCover(String keyword) {
        // 1. 키워드가 없으면 즉시 안전한 외부 디폴트 이미지 반환
        if (keyword == null || keyword.trim().isEmpty()) {
            return "https://via.placeholder.com/100x140?text=No+Image";
        }
        
        try {
            // 💥 정밀 타격: "검은 사슴 :한강 장편소설" -> "검은 사슴" (콜론 앞의 순수 제목만 추출!)
            String pureTitle = keyword.split(":")[0].trim();
            
            String encodedKeyword = java.net.URLEncoder.encode(pureTitle, "UTF-8");
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
                    return bookItem.getString("image"); // 성공 시 네이버 표지 URL 반환
                }
            }
        } catch (Exception e) {
            System.out.println("🚨 네이버 표지 레이더 통신 장애: " + e.getMessage());
        }
        
        // 2. 검색 결과가 0건이거나 통신 에러 시 안전한 외부 디폴트 이미지 반환
        return "https://via.placeholder.com/100x140?text=No+Image";
    }

    /**
     * 📊 도서 판매량 페이지 이동
     */
    @GetMapping("/purchase/salesvolume")
    public String salesVolumePage(HttpSession session, Model model) {

        VendorVO loginVendor = (VendorVO) session.getAttribute("loginVendor");
        Integer vRegNum = (Integer) session.getAttribute("vRegNum");

        if (loginVendor == null || vRegNum == null) {
            return "redirect:/member/login";
        }

        model.addAttribute("vendorInfo", loginVendor);
        model.addAttribute("pageName", "pages/vendor/salesvolume");

        return "common/layout";
    }

    /**
     * 📊 도서 판매량 그래프 데이터 API
     */
    @ResponseBody
    @GetMapping("/purchase/salesvolume/data")
    public List<SalesVolumeVO> salesVolumeData(
            @RequestParam(value = "period", defaultValue = "hour") String period,
            HttpSession session) {

        Integer vRegNum = (Integer) session.getAttribute("vRegNum");

        if (vRegNum == null) {
            return java.util.Collections.emptyList();
        }

        return productSaleService.getSalesVolume(vRegNum, period);
    }
}