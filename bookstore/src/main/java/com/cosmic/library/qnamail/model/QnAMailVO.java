package com.cosmic.library.qnamail.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@AllArgsConstructor
@NoArgsConstructor
@Getter @Setter @ToString
public class QnAMailVO {
    private int id;
    private String title;
    private String mail;
    private String inquiry; // 문의 종류
    private String detail;  // 문의 내용
    private String answer;  // 🔍 [추가] 관리자 답변 내용
}
