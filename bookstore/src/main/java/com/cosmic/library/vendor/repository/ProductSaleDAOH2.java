package com.cosmic.library.vendor.repository;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import com.cosmic.library.vendor.model.ProductSaleVO;

@Repository
public class ProductSaleDAOH2 implements ProductSaleDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 🌟 복합 조인 쿼리 결과를 자바 VO에 완벽 매핑하는 마스터 RowMapper
    private final RowMapper<ProductSaleVO> rowMapper = (rs, rowNum) -> {
        ProductSaleVO vo = new ProductSaleVO();
        
        // 1. PRODUCT_SALE 순수 컬럼 매핑
        vo.setSaleId(rs.getInt("sale_id"));
        vo.setStockId(rs.getInt("stock_id"));
        vo.setVRegNum(rs.getInt("v_reg_num"));
        vo.setPrice(rs.getInt("price"));
        vo.setStockQty(rs.getInt("stock_qty"));
        vo.setSaleStatus(rs.getString("sale_status"));
        vo.setRegDate(rs.getTimestamp("regDate"));
        
        // 2. 조인 결과로 획득한 부가 데이터 매핑 (존재할 때만 매핑되도록 방어막 형성)
        try { vo.setBookId(rs.getInt("book_id")); } catch (Exception e) {}
        try { vo.setTitle(rs.getString("title")); } catch (Exception e) {}
        try { vo.setWriter(rs.getString("writer")); } catch (Exception e) {}
        try { vo.setPublisher(rs.getString("publisher")); } catch (Exception e) {}
        try { vo.setImage(rs.getString("image")); } catch (Exception e) {}
        try { vo.setBizName(rs.getString("biz_name")); } catch (Exception e) {}
        
        return vo;
    };

    // 1. 오픈마켓 신규 판매 상품 등록
    @Override
    public int insert(ProductSaleVO productSale) {
        String sql = "INSERT INTO PRODUCT_SALE (stock_id, v_reg_num, price, stock_qty, sale_status) "
                   + "VALUES (?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql,
                productSale.getStockId(),
                productSale.getVRegNum(),
                productSale.getPrice(),
                productSale.getStockQty(),
                productSale.getSaleStatus());
    }

    // 2. 특정 판매 상품 정밀 단건 조회
    @Override
    public ProductSaleVO findById(int saleId) {
        String sql = "SELECT ps.*, si.book_id, b.title, b.writer, b.publisher, b.image, v.biz_name "
                   + "FROM PRODUCT_SALE ps "
                   + "JOIN STOCK_IN si ON ps.stock_id = si.stock_id "
                   + "JOIN BOOK b ON si.book_id = b.id "
                   + "JOIN VENDOR_REGISTRATION vr ON ps.v_reg_num = vr.vendor_reg_num "
                   + "JOIN VENDOR v ON vr.vendor_id = v.vendor_id "
                   + "WHERE ps.sale_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, saleId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    // 3. 특정 입점 업체의 실시간 판매 상품 목록 관제 (대시보드 전용)
    @Override
    public List<ProductSaleVO> findByVendorRegNum(int vRegNum) {
        String sql = "SELECT ps.*, si.book_id, b.title, b.writer, b.publisher, b.image, v.biz_name "
                   + "FROM PRODUCT_SALE ps "
                   + "JOIN STOCK_IN si ON ps.stock_id = si.stock_id "
                   + "JOIN BOOK b ON si.book_id = b.id "
                   + "JOIN VENDOR_REGISTRATION vr ON ps.v_reg_num = vr.vendor_reg_num "
                   + "JOIN VENDOR v ON vr.vendor_id = v.vendor_id "
                   + "WHERE ps.v_reg_num = ? "
                   + "ORDER BY ps.regDate DESC";
        return jdbcTemplate.query(sql, rowMapper, vRegNum);
    }

    // 4. 우주 도서관 메인 상점에 뿌려질 전체 판매 상품 목록 (소비자 쇼핑몰 뷰)
    @Override
    public List<ProductSaleVO> findAllWithDetails() {
        String sql = "SELECT ps.*, si.book_id, b.title, b.writer, b.publisher, b.image, v.biz_name "
                   + "FROM PRODUCT_SALE ps "
                   + "JOIN STOCK_IN si ON ps.stock_id = si.stock_id "
                   + "JOIN BOOK b ON si.book_id = b.id "
                   + "JOIN VENDOR_REGISTRATION vr ON ps.v_reg_num = vr.vendor_reg_num "
                   + "JOIN VENDOR v ON vr.vendor_id = v.vendor_id "
                   + "WHERE ps.sale_status = 'ON' AND ps.stock_qty > 0 "
                   + "ORDER BY ps.regDate DESC";
        return jdbcTemplate.query(sql, rowMapper);
    }

    // 5. 상품 판매가, 재고 수량, 판매 상태(ON/OFF) 갱신
    @Override
    public int update(ProductSaleVO productSale) {
        String sql = "UPDATE PRODUCT_SALE SET price = ?, stock_qty = ?, sale_status = ? WHERE sale_id = ?";
        return jdbcTemplate.update(sql,
                productSale.getPrice(),
                productSale.getStockQty(),
                productSale.getSaleStatus(),
                productSale.getSaleId());
    }

    // 6. 주문 발생 시 실시간 재고 차감/증감 (changeQty가 음수면 차감, 양수면 복구)
    @Override
    public int updateStock(int saleId, int changeQty) {
        String sql = "UPDATE PRODUCT_SALE SET stock_qty = stock_qty + ? WHERE sale_id = ?";
        return jdbcTemplate.update(sql, changeQty, saleId);
    }

    // 7. 판매 상품 마켓에서 완전 내리기 (삭제)
    @Override
    public int delete(int saleId) {
        String sql = "DELETE FROM PRODUCT_SALE WHERE sale_id = ?";
        return jdbcTemplate.update(sql, saleId);
    }
}