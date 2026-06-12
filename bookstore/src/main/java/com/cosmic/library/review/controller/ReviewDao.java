package com.cosmic.library.review.controller;

import java.util.List;

public interface ReviewDao {

    int insertReview(ReviewUser review);

    List<ReviewUser> selectReviewList(Long bookid);

    double selectAvgStar(Long bookid);

    int selectReviewCount(Long bookid);

    int updateReviewBook(ReviewBook reviewBook);

    void updateReviewBook(double avg, int count, Long bookid);

    // ✅ 새로 추가
    ReviewBook findReviewBook(Long bookid); // review_book 조회
    int insertReviewBook(Long bookid);      // review_book 새로 생성
}