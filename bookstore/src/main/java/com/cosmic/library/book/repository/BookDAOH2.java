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

    // DB 컬럼명과 BookVO 필드명이 일치하면 자동으로 매핑해주는 RowMapper (pubDate, language 자동 처리됨)
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
        // language 필드도 검색 대상에 포함하여 확장 가능
        String sql = "SELECT * FROM BOOK WHERE title LIKE ? OR writer LIKE ? OR genre LIKE ? OR publisher LIKE ? OR language LIKE ? ORDER BY id DESC";
        String search = "%" + keyword + "%";
        return jdbcTemplate.query(sql, rowMapper, search, search, search, search, search);
    }

    @Override
    public List<BookVO> selectRecent(int count) {
        // 기존 regDate 컬럼이 없으므로, Auto Increment 되는 id 역순을 기준으로 가장 최근 데이터를 추출
        String sql = "SELECT * FROM BOOK ORDER BY id DESC LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, count);
    }

    @Override
    public int insert(BookVO book) {
        // price, content, regDate 제거 / pubDate, language 추가
        String sql = "INSERT INTO BOOK (title, writer, publisher, pubDate, genre, language, isbn, image) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, 
                                   book.getTitle(), 
                                   book.getWriter(), 
                                   book.getPublisher(), 
                                   book.getPubDate(), // java.sql.Date 매핑
                                   book.getGenre(), 
                                   book.getLanguage(), 
                                   book.getIsbn(), 
                                   book.getImage());
    }

    @Override
    public int update(BookVO book) {
        // price, content 제거 / pubDate, language 수정 가능하도록 반영
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

    @Override
    public BookVO findById(int id) {
        String sql = "SELECT * FROM book WHERE id = ?";

        return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
            BookVO book = new BookVO();

            book.setId(rs.getInt("id"));
            book.setTitle(rs.getString("title"));
            book.setWriter(rs.getString("writer"));
            book.setPublisher(rs.getString("publisher"));
            book.setPubDate(rs.getDate("pubDate")); // rs.getDate() 사용
            book.setGenre(rs.getString("genre"));
            book.setLanguage(rs.getString("language")); // 신규 컬럼 매핑
            book.setIsbn(rs.getString("isbn"));
            book.setImage(rs.getString("image"));
            // 사라진 price, content, regDate 세터 제거

            return book;
        }, id);
    }
    
    @Override
    public List<BookVO> selectRandom(int count, int excludeId) {
        String sql = "SELECT * FROM BOOK WHERE id != ? ORDER BY RAND() LIMIT ?";
        return jdbcTemplate.query(sql, rowMapper, excludeId, count);
    }
}