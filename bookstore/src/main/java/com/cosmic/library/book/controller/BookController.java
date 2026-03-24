package com.cosmic.library.book.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.service.BookService;

@Controller
@RequestMapping("/book") // 모든 경로는 /book으로 시작합니다.
public class BookController {

    @Autowired
    private BookService bookService;

    // 1. 도서 전체 목록 탐사 (List)
    @GetMapping("/list")
    public String list(@RequestParam(value = "page", defaultValue = "1") int page, Model model) {
        int pageSize = 10;
        
        List<BookVO> books = bookService.findBooksByPage(page, pageSize);
        int totalPages = bookService.getTotalPageCount(pageSize);
        
        model.addAttribute("bookList", books);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("pageName", "book/list");
        
        return "common/layout";
    }

    // 2. 특정 도서 상세 관측 (View)
    @GetMapping("/view")
    public String view(@RequestParam("id") int id, Model model) {
        BookVO book = bookService.findBookById(id);
        
        // 상세 페이지 하단의 '다른 지식' 추천용 (최신 도서 5권)
        List<BookVO> recommendList = bookService.findRecentBooks(5);
        
        model.addAttribute("book", book);
        model.addAttribute("recommendList", recommendList);
        model.addAttribute("pageName", "book/view");
        return "common/layout";
    }

    // 3. 신규 도서 등록 폼 (Insert - GET)
    @GetMapping("/insert")
    public String insertForm(Model model) {
        model.addAttribute("pageName", "book/insert");
        return "common/layout";
    }

    // 4. 신규 도서 실제 등록 (Insert - POST)
    @PostMapping("/insert")
    public String insertProcess(@ModelAttribute BookVO book) {
        bookService.registerBook(book);
        return "redirect:/book/list"; // 등록 후 리스트로 귀환
    }

    // 5. 도서 정보 수정 폼 (Update - GET)
    @GetMapping("/update")
    public String updateForm(@RequestParam("id") int id, Model model) {
        BookVO book = bookService.findBookById(id);
        model.addAttribute("book", book);
        model.addAttribute("pageName", "book/update");
        return "common/layout";
    }

    // 6. 도서 정보 실제 수정 (Update - POST)
    @PostMapping("/update")
    public String updateProcess(@ModelAttribute BookVO book) {
        bookService.modifyBook(book);
        return "redirect:/book/view?id=" + book.getId(); // 수정 후 해당 상세페이지로 이동
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
        
        // 🔍 [주의] Service에 검색용 페이징 메소드가 필요합니다.
        // 기존 searchBooks(keyword) 대신 페이징이 적용된 메소드를 호출해야 합니다.
        List<BookVO> searchResult = bookService.searchBooksPaged(keyword, page, pageSize);
        int totalSearchPages = bookService.getSearchPageCount(keyword, pageSize);
        
        model.addAttribute("bookList", searchResult);
        model.addAttribute("searchKeyword", keyword);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalSearchPages);
        model.addAttribute("pageName", "book/find");
        
        return "common/layout";
    }
}