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

    // 1. 구매 기록 저장 (주문 완료 시 작동)
    public void save(Purchase purchase) {
        // 컬럼명 member_id ➔ user_reg_num 전면 교체
        String sql = "INSERT INTO purchase "
                + "(user_reg_num, book_id, quantity, price, total_price, status) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        jdbcTemplate.update(
                sql,
                purchase.getUserRegNum(), // 🌟 바뀐 VO의 getter 호출 (int)
                purchase.getBookId(),
                purchase.getQuantity(),
                purchase.getPrice(),
                purchase.getTotalPrice(),
                "ORDERED"
        );
    }
    
    // 2. 대원 고유 활동 번호 기준 구매 기록 조회
    public List<Purchase> findByMemberId(int userRegNum) { // 🌟 파라미터 String ➔ int 변경
        // 쿼리문 내 p.member_id ➔ p.user_reg_num 전면 수정
        String sql = "SELECT p.purchase_id, p.user_reg_num, p.book_id, p.quantity, p.price, " +
                     "p.total_price, p.status, p.purchase_date, b.title, b.image " +
                     "FROM purchase p " +
                     "JOIN book b ON p.book_id = b.id " +
                     "WHERE p.user_reg_num = ? " + // 👈 기지 관제 타겟 변경
                     "ORDER BY p.purchase_date DESC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Purchase p = new Purchase();
            
            // 기본 구매 정보 새 스펙에 맞춰 매핑
            p.setId(rs.getInt("purchase_id"));
            p.setUserRegNum(rs.getInt("user_reg_num")); // 🌟 VO 매핑 동기화
            p.setBookId(rs.getInt("book_id"));
            p.setQuantity(rs.getInt("quantity"));
            p.setPrice(rs.getInt("price"));
            p.setTotalPrice(rs.getInt("total_price"));
            p.setStatus(rs.getString("status"));
            p.setPurchaseDate(rs.getTimestamp("purchase_date"));
            
            // JOIN으로 가져온 도서 정보 매핑
            p.setTitle(rs.getString("title"));
            p.setImage(rs.getString("image"));
            
            return p;
        }, userRegNum);
    }
    
    // 🪐 Vendor 배송 관제 전용 메서드 주입 (오류 원천 차단 버전)
    public List<Purchase> findByVendorRegNum(int vendorRegNum) {
        // [격파 포인트] product_sale에 존재하지 않는 book_id 대신 
        // stock_in(si)을 매개체로 조인하여 징검다리를 완벽하게 연결합니다!
        String sql = 
              "SELECT p.purchase_id, p.user_reg_num, p.book_id, p.quantity, "
            + "       p.price, p.total_price, p.status, p.purchase_date, bk.title, bk.image "
            + "FROM purchase p "
            + "JOIN stock_in si     ON p.book_id = si.book_id "
            + "JOIN product_sale ps ON si.stock_id = ps.stock_id "
            + "JOIN book bk         ON p.book_id = bk.id "
            + "WHERE ps.v_reg_num = ? "
            + "ORDER BY p.purchase_date DESC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Purchase p = new Purchase();
            // rs.getInt 타겟 컬럼명을 SELECT 명세와 정확하게 동기화!
            p.setId(rs.getInt("purchase_id")); 
            p.setUserRegNum(rs.getInt("user_reg_num"));
            p.setBookId(rs.getInt("book_id"));
            p.setQuantity(rs.getInt("quantity"));
            p.setPrice(rs.getInt("price"));
            p.setTotalPrice(rs.getInt("total_price"));
            p.setStatus(rs.getString("status"));
            p.setPurchaseDate(rs.getTimestamp("purchase_date"));
            p.setTitle(rs.getString("title"));
            p.setImage(rs.getString("image"));
            return p;
        }, vendorRegNum);
    }

    // 🪐 [배송하기] 클릭 시 상태 워프 엔진 (ORDERED ➔ SHIPPING)
    public int updateStatus(int purchaseId, String status) {
        String sql = "UPDATE purchase SET status = ? WHERE purchase_id = ?";
        return jdbcTemplate.update(sql, status, purchaseId);
    }
}