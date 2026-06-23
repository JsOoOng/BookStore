<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5">
    <h2>주문서 작성</h2>
    <hr>
    
    <form action="${pageContext.request.contextPath}/cookie/purchase/buy" method="post">
        
        <%-- 📡 [추가] 결제한 상품들의 ID를 서버로 다시 전달하기 위한 히든 필드 --%>
        <input type="hidden" name="ids" value="${param.ids}">
        
        <c:if test="${isGuest}">
            <div class="card mb-4">
                <div class="card-header">배송 정보 입력</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label>받으시는 분</label>
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
                                    <img src="${item.image}" alt="Cover"
                                         onerror="this.onerror=null; this.src='https://via.placeholder.com/70x100?text=No+Cover';">
                                </td>
                                <td class="fw-bold">${item.title}</td>
                                <td>${item.quantity}개</td>
                                <td>${item.price * item.quantity}원</td>
                            </tr>
                            
                            <input type="hidden" name="items[${status.index}].saleId" value="${item.saleId}">
                            <input type="hidden" name="items[${status.index}].quantity" class="calc-qty" value="${item.quantity}">
                            <input type="hidden" name="items[${status.index}].price" class="calc-price" value="${item.price}">
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="text-right">
            <h3>총 결제 금액: <span id="displayTotalPrice">0</span>원</h3>
            <input type="hidden" name="totalPrice" id="hiddenTotalPrice" value="0">
            <button type="submit" class="btn btn-primary btn-lg" onclick="return calculateAndSubmit();">결제하기</button>
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
            alert("🚨 결제할 상품 금액이 0원입니다. 주문 궤도를 이탈합니다.");
            return false; 
        }
        return true;
    }

    window.addEventListener('DOMContentLoaded', (event) => {
        calculateAndSubmit();
    });
</script>