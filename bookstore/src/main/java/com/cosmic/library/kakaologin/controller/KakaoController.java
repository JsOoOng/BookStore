package com.cosmic.library.kakaologin.controller;

import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.cosmic.library.kakaologin.service.KakaoService;
import com.cosmic.library.kakaologin.model.KakaoUserInfo;
import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.member.service.MemberService;

@Controller
public class KakaoController {

    @Autowired
    private KakaoService kakaoService;

    @Autowired
    private MemberService memberService; 

    @GetMapping("/login/kakao")
    public String kakaoCallback(@RequestParam("code") String code, HttpSession session) {
        
        System.out.println("====== 카카오 로그인 콜백 시작 ======");
        System.out.println("전달받은 인증 코드: " + code);
        
        try {
            // 1. 토큰 가져오기 단계
            System.out.println("1단계: 카카오 토큰 요청 중...");
            String accessToken = kakaoService.getAccessToken(code);
            System.out.println("발급된 엑세스 토큰 확인: " + accessToken);
            
            // 2. 유저 정보 가져오기 단계
            System.out.println("2단계: 카카오 유저 정보 요청 중...");
            KakaoUserInfo kakaoUser = kakaoService.getUserInfo(accessToken);
            
            String kakaoIdStr = "kakao_" + kakaoUser.getId(); 
            String nickname = kakaoUser.getProperties().getNickname();
            System.out.println("카카오 유저 정보 획득 성공 -> ID: " + kakaoIdStr + ", 닉네임: " + nickname);

            // 3. DB 중복 체크 및 가입 단계
            System.out.println("3단계: DB 중복 체크 진행 중...");
            boolean isNewMember = memberService.isIdAvailable(kakaoIdStr);

            MemberVO loginUser;

            if (isNewMember) {
                System.out.println("-> 신규 대원 가입 프로세스 시작");
                MemberVO newMember = new MemberVO();
                newMember.setId(kakaoIdStr);
                newMember.setPw("KAKAO_LOGIN_ACCOUNT"); 
                newMember.setName(nickname); 
                
             // 💡 여기에 이메일과 주소(기본값)를 세팅해 줍니다!
                newMember.setEmail(kakaoUser.getKakao_account().getEmail()); // 비즈 앱 풀었으니 이메일 연동!
                newMember.setAddress("카카오 가입 회원"); // 👈 이 코드를 추가해서 NULL을 방지합니다
                
                memberService.join(newMember);
                loginUser = newMember;
                System.out.println("🚀 신규 카카오 대원 기지 등록 완료: " + nickname);
            } else {
                System.out.println("-> 기존 대원 로그인 프로세스 시작");
                loginUser = new MemberVO();
                loginUser.setId(kakaoIdStr);
                loginUser.setName(nickname);
                System.out.println("🛰️ 기존 카카오 대원 기지 진입 허가: " + nickname);
            }

            session.setAttribute("loginMember", loginUser);
            System.out.println("====== 카카오 로그인 정상 종료 -> 메인 이동 ======");
            return "redirect:/";

        } catch (Exception e) {
            // 🔥 에러가 발생하면 콘솔에 빨간 글씨로 범인을 잡아줍니다.
            System.err.println("❌ 카카오 로그인 처리 중 에러 발생!!!");
            e.printStackTrace(); 
            
            // 에러가 나면 일단 로그인 페이지로 튕기게 처리
            return "redirect:/member/login"; // 본인의 실제 로그인 뷰 주소로 맞추셔도 됩니다.
        }
    }
}