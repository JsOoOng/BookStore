package com.cosmic.library.vendor.service;

import java.util.List;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.model.SalesVolumeVO;
import com.cosmic.library.statistics.model.SalesSummaryVO;
import com.cosmic.library.statistics.model.SalesTrendVO;
import com.cosmic.library.statistics.model.SoldProductVO;
import com.cosmic.library.statistics.model.VendorOptionVO;
import com.cosmic.library.statistics.model.SalesCompareTrendVO;

public interface ProductSaleService {
    
    // 1. 신규 판매 상품 시장에 등록
    boolean registerProduct(ProductSaleVO productSale);
    
    // 2. 특정 판매 상품 단건 상세 조회
    ProductSaleVO getProductById(int saleId);
    
    // 3. 특정 입점 업체의 등록 상품 전체 조회
    List<ProductSaleVO> getProductsByVendor(int vRegNum);
    
    // 4. 메인 오픈마켓 상점용 전체 상품 리스트
    List<ProductSaleVO> getAllMarketProducts();
    
    // 5. 상품 정보(가격, 재고, 상태) 수정
    boolean modifyProduct(ProductSaleVO productSale);
    
    // 6. 마켓에서 상품 완전 삭제
    boolean removeProduct(int saleId);
    
    // 🛰️ 관제 통신망 추가
    int findStockIdByBookIdAndVendor(int bookId, int vRegNum);
    int insertStockIn(int bookId, int vRegNum, int qty, int cost);
    
    // 📊 업체 본인 판매량 통계 조회
    List<SalesVolumeVO> getSalesVolume(int vRegNum, String period);
    
    // 📊 관리자용 전체 도서 판매량 통계 조회
    List<SalesVolumeVO> getAdminSalesVolume(String period);
    
    Integer getVRegNumByVendorId(String vendorId);
    
	 // =========================================================================
	 // 📊 공통 판매 통계 서비스
	 // =========================================================================
	
	 SalesSummaryVO getSalesSummary(String startDate, String endDate, Integer vRegNum);
	
	 List<SalesTrendVO> getSalesTrend(String period, String startDate, String endDate, Integer vRegNum);
	
	 List<SoldProductVO> getSoldProducts(String startDate, String endDate, Integer vRegNum);
	
	 List<VendorOptionVO> getVendorOptions();
	
	 List<SalesCompareTrendVO> getSalesCompareTrend(
	         String period,
	         String startDate,
	         String endDate,
	         String metric,
	         int vendorA,
	         int vendorB
	 );
}