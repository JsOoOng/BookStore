package com.cosmic.library.common.config;

import javax.annotation.PostConstruct;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.cosmic.library.common.filter.LoginInterceptor;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LoginInterceptor())
                .addPathPatterns("/**") // 🛰️ 모든 경로를 일단 감시 대상으로 설정!
                .excludePathPatterns(   // 🚀 하지만 아래 구역은 자유로운 통행을 허용함
                    "/",                // 메인 페이지
                    "/member/login",    // 로그인 페이지
                    "/member/join",     // 회원가입 페이지
                    "/resources/**",    // CSS, JS, 이미지 등 정적 파일
                    "/static/**",
                    "/error/**"         // 에러 페이지
                );
    }
    
    @PostConstruct
    public void init() {
        System.out.println("✅ WebConfig 설정 본부가 정상 가동되었습니다!");
    }
}