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
    private BasketService basketService; // ⭐ BasketService 주입 확인!

    @GetMapping("/view")
    public String purchasePage(
            @RequestParam(required = false) Integer bookId,    // 단일 구매 (상세페이지에서 옴)
            @RequestParam(required = false) String basketIds, // 장바구니 구매 (장바구니에서 옴)
            HttpSession session,
            Model model) {

        MemberVO member = (MemberVO) session.getAttribute("loginMember");
        if (member == null) return "redirect:/";

        List<BasketVO> purchaseList = new java.util.ArrayList<>();
        int totalPrice = 0;

        // Case 1: 상세페이지에서 [바로 구매]를 누른 경우 (bookId 기반)
        if (bookId != null) {
            BookVO book = bookService.getById(bookId);
            if (book != null) {
                BasketVO temp = new BasketVO();
                
                // 💡 핵심: purchase.jsp에서 사용하는 모든 필드를 다 채워줘야 합니다.
                temp.setBookId(book.getId());
                temp.setTitle(book.getTitle());
                temp.setPrice(book.getPrice());
                temp.setWriter(book.getWriter());
                temp.setImage(book.getImage());
                temp.setQuantity(1); // 바로 구매는 기본 1개
                
                // ✅ 추가된 필드들도 잊지 말고 세팅!
                temp.setGenre(book.getGenre());
                temp.setPublisher(book.getPublisher());
                temp.setIsbn(book.getIsbn());
                
                purchaseList.add(temp);
                totalPrice = book.getPrice();
            }
        }
        // Case 2: 장바구니에서 [선택 구매]를 누른 경우 (basketIds 기반)
        else if (basketIds != null && !basketIds.isEmpty()) {
            String[] arr = basketIds.split(",");
            int[] ids = new int[arr.length];
            for (int i = 0; i < arr.length; i++) ids[i] = Integer.parseInt(arr[i]);

            // ⭐ 새로 만든 findByIds 로직 사용 (장바구니에 담긴 수량까지 정확히 가져옴)
            purchaseList = basketService.getSelectedList(member.getId(), ids);
            
            for (BasketVO vo : purchaseList) {
                totalPrice += (vo.getPrice() * vo.getQuantity());
            }
            
            model.addAttribute("basketIds", basketIds); // 나중에 결제 완료 시 삭제하기 위해 저장
        }

        model.addAttribute("purchaseList", purchaseList);
        model.addAttribute("totalPrice", totalPrice);
        model.addAttribute("pageName", "pages/purchase/purchase");
        
        return "common/layout";
    }

    @PostMapping("/buy")
    public String processPurchase(
            @RequestParam(required = false) Integer bookId,    // 단일 구매 시 사용
            @RequestParam(required = false) String basketIds, // 장바구니 구매 시 사용
            HttpSession session) {
        
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/";

        String memberId = loginMember.getId();

        // 1️⃣ 단일 구매 (바로 구매) 처리
        if (bookId != null) {
            BookVO book = bookService.getById(bookId);
            
            Purchase purchase = new Purchase();
            purchase.setMemberId(memberId);
            purchase.setBookId(bookId);
            purchase.setQuantity(1); // 바로 구매는 기본 1개
            purchase.setPrice(book.getPrice());
            purchase.setTotalPrice(book.getPrice());

            // ⭐ 실제 구매 테이블에 저장
            purchaseService.buy(purchase); 
        }

        // 2️⃣ 장바구니 선택 구매 처리
        if (basketIds != null && !basketIds.isEmpty()) {
            String[] arr = basketIds.split(",");
            int[] ids = new int[arr.length];
            for (int i = 0; i < arr.length; i++) ids[i] = Integer.parseInt(arr[i]);

            // ⭐ 중요: 결제 직전, 장바구니 아이템들을 다시 조회해서 정보를 가져옵니다 (수량 때문)
            List<BasketVO> selectedList = basketService.getSelectedList(memberId, ids);

            for (BasketVO item : selectedList) {
                Purchase purchase = new Purchase();
                purchase.setMemberId(memberId);
                purchase.setBookId(item.getBookId());
                purchase.setQuantity(item.getQuantity()); // 장바구니에 담긴 수량 그대로!
                purchase.setPrice(item.getPrice());
                purchase.setTotalPrice(item.getPrice() * item.getQuantity());

                // ⭐ 각 항목별로 구매 테이블에 저장
                purchaseService.buy(purchase);
            }

            // 3️⃣ 구매 성공 후 장바구니에서 해당 항목들 삭제
            basketService.delete(memberId, ids);
        }

        return "redirect:/purchase/success";
    }
    
    @GetMapping("/success")
    public String showSuccessPage(Model model) {
        // 레이아웃 페이지에 "지금 보여줄 페이지는 success야"라고 알려줌
        model.addAttribute("pageName", "pages/purchase/success");
        return "common/layout"; // 공통 레이아웃 파일 리턴
    }
}