package com.cosmic.library.vendor.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.repository.ProductSaleDAO;
import com.cosmic.library.vendor.model.SalesVolumeVO;

@Service
public class ProductSaleServiceImpl implements ProductSaleService {

    @Autowired
    private ProductSaleDAO productSaleDAO;

    @Override
    public boolean registerProduct(ProductSaleVO productSale) {
        // 이미 가공이 완료된 완벽한 VO 상태이므로 즉시 데이터 런칭 수행!
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
    
    @Override
    public int findStockIdByBookIdAndVendor(int bookId, int vRegNum) {
        return productSaleDAO.findStockIdByBookIdAndVendor(bookId, vRegNum);
    }

    @Override
    public int insertStockIn(int bookId, int vRegNum, int qty, int cost) {
        return productSaleDAO.insertStockIn(bookId, vRegNum, qty, cost);
    }
    
    @Override
    public List<SalesVolumeVO> getSalesVolume(int vRegNum, String period) {
        return productSaleDAO.selectSalesVolume(vRegNum, period);
    }
}