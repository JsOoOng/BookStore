package com.cosmic.library.emailauth.controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.cosmic.library.emailauth.service.EmailAuthService;

@Controller
@RequestMapping("/emailauth")
public class EmailAuthController {

    @Autowired
    private EmailAuthService service;

    @ResponseBody
    @PostMapping("/send")
    public String send(@RequestParam String email) {

        service.sendAuth(email);
        System.out.println("보내기");
        return "OK";
    }

    @ResponseBody
    @PostMapping("/verify")
    public String verify(@RequestParam String email,
                         @RequestParam String authCode) {

        return service.verify(email, authCode) ? "Y" : "N";
    }
}