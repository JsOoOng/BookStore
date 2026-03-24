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
            
            // 🚀 도착지를 '내 문의 내역'으로 변경하고 성공 파라미터를 붙입니다.
            return "redirect:/user/myInquiries?sendSuccess=true"; 
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/user/inquiry?error=true";
        }
    }
    
    // 3. 내 문의 내역 리스트 (문제 1 해결용)
    @GetMapping("/myInquiries")
    public String myInquiries(HttpSession session, Model model) {
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        
        // 🛡️ 로그인 체크
        if (loginMember == null) return "redirect:/member/login";

        // 🚀 [수정] @cosmic.com을 붙이지 않고 순수 ID만 가져옵니다.
        // JSP에서 <input type="hidden" name="name" value="${loginMember.id}"> 로 보냈기 때문입니다.
        String userName = loginMember.getId(); 
        
        // 서비스 호출 (바뀐 규격에 맞춰 name으로 조회)
        List<QnAMailVO> myInquiries = qnAMailService.getMyInquiries(userName);
        
        model.addAttribute("myList", myInquiries);
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