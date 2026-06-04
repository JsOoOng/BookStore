package com.cosmic.library.vendor.controller;

import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.cosmic.library.vendor.model.VendorVO;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.service.VendorService;
import com.cosmic.library.vendor.service.ProductSaleService;

@Controller
@RequestMapping("/vendor")
public class VendorController {

    @Autowired
    private VendorService vendorService;

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
        
        productSale.setVRegNum(vRegNum);
        productSale.setStockId(1); // 가상 stock_id 임시 바인딩 유지
        
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
}