package com.cosmic.library.vendor.repository;

import java.util.List;
import java.util.ArrayList;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.model.SalesVolumeVO;
import com.cosmic.library.statistics.model.SalesSummaryVO;
import com.cosmic.library.statistics.model.SalesTrendVO;
import com.cosmic.library.statistics.model.SoldProductVO;
import com.cosmic.library.statistics.model.VendorOptionVO;
import com.cosmic.library.statistics.model.SalesCompareTrendVO;

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
    
	 // =========================================================================
	 // 📊 공통 판매 통계 메서드
	 // admin / vendor 공용
	 // =========================================================================
	
	 @Override
	 public SalesSummaryVO selectSalesSummary(String startDate, String endDate, Integer vRegNum) {
	
	     StringBuilder sql = new StringBuilder();
	
	     sql.append("SELECT ");
	     sql.append("COALESCE(SUM(pd.quantity * pd.unit_price), 0) AS total_revenue, ");
	     sql.append("COUNT(DISTINCT pd.purchase_id) AS order_count, ");
	     sql.append("COALESCE(SUM(pd.quantity), 0) AS total_book_qty, ");
	     sql.append("COUNT(DISTINCT pd.v_reg_num) AS vendor_count, ");
	     sql.append("COUNT(DISTINCT pd.sale_id) AS product_type_count ");
	     sql.append("FROM PURCHASE_DETAIL pd ");
	     sql.append("JOIN purchase p ON pd.purchase_id = p.purchase_id ");
	     sql.append("WHERE p.purchase_date >= CAST(? AS TIMESTAMP) ");
	     sql.append("AND p.purchase_date < DATEADD('DAY', 1, CAST(? AS DATE)) ");
	
	     List<Object> params = new ArrayList<>();
	     params.add(startDate);
	     params.add(endDate);
	
	     if (vRegNum != null && vRegNum > 0) {
	         sql.append("AND pd.v_reg_num = ? ");
	         params.add(vRegNum);
	     }
	
	     return jdbcTemplate.queryForObject(sql.toString(), (rs, rowNum) -> {
	         SalesSummaryVO vo = new SalesSummaryVO();
	
	         long totalRevenue = rs.getLong("total_revenue");
	         int orderCount = rs.getInt("order_count");
	
	         vo.setTotalRevenue(totalRevenue);
	         vo.setOrderCount(orderCount);
	         vo.setTotalBookQty(rs.getInt("total_book_qty"));
	         vo.setVendorCount(rs.getInt("vendor_count"));
	         vo.setProductTypeCount(rs.getInt("product_type_count"));
	
	         if (orderCount > 0) {
	             vo.setAvgOrderPrice(totalRevenue / orderCount);
	         } else {
	             vo.setAvgOrderPrice(0);
	         }
	
	         return vo;
	     }, params.toArray());
	 }
	
	
	 @Override
	 public List<SalesTrendVO> selectSalesTrend(String period, String startDate, String endDate, Integer vRegNum) {
	
	     String dateColumn = "p.purchase_date";
	     String keyExpr;
	     String labelExpr;
	
	     switch (period) {
	     case "week":
	         // 예: 2026년 8월 1주차
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-W')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy년 M월 W주차')";
	         break;

	     case "month":
	         // 예: 2026년 8월
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy년 M월')";
	         break;

	     case "year":
	         // 예: 2026년
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy년')";
	         break;

	     case "day":
	     default:
	         // 예: 8월 10일
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-dd')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'M월 d일')";
	         break;
	 }
	
	     StringBuilder sql = new StringBuilder();
	
	     sql.append("SELECT ");
	     sql.append(keyExpr).append(" AS sort_key, ");
	     sql.append(labelExpr).append(" AS label, ");
	     sql.append("COALESCE(SUM(pd.quantity * pd.unit_price), 0) AS total_revenue, ");
	     sql.append("COUNT(DISTINCT pd.purchase_id) AS order_count, ");
	     sql.append("COALESCE(SUM(pd.quantity), 0) AS total_book_qty, ");
	     sql.append("COUNT(DISTINCT pd.v_reg_num) AS vendor_count ");
	     sql.append("FROM PURCHASE_DETAIL pd ");
	     sql.append("JOIN purchase p ON pd.purchase_id = p.purchase_id ");
	     sql.append("WHERE p.purchase_date >= CAST(? AS TIMESTAMP) ");
	     sql.append("AND p.purchase_date < DATEADD('DAY', 1, CAST(? AS DATE)) ");
	
	     List<Object> params = new ArrayList<>();
	     params.add(startDate);
	     params.add(endDate);
	
	     if (vRegNum != null && vRegNum > 0) {
	         sql.append("AND pd.v_reg_num = ? ");
	         params.add(vRegNum);
	     }
	
	     sql.append("GROUP BY ").append(keyExpr).append(", ").append(labelExpr).append(" ");
	     sql.append("ORDER BY sort_key");
	
	     return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
	         SalesTrendVO vo = new SalesTrendVO();
	
	         vo.setLabel(rs.getString("label"));
	         vo.setTotalRevenue(rs.getLong("total_revenue"));
	         vo.setOrderCount(rs.getInt("order_count"));
	         vo.setTotalBookQty(rs.getInt("total_book_qty"));
	         vo.setVendorCount(rs.getInt("vendor_count"));
	
	         return vo;
	     }, params.toArray());
	 }
	
	
	 @Override
	 public List<SoldProductVO> selectSoldProducts(String startDate, String endDate, Integer vRegNum) {

	     StringBuilder sql = new StringBuilder();

	     sql.append("SELECT ");
	     sql.append("FORMATDATETIME(p.purchase_date, 'yyyy-MM-dd') AS sale_date, ");
	     sql.append("ps.sale_id AS sale_id, ");
	     sql.append("si.book_id AS book_id, ");
	     sql.append("b.title AS book_title, ");
	     sql.append("pd.v_reg_num AS v_reg_num, ");
	     sql.append("v.biz_name AS vendor_name, ");
	     sql.append("COALESCE(SUM(pd.quantity), 0) AS total_qty, ");
	     sql.append("COALESCE(SUM(pd.quantity * pd.unit_price), 0) AS total_revenue, ");
	     sql.append("COUNT(DISTINCT pd.purchase_id) AS order_count ");
	     sql.append("FROM PURCHASE_DETAIL pd ");
	     sql.append("JOIN purchase p ON pd.purchase_id = p.purchase_id ");
	     sql.append("JOIN PRODUCT_SALE ps ON pd.sale_id = ps.sale_id ");
	     sql.append("JOIN STOCK_IN si ON ps.stock_id = si.stock_id ");
	     sql.append("JOIN BOOK b ON si.book_id = b.id ");
	     sql.append("JOIN VENDOR_REGISTRATION vr ON pd.v_reg_num = vr.vendor_reg_num ");
	     sql.append("JOIN VENDOR v ON vr.vendor_id = v.vendor_id ");
	     sql.append("WHERE p.purchase_date >= CAST(? AS TIMESTAMP) ");
	     sql.append("AND p.purchase_date < DATEADD('DAY', 1, CAST(? AS DATE)) ");

	     List<Object> params = new ArrayList<>();
	     params.add(startDate);
	     params.add(endDate);

	     if (vRegNum != null && vRegNum > 0) {
	         sql.append("AND pd.v_reg_num = ? ");
	         params.add(vRegNum);
	     }

	     sql.append("GROUP BY ");
	     sql.append("FORMATDATETIME(p.purchase_date, 'yyyy-MM-dd'), ");
	     sql.append("ps.sale_id, si.book_id, b.title, pd.v_reg_num, v.biz_name ");

	     sql.append("ORDER BY sale_date DESC, total_revenue DESC");

	     return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
	         SoldProductVO vo = new SoldProductVO();

	         vo.setSaleDate(rs.getString("sale_date"));
	         vo.setSaleId(rs.getInt("sale_id"));
	         vo.setBookId(rs.getInt("book_id"));
	         vo.setBookTitle(rs.getString("book_title"));
	         vo.setVRegNum(rs.getInt("v_reg_num"));
	         vo.setVendorName(rs.getString("vendor_name"));
	         vo.setTotalQty(rs.getInt("total_qty"));
	         vo.setTotalRevenue(rs.getLong("total_revenue"));
	         vo.setOrderCount(rs.getInt("order_count"));

	         return vo;
	     }, params.toArray());
	 }
	
	
	 @Override
	 public List<VendorOptionVO> selectVendorOptions() {

	     String sql =
	         "SELECT " +
	         "vr.vendor_reg_num AS v_reg_num, " +
	         "v.biz_name AS vendor_name " +
	         "FROM VENDOR_REGISTRATION vr " +
	         "JOIN VENDOR v ON vr.vendor_id = v.vendor_id " +
	         "WHERE vr.is_active = 1 " +
	         "ORDER BY vr.vendor_reg_num";

	     return jdbcTemplate.query(sql, (rs, rowNum) -> {
	         VendorOptionVO vo = new VendorOptionVO();

	         vo.setVRegNum(rs.getInt("v_reg_num"));
	         vo.setVendorName(rs.getString("vendor_name"));

	         return vo;
	     });
	 }
	
	
	 @Override
	 public List<SalesCompareTrendVO> selectSalesCompareTrend(
	         String period,
	         String startDate,
	         String endDate,
	         String metric,
	         int vendorA,
	         int vendorB) {
	
	     String dateColumn = "p.purchase_date";
	     String keyExpr;
	     String labelExpr;
	
	     switch (period) {
	     case "week":
	         // 예: 2026년 8월 1주차
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-W')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy년 M월 W주차')";
	         break;

	     case "month":
	         // 예: 2026년 8월
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy년 M월')";
	         break;

	     case "year":
	         // 예: 2026년
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy년')";
	         break;

	     case "day":
	     default:
	         // 예: 8월 10일
	         keyExpr = "FORMATDATETIME(" + dateColumn + ", 'yyyy-MM-dd')";
	         labelExpr = "FORMATDATETIME(" + dateColumn + ", 'M월 d일')";
	         break;
	 }
	
	     String vendorAExpr = getCompareMetricExpression(metric);
	     String vendorBExpr = getCompareMetricExpression(metric);
	
	     String sql =
	         "SELECT " +
	         keyExpr + " AS sort_key, " +
	         labelExpr + " AS label, " +
	         vendorAExpr + " AS vendor_a_value, " +
	         vendorBExpr + " AS vendor_b_value " +
	         "FROM PURCHASE_DETAIL pd " +
	         "JOIN purchase p ON pd.purchase_id = p.purchase_id " +
	         "WHERE p.purchase_date >= CAST(? AS TIMESTAMP) " +
	         "AND p.purchase_date < DATEADD('DAY', 1, CAST(? AS DATE)) " +
	         "AND pd.v_reg_num IN (?, ?) " +
	         "GROUP BY " + keyExpr + ", " + labelExpr + " " +
	         "ORDER BY sort_key";
	
	     return jdbcTemplate.query(sql, (rs, rowNum) -> {
	         SalesCompareTrendVO vo = new SalesCompareTrendVO();
	
	         vo.setLabel(rs.getString("label"));
	         vo.setVendorAValue(rs.getLong("vendor_a_value"));
	         vo.setVendorBValue(rs.getLong("vendor_b_value"));
	
	         return vo;
	     }, vendorA, vendorB, startDate, endDate, vendorA, vendorB);
	 }
	
	
	 /**
	  * 두 회사 비교 그래프에서 선택한 metric에 따라 집계식을 결정한다.
	  * SQL Injection 방지를 위해 metric 문자열을 SQL에 직접 넣지 않고 switch로 제한한다.
	  */
	 private String getCompareMetricExpression(String metric) {
	
	     if ("orderCount".equals(metric)) {
	         return "COUNT(DISTINCT CASE WHEN pd.v_reg_num = ? THEN pd.purchase_id ELSE NULL END)";
	     }
	
	     if ("totalBookQty".equals(metric)) {
	         return "COALESCE(SUM(CASE WHEN pd.v_reg_num = ? THEN pd.quantity ELSE 0 END), 0)";
	     }
	
	     if ("vendorCount".equals(metric)) {
	         return "COUNT(DISTINCT CASE WHEN pd.v_reg_num = ? THEN pd.v_reg_num ELSE NULL END)";
	     }
	
	     if ("productTypeCount".equals(metric)) {
	         return "COUNT(DISTINCT CASE WHEN pd.v_reg_num = ? THEN pd.sale_id ELSE NULL END)";
	     }
	
	     // 기본값: 매출액
	     return "COALESCE(SUM(CASE WHEN pd.v_reg_num = ? THEN pd.quantity * pd.unit_price ELSE 0 END), 0)";
	 }
	 
	 @Override
	 public Integer selectVRegNumByVendorId(String vendorId) {

	     String sql =
	         "SELECT vendor_reg_num " +
	         "FROM VENDOR_REGISTRATION " +
	         "WHERE vendor_id = ? " +
	         "AND is_active = 1";

	     List<Integer> result = jdbcTemplate.query(
	             sql,
	             (rs, rowNum) -> rs.getInt("vendor_reg_num"),
	             vendorId
	     );

	     if (result.isEmpty()) {
	         return null;
	     }

	     return result.get(0);
	 }
}