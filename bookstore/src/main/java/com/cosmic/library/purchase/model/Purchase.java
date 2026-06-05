package com.cosmic.library.purchase.model;

import java.sql.Timestamp;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Purchase {

    // 🧾 --- 마스터(영수증) 공통 정보 ---
    private int id;                 // 마스터 영수증 번호 (purchase_id)
    private int userRegNum;         // 대원 활동 기준 고유 번호 (user_reg_num)
    private Timestamp purchaseDate; // 결제 승인 및 탐사 기록 일시

    // 📦 --- 디테일(세부 품목) 개별 정보 ---
    private int bookId;             // 도서 원천 ID (book_id)
    private int saleId;             // 💥 [추가] 마켓 판매 상품 고유 식별자 (sale_id - 배송/재고 관제 핵심 키!)
    private int price;              // 개별 품목 구매 당시 단가 (unit_price)
    private int quantity;           // 구매 수량
    private int totalPrice;         // 해당 품목의 총 금액 (단가 * 수량)
    private String status;          // 💥 [수정] 마스터의 상태가 아닌, 개별 품목의 배송 상태 (READY, SHIPPING 등)

    // 🖼️ --- 화면 출력을 위한 JOIN 확장 필드 ---
    private String title;           // 도서 제목
    private String image;           // 도서 이미지 (네이버 실시간 표지용)
}