package com.cosmic.library.review.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cosmic.library.review.model.ReviewBookVo;
import com.cosmic.library.review.model.ReviewUserVo;
import com.cosmic.library.review.repository.ReviewDao;

@Service
public class ReviewServiceImple implements ReviewService {

    @Autowired
    private ReviewDao reviewDao;

    @Override
    public void writeReview(Long bookId, String userId, double rating, String content) {

    	// 2. review_book 존재 여부 확인 후 없으면 생성
    	 ReviewBookVo exist = reviewDao.findReviewBook(bookId);
         if(exist == null) {
             reviewDao.insertReviewBook(bookId);
         }
    	
        // 1. ReviewUser 생성 및 저장
        ReviewUserVo review = new ReviewUserVo();
        review.setBookid(bookId);
        review.setUserid(userId);
        review.setStar(rating);
        review.setReview(content);
        reviewDao.insertReview(review);
        

        // 3. 평균/리뷰 수 계산
        double avg = reviewDao.selectAvgStar(bookId);
        int count = reviewDao.selectReviewCount(bookId);

        // 4. review_book 업데이트
        reviewDao.upsertReviewBook(bookId, avg, count);
    }

    @Override
    public List<ReviewUserVo> getReviewList(Long bookId) {
        return reviewDao.selectReviewList(bookId);
    }

    @Override
    public ReviewBookVo getReviewSummary(Long bookId) {
        ReviewBookVo rb = new ReviewBookVo();
        rb.setBookid(bookId);
        rb.setRating(reviewDao.selectAvgStar(bookId));
        rb.setReviewCount(reviewDao.selectReviewCount(bookId));
        return rb;
    }
    
    
}