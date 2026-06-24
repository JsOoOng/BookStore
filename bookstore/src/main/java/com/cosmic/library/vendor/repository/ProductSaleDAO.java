package com.cosmic.library.vendor.repository;

import java.util.List;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.model.SalesVolumeVO;

public interface ProductSaleDAO {

    // 1. 오픈마켓 신규 판매 상품 등록 (STOCK_IN 기반)
    int insert(ProductSaleVO productSale);

    // 2. 특정 판매 상품 정밀 단건 조회 (상세페이지 및 수정 폼 용)
    ProductSaleVO findById(int saleId);

    // 3. 특정 입점 업체의 실시간 판매 상품 목록 관제 (파트너 대시보드 출력용)
    List<ProductSaleVO> findByVendorRegNum(int vRegNum);

    // 4. 우주 도서관 메인 상점에 뿌려질 전체 판매 상품 목록 (BOOK, VENDOR 조인 쿼리)
    List<ProductSaleVO> findAllWithDetails();

    // 5. 상품 판매가 및 실시간 재고 수량, 판매 상태(ON/OFF) 갱신
    int update(ProductSaleVO productSale);

    // 6. 주문 발생 시 실시간 재고 차감/증감 (트랜잭션 연동용)
    int updateStock(int saleId, int changeQty);

    // 7. 판매 상품 마켓에서 완전 내리기 (삭제)
    int delete(int saleId);
    
    // 🛰️ [신규 관제 오더] 특정 업체의 특정 도서 입고 정보 매핑 확인
    int findStockIdByBookIdAndVendor(int bookId, int vRegNum);
    
    // 🛰️ [신규 관제 오더] 필수 필드(업체번호, 수량, 원가)를 대동한 입고 데이터 빌드
    int insertStockIn(int bookId, int vRegNum, int qty, int cost);
    
    // 📊 업체별 도서 판매량 통계 조회
    List<SalesVolumeVO> selectSalesVolume(int vRegNum, String period);
}