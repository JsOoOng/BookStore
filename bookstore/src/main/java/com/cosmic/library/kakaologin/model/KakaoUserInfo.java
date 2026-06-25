package com.cosmic.library.kakaologin.model;

import com.cosmic.library.member.model.MemberVO;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class KakaoUserInfo {
    private Long id;
    private Properties properties;
    private KakaoAccount kakao_account;

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Properties {
        private String nickname;
        public String getNickname() { return nickname; }
        public void setNickname(String nickname) { this.nickname = nickname; }
    }
    
    public static class KakaoAccount {
        private String email;

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Properties getProperties() { return properties; }
    public void setProperties(Properties properties) { this.properties = properties; }
    public KakaoAccount getKakao_account() { return kakao_account; }
    public void setKakao_account(KakaoAccount kakao_account) { this.kakao_account = kakao_account; }
}