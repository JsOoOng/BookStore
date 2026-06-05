package com.cosmic.library.basket.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BasketVO {

    private int basketId;      // 장바구니 고유 ID (PK)
    private int userRegNum;    // 🌟 변경: memberId 제거 후 활동 기준 번호(FK) 장착!
    private int bookId;        // 도서 고유 ID (FK)
    private int quantity;      // 담은 수량
    private String regDate;    // 등록 일시

    // --- 화면 출력 및 조인(JOIN)용 필드 ---
    private String title;
    private String writer;
    private int price;         // 💡 나중에 PRODUCT_SALE과 연동하여 판매가를 담을 구역
    private String image;
    
    // --- 시스템 안정화 및 확장용 필드 ---
    private String genre;      
    private String publisher;  
    private String isbn;
    
    private Integer saleId;        // 오픈마켓 상품 일련번호
    private String bizName;    // 판매 업체명
}