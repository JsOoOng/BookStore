package com.cosmic.library.basket.model;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor; 

@Getter
@Setter
@NoArgsConstructor // 💡 필수: Spring 데이터 바인딩을 위한 기본 생성자
public class BasketVO {
    private int basketId;
    private int userRegNum;
    private int bookId;
    private int quantity; // 값이 없으면 0으로 처리됨
    private String regDate;
    private String title;
    private String writer;
    private int price;
    private String image;
    private String genre;
    private String publisher;
    private String isbn;
    private Integer saleId;
    private String bizName;
}