package com.cosmic.library.review.service;

import java.util.List;

import com.cosmic.library.review.model.ReviewBookVo;
import com.cosmic.library.review.model.ReviewUserVo;


public interface ReviewService {


    List<ReviewUserVo> getReviewList(Long bookId);

    ReviewBookVo getReviewSummary(Long bookId);

	void writeReview(Long bookId, String userId, double rating, String content);
}