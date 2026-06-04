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
}