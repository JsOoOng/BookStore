package com.cosmic.library.purchase.model;

import java.sql.Timestamp;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Purchase {

    private int id;            // 구매 고유 ID (DB의 purchase_id와 매칭)
    private String memberId;   // 회원 ID
    private int bookId;        // 책 ID
    private int price;         // 단가
    private int quantity;      // 수량
    private int totalPrice;    // 총 금액
    
    // 🔥 [추가] 마이페이지 출력을 위한 핵심 필드
    private String status;         // 주문 상태 (ORDERED, CANCEL 등)
    private Timestamp purchaseDate; // 구매 시간 (탐사 기록 일시)

    // 🔥 [추가] JOIN용 필드 (도서관 본부 DB에서 가져올 정보)
    private String title;  // 도서 제목
    private String image;  // 도서 이미지 경로
}