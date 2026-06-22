package com.cosmic.library.review.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cosmic.library.review.model.ReviewBookVo;
import com.cosmic.library.review.model.ReviewUserVo;
import com.cosmic.library.review.repository.ReviewDao;

@Service
public class ReviewServiceImple implements ReviewService {

    @Autowired
    private ReviewDao reviewDao;

    @Override
    @Transactional
    public void writeReview(Long bookId, String userId, double rating, String content) {

        // 🔥 이미 리뷰 작성했는지 체크
        int cnt = reviewDao.countUserReview(bookId, userId);

        if (cnt > 0) {
            throw new RuntimeException("ALREADY_REVIEWED");
        }

        // review_book 없으면 생성
        ReviewBookVo exist = reviewDao.findReviewBook(bookId);
        if (exist == null) {
            reviewDao.insertReviewBook(bookId);
        }

        // 리뷰 저장
        ReviewUserVo review = new ReviewUserVo();
        review.setBookid(bookId);
        review.setUserid(userId);
        review.setStar(rating);
        review.setReview(content);

        reviewDao.insertReview(review);

        // 통계 갱신
        double avg = reviewDao.selectAvgStar(bookId);
        int count = reviewDao.selectReviewCount(bookId);

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
    
    
    
    //추가
    
    //수정
    @Override
    @Transactional
    public void updateReview(Long reviewId, double rating, String content, String loginUserId) {

        ReviewUserVo review = reviewDao.findById(reviewId);

        if (!review.getUserid().equals(loginUserId)) {
            throw new RuntimeException("DENY");
        }
        
        reviewDao.updateReview(reviewId, content, rating);

        double avg = reviewDao.selectAvgStar(review.getBookid());
        int count = reviewDao.selectReviewCount(review.getBookid());

        reviewDao.upsertReviewBook(review.getBookid(), avg, count);
    }
    
    //삭제
    @Override
    @Transactional
    public void deleteReview(Long reviewId, String loginUserId) {

        ReviewUserVo review = reviewDao.findById(reviewId);

        if (!review.getUserid().equals(loginUserId)) {
            throw new RuntimeException("DENY");
        }
        
        reviewDao.deleteReview(reviewId);

        double avg = reviewDao.selectAvgStar(review.getBookid());
        int count = reviewDao.selectReviewCount(review.getBookid());

        reviewDao.upsertReviewBook(review.getBookid(), avg, count);
    }
    
    public boolean isUserReviewed(Long bookId, String userId) {
        return reviewDao.checkUserReviewed(bookId, userId) > 0;
    }
    
}