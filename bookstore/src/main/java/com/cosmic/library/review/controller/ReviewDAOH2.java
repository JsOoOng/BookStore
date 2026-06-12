package com.cosmic.library.review.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ReviewDAOH2 implements ReviewDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public int insertReview(ReviewUser vo) {
        String sql = "INSERT INTO review_user (bookid, userid, review, star) VALUES (?, ?, ?, ?)";
        
        System.out.println("🔥 insertReview 실행");
        System.out.println(sql);
        
        return jdbcTemplate.update(sql,
                vo.getBookid(),
                vo.getUserid(),
                vo.getReview(),
                vo.getStar());
    }
    
    @Override
    public List<ReviewUser> selectReviewList(Long bookid) {

        String sql = "SELECT * FROM review_user WHERE bookid = ? ORDER BY id DESC";

        return jdbcTemplate.query(sql,
                new BeanPropertyRowMapper<>(ReviewUser.class),
                bookid);
    }

    @Override
    public double selectAvgStar(Long bookid) {

        String sql = "SELECT IFNULL(AVG(star),0) FROM review_user WHERE bookid = ?";

        return jdbcTemplate.queryForObject(sql, Double.class, bookid);
    }

    @Override
    public int selectReviewCount(Long bookid) {

        String sql = "SELECT COUNT(*) FROM review_user WHERE bookid = ?";

        return jdbcTemplate.queryForObject(sql, Integer.class, bookid);
    }

    @Override
    public void updateReviewBook(double avg, int count, Long bookid) {

        String sql = "UPDATE review_book SET rating = ?, review_count = ? WHERE bookid = ?";

        jdbcTemplate.update(sql, avg, count, bookid);
    }

    // 🔥 중요: 제거하거나 제대로 구현해야 함
    @Override
    public int updateReviewBook(ReviewBook reviewBook) {
        String sql = "UPDATE review_book SET rating=?, review_count=? WHERE bookid=?";
        return jdbcTemplate.update(sql,
                reviewBook.getRating(),
                reviewBook.getReviewCount(),
                reviewBook.getBookid());
    }

    
    @Override
    public ReviewBook findReviewBook(Long bookid) {
        String sql = "SELECT * FROM review_book WHERE bookid = ?";
        List<ReviewBook> list = jdbcTemplate.query(sql,
                new BeanPropertyRowMapper<>(ReviewBook.class),
                bookid);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public int insertReviewBook(Long bookid) {
        String sql = "INSERT INTO review_book (bookid, rating, review_count) VALUES (?, 0, 0)";
        return jdbcTemplate.update(sql, bookid);
    }
}