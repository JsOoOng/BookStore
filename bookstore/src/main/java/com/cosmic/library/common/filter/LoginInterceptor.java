package com.cosmic.library.common.filter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.web.servlet.HandlerInterceptor;

public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        
        String uri = request.getRequestURI();
        System.out.println("🛡️ 우주 관문 검문소 가동: " + uri);
        
        HttpSession session = request.getSession();
        String contextPath = request.getContextPath();
        
        // 🛰️ 3방향 세션 추출 (사령부 관리자 & 일반 대원 정보 & 기업 파트너 정보)
        Object loginAdmin = session.getAttribute("loginAdmin");
        Object loginMember = session.getAttribute("loginMember");
        Object loginVendor = session.getAttribute("loginVendor");
        
        // ==========================================
        // 🛰️ [0단계: 사령부 프리패스 프로토콜] (새로 신설)
        // ==========================================
        // 관리자 전용 경로(/admin)로 접근하려는 신호인 경우
        if (uri.contains("/admin")) {
            // 관리자 로그인 폼 화면 접근은 검문 없이 통과시켜 줍니다.
            if (uri.contains("/admin/login")) {
                return true;
            }
            
            // 관리자 세션이 없다면 철저하게 사령부 로그인 폼으로 튕겨냅니다.
            if (loginAdmin == null) {
                System.out.println("🚨 [인터셉터] 미인증 사용자가 사령부 제어망 접근 시도 차단 ➔ 관리자 로그인 유도");
                response.sendRedirect(contextPath + "/admin/login?error=login_required");
                return false;
            }
            
            // 관리자 세션이 있다면 사령실 컨트롤러로 프리패스!
            return true;
        }
        
        // ==========================================
        // 1단계 [통합 프리패스 검문]: 세 세션이 전부 없으면 무조건 차단
        // ==========================================
        // [정화] 관리자(loginAdmin)까지 세션이 없는지 체크하여 사령관이 일반 구역을 다닐 때 튕기는 현상 방지
        if (loginMember == null && loginVendor == null && loginAdmin == null) {
            System.out.println("🚨 신분 확인 실패! 비회원 대원 차단 ➔ 로그인 유도");
            
            // 기업 전용 주소(/vendor)로 접근하려다 튕긴 거라면 기업 로그인 폼으로 워프!
            if (uri.contains("/vendor")) {
                response.sendRedirect(contextPath + "/vendor/login?error=login_required");
            } else {
                response.sendRedirect(contextPath + "/member/login?error=login_required");
            }
            return false; 
        }
        
        // ==========================================
        // 2단계 [교통정리 방어막]: 기업 회원이 일반 회원 구역에 침범할 때
        // ==========================================
        if (loginVendor != null && loginMember == null && loginAdmin == null) {
            // 기업 회원이 장바구니(/basket)나 일반 마이페이지(/member/mypage) 등을 찌르고 들어올 경우
            if (uri.contains("/basket") || uri.contains("/member/mypage") || uri.contains("/member/edit")) {
                System.out.println("⚠️ 파트너 대원이 일반 대원 기지에 진입 시도 차단 ➔ 대시보드로 강제 송환");
                response.sendRedirect(contextPath + "/vendor/dashboard?warning=access_denied");
                return false;
            }
        }
        
        // 3단계: 신분 검증 완수! 관문 통과 허가
        return true; 
    }
}