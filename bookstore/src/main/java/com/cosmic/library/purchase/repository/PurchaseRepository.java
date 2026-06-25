package com.cosmic.library.purchase.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import javax.sql.DataSource;

import com.cosmic.library.purchase.model.Purchase;

@Repository
public class PurchaseRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Autowired
    private DataSource dataSource;

    // =========================================================================
    // 🚀 [1단계] 마스터 영수증(PURCHASE) 생성 및 ID 가로채기
    // =========================================================================
    public int insertMaster(int userRegNum, int totalPrice) {
        String sql = "INSERT INTO purchase (user_reg_num, total_price, status, purchase_date) "
                   + "VALUES (?, ?, 'ORDERED', NOW())";
        
        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            // 💥 H2 데이터베이스에게 발급된 PK(purchase_id)를 내놓으라고 강제 지시!
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"PURCHASE_ID"});
            ps.setInt(1, userRegNum);
            ps.setInt(2, totalPrice);
            return ps;
        }, keyHolder);

        // 방금 발급된 따끈따끈한 영수증 번호 반환
        return keyHolder.getKey() != null ? keyHolder.getKey().intValue() : 0;
    }

    // =========================================================================
    // 🚀 [2단계] 영수증 내 세부 품목(PURCHASE_DETAIL) 기록
    // =========================================================================
    public void insertDetail(int purchaseId, int saleId, int vRegNum, int quantity, int unitPrice) {
        String sql = "INSERT INTO PURCHASE_DETAIL (purchase_id, sale_id, v_reg_num, quantity, unit_price, delivery_status) " 
                   + "VALUES (?, ?, ?, ?, ?, 'READY')";
        jdbcTemplate.update(sql, purchaseId, saleId, vRegNum, quantity, unitPrice);
    }

    // =========================================================================
    // 📜 [3단계] 대원(유저) 마이페이지용 구매 기록 조회 (조인 쿼리 전면 개편)
    // =========================================================================
    public List<Purchase> findByMemberId(int userRegNum) {
        // [격파 포인트] 마스터 ➔ 디테일 ➔ 판매상품 ➔ 입고 ➔ 도서까지 완벽하게 이어지는 징검다리!
        String sql = 
              "SELECT p.purchase_id, p.user_reg_num, p.purchase_date, p.total_price AS master_total, "
            + "       pd.sale_id, pd.quantity, pd.unit_price, pd.delivery_status, "
            + "       b.id AS book_id, b.title, b.image "
            + "FROM purchase p "
            + "JOIN PURCHASE_DETAIL pd ON p.purchase_id = pd.purchase_id "
            + "JOIN PRODUCT_SALE ps    ON pd.sale_id = ps.sale_id "
            + "JOIN STOCK_IN si        ON ps.stock_id = si.stock_id "
            + "JOIN BOOK b             ON si.book_id = b.id "
            + "WHERE p.user_reg_num = ? "
            + "ORDER BY p.purchase_date DESC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Purchase p = new Purchase();
            p.setId(rs.getInt("purchase_id"));
            p.setUserRegNum(rs.getInt("user_reg_num"));
            p.setBookId(rs.getInt("book_id")); 
            p.setSaleId(rs.getInt("sale_id")); 
            p.setQuantity(rs.getInt("quantity"));
            p.setPrice(rs.getInt("unit_price"));
            p.setTotalPrice(rs.getInt("unit_price") * rs.getInt("quantity")); // 개별 품목 총액
            p.setStatus(rs.getString("delivery_status")); // 유저에게는 개별 배송 상태를 보여줌
            p.setPurchaseDate(rs.getTimestamp("purchase_date"));
            p.setTitle(rs.getString("title"));
            p.setImage(rs.getString("image"));
            return p;
        }, userRegNum);
    }

    // =========================================================================
    // 🏢 [4단계] 파트너(상점) 대시보드용 주문 긁어오기 (조인 쿼리 전면 개편)
    // =========================================================================
    public List<Purchase> findByVendorRegNum(int vendorRegNum) {
        // [격파 포인트] 특정 상점(v_reg_num)에 들어온 주문만 디테일 테이블에서 필터링!
        String sql = 
              "SELECT p.purchase_id, p.user_reg_num, p.purchase_date, "
            + "       pd.sale_id, pd.quantity, pd.unit_price, pd.delivery_status, "
            + "       b.id AS book_id, b.title, b.image "
            + "FROM PURCHASE_DETAIL pd "
            + "JOIN purchase p         ON pd.purchase_id = p.purchase_id "
            + "JOIN PRODUCT_SALE ps    ON pd.sale_id = ps.sale_id "
            + "JOIN STOCK_IN si        ON ps.stock_id = si.stock_id "
            + "JOIN BOOK b             ON si.book_id = b.id "
            + "WHERE pd.v_reg_num = ? "
            + "ORDER BY p.purchase_date DESC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Purchase p = new Purchase();
            p.setId(rs.getInt("purchase_id"));
            p.setUserRegNum(rs.getInt("user_reg_num"));
            p.setBookId(rs.getInt("book_id"));
            p.setSaleId(rs.getInt("sale_id"));
            p.setQuantity(rs.getInt("quantity"));
            p.setPrice(rs.getInt("unit_price"));
            p.setTotalPrice(rs.getInt("unit_price") * rs.getInt("quantity"));
            p.setStatus(rs.getString("delivery_status"));
            p.setPurchaseDate(rs.getTimestamp("purchase_date"));
            p.setTitle(rs.getString("title"));
            p.setImage(rs.getString("image"));
            return p;
        }, vendorRegNum);
    }

    // =========================================================================
    // 🚚 [5단계] [배송하기] 클릭 시 상태 워프 엔진 (개별 품목의 배송 상태 변경)
    // =========================================================================
    public int updateStatus(int purchaseId, String status) {
        // 마스터의 상태가 아닌, 파트너사가 책임지는 세부 품목(DETAIL)의 배송 상태를 변경!
        String sql = "UPDATE PURCHASE_DETAIL SET delivery_status = ? WHERE purchase_id = ?";
        return jdbcTemplate.update(sql, status, purchaseId);
    }
    
    public Purchase findById(int purchaseId) {

        String sql =
            "SELECT p.PURCHASE_ID, p.USER_REG_NUM, p.PURCHASE_DATE, " +
            "u.EMAIL, u.USER_NAME, u.PHONE " +
            "FROM PURCHASE p " +
            "JOIN cosmic_user u ON p.USER_REG_NUM = u.USER_ID " +
            "WHERE p.PURCHASE_ID = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, purchaseId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                Purchase purchase = new Purchase();

                purchase.setId(rs.getInt("PURCHASE_ID"));
                purchase.setUserRegNum(rs.getInt("USER_REG_NUM"));
                purchase.setPurchaseDate(rs.getTimestamp("PURCHASE_DATE"));

                // 👇 JOIN 결과 주입
                purchase.setEmail(rs.getString("EMAIL"));
                purchase.setUserName(rs.getString("USER_NAME"));
                purchase.setPhone(rs.getString("PHONE"));

                return purchase;
            }

        } catch (Exception e) {
            throw new RuntimeException("purchase 조회 실패", e);
        }

        throw new RuntimeException("purchase 없음: " + purchaseId);
    }

    public String findMemberId(int userRegNum) {
        String sql = "SELECT user_id FROM USER_REGISTRATION WHERE user_reg_num = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userRegNum);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("user_id");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
}