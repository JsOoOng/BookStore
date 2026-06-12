package com.cosmic.library.kakaologin.service;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import com.cosmic.library.kakaologin.model.KakaoTokenResponse;
import com.cosmic.library.kakaologin.model.KakaoUserInfo;

@Service
public class KakaoService {

    private final String clientId = "5704fcbe13d27f9fb045d4e38a2feab2";
    private final String redirectUri = "http://localhost:8888/login/kakao";

    public String getAccessToken(String code) {
        String tokenURL = "https://kauth.kakao.com/oauth/token";
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "authorization_code");
        params.add("client_id", clientId);
        params.add("redirect_uri", redirectUri);
        params.add("code", code);
        params.add("client_secret", "iEx37cSA6tvtrD198oJtzKzRnXGzggpn");

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);
        ResponseEntity<KakaoTokenResponse> response = restTemplate.postForEntity(tokenURL, request, KakaoTokenResponse.class);

        return response.getBody().getAccess_token();
    }

    public KakaoUserInfo getUserInfo(String accessToken) {
        String userURL = "https://kapi.kakao.com/v2/user/me";
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(headers);
        ResponseEntity<KakaoUserInfo> response = restTemplate.postForEntity(userURL, request, KakaoUserInfo.class);

        return response.getBody();
    }
}