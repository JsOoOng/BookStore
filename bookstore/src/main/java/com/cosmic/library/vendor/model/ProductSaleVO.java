package com.cosmic.library.vendor.model;

import java.sql.Timestamp;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class ProductSaleVO {

    // 🌟 PRODUCT_SALE 순수 테이블 컬럼 싱크
    private int saleId;         // sale_id (PK)
    private int stockId;        // stock_id (FK - STOCK_IN 참조)
    private int vRegNum;        // v_reg_num (FK - VENDOR_REGISTRATION 참조)
    private int price;          // price (소비자 판매가)
    private int stockQty;       // stock_qty (현재 판매 가능한 재고 수량)
    private String saleStatus;  // sale_status (ON: 판매중, OFF: 품절/중지)
    private Timestamp regDate;  // regDate (등록 일시)

    // 🛸 JOIN 확장 버퍼 필드 (도서 목록 및 마이페이지 화면 표시용)
    private int bookId;         // 도서 식별 번호 (from STOCK_IN)
    private String title;       // 도서 제목 (from BOOK)
    private String writer;      // 저자 (from BOOK)
    private String publisher;   // 출판사 (from BOOK)
    private String image;       // 도서 이미지 경로 (from BOOK)
    private String bizName;     // 업체 상호명 (from VENDOR)
}