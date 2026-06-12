package com.cosmic.library.review.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewUserVo {

    private Long id;
    private Long bookid;
    private String userid;
    private String review;
    private double star;

    // getter / setter
}