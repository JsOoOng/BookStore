package com.cosmic.library.book.repository;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import com.cosmic.library.book.model.BookVO;

@Repository
public class BookDAOH2 implements BookDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // DB 컬럼명과 BookVO 필드명이 일치하면 자동으로 매핑해주는 RowMapper
    private RowMapper<BookVO> rowMapper = new BeanPropertyRowMapper<>(BookVO.class);

    @Override
    public List<BookVO> selectAll() {
        String sql = "SELECT * FROM BOOK ORDER BY id DESC";
        return jdbcTemplate.query(sql, rowMapper);
    }

    @Override
    public BookVO selectById(int id) {
        String sql = "SELECT * FROM BOOK WHERE id = ?";
        return jdbcTemplate.queryForObject(sql, rowMapper, id);
    }

    @Override
    public List<BookVO> selectByKeyword(String keyword) {
        // 제목, 저자, 장르, 출판사 등 여러 필드에서 검색 가능하도록 확장
        String sql = "SELECT * FROM BOOK WHERE title LIKE ? OR writer LIKE ? OR genre LIKE ? OR publisher LIKE ? ORDER BY id DESC";
        String search = "%" + keyword + "%";
        return jdbcTemplate.query(sql, rowMapper, search, search, search, search);
    }

    @Override
    public List<BookVO> selectRecent(int count) {
        String sql = "SELECT * FROM BOOK ORDER BY regDate DESC LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, count);
    }

    @Override
    public int insert(BookVO book) {
        // genre, isbn, publisher 필드를 추가하여 쿼리 작성
        String sql = "INSERT INTO BOOK (title, writer, publisher, price, genre, isbn, content, image, regDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        return jdbcTemplate.update(sql, 
                                   book.getTitle(), 
                                   book.getWriter(), 
                                   book.getPublisher(), 
                                   book.getPrice(), 
                                   book.getGenre(), 
                                   book.getIsbn(), 
                                   book.getContent(), 
                                   book.getImage());
    }

    @Override
    public int update(BookVO book) {
        // 모든 필드를 동기화할 수 있도록 수정
        String sql = "UPDATE BOOK SET title=?, writer=?, publisher=?, price=?, genre=?, isbn=?, content=?, image=? " +
                     "WHERE id=?";
        return jdbcTemplate.update(sql, 
                                   book.getTitle(), 
                                   book.getWriter(), 
                                   book.getPublisher(), 
                                   book.getPrice(), 
                                   book.getGenre(), 
                                   book.getIsbn(), 
                                   book.getContent(), 
                                   book.getImage(), 
                                   book.getId());
    }

    @Override
    public int delete(int id) {
        String sql = "DELETE FROM BOOK WHERE id = ?";
        return jdbcTemplate.update(sql, id);
    }
    
    // 1. 페이징 처리된 목록 조회
    @Override
    public List<BookVO> selectPaged(int limit, int offset) {
        String sql = "SELECT * FROM BOOK ORDER BY id DESC LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, rowMapper, limit, offset);
    }

    // 2. 전체 도서 개수 조회 (총 페이지 수 계산용)
    @Override
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM BOOK";
        return jdbcTemplate.queryForObject(sql, Integer.class);
    }
    
    // 1. 검색어 기준 페이징 조회
    @Override
    public List<BookVO> selectByKeywordPaged(String keyword, int limit, int offset) {
        String sql = "SELECT * FROM BOOK WHERE title LIKE ? OR writer LIKE ? OR genre LIKE ? OR publisher LIKE ? " +
                     "ORDER BY id DESC LIMIT ? OFFSET ?";
        String search = "%" + keyword + "%";
        return jdbcTemplate.query(sql, rowMapper, search, search, search, search, limit, offset);
    }

    // 2. 검색된 결과의 총 개수 조회
    @Override
    public int countByKeyword(String keyword) {
        String sql = "SELECT COUNT(*) FROM BOOK WHERE title LIKE ? OR writer LIKE ? OR genre LIKE ? OR publisher LIKE ?";
        String search = "%" + keyword + "%";
        return jdbcTemplate.queryForObject(sql, Integer.class, search, search, search, search);
    }

    @Override
    public BookVO findById(int id) {

        String sql = "SELECT * FROM book WHERE id = ?";

        return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
            BookVO book = new BookVO();

            book.setId(rs.getInt("id"));
            book.setTitle(rs.getString("title"));
            book.setWriter(rs.getString("writer"));
            book.setPublisher(rs.getString("publisher"));
            book.setPrice(rs.getInt("price"));
            book.setGenre(rs.getString("genre"));
            book.setIsbn(rs.getString("isbn"));
            book.setContent(rs.getString("content"));
            book.setImage(rs.getString("image"));
            book.setRegDate(rs.getTimestamp("regDate"));

            return book;

        }, id); // ⭐ 여기 중요 (Object... 형태)
    }
    
    @Override
    public List<BookVO> selectRandom(int count, int excludeId) {
        // id != ? 는 현재 상세 페이지에서 보고 있는 책이 추천 목록에 나오지 않게 함
        // ORDER BY RAND() 는 매번 순서를 무작위로 섞음
        String sql = "SELECT * FROM BOOK WHERE id != ? ORDER BY RAND() LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, excludeId, count);
    }
}