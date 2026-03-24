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

import com.cosmic.library.member.model.MemberVO;
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

    // 1. 사용자 문의 작성 폼
    @GetMapping("/inquiry")
    public String inquiryForm(Model model) {
        // 🚀 좌표 수정: QnA/userInquiry -> pages/QnA/userInquiry
        model.addAttribute("pageName", "pages/QnA/userInquiry"); 
        return "common/layout";
    }

    // 2. 사용자 문의 제출
    @PostMapping("/submitInquiry")
    public String submitInquiry(QnAMailVO qnamailvo, HttpSession session) {
        try {
            qnAMailService.createInquiry(qnamailvo);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/user/inquiry?error=true";
        }
        return "redirect:/"; // 제출 후 메인으로 복귀
    }
    
    // 3. 내 문의 내역 리스트 (문제 1 해결용)
    @GetMapping("/myInquiries")
    public String myInquiries(HttpSession session, Model model) {
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");

        // 가입 시 아이디를 기반으로 생성된 메일 주소로 검색 (또는 VO에 맞춰 조정)
        String userMail = loginMember.getId() + "@cosmic.com"; 
        List<QnAMailVO> myInquiries = qnAMailService.getMyInquiries(userMail);
        
        model.addAttribute("myList", myInquiries);
        // 🚀 좌표 설정: pages/QnA/userInquiryList
        model.addAttribute("pageName", "pages/QnA/userInquiryList");
        return "common/layout";
    }
    
    // 4. 내 문의 상세보기 (답변 확인용)
    @GetMapping("/myInquiryDetail")
    public String myInquiryDetail(@RequestParam("id") int id, Model model) {
        QnAMailVO inquiry = qnAMailService.getInquiryById(id);
        model.addAttribute("inquiry", inquiry);
        
        // 🚀 좌표 수정: QnA/userInquiryDetail -> pages/QnA/userInquiryDetail
        model.addAttribute("pageName", "pages/QnA/userInquiryDetail");
        return "common/layout";
    }
}