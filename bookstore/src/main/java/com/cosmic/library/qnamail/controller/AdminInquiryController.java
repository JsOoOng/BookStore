package com.cosmic.library.qnamail.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.cosmic.library.qnamail.model.QnAMailVO;
import com.cosmic.library.qnamail.service.QnAMailService;

@Controller
@RequestMapping("/admin")
public class AdminInquiryController {

    private final QnAMailService qnAMailService;

    @Autowired
    public AdminInquiryController(QnAMailService qnAMailService) {
        this.qnAMailService = qnAMailService;
    }

    // 관리자 문의 리스트
    @GetMapping("/inquiries")
    public String inquiryList(Model model, HttpSession session) {
        // 세션 체크 (관리자인 경우만)
        List<QnAMailVO> inquiries = qnAMailService.getAllInquiries();
        model.addAttribute("inquiries", inquiries);
        model.addAttribute("pageName", "QnA/adminInquiryList"); // JSP 경로
        return "common/layout";
    }

    // 관리자 문의 상세보기
    @GetMapping("/inquiryDetail")
    public String inquiryDetail(@RequestParam("id") int id, Model model, HttpSession session) {
        Object admin = session.getAttribute("loginAdmin");

        QnAMailVO inquiry = qnAMailService.getInquiryById(id);
        model.addAttribute("inquiry", inquiry);
        model.addAttribute("pageName", "QnA/adminInquiryDetail");
        return "common/layout";
    }

    // 관리자 문의 삭제
    @PostMapping("/deleteInquiry")
    public String deleteInquiry(@RequestParam("id") int id, HttpSession session) {
        Object admin = session.getAttribute("loginAdmin");

        qnAMailService.deleteInquiry(id);
        return "redirect:/admin/inquiries";
    }
}