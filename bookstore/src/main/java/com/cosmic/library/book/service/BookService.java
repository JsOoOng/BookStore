package com.cosmic.library.book.service;

import java.util.List;

import com.cosmic.library.book.model.BookVO;

public interface BookService {

    // 1. 전체 도서 목록 조회: 일반 유저 및 관리자 공통 사용
    List<BookVO> findAllBooks();

    // 2. 도서 상세 조회: 특정 도서의 정보를 클릭했을 때 사용
    BookVO findBookById(int id);

    // 3. 도서 검색: 제목이나 저자로 도서를 찾을 때 사용
    List<BookVO> searchBooks(String keyword);

    // 4. 최신 도서 조회: 메인 페이지(main.jsp)에 노출할 최신 도서 n권
    List<BookVO> findRecentBooks(int count);

    // --- 관리자(ADMIN/SUPER) 전용 기능 ---

    // 5. 도서 등록: 새로운 도서를 도서관 시스템에 추가
    int registerBook(BookVO book);

    // 6. 도서 수정: 기존 도서의 정보(가격, 내용 등)를 변경
    int modifyBook(BookVO book);

    // 7. 도서 삭제: 시스템에서 도서 데이터를 영구 삭제
    int removeBook(int id);

    // 8. 페이징 기능 : 시작 지점 계산
	List<BookVO> findBooksByPage(int page, int size);

	// 9. 페이지 계산 기능
	int getTotalPageCount(int size);

	List<BookVO> searchBooksPaged(String keyword, int page, int size);

	int getSearchPageCount(String keyword, int size);
}

