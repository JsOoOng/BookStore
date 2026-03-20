package com.cosmic.library.book.model;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class BookVO {
    private int id;             // 도서 고유 번호 (PK, Auto Increment)
    private String title;       // 도서 제목
    private String writer;      // 저자
    private int price;          // 가격
    private String content;     // 상세 설명 (TEXT)
    private String image;       // 도서 표지 이미지 경로
    private Timestamp regDate;  // 도서 등록일 (DB 기본값: CURRENT_TIMESTAMP)

}
