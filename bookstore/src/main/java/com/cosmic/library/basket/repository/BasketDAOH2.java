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

    // 🪐 1. 장바구니 전체 조회 (4중 조인 기반 완벽 통합 엔진)
    @Override
    public List<BasketVO> findAll(int userRegNum) {
        String sql = 
            // [A 구역] 순수 도서관 대여 목록 조회 (sale_id가 NULL인 경우)
            "SELECT b.basket_id, b.user_reg_num, b.book_id, b.sale_id, b.qty AS quantity, b.reg_date, "
          + "       bk.title, bk.writer, 0 AS price, bk.image, 'LIBRARY' AS biz_name "
          + "FROM basket b "
          + "JOIN book bk ON b.book_id = bk.id "
          + "WHERE b.user_reg_num = ? AND b.sale_id IS NULL "
          + "UNION ALL "
          // [B 구역] 🪐 오픈마켓 입점 상품 목록 조회 (vr을 거쳐 v.vendor_id까지 완벽 체인 조인!)
          + "SELECT b.basket_id, b.user_reg_num, si.book_id, b.sale_id, b.qty AS quantity, b.reg_date, "
          + "       bk.title, bk.writer, ps.price, bk.image, v.biz_name " // 🌟 v.biz_name 에서 안전하게 업체명 획득!
          + "FROM basket b "
          + "JOIN product_sale ps         ON b.sale_id = ps.sale_id "
          + "JOIN stock_in si             ON ps.stock_id = si.stock_id "
          + "JOIN book bk                 ON si.book_id = bk.id "
          + "JOIN vendor_registration vr  ON ps.v_reg_num = vr.vendor_reg_num " // 1단계: 승인번호로 vr 워프
          + "JOIN vendor v                ON vr.vendor_id = v.vendor_id "       // 2단계: vr의 vendor_id로 v 워프!
          + "WHERE b.user_reg_num = ? AND b.sale_id IS NOT NULL "
          + "ORDER BY reg_date DESC";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            BasketVO vo = new BasketVO();
            vo.setBasketId(rs.getInt("basket_id"));
            vo.setUserRegNum(rs.getInt("user_reg_num"));
            vo.setBookId(rs.getInt("book_id"));
            vo.setSaleId(rs.getInt("sale_id"));
            vo.setBizName(rs.getString("biz_name"));
            vo.setQuantity(rs.getInt("quantity"));
            vo.setRegDate(rs.getString("reg_date"));
            vo.setTitle(rs.getString("title"));
            vo.setWriter(rs.getString("writer"));
            vo.setPrice(rs.getInt("price"));
            vo.setImage(rs.getString("image"));
            return vo;
        }, userRegNum, userRegNum);
    }
    
    // 🪐 2. 선택된 장바구니 항목 상세 조회 (4중 조인 기반 완벽 통합 엔진)
    @Override
    public List<BasketVO> findByIds(int[] basketIds, int userRegNum) {
        if (basketIds == null || basketIds.length == 0) return new java.util.ArrayList<>();

        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < basketIds.length; i++) {
            inClause.append("?");
            if (i < basketIds.length - 1) inClause.append(",");
        }

        String sql = 
            "SELECT b.basket_id, b.user_reg_num, b.book_id, b.sale_id, b.qty AS quantity, b.reg_date, "
          + "       bk.title, bk.writer, 0 AS price, bk.image, 'LIBRARY' AS biz_name "
          + "FROM basket b "
          + "JOIN book bk ON b.book_id = bk.id "
          + "WHERE b.user_reg_num = ? AND b.sale_id IS NULL AND b.basket_id IN (" + inClause + ") "
          + "UNION ALL "
          + "SELECT b.basket_id, b.user_reg_num, si.book_id, b.sale_id, b.qty AS quantity, b.reg_date, "
          + "       bk.title, bk.writer, ps.price, bk.image, v.biz_name " // 🌟 v.biz_name 매핑
          + "FROM basket b "
          + "JOIN product_sale ps         ON b.sale_id = ps.sale_id "
          + "JOIN stock_in si             ON ps.stock_id = si.stock_id "
          + "JOIN book bk                 ON si.book_id = bk.id "
          + "JOIN vendor_registration vr  ON ps.v_reg_num = vr.vendor_reg_num "
          + "JOIN vendor v                ON vr.vendor_id = v.vendor_id "       // 🌟 4중 완벽 체인 조인!
          + "WHERE b.user_reg_num = ? AND b.sale_id IS NOT NULL AND b.basket_id IN (" + inClause + ")";

        Object[] params = new Object[(basketIds.length + 1) * 2];
        int idx = 0;
        
        params[idx++] = userRegNum;
        for (int id : basketIds) params[idx++] = id;
        
        params[idx++] = userRegNum;
        for (int id : basketIds) params[idx++] = id;

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            BasketVO vo = new BasketVO();
            vo.setBasketId(rs.getInt("basket_id"));
            vo.setUserRegNum(rs.getInt("user_reg_num"));
            vo.setBookId(rs.getInt("book_id"));
            try { vo.setSaleId(rs.getInt("sale_id")); } catch(Exception e){}
            try { vo.setBizName(rs.getString("biz_name")); } catch(Exception e){}
            vo.setQuantity(rs.getInt("quantity"));
            vo.setTitle(rs.getString("title"));
            vo.setWriter(rs.getString("writer"));
            vo.setPrice(rs.getInt("price"));
            vo.setImage(rs.getString("image"));
            return vo;
        }, params);
    }

    // 3. 기존 도서 장바구니 추가 오버라이드
    @Override
    public void insert(int userRegNum, int bookId) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM basket WHERE user_reg_num = ? AND book_id = ? AND sale_id IS NULL",
                Integer.class,
                userRegNum, bookId
        );

        if (count != null && count > 0) {
            jdbcTemplate.update(
                    "UPDATE basket SET qty = qty + 1 WHERE user_reg_num = ? AND book_id = ? AND sale_id IS NULL",
                    userRegNum, bookId
            );
        } else {
            jdbcTemplate.update(
                    "INSERT INTO basket (user_reg_num, book_id, qty) VALUES (?, ?, 1)",
                    userRegNum, bookId
            );
        }
    }

    // 4. 단일 제어 삭제
    @Override
    public void deleteById(int basketId, int userRegNum) {
        jdbcTemplate.update(
                "DELETE FROM basket WHERE basket_id = ? AND user_reg_num = ?",
                basketId, userRegNum
        );
    }

    // 5. 다중 선택 삭제
    @Override
    public void deleteByIds(int[] basketIds, int userRegNum) {
        if (basketIds == null || basketIds.length == 0) return;

        StringBuilder sql = new StringBuilder(
                "DELETE FROM basket WHERE user_reg_num = ? AND basket_id IN ("
        );

        for (int i = 0; i < basketIds.length; i++) {
            sql.append("?");
            if (i < basketIds.length - 1) sql.append(",");
        }
        sql.append(")");

        Object[] params = new Object[basketIds.length + 1];
        params[0] = userRegNum;

        for (int i = 0; i < basketIds.length; i++) {
            params[i + 1] = basketIds[i];
        }

        jdbcTemplate.update(sql.toString(), params);
    }

    @Override
    public void buy(int basketId, int userRegNum) {
        deleteById(basketId, userRegNum);
    }

    @Override
    public void buy(int[] basketIds, int userRegNum) {
        deleteByIds(basketIds, userRegNum);
    }

    @Override
    public void delete(int userRegNum, int bookId) {
        String sql = "DELETE FROM basket WHERE user_reg_num = ? AND book_id = ? AND sale_id IS NULL";
        jdbcTemplate.update(sql, userRegNum, bookId);
    }
    
    // 6. 오픈마켓 전용 비동기 추가 엔진
    @Override
    public int insertMarketBasket(int userRegNum, int saleId, int qty) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM basket WHERE user_reg_num = ? AND sale_id = ?",
                Integer.class,
                userRegNum, saleId
        );

        if (count != null && count > 0) {
            return jdbcTemplate.update(
                    "UPDATE basket SET qty = qty + ? WHERE user_reg_num = ? AND sale_id = ?",
                    qty, userRegNum, saleId
            );
        } else {
            String findBookIdSql = 
                  "SELECT si.book_id "
                + "FROM product_sale ps "
                + "JOIN stock_in si ON ps.stock_id = si.stock_id "
                + "WHERE ps.sale_id = ?";
                
            Integer realBookId = jdbcTemplate.queryForObject(findBookIdSql, Integer.class, saleId);
            
            String sql = "INSERT INTO BASKET (user_reg_num, book_id, sale_id, qty, reg_date) "
                       + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
                       
            return jdbcTemplate.update(sql, userRegNum, realBookId, saleId, qty);
        }
    }
    
    @Override
    public int updateQty(int basketId, int userRegNum, int qty) {
        // 네 테이블 컬럼명 스펙에 맞춰 'qty' 자리에 데이터를 꽂아넣습니다!
        String sql = "UPDATE basket SET qty = ? WHERE basket_id = ? AND user_reg_num = ?";
        return jdbcTemplate.update(sql, qty, basketId, userRegNum);
    }
    
 // ==============================================================
    // 🚀 [추가] 장바구니 수량 변경 전 재고 검증용 단일 품목 스캔
    // ==============================================================
    @Override
    public BasketVO findById(int basketId) {
        String sql = "SELECT * FROM basket WHERE basket_id = ?";
        
        try {
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                BasketVO basket = new BasketVO();
                
                basket.setBasketId(rs.getInt("basket_id"));
                basket.setUserRegNum(rs.getInt("user_reg_num"));
                basket.setBookId(rs.getInt("book_id"));
                basket.setQuantity(rs.getInt("qty"));
                
                // 💥 [NULL 완벽 방어] sale_id가 NULL인 대여 도서도 안전하게 매핑!
                Object saleIdObj = rs.getObject("sale_id");
                if (saleIdObj != null) {
                    basket.setSaleId(((Number) saleIdObj).intValue());
                } else {
                    basket.setSaleId(null);
                }
                
                return basket;
            }, basketId);
        } catch (Exception e) {
            System.out.println("🚨 장바구니 품목 추적 실패: " + e.getMessage());
            return null; // 스캔 실패 시 튕겨내기 위한 안전장치
        }
    }
}