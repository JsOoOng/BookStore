package com.cosmic.library.cookie.model;

import java.util.ArrayList;
import java.util.List;
import com.cosmic.library.basket.model.BasketVO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CookieOrderVO {
    // 1. GUEST_USER (비회원 원천 정보) 매핑 필드
    private String guestId;      // 비회원 고유 식별자 (세션 ID 혹은 쿠키 토큰 좌표)
    private String name;         // 수령인 성명
    private String nickname;	//별명
    private String phone;        // 연락처 주파수
    private String address;      // 배송지 주소

    // 2. GUEST_PURCHASE (비회원 결제 마스터) 매핑 필드
    private String purchaseId;   // 영수증 주문 번호 (ex: G17822...)
    private int totalPrice;      // 총 결제 예정 금액
    private String paymentKey;   // PG사 인증 키락
    private String status;       // 주문 관제 상태 (기본값 'ORDERED')
    private String purchaseDate; // 주문 일시

    // 3. GUEST_PURCHASE_DETAIL (하위 품목 데이터 버퍼)
    private List<BasketVO> items = new ArrayList<>();
}