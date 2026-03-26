package com.cosmic.library.basket.service;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.repository.BasketDAO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BasketServiceImpl implements BasketService {

    @Autowired
    private BasketDAO busketDAO;

    // 회원 기준 장바구니 리스트 조회
    @Override
    public List<BasketVO> getList(String memberId) {
        return busketDAO.findAll(memberId);
    }

    // 장바구니 삭제 (단일)
    @Override
    public void delete(String memberId, int busketId) {
        busketDAO.deleteById(busketId, memberId);
    }

    // 장바구니 삭제 (다중)
    @Override
    public void delete(String memberId, int[] busketIds) {
        busketDAO.deleteByIds(busketIds, memberId); // 🔥 반복문 제거
    }

    // 구매 처리 (단일)
    @Override
    public void buy(String memberId, int busketId) {
        busketDAO.buy(busketId, memberId);
    }

    // 구매 처리 (다중)
    @Override
    public void buy(String memberId, int[] busketIds) {
        busketDAO.buy(busketIds, memberId); // 🔥 반복문 제거
    }

    // 장바구니에 책 추가
    @Override
    public void add(String memberId, int bookId) {
        System.out.println("장바구니 담기 실행: member=" + memberId + ", book=" + bookId);
        busketDAO.insert(memberId, bookId);
    }
}