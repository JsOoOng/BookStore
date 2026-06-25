<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5">
    <h2>주문서 작성</h2>
    <div class="alert alert-info" role="alert">
	    <strong>💡 주문 확인 방법 안내</strong><br>
	    주문 완료 후 제공되는 <strong>주문번호</strong>와 <strong>이름</strong>을 입력하여 배송 현황을 조회할 수 있습니다. 
	    주문번호는 결제 완료 시 안내되오니 참고 부탁드립니다.
	</div>
    
    <hr>
    
    <form action="${pageContext.request.contextPath}/cookie/purchase/buy" method="post">
        
        <%-- 📡 [관제 동기화] 결제 대상 상품 ID 리스트 포워딩 --%>
        <input type="hidden" name="ids" value="${param.ids}">
        
        <%-- 🪐 [미래 자산] PG사 결제 연동 시 필요한 paymentKey 파이프라인 선제 확보 --%>
        <input type="hidden" name="paymentKey" value="MOCK_PAYMENT_KEY_SUCCESS">
        
        <c:if test="${isGuest}">
            <div class="card mb-4">
                <div class="card-header">배송 정보 입력</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label>이름</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>연락처</label>
                        <input type="text" name="phone" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>배송지 주소</label>
                        <input type="text" name="address" class="form-control" required>
                    </div>
                </div>
            </div>
        </c:if>

        <div class="card mb-4">
            <div class="card-header">주문 상품</div>
            <div class="card-body">
                <table class="table align-middle">
                    <thead>
                        <tr>
                            <th style="width: 120px;">표지</th>
                            <th>상품명</th>
                            <th>수량</th>
                            <th>가격</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${purchaseList}" var="item" varStatus="status">
                            <tr class="item-row">
                                <td>
                                    <%-- 💥 [수리 완료] 네트워크 차단 없는 안전한 이미지 플레이스홀더 주소로 동기화! --%>
                                    <img src="${item.image}" alt="Cover" style="width: 70px; height: 100px; object-fit: cover; border-radius: 4px;"
                                         onerror="this.onerror=null; this.src='https://placehold.co/150x220/f8fafc/a4b0be?text=No+Cover';">
                                </td>
                                <td class="fw-bold">${item.title}</td>
                                <td>${item.quantity}개</td>
                                <td>${item.price * item.quantity}원</td>
                            </tr>
                            
                            <%-- 📡 커맨드 객체 바인딩 파이프라인 (CookieOrderVO 내의 List<BasketVO> items 와 100% 결합) --%>
                            <input type="hidden" name="items[${status.index}].saleId" value="${item.saleId}">
                            <input type="hidden" name="items[${status.index}].quantity" class="calc-qty" value="${item.quantity}">
                            <input type="hidden" name="items[${status.index}].price" class="calc-price" value="${item.price}">
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="text-right d-flex flex-column align-items-end mb-5">
            <h3>총 결제 금액: <span id="displayTotalPrice">0</span>원</h3>
            <input type="hidden" name="totalPrice" id="hiddenTotalPrice" value="0">
            <button type="submit" class="btn btn-primary btn-lg mt-2 px-5" onclick="return calculateAndSubmit();">결제하기</button>
        </div>
    </form>
</div>

<script>
    // 📊 실시간 금액 연산 및 검증 시퀀스
    function calculateAndSubmit() {
        let total = 0;
        const qtys = document.querySelectorAll('.calc-qty');
        const prices = document.querySelectorAll('.calc-price');

        for (let i = 0; i < qtys.length; i++) {
            const qty = parseInt(qtys[i].value) || 0;
            const price = parseInt(prices[i].value) || 0;
            total += (qty * price);
        }

        document.getElementById('hiddenTotalPrice').value = total;
        document.getElementById('displayTotalPrice').innerText = total.toLocaleString();

        if (total <= 0) {
            alert("🚨 결제할 상품 금액이 0원입니다. 주문 궤도를 이탈합니다.");
            return false; 
        }
        return true;
    }

    // 초기 화면 로드 시 연산 엔진 즉시 시동
    window.addEventListener('DOMContentLoaded', (event) => {
        calculateAndSubmit();
    });
</script>