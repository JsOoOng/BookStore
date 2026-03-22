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

    // 로그인 페이지로 이동
    @GetMapping("/login")
    public String loginForm(Model model) {
        model.addAttribute("pageName", "member/login");
        return "common/layout";
    }

    // 로그인 처리
    @PostMapping("/login")
    public String loginProcess(@RequestParam("id") String id, @RequestParam("pw") String pw, HttpSession session) {
        MemberVO loginMember = memberService.login(id, pw);
        if (loginMember != null) {
            session.setAttribute("loginMember", loginMember); // 세션에 탑승권 저장
            return "redirect:/"; // 메인 본부로 이동
        }
        return "redirect:/member/login?error=true"; // 실패 시 다시 로그인
    }

    // 로그아웃
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate(); // 세션 파괴 (탑승권 회수)
        return "redirect:/";
    }

    // 회원가입 페이지 이동
    @GetMapping("/join")
    public String joinForm(Model model) {
        model.addAttribute("pageName", "member/join");
        return "common/layout";
    }

    // 회원가입 처리 (POST)
    @PostMapping("/join")
    public String joinProcess(@ModelAttribute MemberVO member) {
        // 기본 권한은 'USER'로 설정 (서비스나 DAO에서 처리해도 좋습니다)
        int result = memberService.join(member);
        
        if (result > 0) {
            // 가입 성공 시 로그인 페이지로 이동
            return "redirect:/member/login?joinSuccess=true";
        } else {
            // 가입 실패 (중복 ID 등) 시 다시 가입 페이지로
            return "redirect:/member/join?error=id_exists";
        }
    }

    // 내 정보 수정 페이지 (로그인 필요)
    @GetMapping("/edit")
    public String editForm(Model model, HttpSession session) {
        if (session.getAttribute("loginMember") == null) return "redirect:/member/login";
        model.addAttribute("pageName", "member/edit");
        return "common/layout";
    }
    
    // 정보 수정 처리 (POST)
    @PostMapping("/edit")
    public String editProcess(@ModelAttribute MemberVO member, HttpSession session) {
        // 1. 서비스 호출하여 DB 업데이트
        int result = memberService.updateProfile(member);
        
        if (result > 0) {
            // 2. 중요! DB가 바뀌었으니 세션에 저장된 정보도 최신으로 교체합니다.
            // 기존 세션 정보를 가져와서 변경된 부분만 덮어쓰거나 다시 조회합니다.
            MemberVO updatedMember = memberService.login(member.getId(), member.getPw());
            session.setAttribute("loginMember", updatedMember);
            
            return "redirect:/"; // 수정 완료 후 메인으로
        }
        return "redirect:/member/edit?error=true";
    }
}