package com.cosmic.library.rent.model;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class RentVO {
    private int id;
    private String memberId;
    private int bookId;
    private Timestamp rentDate;
    
    // JOIN 결과를 담기 위해 추가
    private String bookTitle; 
    private String userName;
}
