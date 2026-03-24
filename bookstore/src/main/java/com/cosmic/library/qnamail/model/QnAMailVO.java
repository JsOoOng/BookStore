package com.cosmic.library.qnamail.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class QnAMailVO {
	
	int id;
	String title;
	String mail;
	String inquiry;
	String detail;
	
}
