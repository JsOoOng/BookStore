package com.cosmic.library.common.filter; // 패키지 경로 확인하세요!

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.web.servlet.HandlerInterceptor;

public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        
    	System.out.println("🛡️ 보안 인터셉터 가동: " + request.getRequestURI());
    	
    	HttpSession session = request.getSession();
        
        // 🛰️ 세션에서 로그인한 대원 정보를 확인합니다.
        if (session.getAttribute("loginMember") == null) {
            // 신분 확인 실패! 로그인 페이지로 강제 워프시킵니다.
            String contextPath = request.getContextPath();
            response.sendRedirect(contextPath + "/member/login?error=login_required");
            return false; // 컨트롤러로 보내지 않고 여기서 차단!
        }
        
        return true; // 신분 확인 완료! 통과시켜줍니다.
    }
}