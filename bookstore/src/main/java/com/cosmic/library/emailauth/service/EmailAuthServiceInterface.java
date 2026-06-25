package com.cosmic.library.emailauth.service;

public interface EmailAuthServiceInterface {

    // 인증메일 발송
    void sendAuth(String email);

    // 인증 확인
    boolean verify(String email, String authCode);
}