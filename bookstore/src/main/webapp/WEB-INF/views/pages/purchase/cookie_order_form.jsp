<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 💥 [수리 완료] 전용 스타일 타격을 위한 고유 ID(cosmic-guest-order-container) 부여! --%>
<div id="cosmic-guest-order-container" class="container mt-5 mb-5">
    <h2 class="form-main-title">주문서 작성</h2>
    <div class="alert alert-info cosmic-alert" role="alert">
        <strong>💡 주문 확인 방법 안내</strong><br>
        <strong>주문번호</strong>, <strong>이름</strong>을 입력하여 배송 현황을 조회할 수 있습니다.<br>
        주문번호는 결제 완료 시 안내되오니 참고 부탁드립니다.<br>
        주문번호 분실 시에는 <strong>이름</strong>, <strong>전화번호</strong>, <strong>별명</strong>을 입력하여 주문번호를 확인하실 수 있습니다.
    </div>
    
    <hr class="cosmic-hr">
    
    <form action="${pageContext.request.contextPath}/cookie/purchase/buy" method="post">
        
        <%-- 📡 [관제 동기화] 결제 대상 상품 ID 리스트 포워딩 --%>
        <input type="hidden" name="ids" value="${param.ids}">
        
        <%-- 🪐 [미래 자산] PG사 결제 연동 시 필요한 paymentKey 파이프라인 선제 확보 --%>
        <input type="hidden" name="paymentKey" value="MOCK_PAYMENT_KEY_SUCCESS">
        
        <c:if test="${isGuest}">
            <div class="card mb-4 cosmic-card">
                <div class="card-header">배송 정보 입력</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label>이름</label>
                        <input type="text" name="name" class="form-control" placeholder="예: 홍길동" required>
                    </div>
                    <div class="mb-3">
                        <label>전화번호</label>
                        <input type="text" name="phone" class="form-control" 
                           pattern="[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}" 
                           title="010-0000-0000"
                           placeholder="예: 010-0000-0000" required>
                    </div>
                    <div class="mb-3">
                        <label>별명</label>
                        <input type="text" name="nickname" class="form-control" placeholder="예: 별명" required>
                    </div>
                    <div class="mb-3">
                        <label>배송지 주소</label>
                        <input type="text" name="address" class="form-control" placeholder="예: 서울특별시 중랑구 용마산로90길 28 (면목동)" required>
                    </div>
                </div>
            </div>
        </c:if>

        <div class="card mb-4 cosmic-card">
            <div class="card-header">주문 상품</div>
            <div class="card-body">
                <table class="table align-middle cosmic-order-table">
				    <thead>
				        <tr>
				            <%-- 💥 [타격 지점] 각 칸의 가로폭(width)을 강제 할당하여 찌그러짐 원천 차단! --%>
				            <th style="width: 120px; text-align: center;">표지</th>
				            <th style="width: auto; text-align: left; padding-left: 20px;">상품명</th>
				            <th style="width: 100px; text-align: center;">수량</th>
				            <th style="width: 150px; text-align: center;">가격</th>
				        </tr>
				    </thead>
				    <tbody>
				        <c:forEach items="${purchaseList}" var="item" varStatus="status">
				            <tr class="item-row">
				                <td style="text-align: center;">
				                    <img src="${item.image}" alt="Cover" style="width: 70px; height: 100px; object-fit: cover; border-radius: 4px;"
				                         onerror="this.onerror=null; this.src='https://placehold.co/150x220/f8fafc/a4b0be?text=No+Cover';">
				                </td>
				                <%-- 💥 [타격 지점] text-light 제거하고 text-dark 주입! --%>
				                <td class="fw-bold text-dark" style="text-align: left; padding-left: 20px; font-size: 1.1rem;">
				                    ${item.title}
				                </td>
				                <td style="text-align: center; font-size: 1.1rem; color: #2f3542;">
				                    ${item.quantity}개
				                </td>
				                <%-- 💥 [타격 지점] 가격 칸 줄바꿈 강제 방지 (nowrap) --%>
				                <td class="fw-bold text-primary" style="text-align: center; font-size: 1.2rem; white-space: nowrap;">
				                    ${item.price * item.quantity}원
				                </td>
				            </tr>
				            
				            <input type="hidden" name="items[${status.index}].saleId" value="${item.saleId}">
				            <input type="hidden" name="items[${status.index}].quantity" class="calc-qty" value="${item.quantity}">
				            <input type="hidden" name="items[${status.index}].price" class="calc-price" value="${item.price}">
				        </c:forEach>
				    </tbody>
				</table>
            </div>
        </div>

        <div class="text-right d-flex flex-column align-items-end mb-5 total-price-box">
            <h3>총 결제 금액: <span id="displayTotalPrice" class="text-primary-glow">0</span>원</h3>
            <input type="hidden" name="totalPrice" id="hiddenTotalPrice" value="0">
            <button type="submit" class="btn btn-cosmic-submit btn-lg mt-3 px-5" onclick="return calculateAndSubmit();">결제하기</button>
        </div>
    </form>
</div>

<script>
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
            alert("🚨 결제할 상품 금액이 0원입니다.");
            return false; 
        }
        return true;
    }

    window.addEventListener('DOMContentLoaded', (event) => {
        calculateAndSubmit();
    });
</script>