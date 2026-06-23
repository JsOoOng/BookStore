<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container mt-4 mb-5">

    <%-- 상단 제어 바 --%>
    <div class="cosmic-basket-top-bar">
        <div class="cosmic-check-group">
            <input type="checkbox" id="selectAll" class="cosmic-checkbox">
            <label for="selectAll">전체 선택</label>
        </div>
        <div class="cosmic-basket-btn-group">
            <button type="button" class="btn-cancel-cosmic btn-sm" onclick="deleteSelected()">선택 삭제</button>
            <button type="button" class="btn-confirm-cosmic btn-sm" id="buyBtn">🛒 선택 구매</button>
        </div>
    </div>

    <%-- 장바구니 도서 목록 --%>
    <div class="cosmic-basket-list">
        <c:choose>
            <c:when test="${not empty purchaseList}">
                <c:forEach var="item" items="${purchaseList}" varStatus="status">
                    <div class="cosmic-basket-card book-item">
                        <div class="basket-checkbox-wrap">
                            <input type="checkbox" name="ids" value="${item.saleId}" class="selectItem cosmic-checkbox" checked>
                        </div>

                        <%-- 💥 인라인 스타일 삭제 및 CSS 클래스로 이관! --%>
                        <img src="${item.image.trim()}" class="basket-item-img" 
                             onerror="this.onerror=null; this.src='https://via.placeholder.com/100x150?text=No+Cover';">

                        <div class="basket-item-info">
                            <h3 class="basket-item-title">${item.title}</h3>
                            <p class="basket-item-author">👨‍🚀 ${item.writer}</p>

                            <div class="basket-price-qty-row">
                                <div class="qty-control">
                                    <label>수량:</label>
                                    <input type="number" value="${item.quantity}" min="1" class="quantity cosmic-qty-input" 
                                           data-price="${item.price}" data-saleid="${item.saleId}">
                                </div>
                                <div class="book-price totalPrice">
                                    💫 <fmt:formatNumber value="${item.quantity * item.price}" pattern="#,###"/> 원
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="cosmic-empty-basket text-center">
                    <span class="empty-icon">🕳️</span>
                    <p>장바구니가 비어 있습니다.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 총 결제 금액 패널 --%>
    <div class="cosmic-total-panel mt-4">
        <span class="total-label">💳 총 결제 예정 금액:</span>
        <span class="total-amount"><span id="totalPrice">0</span> 원</span>
        <button type="button" class="btn-checkout-cosmic" id="finalBuyBtn">결제하기 ➔</button>
    </div>
</div>

<script>
    document.getElementById("selectAll").addEventListener("change", function() {
        document.querySelectorAll(".selectItem").forEach(cb => cb.checked = this.checked);
        updateTotal();
    });

    document.querySelectorAll(".quantity").forEach(input => {
        input.addEventListener("change", function() {
            const saleId = this.dataset.saleid;
            const newQty = this.value;

            fetch("${pageContext.request.contextPath}/cookie/basket/update", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "saleId=" + saleId + "&qty=" + newQty
            })
            .then(res => res.text())
            .then(data => {
                if(data.trim() === "ok") {
                    updateTotal(); 
                } else {
                    alert("수량 변경에 실패했습니다.");
                }
            });
        });
    });

    function updateTotal() {
        let total = 0;
        document.querySelectorAll(".book-item").forEach(item => {
            const checkbox = item.querySelector(".selectItem");
            const qtyInput = item.querySelector(".quantity");
            if(checkbox && checkbox.checked) {
                const qty = parseInt(qtyInput.value) || 0;
                const price = parseFloat(qtyInput.dataset.price) || 0;
                total += (qty * price);
                item.querySelector(".totalPrice").innerText = "💫 " + (qty * price).toLocaleString() + " 원";
            }
        });
        document.getElementById("totalPrice").innerText = total.toLocaleString();
    }

    // 결제선 워프 함수
    function goToCheckout() {
        location.href = "${pageContext.request.contextPath}/cookie/basket/checkout";
    }
    document.getElementById("buyBtn").addEventListener("click", goToCheckout);
    document.getElementById("finalBuyBtn").addEventListener("click", goToCheckout);

    // 삭제 버튼 동작 스텁 (필요시 백엔드 연결)
    function deleteSelected() {
        alert("비회원 선택 삭제 기능은 백엔드 통신이 필요합니다!");
    }

    updateTotal();
</script>