package com.cosmic.library.statistics.model;

public class SalesSummaryVO {

    private long totalRevenue;      // 전체 매출액
    private int orderCount;         // 전체 주문 건 수
    private int totalBookQty;       // 전체 판매 책 수
    private int vendorCount;        // 참여 협력업체 수
    private int productTypeCount;   // 판매 상품 종류 수
    private long avgOrderPrice;     // 평균 주문 금액
    
    // getter / setter
    
	public long getTotalRevenue() {
		return totalRevenue;
	}
	public void setTotalRevenue(long totalRevenue) {
		this.totalRevenue = totalRevenue;
	}
	public int getOrderCount() {
		return orderCount;
	}
	public void setOrderCount(int orderCount) {
		this.orderCount = orderCount;
	}
	public int getTotalBookQty() {
		return totalBookQty;
	}
	public void setTotalBookQty(int totalBookQty) {
		this.totalBookQty = totalBookQty;
	}
	public int getVendorCount() {
		return vendorCount;
	}
	public void setVendorCount(int vendorCount) {
		this.vendorCount = vendorCount;
	}
	public int getProductTypeCount() {
		return productTypeCount;
	}
	public void setProductTypeCount(int productTypeCount) {
		this.productTypeCount = productTypeCount;
	}
	public long getAvgOrderPrice() {
		return avgOrderPrice;
	}
	public void setAvgOrderPrice(long avgOrderPrice) {
		this.avgOrderPrice = avgOrderPrice;
	}
}