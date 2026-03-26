package com.cosmic.library.purchase.repository;

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
}