package com.cosmic.library.purchase.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

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

    // 🔥 구매 페이지
    @GetMapping("/view")
    public String purchasePage(@RequestParam int bookId, Model model) {

        BookVO book = bookService.getById(bookId); // ⭐ 핵심

        model.addAttribute("book", book);
        model.addAttribute("pageName", "pages/purchase/purchase");

        return "common/layout";
    }

    // 🔥 구매 처리
    @PostMapping("/buy")
    public String buy(@RequestParam int bookId, HttpSession session) {

        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");

        if (loginMember == null) {
            return "redirect:/common/login-required";
        }

        BookVO book = bookService.getById(bookId); // ⭐ 가격 가져오기

        Purchase purchase = new Purchase();
        purchase.setBookId(bookId);
        purchase.setMemberId(loginMember.getId());
        purchase.setPrice(book.getPrice());

        purchaseService.buy(purchase);

        return "redirect:/?purchaseSuccess=true";
    }
}