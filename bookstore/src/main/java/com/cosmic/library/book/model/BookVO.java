package com.cosmic.library.book.model;

import java.sql.Date; // pubDate(DATE) 처리를 위해 추가
import lombok.Data;

@Data
public class BookVO {
    private int id;             // 도서 고유 번호 (PK, Auto Increment)
    private String title;       // 도서 제목
    private String writer;      // 저자 이름
    private String publisher;   // 출판사
    private Date pubDate;       // 출판일 (시/분/초가 없는 순수 날짜 형식이므로 java.sql.Date 권장)
    private String genre;       // 도서 장르
    private String language;    // 도서 기록 언어 (기본값: 'Korean')
    private String isbn;        // 국제 표준 식별 번호 (UNIQUE)
    private String image;       // 표지 이미지 경로
    private int saleId; 
 // ★ 추가: DB에는 없지만 장바구니 기능을 위해 필요한 필드
    private int quantity; 
    
   
    
    // ★ 추가: 화면에서 가격을 표시하려면 price 필드도 필요할 수 있습니다. 
    // 만약 DB에 price 컬럼이 있다면 추가해 주세요!
    private int price;
}