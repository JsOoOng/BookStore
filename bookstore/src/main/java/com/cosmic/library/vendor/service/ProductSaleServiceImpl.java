package com.cosmic.library.vendor.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.repository.ProductSaleDAO;

@Service
public class ProductSaleServiceImpl implements ProductSaleService {

    @Autowired
    private ProductSaleDAO productSaleDAO;

    @Override
    public boolean registerProduct(ProductSaleVO productSale) {
        // 기본 판매 상태를 'ON'(판매중)으로 안전하게 세팅
        if (productSale.getSaleStatus() == null) {
            productSale.setSaleStatus("ON");
        }
        return productSaleDAO.insert(productSale) > 0;
    }

    @Override
    public ProductSaleVO getProductById(int saleId) {
        return productSaleDAO.findById(saleId);
    }

    @Override
    public List<ProductSaleVO> getProductsByVendor(int vRegNum) {
        return productSaleDAO.findByVendorRegNum(vRegNum);
    }

    @Override
    public List<ProductSaleVO> getAllMarketProducts() {
        return productSaleDAO.findAllWithDetails();
    }

    @Override
    public boolean modifyProduct(ProductSaleVO productSale) {
        return productSaleDAO.update(productSale) > 0;
    }

    @Override
    public boolean removeProduct(int saleId) {
        return productSaleDAO.delete(saleId) > 0;
    }
}