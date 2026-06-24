package com.cosmic.library.cookie.model;

import java.util.Date;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GuestOrderVO {
    // 1. 주문 테이블 정보
    private String id;           // 주문번호 (orderId)
    private String name;         // 주문자 이름
    private String phone;        // 연락처
    private String address;      // 주소
    private int totalPrice;      // 결제 금액
    private String status;       // 상태 (READY, SHIPPING 등)
    private Date purchaseDate;   // 주문 일시
    
    // 2. 상품 정보 (화면 표시용)
    private String title;        // 도서 제목
    private int quantity;        // 주문 수량
    private String image;        // 이미지 경로
    
    
}