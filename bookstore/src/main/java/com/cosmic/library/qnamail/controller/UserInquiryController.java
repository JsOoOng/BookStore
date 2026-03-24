package com.cosmic.library.qnamail.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.cosmic.library.qnamail.model.QnAMailVO;
import com.cosmic.library.qnamail.service.QnAMailService;

@Controller
@RequestMapping("/user")
public class UserInquiryController {

    private final QnAMailService qnAMailService;

    @Autowired
    public UserInquiryController(QnAMailService qnAMailService) {
        this.qnAMailService = qnAMailService;
    }

    // 사용자 문의 폼
    @GetMapping("/inquiry")
    public String inquiryForm(Model model) {
        model.addAttribute("pageName", "QnA/userInquiry"); // JSP 경로
        return "common/layout";
    }

    // 사용자 문의 제출
    @PostMapping("/submitInquiry")
    public String submitInquiry(QnAMailVO qnamailvo, HttpSession session) {
        try {
            qnAMailService.createInquiry(qnamailvo);
        } catch (Exception e) {
            // 예외 처리 (유효성 검사 등)
            e.printStackTrace();
            return "redirect:/user/inquiry?error=true";
        }
        return "redirect:/";
    }
}