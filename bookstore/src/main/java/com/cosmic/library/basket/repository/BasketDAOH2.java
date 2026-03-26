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
    	String sql = "SELECT b.busket_id, b.member_id, b.book_id, b.quantity, b.reg_date, "
                + "bk.title, bk.writer, bk.price, bk.image "
                + "FROM busket b "
                + "JOIN book bk ON b.book_id = bk.id "
                + "WHERE b.member_id = ? "
                + "ORDER BY b.reg_date DESC";

        return jdbcTemplate.query(sql, new Object[]{memberId}, (rs, rowNum) -> {
            BasketVO vo = new BasketVO();
            vo.setBasketId(rs.getInt("busket_id")); 
            vo.setMemberId(rs.getString("member_id"));
            vo.setBookId(rs.getInt("book_id"));
            vo.setQuantity(rs.getInt("quantity"));
            vo.setRegDate(rs.getString("reg_date"));
            vo.setTitle(rs.getString("title"));
            vo.setWriter(rs.getString("writer"));
            vo.setPrice(rs.getInt("price"));
            vo.setImage(rs.getString("image"));
            return vo;
        });
    }

    // 장바구니에 추가
    @Override
    public void insert(String memberId, int bookId) {

        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM busket WHERE member_id = ? AND book_id = ?",
                new Object[]{memberId, bookId}, Integer.class
        );

        if (count != null && count > 0) {
            jdbcTemplate.update(
                    "UPDATE busket SET quantity = quantity + 1 WHERE member_id = ? AND book_id = ?",
                    memberId, bookId
            );
        } else {
            jdbcTemplate.update(
                    "INSERT INTO busket (member_id, book_id, quantity) VALUES (?, ?, 1)",
                    memberId, bookId
            );
        }
    }

    // 장바구니 항목 삭제 (단일)
    @Override
    public void deleteById(int busketId, String memberId) {
        jdbcTemplate.update(
                "DELETE FROM busket WHERE busket_id = ? AND member_id = ?",
                busketId, memberId
        );
    }

    // 장바구니 항목 삭제 (다중)
    @Override
    public void deleteByIds(int[] busketIds, String memberId) {
        if (busketIds == null || busketIds.length == 0) return;

        StringBuilder sql = new StringBuilder(
                "DELETE FROM busket WHERE member_id = ? AND busket_id IN ("
        );

        for (int i = 0; i < busketIds.length; i++) {
            sql.append("?");
            if (i < busketIds.length - 1) sql.append(",");
        }
        sql.append(")");

        Object[] params = new Object[busketIds.length + 1];
        params[0] = memberId;

        for (int i = 0; i < busketIds.length; i++) {
            params[i + 1] = busketIds[i];
        }

        jdbcTemplate.update(sql.toString(), params);
    }

    // 구매 처리 (단일)
    @Override
    public void buy(int busketId, String memberId) {
        deleteById(busketId, memberId);
    }

    // 구매 처리 (다중)
    @Override
    public void buy(int[] busketIds, String memberId) {
        deleteByIds(busketIds, memberId);
    }
}