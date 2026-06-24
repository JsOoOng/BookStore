package com.cosmic.library.cookie.repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import com.cosmic.library.cookie.model.CookieOrderVO;
import com.cosmic.library.cookie.model.GuestOrderVO;

@Repository
public class CookiePurchaseRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public int insertCookieOrder(CookieOrderVO cookieOrder) {
        // 1. schema.sql에 정의된 GUEST_ORDER 테이블에 맞게 SQL 수정
        String sql = "INSERT INTO GUEST_ORDER (ORDER_ID, CUSTOMER_NAME, CUSTOMER_PHONE, ADDRESS, TOTAL_PRICE, REGDATE) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        
        // 2. 이미 서비스단에서 생성한 G17822... 주문번호를 사용합니다.
        // KeyHolder가 필요 없는 구조입니다 (PK를 이미 자바에서 생성했으므로).
        int result = jdbcTemplate.update(sql, 
            cookieOrder.getOrderId(), 
            cookieOrder.getName(), 
            cookieOrder.getPhone(), 
            cookieOrder.getAddress(), 
            cookieOrder.getTotalPrice()
        );
        
        return result; // 저장된 행의 개수(1) 반환
    }
    
 // 비회원 주문 상세 내역 저장 (데이터베이스에 입력된 행의 개수를 반환)
    public int insertCookieOrderDetail(String orderId, com.cosmic.library.basket.model.BasketVO item) {
        // 테이블명을 GUEST_ORDER_DETAIL로 수정 (이전 논의된 내용)
        String sql = "INSERT INTO GUEST_ORDER_DETAIL (order_id, sale_id, qty, price) VALUES (?, ?, ?, ?)";
        
        return jdbcTemplate.update(sql, 
            orderId, 
            item.getSaleId(), 
            item.getQuantity(), 
            item.getPrice()
        );
    }
    
    public int decreaseStock(int saleId, int quantity) {
        String sql = "UPDATE PRODUCT_SALE SET stock_qty = stock_qty - ? WHERE sale_id = ?";
        return jdbcTemplate.update(sql, quantity, saleId);
    }
    
    public List<GuestOrderVO> getVendorGuestOrders(int vendorRegNum) {
        // O: GUEST_ORDER, D: GUEST_ORDER_DETAIL, S: PRODUCT_SALE
        String sql = "SELECT o.ORDER_ID AS id, o.CUSTOMER_NAME AS name, o.CUSTOMER_PHONE AS phone, " +
                     "o.ADDRESS, o.TOTAL_PRICE AS totalPrice, o.DELIVERY_STATUS AS status, " +
                     "o.REGDATE AS purchaseDate, d.QTY AS quantity, s.TITLE " +
                     "FROM GUEST_ORDER o " +
                     "JOIN GUEST_ORDER_DETAIL d ON o.ORDER_ID = d.ORDER_ID " +
                     "JOIN PRODUCT_SALE s ON d.SALE_ID = s.SALE_ID " +
                     "WHERE s.VENDOR_REG_NUM = ? " +
                     "ORDER BY o.REGDATE DESC";

        return jdbcTemplate.query(sql, 
            new org.springframework.jdbc.core.BeanPropertyRowMapper<>(GuestOrderVO.class), 
            vendorRegNum);
    }
}