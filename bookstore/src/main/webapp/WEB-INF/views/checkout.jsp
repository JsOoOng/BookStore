<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <link rel="icon" href="https://static.toss.im/icons/png/4x/icon-toss-logo.png" />
    <link rel="stylesheet" type="text/css" href="/resources/css/style.css" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>토스 결제</title>

    <script src="https://js.tosspayments.com/v2/standard"></script>

    <script>
        // 🔥 서버에서 받은 데이터
        const orderId = "${orderId}";
        const orderName = "${empty orderName ? '도서 결제' : orderName}";
        const amountValue = ${amount};
        const customerEmail = "${customerEmail}";
        const customerName = "${customerName}";
        const customerMobilePhone = "01012345678"; /*알고 봤더니 우리 전화번호 없음*/
    </script>
</head>

<body>

<div class="wrapper">
    <div class="box_section" style="padding: 40px">

        <div id="payment-method"></div>
        <div id="agreement"></div>

        <div style="padding-left: 25px">
            <label>
                <input id="coupon-box" type="checkbox" />
                5,000원 쿠폰 적용
            </label>
        </div>

        <button id="payment-button" style="margin-top: 30px">
            결제하기
        </button>

    </div>
</div>

<script>
    main();

    async function main() {

        const button = document.getElementById("payment-button");
        const coupon = document.getElementById("coupon-box");

        const amount = {
            currency: "KRW",
            value: amountValue
        };

        const clientKey = "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm";

        const tossPayments = TossPayments(clientKey);

        const widgets = tossPayments.widgets({
            customerKey: generateRandomString()
        });

        await widgets.setAmount(amount);

        await widgets.renderPaymentMethods({
            selector: "#payment-method",
            variantKey: "DEFAULT",
        });

        await widgets.renderAgreement({
            selector: "#agreement",
            variantKey: "AGREEMENT"
        });

        // 쿠폰
        coupon.addEventListener("change", async function () {

            if (coupon.checked) {
                await widgets.setAmount({
                    currency: "KRW",
                    value: amount.value - 5000
                });
                return;
            }

            await widgets.setAmount(amount);
        });

        // 결제 버튼
        button.addEventListener("click", async function () {

            await widgets.requestPayment({
                orderId: orderId,   // 🔥 서버에서 생성된 값 사용 (중요)
                orderName: orderName,

                successUrl: window.location.origin + "/order/success",
                failUrl: window.location.origin + "/order/fail",

                customerEmail: customerEmail,
                customerName: customerName,
                customerMobilePhone: customerMobilePhone
            });
        });
    }

    function generateRandomString() {
        return window.btoa(Math.random()).slice(0, 20);
    }
</script>

</body>
</html>