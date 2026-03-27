package com.cosmic.library.purchase.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cosmic.library.basket.repository.BasketDAOH2;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.service.BookService;
import com.cosmic.library.purchase.model.Purchase;
import com.cosmic.library.purchase.repository.PurchaseRepository;

@Service
public class PurchaseService {

    @Autowired
    private PurchaseRepository purchaseRepository;

    @Autowired
    private BookService bookService;

    @Autowired
    private BasketDAOH2 basketRepository;

    // 기존 컨트롤러에서 쓰는 방식
    public void buy(Purchase purchase) {
        purchaseRepository.save(purchase);
    }

    // 단일 구매
    public void buySingle(String memberId, int bookId) {
        BookVO book = bookService.getById(bookId);

        Purchase p = new Purchase();
        p.setMemberId(memberId);
        p.setBookId(bookId);
        p.setPrice(book.getPrice());
        p.setQuantity(1);
        p.setTotalPrice(book.getPrice());

        purchaseRepository.save(p);
    }

    // 장바구니 구매
    public void buyFromBusket(String memberId, String bookIds) {
        String[] ids = bookIds.split(",");

        for (String id : ids) {
            int bookId = Integer.parseInt(id.trim());

            BookVO book = bookService.getById(bookId);

            Purchase p = new Purchase();
            p.setMemberId(memberId);
            p.setBookId(bookId);
            p.setPrice(book.getPrice());
            p.setQuantity(1);
            p.setTotalPrice(book.getPrice());

            purchaseRepository.save(p);

            basketRepository.delete(memberId, bookId);
        }
    }
    
    public List<Purchase> getMyPurchases(String memberId) {
        return purchaseRepository.findByMemberId(memberId);
    }
}