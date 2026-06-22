package com.cosmic.library.cookie.repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import com.cosmic.library.cookie.model.CookieOrderVO;

@Repository
public class CookiePurchaseRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public int insertCookieOrder(CookieOrderVO cookieOrder) {
        String sql = "INSERT INTO COOKIE_ORDER (NAME, PHONE, ADDRESS, TOTALPRICE, ORDERDATE) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        
        KeyHolder keyHolder = new GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, cookieOrder.getName());
            ps.setString(2, cookieOrder.getPhone());
            ps.setString(3, cookieOrder.getAddress());
            ps.setInt(4, cookieOrder.getTotalPrice() != null ? cookieOrder.getTotalPrice() : 0);
            return ps;
        }, keyHolder);

        // 💡 수정: getKey() 대신 getKeys()를 사용하여 ID 컬럼만 명시적으로 추출
        Map<String, Object> keys = keyHolder.getKeys();
        if (keys != null && keys.containsKey("ID")) {
            return ((Number) keys.get("ID")).intValue();
        } else {
            throw new RuntimeException("주문 ID를 가져오는데 실패했습니다.");
        }
    }
}