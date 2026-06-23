package com.cosmic.library.emailauth.service;

import java.sql.Timestamp;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cosmic.library.emailauth.repository.*;
import com.cosmic.library.emailauth.util.AuthCodeGenerator;
import com.cosmic.library.emailauth.util.BrevoMailSender;
import com.cosmic.library.emailauth.model.*;

@Service
public class EmailAuthService {

    @Autowired
    private EmailAuthDAO dao;

    // 인증 메일 발송
    public void sendAuth(String email) {

        String code = AuthCodeGenerator.generate();

        EmailAuthVO vo = new EmailAuthVO();
        vo.setEmail(email);
        vo.setAuthCode(code);

        long now = System.currentTimeMillis();
        vo.setExpireTime(new Timestamp(now + 5 * 60 * 1000));

        dao.saveAuth(vo);
        System.out.println("보내기2");
        BrevoMailSender.send(email, code);
    }

    // 인증 확인
    public boolean verify(String email, String code) {
        return dao.verify(email, code) > 0;
    }
}