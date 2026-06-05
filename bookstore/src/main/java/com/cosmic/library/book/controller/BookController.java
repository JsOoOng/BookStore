package com.cosmic.library.book.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.service.BookService;
import com.cosmic.library.vendor.model.ProductSaleVO;
import com.cosmic.library.vendor.repository.ProductSaleDAO;

@Controller
@RequestMapping("/book") 
public class BookController {

    @Autowired
    private BookService bookService;
    
    @Autowired
    private ProductSaleDAO productSaleDAO;

    // 🪐 [네이버 발급 토큰 장착] 발급받은 실제 Client ID와 Secret 값을 여기에 입력해 줘!
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        dateFormat.setLenient(false);
        binder.registerCustomEditor(java.sql.Date.class, new CustomDateEditor(dateFormat, true));
    }

    // ==============================================================
    // 🛰️ [사령부 핵심 기믹] 네이버 실시간 도서 표지 수집 전용 통신 파이프라인
    // ==============================================================
    private String getNaverBookCover(String isbn) {
        if (isbn == null || isbn.trim().isEmpty()) {
            return "/resources/images/books/no_image.jpg";
        }
        try {
            String apiURL = "https://openapi.naver.com/v1/search/book.json?query=" + isbn.trim() + "&display=1";
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            
            con.setRequestMethod("GET");
            con.setRequestProperty("X-Naver-Client-Id", NAVER_CLIENT_ID);
            con.setRequestProperty("X-Naver-Client-Secret", NAVER_CLIENT_SECRET);

            int responseCode = con.getResponseCode();
            if (responseCode == 200) { 
                BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
                String inputLine;
                StringBuilder response = new StringBuilder();
                while ((inputLine = br.readLine()) != null) {
                    response.append(inputLine);
                }
                br.close();

                JSONObject jsonObject = new JSONObject(response.toString());
                JSONArray items = jsonObject.getJSONArray("items");
                
                if (items.length() > 0) {
                    JSONObject bookItem = items.getJSONObject(0);
                    return bookItem.getString("image"); // 네이버 공식 표지 주소 확보 성공!
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "/resources/images/books/no_image.jpg"; // 실패 시 엑스박스 방어용 디폴트 표지 반환
    }

    // 1. 도서 전체 목록 탐사 (List - 네이버 실시간 표지 동기화 완료)
    @GetMapping("/list")
    public String list(@RequestParam(value = "page", defaultValue = "1") int page, Model model) {
        int pageSize = 10;
        int blockSize = 5; 
        
        List<BookVO> books = bookService.findBooksByPage(page, pageSize);
        
        // 📡 [레이더 포격] 꺼내온 10권의 책에 각각 네이버 표지를 실시간 자석 매핑한다!
        for (BookVO book : books) {
            book.setImage(getNaverBookCover(book.getIsbn()));
        }
        
        int totalPages = bookService.getTotalPageCount(pageSize);
        
        int startPage = ((page - 1) / blockSize) * blockSize + 1;
        int endPage = startPage + blockSize - 1;
        if (endPage > totalPages) endPage = totalPages;
        
        model.addAttribute("bookList", books);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("startPage", startPage); 
        model.addAttribute("endPage", endPage);
        
        model.addAttribute("pageName", "pages/book/list");
        return "common/layout";
    }

    // 2. 🪐 특정 도서 상세 관측 (View - 네이버 실시간 표지 동기화 완료)
    @GetMapping("/view")
    public String view(
        @RequestParam("id") int id, 
        @RequestParam(value = "saleId", required = false, defaultValue = "0") int saleId,
        @RequestParam(value = "price", required = false, defaultValue = "0") int price,
        @RequestParam(value = "stockQty", required = false, defaultValue = "0") int stockQty,
        @RequestParam(value = "bizName", required = false, defaultValue = "") String bizName,
        Model model) {
        
        BookVO book = bookService.findBookById(id);
        
        // 📡 [레이더 포격] 상세 페이지에 진입한 이 책의 진짜 네이버 표지를 강제 주입한다!
        if (book != null) {
            book.setImage(getNaverBookCover(book.getIsbn()));
        }
        
        List<BookVO> recommendList = bookService.findRandomBooks(5, id);
        // 추천 도서 5권의 표지도 엑스박스 방지를 위해 레이더망 연동!
        for (BookVO recBook : recommendList) {
            recBook.setImage(getNaverBookCover(recBook.getIsbn()));
        }
        
        model.addAttribute("book", book);
        model.addAttribute("recommendList", recommendList);
        
        if (saleId > 0 && price > 0) {
            ProductSaleVO mockMarket = new ProductSaleVO();
            mockMarket.setSaleId(saleId);
            mockMarket.setPrice(price);
            mockMarket.setStockQty(stockQty);
            mockMarket.setBizName(bizName);
            
            model.addAttribute("market", mockMarket);
        } else {
            List<ProductSaleVO> allSales = productSaleDAO.findAllWithDetails();
            ProductSaleVO bestMarket = null;
            for (ProductSaleVO sale : allSales) {
                if (sale.getBookId() == id) {
                    if (bestMarket == null || sale.getPrice() < bestMarket.getPrice()) {
                        bestMarket = sale;
                    }
                }
            }
            if (bestMarket != null) {
                model.addAttribute("market", bestMarket);
            }
        }
        
        model.addAttribute("pageName", "pages/book/view");
        return "common/layout";
    }

    // 3. 신규 도서 등록 폼 (Insert - GET)
    @GetMapping("/insert")
    public String insertForm(Model model) {
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
        
        // 📡 [레이더 포격 추가!] 수정 폼에서도 네이버 실시간 표지를 땡겨오도록 동기화!
        if (book != null) {
            book.setImage(getNaverBookCover(book.getIsbn()));
        }
        
        model.addAttribute("book", book);
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

    // 8. 키워드 기반 도서 검색 (Find - 네이버 실시간 표지 동기화 완료)
    @GetMapping("/find")
    public String find(
        @RequestParam("title") String keyword, 
        @RequestParam(value = "page", defaultValue = "1") int page, 
        Model model) {
        
        int pageSize = 8; 
        int blockSize = 5;
        
        List<BookVO> searchResult = bookService.searchBooksPaged(keyword, page, pageSize);
        
        // 📡 [레이더 포격] 검색된 결과 리스트도 빠짐없이 네이버 표지로 전환!
        for (BookVO book : searchResult) {
            book.setImage(getNaverBookCover(book.getIsbn()));
        }
        
        int totalSearchPages = bookService.getSearchPageCount(keyword, pageSize);
        
        int startPage = ((page - 1) / blockSize) * blockSize + 1;
        int endPage = startPage + blockSize - 1;
        if (endPage > totalSearchPages) endPage = totalSearchPages;
        
        model.addAttribute("bookList", searchResult);
        model.addAttribute("searchKeyword", keyword);
        
        model.addAttribute("startPage", startPage); 
        model.addAttribute("endPage", endPage);
        
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalSearchPages);
        
        model.addAttribute("pageName", "pages/book/find");
        return "common/layout";
    }
}