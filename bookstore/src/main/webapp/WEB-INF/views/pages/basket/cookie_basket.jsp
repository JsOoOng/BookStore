<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container mt-4 mb-5">
    <%-- 🌌 헤더 --%>
    <div class="cosmic-title-section mb-4 border-0">
        <span class="cosmic-logo-icon">🛒</span>
        <h2 class="cosmic-main-title text-primary-cosmic">Guest Basket</h2>
        <p class="cosmic-subtitle-text">🚀 비회원 대원의 임시 장바구니 보관소입니다.</p>
    </div>

    <%-- ⚙️ 상단 제어 바 --%>
    <div class="cosmic-basket-top-bar">
        <div class="cosmic-check-group">
            <input type="checkbox" id="selectAll" class="cosmic-checkbox">
            <label for="selectAll">전체 선택</label>
        </div>
        <div class="cosmic-basket-btn-group">
            <button type="button" class="btn-cancel-cosmic btn-sm" onclick="deleteSelected()">선택 삭제</button>
        </div>
    </div>

    <%-- 장바구니 목록 --%>
    <div class="cosmic-basket-list">
        <c:choose>
            <c:when test="${not empty purchaseList}">
                <c:forEach var="item" items="${purchaseList}">
                    <div class="cosmic-basket-card book-item">
                        <div class="basket-checkbox-wrap">
                            <input type="checkbox" name="ids" value="${item.saleId}" class="selectItem cosmic-checkbox" checked>
                        </div>
                        <%-- 💥 [수리 완료] 차단당하지 않는 안전한 플레이스홀더 이미지 서버로 좌표 변경! --%>
                        <img src="${item.image}" class="basket-item-img" onerror="this.onerror=null; this.src='https://placehold.co/100x150/f8fafc/a4b0be?text=No+Img';">
                        
                        <div class="basket-item-info">
                            <h3 class="basket-item-title">${item.title}</h3>
                            <p class="basket-item-author">👨‍🚀 ${item.writer}</p>
                            
                            <div class="basket-price-qty-row">
                                <div class="qty-control">
                                    <label>수량:</label>
                                    <input type="number" value="${item.quantity}" min="1" class="quantity cosmic-qty-input" 
                                           data-price="${item.price}" data-saleid="${item.saleId}">
                                </div>
                                <div class="book-price totalPrice">💫 0 원</div>
                            </div>

                            <%-- 개별 삭제 버튼 추가 --%>
                            <div class="basket-item-actions">
                                <button type="button" class="btn-cancel-cosmic btn-sm" onclick="deleteOne('${item.saleId}')">🗑 삭제</button>
                                <button type="button" class="btn-confirm-cosmic btn-sm" onclick="buyOne('${item.saleId}')">🚀 바로 구매</button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="cosmic-empty-basket text-center">
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
    // 1. 금액 계산 엔진
    function updateTotal() {
        let total = 0;
        document.querySelectorAll(".book-item").forEach(item => {
            const checkbox = item.querySelector(".selectItem");
            const qtyInput = item.querySelector(".quantity");
            const priceDisplay = item.querySelector(".totalPrice");
            const qty = parseInt(qtyInput.value) || 0;
            const price = parseFloat(qtyInput.dataset.price) || 0;

            if (checkbox && checkbox.checked) {
                total += (qty * price);
                priceDisplay.innerText = "💫 " + (qty * price).toLocaleString() + " 원";
            } else {
                priceDisplay.innerText = "💫 0 원";
            }
        });
        document.getElementById("totalPrice").innerText = total.toLocaleString();
    }

    // 2. 이벤트 리스너들
    document.getElementById("selectAll").addEventListener("change", function() {
        document.querySelectorAll(".selectItem").forEach(cb => cb.checked = this.checked);
        updateTotal();
    });

    document.querySelectorAll(".selectItem").forEach(cb => cb.addEventListener("change", updateTotal));

    document.querySelectorAll(".quantity").forEach(input => {
        input.addEventListener("change", function() {
            fetch("${pageContext.request.contextPath}/cookie/basket/update", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "saleId=" + this.dataset.saleid + "&qty=" + this.value
            }).then(() => updateTotal());
        });
    });

    // 3. 결제하기
    document.getElementById("finalBuyBtn").addEventListener("click", function() {
        const checkedItems = document.querySelectorAll(".selectItem:checked");
        if (checkedItems.length === 0) return alert("결제할 상품을 선택해 주세요!");
        const ids = Array.from(checkedItems).map(cb => cb.value).join(",");
        location.href = "${pageContext.request.contextPath}/cookie/basket/checkout?ids=" + ids;
    });

    // 4. 삭제 로직 (단일/다중 통합)
    function deleteOne(saleId) {
        if(confirm("이 상품을 삭제하시겠습니까?")) {
            executeDelete(saleId);
        }
    }

    function deleteSelected() {
        const checkedItems = document.querySelectorAll(".selectItem:checked");
        if (checkedItems.length === 0) return alert("삭제할 상품을 선택하세요!");
        if (confirm(checkedItems.length + "개의 상품을 삭제하시겠습니까?")) {
            const ids = Array.from(checkedItems).map(cb => cb.value).join(",");
            executeDelete(ids);
        }
    }

    function executeDelete(ids) {
        fetch("${pageContext.request.contextPath}/cookie/basket/delete", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "ids=" + ids
        }).then(res => res.text()).then(data => {
            if(data.trim() === "ok") {
                location.reload();
            } else {
                alert("삭제 실패");
            }
        });
    }
    
    // 단일 구매
    function buyOne(saleId) {
        location.href = "${pageContext.request.contextPath}/cookie/basket/checkout?ids=" + saleId;
    }
    
    // 체크박스 제어
    // 페이지 로드 시 모든 상품이 체크되어 있다면 '전체 선택'도 체크
    function updateSelectAllCheckbox() {
        const allItems = document.querySelectorAll(".selectItem");
        const checkedItems = document.querySelectorAll(".selectItem:checked");
        const selectAll = document.getElementById("selectAll");
        
        // 상품이 하나라도 있고, 모두 체크된 상태라면 전체 선택도 체크
        if (allItems.length > 0 && allItems.length === checkedItems.length) {
            selectAll.checked = true;
        } else {
            selectAll.checked = false;
        }
    }

    // 기존 개별 체크박스 이벤트에 '전체 선택 상태 업데이트' 추가
    document.querySelectorAll(".selectItem").forEach(cb => {
        cb.addEventListener("change", function() {
            updateTotal();
            updateSelectAllCheckbox();
        });
    });

    // 초기 실행
    updateTotal();
    updateSelectAllCheckbox();
</script>