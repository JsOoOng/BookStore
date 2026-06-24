package com.cosmic.library.vendor.model;

public class SalesVolumeVO {

    private String label;
    private int totalQty;

    public SalesVolumeVO() {
    }

    public SalesVolumeVO(String label, int totalQty) {
        this.label = label;
        this.totalQty = totalQty;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public int getTotalQty() {
        return totalQty;
    }

    public void setTotalQty(int totalQty) {
        this.totalQty = totalQty;
    }
}