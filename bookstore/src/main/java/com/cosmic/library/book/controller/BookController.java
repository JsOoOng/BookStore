package com.cosmic.library.book.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.service.BookService;

@Controller
@RequestMapping("/book") 
public class BookController {

    @Autowired
    private BookService bookService;

    // 1. 도서 전체 목록 탐사 (List)
    @GetMapping("/list")
    public String list(@RequestParam(value = "page", defaultValue = "1") int page, Model model) {
        int pageSize = 10;
        int blockSize = 5; // 🚀 한 번에 보여줄 페이지 번호 개수
        
        List<BookVO> books = bookService.findBooksByPage(page, pageSize);
        int totalPages = bookService.getTotalPageCount(pageSize);
        
        int startPage = ((page - 1) / blockSize) * blockSize + 1;
        int endPage = startPage + blockSize - 1;
        if (endPage > totalPages) endPage = totalPages;
        
        model.addAttribute("bookList", books);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("startPage", startPage); // 🚀 추가
        model.addAttribute("endPage", endPage);
        
        // 🚀 좌표 수정: book/list -> pages/book/list
        model.addAttribute("pageName", "pages/book/list");
        
        return "common/layout";
    }

    // 2. 특정 도서 상세 관측 (View)
    @GetMapping("/view")
    public String view(@RequestParam("id") int id, Model model) {
        BookVO book = bookService.findBookById(id);
        List<BookVO> recommendList = bookService.findRandomBooks(5, id);
        
        model.addAttribute("book", book);
        model.addAttribute("recommendList", recommendList);
        
        // 🚀 좌표 수정: book/view -> pages/book/view
        model.addAttribute("pageName", "pages/book/view");
        
        return "common/layout";
    }

    // 3. 신규 도서 등록 폼 (Insert - GET)
    @GetMapping("/insert")
    public String insertForm(Model model) {
        // 🚀 좌표 수정: book/insert -> pages/book/insert
        model.addAttribute("pageName", "pages/book/insert");
        return "common/layout";
    }

    // 4. 신규 도서 실제 등록 (Insert - POST)
    @PostMapping("/insert")
    public String insertProcess(@ModelAttribute BookVO book) {
        bookService.registerBook(book);
        return "redirect:/book/list"; 
    }

    // 5. 도서 정보 수정 폼 (Update - GET)
    @GetMapping("/update")
    public String updateForm(@RequestParam("id") int id, Model model) {
        BookVO book = bookService.findBookById(id);
        model.addAttribute("book", book);
        
        // 🚀 좌표 수정: book/update -> pages/book/update
        model.addAttribute("pageName", "pages/book/update");
        
        return "common/layout";
    }

    // 6. 도서 정보 실제 수정 (Update - POST)
    @PostMapping("/update")
    public String updateProcess(@ModelAttribute BookVO book) {
        bookService.modifyBook(book);
        return "redirect:/book/view?id=" + book.getId(); 
    }

    // 7. 도서 데이터 말소 (Delete)
    @GetMapping("/delete")
    public String delete(@RequestParam("id") int id) {
        bookService.removeBook(id);
        return "redirect:/book/list";
    }

 // 8. 키워드 기반 도서 검색 (Find - 페이징 추가 버전)
    @GetMapping("/find")
    public String find(
        @RequestParam("title") String keyword, 
        @RequestParam(value = "page", defaultValue = "1") int page, // 페이지 파라미터 추가
        Model model) {
        
        int pageSize = 8; // 리스트와 동일하게 10개씩
        int blockSize = 5;
        
        // 🔍 [주의] Service에 검색용 페이징 메소드가 필요합니다.
        // 기존 searchBooks(keyword) 대신 페이징이 적용된 메소드를 호출해야 합니다.
        List<BookVO> searchResult = bookService.searchBooksPaged(keyword, page, pageSize);
        int totalSearchPages = bookService.getSearchPageCount(keyword, pageSize);
        
        int startPage = ((page - 1) / blockSize) * blockSize + 1;
        int endPage = startPage + blockSize - 1;
        if (endPage > totalSearchPages) endPage = totalSearchPages;
        
        model.addAttribute("bookList", searchResult);
        model.addAttribute("searchKeyword", keyword);
        
        model.addAttribute("startPage", startPage); // 🚀 추가
        model.addAttribute("endPage", endPage);
        
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalSearchPages);
        
        // 🚀 좌표 수정: book/find -> pages/book/find
        model.addAttribute("pageName", "pages/book/find");
        

        return "common/layout";
    }
}