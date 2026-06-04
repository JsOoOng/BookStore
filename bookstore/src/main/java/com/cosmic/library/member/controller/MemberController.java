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

import com.cosmic.library.basket.service.BasketService;
import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.member.service.MemberService;
import com.cosmic.library.purchase.service.PurchaseService;

@Controller
@RequestMapping("/member")
public class MemberController {

    @Autowired
    private MemberService memberService;
    
    @Autowired
    private BasketService basketService;

    @Autowired
    private PurchaseService purchaseService;

    // 1. 로그인 페이지로 이동
    @GetMapping("/login")
    public String loginForm(Model model) {
        model.addAttribute("pageName", "pages/member/login");
        return "common/layout";
    }

    // 2. 로그인 처리
    @PostMapping("/login")
    public String loginProcess(@RequestParam("id") String id, @RequestParam("pw") String pw, HttpSession session) {
        MemberVO loginMember = memberService.login(id, pw);
        if (loginMember != null) {
            // 성공 시 세션에 담기는 loginMember 안에는 조인 쿼리 덕분에
            // 새 테이블 구조의 user_reg_num, reg_status, email, points, 그리고 [address]까지 완벽 장착됩니다!
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
        model.addAttribute("pageName", "pages/member/join");
        return "common/layout";
    }

    // 5. 회원가입 처리 (POST)
    @PostMapping("/join")
    public String joinProcess(@ModelAttribute MemberVO member) {
        // 🪐 [방어 코드] 회원가입 폼에서 주소를 입력하지 않았을 때 기본값 강제 할당
        if (member.getAddress() == null || member.getAddress().trim().isEmpty()) {
            member.setAddress("은하계 미지정 구역");
        }
        
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
        
        model.addAttribute("pageName", "pages/member/edit");
        return "common/layout";
    }
    

    // 정보 수정 처리 (POST)
    @PostMapping("/edit")
    public String editProcess(
            @ModelAttribute MemberVO member, 
            @RequestParam("currentPw") String currentPw, 
            @RequestParam(value = "newPw", required = false) String newPw, 
            HttpSession session) {
        
        // 1. [보안 검문] 현재 세션에 로그인된 대원 정보를 가져옵니다.
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        
        // 2. [신원 확인]
        if (loginMember == null || !loginMember.getPw().equals(currentPw)) {
            return "redirect:/member/edit?error=pw_mismatch";
        }
        
        // 3. [비밀번호 및 이메일 갱신 결정] 
        if (newPw != null && !newPw.trim().isEmpty()) {
            member.setPw(newPw); 
        } else {
            member.setPw(loginMember.getPw()); 
        }
        
        // 만약 JSP 폼에서 이메일 수정란을 안 만들었거나 비어있다면 기존 이메일을 유지하도록 방어 코드 보강
        if (member.getEmail() == null || member.getEmail().trim().isEmpty()) {
            member.setEmail(loginMember.getEmail());
        }
        
        // 🪐 [💥 신규 배송지 주소 방어 코드] 
        // 수정 폼에서 배송지 주소가 비어있거나 누락되어 오면 기존 주소를 유지시킵니다.
        if (member.getAddress() == null || member.getAddress().trim().isEmpty()) {
            member.setAddress(loginMember.getAddress());
        }
        
        // 4. [기지 데이터 업데이트] DB에 수정된 정보(pw, name, email, address)를 동기화합니다.
        int result = memberService.updateProfile(member);
        
        if (result > 0) {
            // 5. [세션 최신화] 변경된 ID와 PW를 사용하여 다시 조회(Address 포함)하여 세션을 교체합니다.
            MemberVO updatedMember = memberService.login(member.getId(), member.getPw());
            session.setAttribute("loginMember", updatedMember);
            
            return "redirect:/?editSuccess=true"; 
        }
        
        return "redirect:/member/edit?error=true";
    }
    
    // 아이디 중복 확인 (AJAX)
    @ResponseBody 
    @GetMapping("/checkId")
    public String checkId(@RequestParam("id") String id) {
        boolean isAvailable = memberService.isIdAvailable(id);
        return isAvailable ? "Y" : "N";
    }
    
    // 7. 마이페이지 관제소
    @GetMapping("/mypage")
    public String myPage(
            @RequestParam(value = "msg", required = false) String msg, // 🪐 결제 방어선에서 토스한 가이드 문구 수집 레이더 장착
            HttpSession session, 
            Model model) {
        
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/member/login";
        }

        // 🪐 [추가] 리다이렉트되어 넘어온 안내 메시지가 존재하면 뷰 레이어(JSP)로 그대로 전송!
        if (msg != null && !msg.trim().isEmpty()) {
            model.addAttribute("addressAlert", msg);
        }

        // 핵심 개편: 장바구니 조회를 위해 세션에서 정수형 고유 식별자인 user_reg_num을 추출합니다.
        int userRegNum = loginMember.getUser_reg_num();

        model.addAttribute("basketList", basketService.getList(userRegNum));
        model.addAttribute("purchaseList", purchaseService.getMyPurchases(userRegNum));

        model.addAttribute("pageName", "pages/member/mypage");
        return "common/layout";
    }
    
    // 🪐 [신규 개착] 결제 직전 주소를 즉시 업데이트하고 세션을 갱신하는 비동기 관제 밸런서
    @ResponseBody
    @PostMapping("/updateAddressAjax")
    public String updateAddressAjax(@RequestParam("address") String address, HttpSession session) {
        MemberVO loginMember = (MemberVO) session.getAttribute("loginMember");
        if (loginMember == null) return "NOT_LOGIN";

        if (address == null || address.trim().isEmpty() || address.equals("은하계 미지정 구역")) {
            return "INVALID_ADDRESS";
        }

        // 1. 객체에 신규 주소 세팅 및 DB 원천 행성 업데이트
        loginMember.setAddress(address);
        int result = memberService.updateProfile(loginMember);

        if (result > 0) {
            // 2. 💥 핵심: 세션 정보도 즉시 새 주소로 치환하여 프리패스 자격 부여!
            session.setAttribute("loginMember", loginMember);
            return "OK";
        }
        return "FAIL";
    }
}