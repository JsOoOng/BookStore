package com.cosmic.library.basket.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.cosmic.library.basket.model.BasketVO;

import java.util.List;

@Repository
public class BasketDAOH2 implements BasketDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 회원 기준 장바구니 조회
    @Override
    public List<BasketVO> findAll(String memberId) {

        String sql = "SELECT b.basket_id, b.member_id, b.book_id, b.quantity, b.reg_date, "
                + "bk.title, bk.writer, bk.price, bk.image "
                + "FROM basket b "
                + "JOIN book bk ON b.book_id = bk.id "
                + "WHERE b.member_id = ? "
                + "ORDER BY b.reg_date DESC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            BasketVO vo = new BasketVO();
            vo.setBasketId(rs.getInt("basket_id"));
            vo.setMemberId(rs.getString("member_id"));
            vo.setBookId(rs.getInt("book_id"));
            vo.setQuantity(rs.getInt("quantity"));
            vo.setRegDate(rs.getString("reg_date"));
            vo.setTitle(rs.getString("title"));
            vo.setWriter(rs.getString("writer"));
            vo.setPrice(rs.getInt("price"));
            vo.setImage(rs.getString("image"));
            return vo;
        }, memberId);
    }

    // 장바구니 추가
    @Override
    public void insert(String memberId, int bookId) {

        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM basket WHERE member_id = ? AND book_id = ?",
                Integer.class,
                memberId, bookId
        );

        if (count != null && count > 0) {
            jdbcTemplate.update(
                    "UPDATE basket SET quantity = quantity + 1 WHERE member_id = ? AND book_id = ?",
                    memberId, bookId
            );
        } else {
            jdbcTemplate.update(
                    "INSERT INTO basket (member_id, book_id, quantity) VALUES (?, ?, 1)",
                    memberId, bookId
            );
        }
    }

    // 단일 삭제
    @Override
    public void deleteById(int basketId, String memberId) {
        jdbcTemplate.update(
                "DELETE FROM basket WHERE basket_id = ? AND member_id = ?",
                basketId, memberId
        );
    }

    // 다중 삭제
    @Override
    public void deleteByIds(int[] basketIds, String memberId) {

        if (basketIds == null || basketIds.length == 0) return;

        StringBuilder sql = new StringBuilder(
                "DELETE FROM basket WHERE member_id = ? AND basket_id IN ("
        );

        for (int i = 0; i < basketIds.length; i++) {
            sql.append("?");
            if (i < basketIds.length - 1) {
                sql.append(",");
            }
        }
        sql.append(")");

        Object[] params = new Object[basketIds.length + 1];
        params[0] = memberId;

        for (int i = 0; i < basketIds.length; i++) {
            params[i + 1] = basketIds[i];
        }

        jdbcTemplate.update(sql.toString(), params);
    }

    // 구매 처리 (단일)
    @Override
    public void buy(int basketId, String memberId) {
        deleteById(basketId, memberId);
    }

    // 구매 처리 (다중)
    @Override
    public void buy(int[] basketIds, String memberId) {
        deleteByIds(basketIds, memberId);
    }

    // book 기준 삭제
    @Override
    public void delete(String memberId, int bookId) {

        String sql = "DELETE FROM basket WHERE member_id = ? AND book_id = ?";

        jdbcTemplate.update(sql, memberId, bookId);
    }
}