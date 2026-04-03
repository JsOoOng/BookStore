package com.cosmic.library.purchase.repository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.cosmic.library.purchase.model.Purchase;

@Repository
public class PurchaseRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void save(Purchase purchase) {

        String sql = "INSERT INTO purchase "
                + "(member_id, book_id, quantity, price, total_price, status) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        jdbcTemplate.update(
                sql,
                purchase.getMemberId(),
                purchase.getBookId(),
                purchase.getQuantity(),
                purchase.getPrice(),
                purchase.getTotalPrice(),
                "ORDERED"
        );
    }
    
    public List<Purchase> findByMemberId(String memberId) {
        // 🛰️ JOIN을 통해 구매 기록과 도서의 제목/이미지를 함께 가져옵니다.
        String sql = "SELECT p.purchase_id, p.member_id, p.book_id, p.quantity, p.price, " +
                     "p.total_price, p.status, p.purchase_date, b.title, b.image " +
                     "FROM purchase p " +
                     "JOIN book b ON p.book_id = b.id " +
                     "WHERE p.member_id = ? " +
                     "ORDER BY p.purchase_date DESC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Purchase p = new Purchase();
            // 기본 구매 정보 매핑
            p.setId(rs.getInt("purchase_id"));
            p.setMemberId(rs.getString("member_id"));
            p.setBookId(rs.getInt("book_id"));
            p.setQuantity(rs.getInt("quantity"));
            p.setPrice(rs.getInt("price"));
            p.setTotalPrice(rs.getInt("total_price"));
            p.setStatus(rs.getString("status"));
            p.setPurchaseDate(rs.getTimestamp("purchase_date"));
            
            // 🔥 JOIN으로 가져온 도서 정보 매핑 (VO에 추가한 필드)
            p.setTitle(rs.getString("title"));
            p.setImage(rs.getString("image"));
            
            return p;
        }, memberId);
    }
}