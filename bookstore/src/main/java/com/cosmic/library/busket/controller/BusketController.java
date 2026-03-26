package com.cosmic.library.busket.controller;

import com.cosmic.library.busket.model.BusketVO;
import com.cosmic.library.busket.service.BusketService;
import com.cosmic.library.member.model.MemberVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/busket")
public class BusketController {

    @Autowired
    private BusketService busketService;

    // 장바구니 페이지 조회
    @GetMapping("")
    public String list(Model model, HttpSession session) {
        MemberVO member = getLoginMember(session);
        if (member == null) return "redirect:/";

        List<BusketVO> list = busketService.getList(member.getId());
        model.addAttribute("busketList", list);

        return "pages/busket/busket";
    }

    // 장바구니 삭제 (단일 + 선택 삭제)
    @PostMapping("/delete")
    public String delete(
            @RequestParam(value = "busketId", required = false) Integer busketId,
            @RequestParam(value = "ids", required = false) int[] ids,
            HttpSession session) {

        MemberVO member = getLoginMember(session);
        if (member == null) return "redirect:/";

        // 개별 삭제
        if (busketId != null) {
            busketService.delete(member.getId(), busketId);
        }

        // 선택 삭제
        else if (ids != null && ids.length > 0) {
            busketService.delete(member.getId(), ids);
        }

        return "redirect:/busket";
    }

    // 장바구니 선택 구매
    @GetMapping("/buy")
    public String buy(
            @RequestParam(value = "busketIds", required = false) String busketIds,
            HttpSession session) {

        MemberVO member = getLoginMember(session);
        if (member == null) return "redirect:/";

        if (busketIds != null && !busketIds.isEmpty()) {
            String[] arr = busketIds.split(",");
            int[] ids = new int[arr.length];

            for (int i = 0; i < arr.length; i++) {
                ids[i] = Integer.parseInt(arr[i]);
            }

            busketService.buy(member.getId(), ids);
        }

        return "redirect:/purchase/view?bookIds=" + busketIds;
    }

    // 장바구니 담기 (AJAX)
    @GetMapping("/add")
    @ResponseBody
    public String add(@RequestParam("id") Integer bookId, HttpSession session) {
        try {
            if (bookId == null) return "error";

            MemberVO member = getLoginMember(session);
            if (member == null) return "error";

            busketService.add(member.getId(), bookId);
            return "ok";

        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }

    // 로그인 멤버 가져오기
    private MemberVO getLoginMember(HttpSession session) {
        return (MemberVO) session.getAttribute("loginMember");
    }
}