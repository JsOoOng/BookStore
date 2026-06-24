package com.cosmic.library.emailauth.repository;

import com.cosmic.library.emailauth.model.*;

public interface EmailAuthDAOInterface {

    // 인증코드 저장 (insert or update)
    void saveAuth(EmailAuthVO vo);

    // 인증 확인 (성공 시 업데이트)
    int verify(String email, String authCode);

    // 이메일로 조회
    EmailAuthVO findByEmail(String email);
}