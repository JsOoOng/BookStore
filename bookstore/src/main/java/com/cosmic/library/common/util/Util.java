package com.cosmic.library.common.util;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/") 
public class Util {

	@GetMapping("/map")
    public String map(Model model) {
        
        
        // 🚀 좌표 수정: book/list -> pages/book/list
        model.addAttribute("pageName", "pages/map");
        
        return "common/layout";
    }
	
	
}
