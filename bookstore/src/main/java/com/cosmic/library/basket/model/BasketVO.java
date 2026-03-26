package com.cosmic.library.basket.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BasketVO {

    private int basketId;   // 장바구니 고유 ID (PK)
    private String memberId;
    private int bookId;
    private int quantity;
    private String regDate;

    // 화면용 (JOIN)
    private String title;
    private String writer;
    private int price;
    private String image;
}