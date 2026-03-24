package com.cosmic.library.member.controller;

import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.member.service.MemberService;

@Controller
@RequestMapping("/super")
public class SuperController {

    @Autowired
    private MemberService memberService;

    // 1. 대원 통제 센터 (User Management)
    @GetMapping("/userControl")
    public String userControl(Model model, HttpSession session) {
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        
        // 🛡️ 보안 프로토콜: SUPER 권한이 아닐 시 메인 본부로 즉시 강제 퇴출
        if (loginMember == null || !loginMember.getRole().equals("SUPER")) {
            return "redirect:/";
        }

        model.addAttribute("memberList", memberService.getAllMembers());
        
        // 🚀 좌표 수정: super/userControl -> pages/super/userControl
        model.addAttribute("pageName", "pages/super/userControl");
        
        return "common/layout";
    }
    
    // 2. 계급(Role) 변경 승인
    @GetMapping("/changeRole")
    public String changeRole(@RequestParam("id") String id, @RequestParam("role") String role) {
        memberService.changeRole(id, role);
        return "redirect:/super/userControl"; // ⚓ 리다이렉트는 URL 주소이므로 그대로 유지
    }

    // 3. 불량 대원 강제 퇴출 (Kick)
    @GetMapping("/kick")
    public String kickMember(@RequestParam("id") String id) {
        memberService.withdraw(id);
        return "redirect:/super/userControl"; // ⚓ 리다이렉트는 URL 주소이므로 그대로 유지
    }
}