package com.cosmic.library.cookie.model;

import java.util.ArrayList;
import java.util.List;

import com.cosmic.library.basket.model.BasketVO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CookieOrderVO {
    private int cookieOrderId;   // PK
    private String name;         // 주문자 이름
    private String phone;        // 연락처
    private String address;      // 주소
    private Integer totalPrice;      // 총 결제 금액
    private String status;       // 상태 (기본값 'ORDERED')
    private String purchaseDate; // 주문 일시
    private int orderId; // insert 후 생성된 키를 담을 용도
    private List<BasketVO> items = new ArrayList<>();
}