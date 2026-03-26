package com.cosmic.library.purchase.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cosmic.library.purchase.model.Purchase;
import com.cosmic.library.purchase.repository.PurchaseRepository;

@Service
public class PurchaseService {

    @Autowired
    private PurchaseRepository purchaseRepository;

    public void buy(Purchase purchase) {

        // 🔥 여기서 확장 가능
        // - 재고 체크
        // - 할인 적용
        // - 포인트 처리

        purchaseRepository.save(purchase);
    }
}