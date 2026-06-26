package com.cosmic.library.statistics.model;

public class VendorOptionVO {

    private int vRegNum;        // 협력업체 등록 번호
    private String vendorName;  // 협력업체명

    public int getVRegNum() {
        return vRegNum;
    }

    public void setVRegNum(int vRegNum) {
        this.vRegNum = vRegNum;
    }

    public String getVendorName() {
        return vendorName;
    }

    public void setVendorName(String vendorName) {
        this.vendorName = vendorName;
    }
}