package com.cosmic.library.review.controller;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewUser {

    private Long id;
    private Long bookid;
    private String userid;
    private String review;
    private double star;

    // getter / setter
}