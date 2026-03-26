package com.cosmic.library.book.repository;

import java.util.List;

import com.cosmic.library.book.model.BookVO;

public interface BookDAO {

    // 전체 도서 SELECT
    List<BookVO> selectAll();

    // ID로 도서 하나 SELECT (PK 기준)
    BookVO selectById(int id);

    // 키워드로 도서 SELECT (LIKE 쿼리 활용)
    List<BookVO> selectByKeyword(String keyword);

    // 최신 등록 순으로 n개 SELECT (ORDER BY B_REGDATE DESC)
    List<BookVO> selectRecent(int count);

    // 도서 데이터 INSERT
    int insert(BookVO book);

    // 도서 데이터 UPDATE
    int update(BookVO book);

    // 도서 데이터 DELETE
    int delete(int id);

    // 도서 페이지 기능
	List<BookVO> selectPaged(int limit, int offset);

	// 도서 전체 갯수
	int countAll();
	
	// 검색어에 따른 페이징 목록 조회
	List<BookVO> selectByKeywordPaged(String keyword, int limit, int offset);

	// 검색 결과의 총 개수 조회 (검색용 페이지 계산)
	int countByKeyword(String keyword);
	
	public BookVO findById(int id);
}

