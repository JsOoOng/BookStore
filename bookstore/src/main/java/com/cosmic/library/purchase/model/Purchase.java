package com.cosmic.library.purchase.model;

import java.sql.Timestamp;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Purchase {

    private int id;             // 구매 고유 ID (DB의 purchase_id와 매칭)
    private int userRegNum;     // 🌟 전면 개편: memberId 제거 후 활동 기준 고유 번호(FK) 장착!
    private int bookId;         // 책 ID
    private int price;          // 단가 (차후 PRODUCT_SALE의 실판매가와 조인 연동)
    private int quantity;       // 수량
    private int totalPrice;     // 총 금액
    
    // 주문 상태 및 탐사 기록 일시
    private String status;         // 주문 상태 (ORDERED, CANCEL 등)
    private Timestamp purchaseDate; // 구매 시간 (탐사 기록 일시)

    // --- 화면 출력을 위한 JOIN용 필드 ---
    private String title;  // 도서 제목
    private String image;  // 도서 이미지 경로
}