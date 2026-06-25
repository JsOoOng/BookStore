package com.cosmic.library.cookie.model;

import java.util.Date;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GuestOrderVO {
    // 1. GUEST_PURCHASE & DETAIL (주문서 관제 코드)
    private String purchaseId;   // 주문 번호
    private int detailId;        // 상세 내역 ID (PK)
    private int saleId;          // 마켓 상품 번호
    private int vRegNum;         // 파트너사 등록 번호
    private int quantity;        // 주문 수량
    private int unitPrice;       // 단가 (구매 당시 가격)
    private String status;       // 배송 상태 (READY 등)
    private Date purchaseDate;   // 주문 일시
    
    // 2. GUEST_USER (고객 정보 소스)
    private String name;         // 주문자 이름
    private String phone;        // 연락처
    private String address;      // 주소
    
    // 3. BOOK (도서 원천 정보 매핑 - 네이버 API 가동기)
    private String title;        // 도서 제목
    private String image;        // 표지 이미지 경로
    private String writer;		// 도서 저자
}