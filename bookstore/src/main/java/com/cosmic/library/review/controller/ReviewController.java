package com.cosmic.library.review.controller;

import com.cosmic.library.purchase.controller.PurchaseController;
import com.cosmic.library.review.service.ReviewService;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.cosmic.library.member.model.MemberVO;

@Controller
@RequestMapping("/review")
public class ReviewController {

    private final PurchaseController purchaseController;
	@Autowired
    private ReviewService reviewService;
	ReviewController(PurchaseController purchaseController) {
		this.purchaseController = purchaseController;
	}
    @PostMapping("/write")
    @ResponseBody
    public String writeReview(@RequestParam Long bookId,
                              @RequestParam double rating,
                              @RequestParam String content,
                              HttpSession session) {
    	
        Object loginObj = session.getAttribute("loginMember");
        
        
        System.out.println("🔥 리뷰 컨트롤러 들어옴");
        System.out.println(loginObj);
        
        if (loginObj == null) {
            return "NOT_LOGIN";
        }

        MemberVO loginUser = (MemberVO) loginObj;

        System.out.println(loginUser);
        
        // ⚠️ userId String → Long 변환 (DB FK 때문)
        String userIdStr = loginUser.getId();
        
        System.out.println(userIdStr);
        
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            return "NOT_LOGIN";
        }

        

        reviewService.writeReview(bookId, userIdStr, rating, content);
        
        return "OK";
    }
    
    
    
    
}