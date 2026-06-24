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

    // 🚀 DB 컬럼명과 BookVO 필드명이 일치하면 자동으로 매핑해주는 만능 RowMapper
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
        String sql = "SELECT * FROM BOOK WHERE title LIKE ? OR writer LIKE ? OR genre LIKE ? OR publisher LIKE ? OR language LIKE ? ORDER BY id DESC";
        String search = "%" + keyword + "%";
        return jdbcTemplate.query(sql, rowMapper, search, search, search, search, search);
    }

    @Override
    public List<BookVO> selectRecent(int count) {
        String sql = "SELECT * FROM BOOK ORDER BY id DESC LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, count);
    }

    @Override
    public int insert(BookVO book) {
        String sql = "INSERT INTO BOOK (title, writer, publisher, pubDate, genre, language, isbn, image) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, 
                                   book.getTitle(), 
                                   book.getWriter(), 
                                   book.getPublisher(), 
                                   book.getPubDate(), 
                                   book.getGenre(), 
                                   book.getLanguage(), 
                                   book.getIsbn(), 
                                   book.getImage());
    }

    @Override
    public int update(BookVO book) {
        String sql = "UPDATE BOOK SET title=?, writer=?, publisher=?, pubDate=?, genre=?, language=?, isbn=?, image=? " +
                     "WHERE id=?";
        return jdbcTemplate.update(sql, 
                                   book.getTitle(), 
                                   book.getWriter(), 
                                   book.getPublisher(), 
                                   book.getPubDate(), 
                                   book.getGenre(), 
                                   book.getLanguage(), 
                                   book.getIsbn(), 
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
        String sql = "SELECT * FROM BOOK WHERE title LIKE ? OR writer LIKE ? OR genre LIKE ? OR publisher LIKE ? OR language LIKE ? " +
                     "ORDER BY id DESC LIMIT ? OFFSET ?";
        String search = "%" + keyword + "%";
        return jdbcTemplate.query(sql, rowMapper, search, search, search, search, search, limit, offset);
    }

    // 2. 검색된 결과의 총 개수 조회
    @Override
    public int countByKeyword(String keyword) {
        String sql = "SELECT COUNT(*) FROM BOOK WHERE title LIKE ? OR writer LIKE ? OR genre LIKE ? OR publisher LIKE ? OR language LIKE ?";
        String search = "%" + keyword + "%";
        return jdbcTemplate.queryForObject(sql, Integer.class, search, search, search, search, search);
    }

    // 💥 [수정 완료] 수동 매핑의 잔재를 지우고 rowMapper로 일괄 통합!
    @Override
    public BookVO findById(int id) {
        String sql = "SELECT * FROM BOOK WHERE id = ?";
        return jdbcTemplate.queryForObject(sql, rowMapper, id);
    }
    
    // 무작위 추천 도서 추출 (상세 페이지 하단용)
    @Override
    public List<BookVO> selectRandom(int count, int excludeId) {
        String sql = "SELECT * FROM BOOK WHERE id != ? ORDER BY RAND() LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, excludeId, count);
    }

    @Override
    public BookVO selectBookBySaleId(int saleId) {
        // 💡 [수리 완료] PRODUCT_SALE -> STOCK_IN -> BOOK 순서로 
        // 정확한 외래키(FK) 다리를 건너도록 JOIN 쿼리 정밀 수리!
        String sql = "SELECT b.*, p.PRICE " +
                     "FROM PRODUCT_SALE p " +
                     "JOIN STOCK_IN s ON p.STOCK_ID = s.stock_id " +
                     "JOIN BOOK b ON s.book_id = b.id " +
                     "WHERE p.SALE_ID = ?"; 
        
        try {
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                BookVO book = new BookVO();
                book.setId(rs.getInt("id"));
                book.setTitle(rs.getString("title"));
                book.setWriter(rs.getString("writer"));
                book.setImage(rs.getString("image"));
                
                book.setIsbn(rs.getString("isbn"));
                
                book.setPrice(rs.getInt("PRICE")); // PRODUCT_SALE 테이블의 가격
                book.setSaleId(saleId);
                return book;
            }, saleId);
        } catch (Exception e) {
            System.out.println("❌ 데이터 조회 실패: " + e.getMessage());
            return null;
        }
    }
    
    // 🪐 [테마 1] 특정 저자(한강) 도서 실시간 추출 엔진
    @Override
    public List<BookVO> selectByWriterOnly(String writer, int limit) {
        String sql = "SELECT * FROM BOOK WHERE writer LIKE ? ORDER BY id DESC LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, "%" + writer + "%", limit);
    }

    // 🪐 [테마 2] 특정 장르 및 키워드(우주/천체) 도서 추출 엔진
    @Override
    public List<BookVO> selectByGenreOnly(String genre, int limit) {
        String sql = "SELECT * FROM BOOK WHERE genre LIKE ? OR title LIKE ? ORDER BY id DESC LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, "%" + genre + "%", "%" + genre + "%", limit);
    }
}