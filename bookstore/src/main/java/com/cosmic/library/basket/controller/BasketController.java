package com.cosmic.library.basket.controller;

import com.cosmic.library.basket.model.BasketVO;
import com.cosmic.library.basket.service.BasketService;
import com.cosmic.library.member.model.MemberVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/basket")
public class BasketController {

	@Autowired
	private BasketService basketService;

	// 장바구니 페이지 조회
	@GetMapping("")
	public String list(Model model, HttpSession session) {
		MemberVO member = getLoginMember(session);
		if (member == null)
			return "redirect:/";

		List<BasketVO> list = basketService.getList(member.getId());
		model.addAttribute("basketList", list);

		return "pages/basket/basket";
	}

	// 장바구니 삭제 (단일 + 선택 삭제)
	@PostMapping("/delete")
	public String delete(@RequestParam(value = "basketId", required = false) Integer basketId,
			@RequestParam(value = "ids", required = false) int[] ids, HttpSession session) {

		MemberVO member = getLoginMember(session);
		if (member == null)
			return "redirect:/";

		// 개별 삭제
		if (basketId != null) {
			basketService.delete(member.getId(), basketId);
		}

		// 선택 삭제
		else if (ids != null && ids.length > 0) {
			basketService.delete(member.getId(), ids);
		}

		return "redirect:/basket";
	}

	// 장바구니 선택 구매
	@GetMapping("/buy")
	public String buy(@RequestParam(value = "basketIds", required = false) String basketIds, HttpSession session) {

		MemberVO member = getLoginMember(session);
		if (member == null)
			return "redirect:/";

		if (basketIds != null && !basketIds.isEmpty()) {
			String[] arr = basketIds.split(",");
			int[] ids = new int[arr.length];

			for (int i = 0; i < arr.length; i++) {
				ids[i] = Integer.parseInt(arr[i]);
			}

			basketService.buy(member.getId(), ids);
		}

		return "redirect:/purchase/view?bookIds=" + basketIds;
	}

	// 장바구니 담기 (AJAX)
	@GetMapping("/add")
	@ResponseBody
	public String add(@RequestParam("id") Integer bookId, HttpSession session) {
		try {
			if (bookId == null)
				return "error";

			MemberVO member = getLoginMember(session);
			if (member == null)
				return "error";

			basketService.add(member.getId(), bookId);
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