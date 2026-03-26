package com.cosmic.library.purchase.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.cosmic.library.basket.repository.BasketDAOH2;
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
    private BasketDAOH2 busketRepository; // ⭐ 지금은 유지

    // 🔥 구매 페이지 (단일 or 장바구니)
    @GetMapping("/view")
    public String purchasePage(
            @RequestParam(required = false) Integer bookId,
            @RequestParam(required = false) String bookIds,
            Model model) {

        // 🔥 단일 구매
        if (bookId != null) {
            BookVO book = bookService.getById(bookId);
            model.addAttribute("book", book);
        }

        // 🔥 장바구니 구매 (간단 처리)
        if (bookIds != null) {
            model.addAttribute("bookIds", bookIds);
            model.addAttribute("title", "장바구니 상품 구매");
        }

        model.addAttribute("pageName", "pages/purchase/purchase");
        return "common/layout";
    }

    // 🔥 구매 처리
    @PostMapping("/buy")
    public String buy(
            @RequestParam(required = false) Integer bookId,
            @RequestParam(required = false) String bookIds,
            HttpSession session) {
    	
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");

        if (loginMember == null) {
            return "redirect:/common/login-required";
        }

        String memberId = loginMember.getId();

        // 🔥 단일 구매
        if (bookId != null) {

            BookVO book = bookService.getById(bookId);

            Purchase purchase = new Purchase();
            purchase.setBookId(bookId);
            purchase.setMemberId(memberId);
            purchase.setPrice(book.getPrice());
            purchase.setQuantity(1);
            purchase.setTotalPrice(book.getPrice());

            purchaseService.buy(purchase);
        }

        // 🔥 장바구니 구매
        if (bookIds != null && !bookIds.isEmpty()) {

            String[] ids = bookIds.split(",");

            for (String id : ids) {

                int bId = Integer.parseInt(id);

                BookVO book = bookService.getById(bId);

                Purchase purchase = new Purchase();
                purchase.setBookId(bId);
                purchase.setMemberId(memberId);
                purchase.setPrice(book.getPrice());
                purchase.setQuantity(1);
                purchase.setTotalPrice(book.getPrice());

                purchaseService.buy(purchase);

                // ⭐ 장바구니 삭제
                busketRepository.delete(memberId, bId);
            }
        }

        return "redirect:/purchase/success";
    }

    // 🔥 구매 완료 페이지
    @GetMapping("/success")
    public String success(Model model) {

        model.addAttribute("pageName", "pages/purchase/success");

        return "common/layout";
    }
}