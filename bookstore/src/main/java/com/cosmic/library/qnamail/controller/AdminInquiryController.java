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

    // 1. 관리자 문의 리스트
    @GetMapping("/inquiries")
    public String inquiryList(Model model, HttpSession session) {
        // 🛡️ 사령관 권한 체크 (필요시 추가 로직 구현)
        List<QnAMailVO> inquiries = qnAMailService.getAllInquiries();
        model.addAttribute("inquiries", inquiries);
        
        // 🚀 좌표 수정: QnA/adminInquiryList -> pages/QnA/adminInquiryList
        model.addAttribute("pageName", "pages/QnA/adminInquiryList"); 
        
        return "common/layout";
    }

    // 2. 관리자 문의 상세보기
    @GetMapping("/inquiryDetail")
    public String inquiryDetail(@RequestParam("id") int id, Model model, HttpSession session) {
        // 🛡️ 사령관 세션 확인 (기존 로직 유지)
        session.getAttribute("loginAdmin");

        QnAMailVO inquiry = qnAMailService.getInquiryById(id);
        model.addAttribute("inquiry", inquiry);
        
        // 🚀 좌표 수정: QnA/adminInquiryDetail -> pages/QnA/adminInquiryDetail
        model.addAttribute("pageName", "pages/QnA/adminInquiryDetail");
        
        return "common/layout";
    }
    
    // 3. 관리자 문의 답변 등록 (POST)
    @PostMapping("/replyInquiry")
    public String replyInquiry(@RequestParam("id") int id, @RequestParam("answer") String answer) {
        qnAMailService.replyInquiry(id, answer);
        
        // 🚀 도착지를 '관리자 문의 리스트'로 변경하고 성공 신호를 보냅니다.
        return "redirect:/admin/inquiries?replySuccess=true"; 
    }
    // 4. 관리자 문의 삭제 (POST)
    @PostMapping("/deleteInquiry")
    public String deleteInquiry(@RequestParam("id") int id, HttpSession session) {
        session.getAttribute("loginAdmin");

        qnAMailService.deleteInquiry(id);
        
        // ⚓ 리다이렉트는 URL 주소이므로 그대로 유지합니다.
        return "redirect:/admin/inquiries";
    }
    
    
}