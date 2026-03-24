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
import org.springframework.web.bind.annotation.ResponseBody;

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
    
    // 정보 수정 처리 (POST) - 비밀번호 선택 변경 및 보안 강화 버전
    @PostMapping("/edit")
    public String editProcess(
            @ModelAttribute MemberVO member, 
            @RequestParam("currentPw") String currentPw, // 현재 비번 (본인 확인용)
            @RequestParam(value = "newPw", required = false) String newPw, // 새 비번 (변경용)
            HttpSession session) {
        
        // 1. [보안 검문] 현재 세션에 로그인된 대원 정보를 가져옵니다.
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        
        // 2. [신원 확인] 입력한 '현재 보안 코드'가 DB(세션)의 정보와 일치하는지 검사합니다.
        if (loginMember == null || !loginMember.getPw().equals(currentPw)) {
            // 일치하지 않으면 'pw_mismatch' 에러 코드를 들고 다시 수정 페이지로 보냅니다.
            return "redirect:/member/edit?error=pw_mismatch";
        }
        
        // 3. [비밀번호 갱신 결정] 
        // 새 보안 코드가 입력되었다면 그 값으로, 비어있다면 기존 값을 그대로 유지합니다.
        if (newPw != null && !newPw.trim().isEmpty()) {
            member.setPw(newPw); // 새로운 코드로 교체
        } else {
            member.setPw(loginMember.getPw()); // 기존 코드를 그대로 주입 (5번 문제 해결!)
        }
        
        // 4. [기지 데이터 업데이트] DB에 수정된 정보를 동기화합니다.
        int result = memberService.updateProfile(member);
        
        if (result > 0) {
            // 5. [세션 동기화] DB가 바뀌었으니 세션의 탑승권(loginMember)도 최신 정보로 갱신합니다.
            // 수정된 ID와 PW를 사용하여 다시 조회합니다.
            MemberVO updatedMember = memberService.login(member.getId(), member.getPw());
            session.setAttribute("loginMember", updatedMember);
            
            return "redirect:/?editSuccess=true"; // 성공 신호와 함께 메인 본부로!
        }
        
        return "redirect:/member/edit?error=true";
    }
    
    // 아이디 중복 확인 (AJAX 통신 전용)
    @ResponseBody // 🚀 중요: JSP 뷰를 찾지 않고, 리턴하는 문자열을 브라우저에 바로 전달합니다.
    @GetMapping("/checkId")
    public String checkId(@RequestParam("id") String id) {
        // 1. 서비스에게 해당 아이디의 가용 여부를 묻습니다.
        boolean isAvailable = memberService.isIdAvailable(id);
        
        // 2. 결과에 따라 브라우저에 신호를 보냅니다.
        // "Y" : 사용 가능 (Yellow Light? 아니, Green Light!)
        // "N" : 중복됨 (No Go)
        return isAvailable ? "Y" : "N";
    }
}