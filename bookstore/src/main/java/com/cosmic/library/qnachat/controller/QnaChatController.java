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
        // 로그인이 안 되어있으면 로그인 페이지로 리다이렉트
        if (session.getAttribute("loginMember") == null) {
            return "redirect:/member/login"; // 로그인 페이지 URL에 맞게 수정
        }
        // 로그인이 되어있으면 채팅 JSP로 이동
        return "pages/QnA/qnachat";
    }
}