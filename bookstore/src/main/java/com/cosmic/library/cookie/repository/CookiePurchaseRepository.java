package com.cosmic.library.cookie.repository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.cookie.model.CookieOrderVO;
import com.cosmic.library.cookie.model.GuestOrderVO;

@Repository
public class CookiePurchaseRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 💥 1. GUEST_USER (비회원 원천 정보) 인서트 엔진
    public int insertGuestUser(CookieOrderVO cookieOrder) {
        // 중복 가입 방지를 위해 guest_id가 이미 존재하면 정보만 업데이트(UPSERT) 처리
        String sql = "MERGE INTO GUEST_USER (guest_id, guest_name, guest_phone, address, reg_date) " +
                     "KEY (guest_id) " +
                     "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        
        return jdbcTemplate.update(sql, 
            cookieOrder.getGuestId(), 
            cookieOrder.getName(), 
            cookieOrder.getPhone(), 
            cookieOrder.getAddress()
        );
    }

    // 💥 2. GUEST_PURCHASE (비회원 영수증 마스터) 인서트 엔진
    public int insertCookieOrder(CookieOrderVO cookieOrder) {
        String sql = "INSERT INTO GUEST_PURCHASE (purchase_id, guest_id, total_price, payment_key, status, purchase_date) " +
                     "VALUES (?, ?, ?, ?, 'ORDERED', CURRENT_TIMESTAMP)";
        
        return jdbcTemplate.update(sql, 
            cookieOrder.getPurchaseId(), 
            cookieOrder.getGuestId(), 
            cookieOrder.getTotalPrice(),
            cookieOrder.getPaymentKey()
        );
    }
    
    // 💥 3. GUEST_PURCHASE_DETAIL (비회원 구매 상세 품목) 인서트 엔진
    public int insertCookieOrderDetail(String purchaseId, BasketVO item) {
        // 서브쿼리를 이용해 PRODUCT_SALE 테이블에서 해당 상품의 판매 업체(v_reg_num)를 자동으로 끌고 와서 저장!
        String sql = "INSERT INTO GUEST_PURCHASE_DETAIL (purchase_id, sale_id, v_reg_num, quantity, unit_price, delivery_status) " +
                     "VALUES (?, ?, (SELECT v_reg_num FROM PRODUCT_SALE WHERE sale_id = ?), ?, ?, 'READY')";
        
        return jdbcTemplate.update(sql, 
            purchaseId, 
            item.getSaleId(), 
            item.getSaleId(), // 서브쿼리용 매핑
            item.getQuantity(), 
            item.getPrice()
        );
    }
    
    // 💥 4. 상품 재고(Stock) 차감 엔진 (기존 유지)
    public int decreaseStock(int saleId, int quantity) {
        String sql = "UPDATE PRODUCT_SALE SET stock_qty = stock_qty - ? WHERE sale_id = ?";
        return jdbcTemplate.update(sql, quantity, saleId);
    }
    
    // 💥 5. 업체(Vendor) 대시보드 전용 비회원 주문 목록 추출 엔진
    public List<GuestOrderVO> getVendorGuestOrders(int vendorRegNum) {
        // U: GUEST_USER, P: GUEST_PURCHASE, D: GUEST_PURCHASE_DETAIL, S: PRODUCT_SALE, SI: STOCK_IN, B: BOOK
        // 외래키(FK)를 타고 건너가 도서 제목(TITLE)과 이미지(IMAGE)까지 완벽하게 스캔하는 마스터 조인 쿼리!
        String sql = "SELECT " +
                     "    p.purchase_id AS purchaseId, " +
                     "    d.detail_id AS detailId, " +
                     "    d.sale_id AS saleId, " +
                     "    d.v_reg_num AS vRegNum, " +
                     "    d.quantity AS quantity, " +
                     "    d.unit_price AS unitPrice, " +
                     "    d.delivery_status AS status, " +
                     "    p.purchase_date AS purchaseDate, " +
                     "    u.guest_name AS name, " +
                     "    u.guest_phone AS phone, " +
                     "    u.address AS address, " +
                     "    b.title AS title, " +
                     "    b.image AS image " +
                     "FROM GUEST_PURCHASE p " +
                     "JOIN GUEST_USER u ON p.guest_id = u.guest_id " +
                     "JOIN GUEST_PURCHASE_DETAIL d ON p.purchase_id = d.purchase_id " +
                     "JOIN PRODUCT_SALE s ON d.sale_id = s.sale_id " +
                     "JOIN STOCK_IN si ON s.stock_id = si.stock_id " +
                     "JOIN BOOK b ON si.book_id = b.id " +
                     "WHERE d.v_reg_num = ? " +
                     "ORDER BY p.purchase_date DESC";

        return jdbcTemplate.query(sql, 
            new org.springframework.jdbc.core.BeanPropertyRowMapper<>(GuestOrderVO.class), 
            vendorRegNum);
    }
    
    public List<GuestOrderVO> trackGuestOrder(String purchaseId, String name) {
        String sql = "SELECT " +
                     "    p.purchase_id AS purchaseId, " +
                     "    d.detail_id AS detailId, " +
                     "    d.sale_id AS saleId, " +
                     "    d.v_reg_num AS vRegNum, " +
                     "    d.quantity AS quantity, " +
                     "    d.unit_price AS unitPrice, " +
                     "    d.delivery_status AS status, " +
                     "    p.purchase_date AS purchaseDate, " +
                     "    u.guest_name AS name, " +
                     "    u.guest_phone AS phone, " +
                     "    u.address AS address, " +
                     "    b.title AS title, " +
                     "    b.writer AS writer, " + // 💥 [추가됨] 저자 정보 추가!
                     "    b.image AS image " +
                     "FROM GUEST_PURCHASE p " +
                     "JOIN GUEST_USER u ON p.guest_id = u.guest_id " +
                     "JOIN GUEST_PURCHASE_DETAIL d ON p.purchase_id = d.purchase_id " +
                     "JOIN PRODUCT_SALE s ON d.sale_id = s.sale_id " +
                     "JOIN STOCK_IN si ON s.stock_id = si.stock_id " +
                     "JOIN BOOK b ON si.book_id = b.id " +
                     "WHERE p.purchase_id = ? AND u.guest_name = ? " +
                     "ORDER BY d.detail_id ASC";

        return jdbcTemplate.query(sql, 
            new org.springframework.jdbc.core.BeanPropertyRowMapper<>(GuestOrderVO.class), 
            purchaseId, name);
    }
}