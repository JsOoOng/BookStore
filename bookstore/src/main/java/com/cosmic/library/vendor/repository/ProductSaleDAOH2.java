package com.cosmic.library.vendor.repository;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.model.SalesVolumeVO;

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
    
    // 1. 특정 업체의 도서가 이미 입고 테이블에 존재하는지 정밀 스캔
    @Override
    public int findStockIdByBookIdAndVendor(int bookId, int vRegNum) {
        String sql = "SELECT stock_id FROM STOCK_IN WHERE book_id = ? AND v_reg_num = ? LIMIT 1";
        try {
            return jdbcTemplate.queryForObject(sql, Integer.class, bookId, vRegNum);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return 0; // 데이터 파편 없음
        }
    }

    // 2. 💥 핵심 진압: 모든 NOT NULL 제약조건을 우회하는 대형 삽입 쿼리 및 PK 가로채기
    @Override
    public int insertStockIn(int bookId, int vRegNum, int qty, int cost) {
        String sql = "INSERT INTO STOCK_IN (book_id, v_reg_num, qty, cost) VALUES (?, ?, ?, ?)";
        
        org.springframework.jdbc.support.GeneratedKeyHolder keyHolder = new org.springframework.jdbc.support.GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            // 🎯 수정 포인트: RETURN_GENERATED_KEYS 대신 반환받을 컬럼명을 정확히 명시!
            // 이렇게 하면 H2가 REGDATE를 던지지 않고 오직 STOCK_ID만 반환한다.
            java.sql.PreparedStatement ps = connection.prepareStatement(sql, new String[] {"STOCK_ID"});
            ps.setInt(1, bookId);
            ps.setInt(2, vRegNum);
            ps.setInt(3, qty);
            ps.setInt(4, cost);
            return ps;
        }, keyHolder);
        
        // 🎯 이제 키가 무조건 1개만 반환되므로 기존 코드가 완벽하게 작동한다!
        return (keyHolder.getKey() != null) ? keyHolder.getKey().intValue() : 0;
    }
    
 // 📊 실제 판매량 통계 조회 - PURCHASE_DETAIL.quantity 기준
    @Override
    public List<SalesVolumeVO> selectSalesVolume(int vRegNum, String period) {

        String dateColumn = "p.purchase_date";
        String keyExpr;
        String labelExpr;

        switch (period) {
            case "day":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-dd')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-dd')";
                break;

            case "week":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-ww')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy') || '-' || FORMATDATETIME(" + dateColumn + ", 'ww') || '주'";
                break;

            case "month":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM')";
                break;

            case "year":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy')";
                break;

            case "hour":
            default:
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'HH')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'HH') || '시'";
                break;
        }

        String sql =
            "SELECT " + keyExpr + " AS sort_key, " +
            labelExpr + " AS label, " +
            "COALESCE(SUM(pd.quantity), 0) AS total_qty " +
            "FROM PURCHASE_DETAIL pd " +
            "JOIN purchase p ON pd.purchase_id = p.purchase_id " +
            "WHERE pd.v_reg_num = ? " +
            "GROUP BY " + keyExpr + ", " + labelExpr + " " +
            "ORDER BY sort_key";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            SalesVolumeVO vo = new SalesVolumeVO();
            vo.setLabel(rs.getString("label"));
            vo.setTotalQty(rs.getInt("total_qty"));
            return vo;
        }, vRegNum);
    }
    
 // 📊 관리자용 전체 판매량 통계 조회 - 모든 업체 기준
    @Override
    public List<SalesVolumeVO> selectAdminSalesVolume(String period) {

        String dateColumn = "p.purchase_date";
        String keyExpr;
        String labelExpr;

        switch (period) {
            case "day":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-dd')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-dd')";
                break;

            case "week":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-ww')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy') || '-' || FORMATDATETIME(" + dateColumn + ", 'ww') || '주'";
                break;

            case "month":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM')";
                break;

            case "year":
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy')";
                break;

            case "hour":
            default:
                keyExpr = "FORMATDATETIME(" + dateColumn + ", 'HH')";
                labelExpr = "FORMATDATETIME(" + dateColumn + ", 'HH') || '시'";
                break;
        }

        String sql =
            "SELECT " + keyExpr + " AS sort_key, " +
            labelExpr + " AS label, " +
            "COALESCE(SUM(pd.quantity), 0) AS total_qty " +
            "FROM PURCHASE_DETAIL pd " +
            "JOIN purchase p ON pd.purchase_id = p.purchase_id " +
            "GROUP BY " + keyExpr + ", " + labelExpr + " " +
            "ORDER BY sort_key";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            SalesVolumeVO vo = new SalesVolumeVO();
            vo.setLabel(rs.getString("label"));
            vo.setTotalQty(rs.getInt("total_qty"));
            return vo;
        });
    }
}