package com.cosmic.library.review.controller;

import java.util.List;


public interface ReviewService {


    List<ReviewUser> getReviewList(Long bookId);

    ReviewBook getReviewSummary(Long bookId);

	void writeReview(Long bookId, String userId, double rating, String content);
}