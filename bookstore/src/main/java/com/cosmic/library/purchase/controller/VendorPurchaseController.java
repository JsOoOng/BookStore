package com.cosmic.library.purchase.controller;

import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.cosmic.library.purchase.model.Purchase;
import com.cosmic.library.purchase.service.PurchaseService;

@Controller
@RequestMapping("/vendor/purchase")
public class VendorPurchaseController {

    @Autowired
    private PurchaseService purchaseService;

    // 📦 1. 판매자 주문 관제 탑 화면
    @GetMapping("/list")
    public String vendorOrderList(HttpSession session, Model model) {
        // 사장님 로그인 세션 체크 (세션에 보관된 사장님 VO 정보가 있다고 가정)
        // 여기서는 임시로 사장님의 입점 번호(vendorRegNum)가 1번이라고 가정하고 코드를 짤게!
        // 원래는 세션에서 사장님 객체 꺼내서 정수 번호 추출해야 해!
        int vendorRegNum = 1; 

        List<Purchase> orderList = purchaseService.getVendorOrders(vendorRegNum);
        
        model.addAttribute("orderList", orderList);
        model.addAttribute("pageName", "pages/vendor/orderList");
        return "common/layout"; 
    }

    // 🚀 2. 배송 시작 버튼 클릭 시 워프 통문
    @PostMapping("/ship")
    @ResponseBody
    public String shipProduct(@RequestParam("purchaseId") int purchaseId) {
        boolean isSuccess = purchaseService.startShipping(purchaseId);
        return isSuccess ? "ok" : "fail";
    }
}