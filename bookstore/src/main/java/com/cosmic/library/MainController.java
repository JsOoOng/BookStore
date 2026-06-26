package com.cosmic.library;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import com.cosmic.library.book.model.BookVO;
import com.cosmic.library.book.service.BookService;

// 💥 [주의] 사령부의 BookVO 실제 패키지 경로에 맞게 이 Import 구문은 수정해서 써라!
import com.cosmic.library.book.model.BookVO; 

@Controller
public class MainController {

    @Autowired
    private BookService bookService;

    // 🛰️ 네이버 API 관제실 코드 동기화
    private static final String NAVER_CLIENT_ID = "0KouZkh6WK0a8kEp0TwY"; 
    private static final String NAVER_CLIENT_SECRET = "z9aV9S6rPW";

    @RequestMapping("/")
    public String mainPage(Model model) {
        
        // 1. [트랙 1] 신규 입고 도서 (최근 등록 10권)
        List<BookVO> recentBooks = bookService.findRecentBooks(10);
        for (BookVO book : recentBooks) {
            book.setImage(getNaverBookCover(extractSmartQuery(book)));
        }
        
        // 2. [트랙 2] 노벨 문학상: 한강 스페셜 (최대 10권)
        List<BookVO> hankangBooks = bookService.findBooksByWriter("한강", 10);
        for (BookVO book : hankangBooks) {
            book.setImage(getNaverBookCover(extractSmartQuery(book)));
        }
        
        // 3. [트랙 3] 미지의 세계: 우주 & 천체 과학 (최대 10권)
        List<BookVO> spaceBooks = bookService.findBooksByGenre("우주", 10);
        for (BookVO book : spaceBooks) {
            book.setImage(getNaverBookCover(extractSmartQuery(book)));
        }

        model.addAttribute("recentBooks", recentBooks);
        model.addAttribute("hankangBooks", hankangBooks);
        model.addAttribute("spaceBooks", spaceBooks);
        
        model.addAttribute("pageName", "pages/main"); 
        return "common/layout"; 
    }

    // 💥 [신규 엔진] 가짜 ISBN을 걸러내고 제목의 괄호를 정제하는 스마트 필터!
    private String extractSmartQuery(BookVO book) {
        // 1. ISBN이 존재하고, 10자리 이상(실제 규격)일 경우 무조건 ISBN 최우선 검색
        if (book.getIsbn() != null && book.getIsbn().trim().length() >= 10) {
            return book.getIsbn().trim();
        }
        // 2. 가짜 ISBN이거나 비어있다면 제목으로 검색하되, 부제(:)나 대괄호([]) 등을 잘라내어 검색 성공률 극대화
        String title = book.getTitle();
        if (title != null) {
            return title.replaceAll("\\[.*?\\]", "").split(":")[0].trim();
        }
        return "";
    }

    // 📡 실시간 네이버 이미지 수집 셔틀 엔진 (쿨타임 장착 버전)
    private String getNaverBookCover(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return "https://placehold.co/150x220/f8fafc/a4b0be?text=No+Cover";
        }
        
        try {
            // 💥 [핵심 방어막] 네이버 API 초당 호출 제한(Rate Limit) 우회!
            // 1건 조회 후 0.065초(65ms) 대기하여 네이버 서버가 차단하지 않도록 속도 조절
            Thread.sleep(65); 

            String encodedKeyword = URLEncoder.encode(keyword.trim(), "UTF-8");
            String apiURL = "https://openapi.naver.com/v1/search/book.json?query=" + encodedKeyword + "&display=1";
            
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
                    return items.getJSONObject(0).getString("image");
                }
            } else {
                // 네이버가 응답을 거부했을 때 콘솔창에 빨간불 켜기! (예: 429, 401 등)
                System.out.println("🚨 네이버 API 접근 거부! 응답 코드: " + responseCode);
            }
        } catch (Exception e) {
            System.out.println("🚨 메인 화면 API 수집 장애: " + e.getMessage());
        }
        return "https://placehold.co/150x220/f8fafc/a4b0be?text=No+Cover";
    }
}