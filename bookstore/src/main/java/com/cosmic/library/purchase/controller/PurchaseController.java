package com.cosmic.library.purchase.controller;

import java.util.List;
import javax.servlet.http.HttpSession;

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
import com.cosmic.library.purchase.model.Purchase;
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

 // 1️⃣ 결제 대기 페이지 (주문서 작성 화면 - 하이브리드 밸런싱 동기화 버전)
    @GetMapping("/view")
    public String purchasePage(
            @RequestParam(required = false) Integer bookId,    
            @RequestParam(required = false) Integer saleId,  // 🌟 [추가] 어떤 파트너사의 상품인지 식별자 장착
            @RequestParam(required = false, defaultValue = "0") Integer price, // 🌟 [추가] 마켓 실시간 가격 장착
            @RequestParam(required = false) String basketIds, 
            HttpSession session,
            Model model) {

        MemberVO member = (MemberVO) session.getAttribute("loginMember");
        if (member == null) return "redirect:/member/login";

        int userRegNum = member.getUser_reg_num();
        List<BasketVO> purchaseList = new java.util.ArrayList<>();
        int totalPrice = 0;

        // Case 1: 상세페이지에서 [바로 구매]를 누른 경우 (실시간 마켓 가격 완벽 보정)
        if (bookId != null) {
            BookVO book = bookService.findBookById(bookId); // (기존 getById 메서드명을 프로젝트 싱크에 맞게 보정)
            if (book != null) {
                BasketVO temp = new BasketVO();
                
                temp.setBookId(book.getId());
                temp.setTitle(book.getTitle());
                temp.setWriter(book.getWriter());
                temp.setImage(book.getImage());
                temp.setQuantity(1); 
                
                // 🌟 중요: 0원으로 강제 락인되던 임시 변수를 주소창에서 들고 온 진짜 마켓 실시간 단가로 바인딩!
                temp.setPrice(price); 
                
                temp.setGenre(book.getGenre());
                temp.setPublisher(book.getPublisher());
                temp.setIsbn(book.getIsbn());
                
                purchaseList.add(temp);
                totalPrice = price; // 총 결제 금액도 실제 마켓 단가로 즉시 동기화!
            }
        }
        // Case 2: 장바구니에서 [선택 구매]를 누른 경우
        else if (basketIds != null && !basketIds.isEmpty()) {
            String[] arr = basketIds.split(",");
            int[] ids = new int[arr.length];
            for (int i = 0; i < arr.length; i++) ids[i] = Integer.parseInt(arr[i]);

            purchaseList = basketService.getSelectedList(userRegNum, ids);
            
            for (BasketVO vo : purchaseList) {
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
            @RequestParam(required = false) String basketIds, 
            HttpSession session) {
        
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";

        // 🌟 3차 빌딩 핵심 정수형 식별자 추출
        int userRegNum = loginMember.getUser_reg_num();

        // 1) 단일 바로 구매 처리
        if (bookId != null) {
            Purchase purchase = new Purchase();
            purchase.setUserRegNum(userRegNum); // 🌟 바뀐 VO 스펙(int) 반영
            purchase.setBookId(bookId);
            purchase.setQuantity(1); 
            purchase.setPrice(0);      // 임시 0원 처리
            purchase.setTotalPrice(0);

            purchaseService.buy(purchase); 
        }

        // 2) 장바구니 선택 구매 처리
        if (basketIds != null && !basketIds.isEmpty()) {
            String[] arr = basketIds.split(",");
            int[] ids = new int[arr.length];
            for (int i = 0; i < arr.length; i++) ids[i] = Integer.parseInt(arr[i]);

            // 🌟 변경: 문자열 ID 대신 userRegNum(int)을 주입해 다시 덤프 수량 추출!
            List<BasketVO> selectedList = basketService.getSelectedList(userRegNum, ids);

            for (BasketVO item : selectedList) {
                Purchase purchase = new Purchase();
                purchase.setUserRegNum(userRegNum); // 🌟 바뀐 VO 스펙(int) 반영
                purchase.setBookId(item.getBookId());
                purchase.setQuantity(item.getQuantity()); 
                purchase.setPrice(item.getPrice());
                purchase.setTotalPrice(item.getPrice() * item.getQuantity());

                purchaseService.buy(purchase);
            }

            // 🌟 변경: 구매 완료 후 장바구니 비우기 시 userRegNum(int) 전송!
            basketService.delete(userRegNum, ids);
        }

        return "redirect:/purchase/success";
    }
    
    // 3️⃣ 결제 완료 성공 화면 워프
    @GetMapping("/success")
    public String showSuccessPage(Model model) {
        model.addAttribute("pageName", "pages/purchase/success");
        return "common/layout"; 
    }
}