package com.cosmic.library.member.model;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class MemberVO {
    private String id;
    private String pw;
    private String name;
    private String role;
    private Timestamp regDate;
}
