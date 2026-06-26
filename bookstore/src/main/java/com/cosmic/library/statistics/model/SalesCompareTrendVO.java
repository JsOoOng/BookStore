package com.cosmic.library.statistics.model;

public class SalesCompareTrendVO {

    private String label;
    private Long vendorAValue;
    private Long vendorBValue;
    
    // getter / setter
    
	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}
	public Long getVendorAValue() {
		return vendorAValue;
	}
	public void setVendorAValue(Long vendorAValue) {
		this.vendorAValue = vendorAValue;
	}
	public Long getVendorBValue() {
		return vendorBValue;
	}
	public void setVendorBValue(Long vendorBValue) {
		this.vendorBValue = vendorBValue;
	}
}