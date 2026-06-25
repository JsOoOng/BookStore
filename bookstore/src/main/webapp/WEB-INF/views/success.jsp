<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <link rel="icon" href="https://static.toss.im/icons/png/4x/icon-toss-logo.png" />
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/style.css" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>결제 완료</title>
</head>

<script>
window.onload = async function() {

    try {

        const response = await fetch("/order/confirm", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                paymentKey: "${paymentKey}",
                orderId: "${orderId}",
                amount: ${amount}
            })
        });

        const result = await response.json();

        console.log(result);

        if (!response.ok) {
            alert("결제 승인 실패");
            console.error(result);
        }

    } catch(e) {
        console.error("confirm 호출 실패", e);
    }
};
</script>

<body>

<div class="box_section" style="width: 600px">
    <img width="100px" src="https://static.toss.im/illusts/check-blue-spot-ending-frame.png" />
    <h2>결제를 완료했어요</h2>

    <div class="p-grid typography--p" style="margin-top: 50px">
        <div class="p-grid-col text--left"><b>결제금액</b></div>
        <div class="p-grid-col text--right">${amount}원</div>
    </div>

    <div class="p-grid typography--p" style="margin-top: 10px">
        <div class="p-grid-col text--left"><b>주문번호</b></div>
        <div class="p-grid-col text--right">${orderId}</div>
    </div>

    <div class="p-grid typography--p" style="margin-top: 10px">
        <div class="p-grid-col text--left"><b>paymentKey</b></div>
        <div class="p-grid-col text--right" style="word-break: break-all;">
            ${paymentKey}
        </div>
    </div>

    <div class="p-grid" style="margin-top: 30px">
        <button class="button p-grid-col5"
                onclick="location.href='https://docs.tosspayments.com/guides/v2/payment-widget/integration';">
            연동 문서
        </button>

        <button class="button p-grid-col5"
                onclick="location.href='https://discord.gg/A4fRFXQhRu';"
                style="background-color: #e8f3ff; color: #1b64da">
            실시간 문의
        </button>
    </div>
    <div class="p-grid" style="margin-top: 15px">
    <button class="button"
            style="width: 100%;"
            onclick="location.href='http://localhost:8888/'">
        메인으로 돌아가기
    </button>
</div>
    
</div>

</body>
</html>