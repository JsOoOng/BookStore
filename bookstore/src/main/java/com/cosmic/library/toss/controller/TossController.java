package com.cosmic.library.toss.controller;


import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.cosmic.library.purchase.model.Purchase;
import com.cosmic.library.purchase.service.PurchaseService;
import com.cosmic.library.toss.service.TossService;



@Controller
@RequestMapping("/order")
public class TossController {
	
	private final TossService tossService;

	public TossController(TossService tossService) {
	    this.tossService = tossService;
	}
	
	@Autowired
	private PurchaseService purchaseService;

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    // =========================
    // 1. 결제 승인 API (토스)
    // =========================
    @PostMapping("/confirm")
    @ResponseBody
    public ResponseEntity<JSONObject> confirmPayment(@RequestBody String jsonBody) throws Exception {
    	System.out.println("호출!!!!!!!!!!");
    	
        JSONParser parser = new JSONParser();

        JSONObject requestData = (JSONObject) parser.parse(jsonBody);

        String paymentKey = (String) requestData.get("paymentKey");
        String orderId = (String) requestData.get("orderId");
        int amount = Integer.parseInt(String.valueOf(requestData.get("amount")));

        JSONObject obj = new JSONObject();
        obj.put("orderId", orderId);
        obj.put("amount", amount);
        obj.put("paymentKey", paymentKey);

        String widgetSecretKey = "test_gsk_docs_OaPz8L5KdmQXkzRz3y47BMw6";

        Base64.Encoder encoder = Base64.getEncoder();
        String authorizations =
                "Basic " + new String(encoder.encode((widgetSecretKey + ":")
                .getBytes(StandardCharsets.UTF_8)));

        URL url = new URL("https://api.tosspayments.com/v1/payments/confirm");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        connection.setRequestProperty("Authorization", authorizations);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestMethod("POST");
        connection.setDoOutput(true);

        OutputStream outputStream = connection.getOutputStream();
        outputStream.write(obj.toString().getBytes(StandardCharsets.UTF_8));

        int code = connection.getResponseCode();

        InputStream responseStream =
                code == 200 ? connection.getInputStream() : connection.getErrorStream();

        JSONObject jsonObject = (JSONObject) parser.parse(
                new InputStreamReader(responseStream, StandardCharsets.UTF_8));

        responseStream.close();

        // 🔥 핵심 추가 (DB 반영)
        if (code == 200) {
            tossService.confirmPayment(orderId, paymentKey, amount);
            tossService.approveOrder(orderId, paymentKey);
        }

        return ResponseEntity.status(code).body(jsonObject);
    }

    // =========================
    // 2. 결제 성공 페이지
    // =========================
    @GetMapping("/success")
    public String success(
            @RequestParam String paymentKey,
            @RequestParam String orderId,
            @RequestParam int amount,
            Model model) {

        model.addAttribute("paymentKey", paymentKey);
        model.addAttribute("orderId", orderId);
        model.addAttribute("amount", amount);
        
        // 💥 [궤도 수정] 알맹이 jsp 경로를 pageName에 담고 공통 레이아웃으로 쏜다!
        model.addAttribute("pageName", "pages/toss/success"); // ⚠️ 실제 폴더 경로에 맞게 조정할 것 (예: pages/toss/success)
        return "common/layout";
    }

    // =========================
    // 3. 메인 결제 페이지
    // =========================
    @GetMapping("/checkout")
    public String checkout(@RequestParam String orderId,
                           @RequestParam int amount,
                           Model model) {
        model.addAttribute("orderId", orderId);
        model.addAttribute("amount", amount);
        
        // 💥 [궤도 수정]
        model.addAttribute("pageName", "pages/toss/checkout"); 
        return "common/layout";
    }

    // =========================
    // 4. 결제 실패 페이지
    // =========================
    @GetMapping("/fail")
    public String fail(HttpServletRequest request, Model model) {

        String code = request.getParameter("code");
        String message = request.getParameter("message");

        if (code == null) code = "UNKNOWN_ERROR";
        if (message == null) message = "결제 실패";

        model.addAttribute("code", code);
        model.addAttribute("message", message);
        
        // 💥 [궤도 수정]
        model.addAttribute("pageName", "pages/toss/fail"); 
        return "common/layout";
    }
}