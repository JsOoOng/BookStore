package com.cosmic.library.purchase.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Purchase {

    private int id;

    private String memberId;   // 회원 ID
    private int bookId;        // 책 ID

    private int price;         // 단가
    private int quantity;      // 수량 ⭐ 추가
    private int totalPrice;    // 총 금액 ⭐ 추가
}