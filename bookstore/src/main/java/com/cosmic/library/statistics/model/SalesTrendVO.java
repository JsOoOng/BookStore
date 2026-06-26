package com.cosmic.library.statistics.model;

public class SalesTrendVO {

    private String label;

    private long totalRevenue;
    private int orderCount;
    private int totalBookQty;
    private int vendorCount;
    private int productTypeCount;

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

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
}