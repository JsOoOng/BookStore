package com.cosmic.library.book.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.repository.BookDAO;

@Service // 1. 이 클래스가 '서비스'임을 스프링에게 알립니다. (매우 중요!)
public class BookServiceImple implements BookService {

    @Autowired // 2. DB 처리를 담당할 DAO를 자동으로 연결(주입)합니다.
    private BookDAO bookDAO;

    @Override
    public List<BookVO> findAllBooks() {
        // 모든 도서 목록을 가져오라고 DAO에게 시킵니다.
        return bookDAO.selectAll();
    }

    @Override
    public BookVO findBookById(int id) {
        // 특정 ID의 도서 정보를 가져옵니다.
        return bookDAO.selectById(id);
    }

    @Override
    public List<BookVO> searchBooks(String keyword) {
        // 검색 키워드에 맞는 도서를 찾습니다.
        return bookDAO.selectByKeyword(keyword);
    }

    @Override
    public List<BookVO> findRecentBooks(int count) {
        // 메인 페이지용 최신 도서 리스트를 가져옵니다.
        return bookDAO.selectRecent(count);
    }

    @Override
    public int registerBook(BookVO book) {
        // 새로운 도서(행성)를 DB에 등록합니다.
        return bookDAO.insert(book);
    }

    @Override
    public int modifyBook(BookVO book) {
        // 도서 정보를 수정(동기화)합니다.
        return bookDAO.update(book);
    }

    @Override
    public int removeBook(int id) {
        // 도서 정보를 삭제(말소)합니다.
        return bookDAO.delete(id);
    }
    
    @Override
    public List<BookVO> findBooksByPage(int page, int size) {
        int offset = (page - 1) * size; // 시작 지점 계산
        return bookDAO.selectPaged(size, offset);
    }

    @Override
    public int getTotalPageCount(int size) {
        int totalCount = bookDAO.countAll();
        // 전체 개수가 23개면 3페이지가 나와야 함 (23 / 10 = 2.3 -> 올림해서 3)
        return (int) Math.ceil((double) totalCount / size);
    }
    
    @Override
    public List<BookVO> searchBooksPaged(String keyword, int page, int size) {
        int offset = (page - 1) * size;
        return bookDAO.selectByKeywordPaged(keyword, size, offset);
    }

    @Override
    public int getSearchPageCount(String keyword, int size) {
        int totalCount = bookDAO.countByKeyword(keyword);
        // 검색 결과가 0개여도 최소 1페이지는 나오게 하거나, 0을 반환하도록 처리
        if (totalCount == 0) return 1;
        return (int) Math.ceil((double) totalCount / size);
    }

	@Override
	public BookVO getById(int id) {
		return bookDAO.findById(id); // ⭐ 연결
	}
}