package com.cosmic.library.review.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewBookVo {

    private Long id;
    private Long bookid;
    private double rating;
    private int reviewCount;

    // getter / setter
}