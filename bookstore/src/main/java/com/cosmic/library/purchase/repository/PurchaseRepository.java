package com.cosmic.library.purchase.repository;

import org.springframework.stereotype.Repository;

import com.cosmic.library.purchase.model.Purchase;

@Repository
public class PurchaseRepository {

    public void save(Purchase purchase) {

        // TODO: 나중에 DB INSERT
        System.out.println("===== 구매 저장 =====");
        System.out.println("회원ID: " + purchase.getMemberId());
        System.out.println("책ID: " + purchase.getBookId());
        System.out.println("가격: " + purchase.getPrice());
    }
}