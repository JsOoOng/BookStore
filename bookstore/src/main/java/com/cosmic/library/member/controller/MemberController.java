package com.cosmic.library.member.controller;

import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.member.service.MemberService;

@Controller
@RequestMapping("/member")
public class MemberController {

    @Autowired
    private MemberService memberService;

    // 1. 로그인 페이지로 이동
    @GetMapping("/login")
    public String loginForm(Model model) {
        // 🚀 경로 수정: pages/member/login
        model.addAttribute("pageName", "pages/member/login");
        return "common/layout";
    }

    // 2. 로그인 처리
    @PostMapping("/login")
    public String loginProcess(@RequestParam("id") String id, @RequestParam("pw") String pw, HttpSession session) {
        MemberVO loginMember = memberService.login(id, pw);
        if (loginMember != null) {
            session.setAttribute("loginMember", loginMember);
            return "redirect:/";
        }
        return "redirect:/member/login?error=true";
    }

    // 3. 로그아웃
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

    // 4. 회원가입 페이지 이동
    @GetMapping("/join")
    public String joinForm(Model model) {
        // 🚀 경로 수정: pages/member/join
        model.addAttribute("pageName", "pages/member/join");
        return "common/layout";
    }

    // 5. 회원가입 처리 (POST)
    @PostMapping("/join")
    public String joinProcess(@ModelAttribute MemberVO member) {
        int result = memberService.join(member);
        if (result > 0) {
            return "redirect:/member/login?joinSuccess=true";
        } else {
            return "redirect:/member/join?error=id_exists";
        }
    }

    // 6. 내 정보 수정 페이지 (로그인 필요)
    @GetMapping("/edit")
    public String editForm(Model model, HttpSession session) {
        if (session.getAttribute("loginMember") == null) return "redirect:/member/login";
        
        // 🚀 경로 수정: pages/member/edit
        model.addAttribute("pageName", "pages/member/edit");
        return "common/layout";
    }
    
    // 7. 정보 수정 처리 (POST)
    @PostMapping("/edit")
    public String editProcess(@ModelAttribute MemberVO member, HttpSession session) {
        int result = memberService.updateProfile(member);
        
        if (result > 0) {
            MemberVO updatedMember = memberService.login(member.getId(), member.getPw());
            session.setAttribute("loginMember", updatedMember);
            return "redirect:/";
        }
        return "redirect:/member/edit?error=true";
    }
}