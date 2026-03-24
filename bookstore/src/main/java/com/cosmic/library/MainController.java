package com.cosmic.library;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MainController {

    @RequestMapping("/")
    public String mainPage(Model model) {
    	
        // layout.jsp에서 "pages/main.jsp 본문 띄우기
        model.addAttribute("pageName", "pages/main"); 
        return "common/layout"; // 실제 이동은 common/layout.jsp로 함
    }
}