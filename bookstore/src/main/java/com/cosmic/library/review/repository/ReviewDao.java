package com.cosmic.library.review.repository;

import java.util.List;

import com.cosmic.library.review.model.ReviewBookVo;
import com.cosmic.library.review.model.ReviewUserVo;

public interface ReviewDao {

    int insertReview(ReviewUserVo review);

    List<ReviewUserVo> selectReviewList(Long bookid);

    double selectAvgStar(Long bookid);

    int selectReviewCount(Long bookid);

    int updateReviewBook(ReviewBookVo reviewBook);

    void updateReviewBook(double avg, int count, Long bookid);

    // ✅ 새로 추가
    ReviewBookVo findReviewBook(Long bookid); // review_book 조회
    int insertReviewBook(Long bookid);      // review_book 새로 생성

	void upsertReviewBook(Long bookid, double avg, int count);
}