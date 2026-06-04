package com.cosmic.library.qnachat.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/qna")
public class QnaChatController {

    @GetMapping("/chat")
    public String openChatRoom(HttpSession session) {
        
        // 🪐 [방어선 리팩토링] 일반 대원(loginMember)도 아니고 사령부 관리자(loginAdmin)도 아니라면 
        // 완벽하게 비인가 조난자로 판정하여 로그인 게이트웨이로 리다이렉트 시킵니다.
        if (session.getAttribute("loginMember") == null && session.getAttribute("loginAdmin") == null) {
            return "redirect:/member/login?error=login_required"; 
        }
        
        // 두 신분 중 하나라도 인증에 성공했다면 웅장한 통합 실시간 통신망 단말기로 인입 승인!
        return "pages/QnA/qnachat";
    }
}