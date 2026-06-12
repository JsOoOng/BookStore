package com.cosmic.library.review.controller;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewBook {

    private Long id;
    private Long bookid;
    private double rating;
    private int reviewCount;

    // getter / setter
}