<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- ❌ main-content 제거 (layout에서 이미 감쌈) -->

	<div class="basket-header">

    	<h2 class="cosmic-title">
        🚀 ${loginMember.name} 대원의 장바구니
    	</h2>

	</div>

	<div class="top-action-bar">

    <div class="right-buttons">

        <button type="submit" form="deleteForm"
            class="btn-cosmic btn-delete btn-unified">
            선택 삭제
        </button>

        <button type="button"
            class="btn-cosmic btn-confirm btn-unified"
            id="buyBtn">
            🛒 선택 구매
        </button>

        <a href="/" class="btn-home">
            🪐 홈
        </a>

    	</div>
	
	</div>

<form action="${pageContext.request.contextPath}/basket/delete"
      method="post" id="deleteForm">

    <!-- 🔥 카드 리스트 -->
    <div class="book-list">

        <c:forEach var="vo" items="${basketList}">

            <div class="book-item">

                <!-- 체크 -->
                <div style="margin-right:10px;">
                    <input type="checkbox"
                           name="ids"
                           value="${vo.basketId}"
                           class="selectItem">
                </div>

                <!-- 이미지 -->
                <img src="${pageContext.request.contextPath}${vo.image}"
                     class="book-img">

                <!-- 정보 -->
                <div class="book-info">

                    <!-- 제목 -->
                    <h3 class="book-title">${vo.title}</h3>

                    <!-- 작가 -->
                    <p class="book-author">
					    👨‍🚀 ${vo.writer}
					</p>

                    <!-- 수량 + 가격 -->
                    <div style="display:flex; align-items:center; gap:15px; flex-wrap:wrap;">

                        <!-- 수량 -->
                        <div>
                            수량:
                            <input type="number"
                                   value="${vo.quantity}"
                                   min="1"
                                   class="quantity"
                                   data-price="${vo.price}"
                                   style="width:60px;">
                        </div>

                        <!-- 가격 -->
                        <div class="book-price totalPrice">
						    💫 <fmt:formatNumber value="${vo.quantity * vo.price}" pattern="#,###"/> 원
						</div>

                    </div>

                    <!-- 버튼 -->
                    <div class="form-actions" style="margin-top:20px;">

                        <button type="button"
                                class="btn-cosmic btn-delete"
                                onclick="deleteOne(${vo.basketId})">
                            🗑 삭제
                        </button>

                        <button type="button"
                                class="btn-cosmic btn-confirm"
                                onclick="location.href='${pageContext.request.contextPath}/basket/buy?basketIds=${vo.basketId}'">
                            🚀 바로 구매
                        </button>

                    </div>

                </div>

            </div>

        </c:forEach>

    </div>
	<!-- 🔥 총 결제 금액 -->
	<div class="total-box">
	    💳 총 결제 금액: <span id="totalPrice">0</span> 원
	</div>
</form>
<script>
	function updateTotal() {
	
	    let total = 0;
	
	    document.querySelectorAll(".book-item").forEach(item => {
	
	        const checkbox = item.querySelector(".selectItem");
	        const quantity = item.querySelector(".quantity");
	        const price = parseInt(quantity.dataset.price);
	
	        // 체크된 것만 합산
	        if (checkbox.checked) {
	            total += price * quantity.value;
	        }
	
	        // 개별 가격 업데이트
	        const priceBox = item.querySelector(".totalPrice");
	        priceBox.innerText = "💫 " + (price * quantity.value).toLocaleString() + " 원";
	    });
	
	    document.getElementById("totalPrice").innerText = total.toLocaleString();
	}
	
	// 🔥 수량 변경 시
	document.querySelectorAll(".quantity").forEach(input => {
	    input.addEventListener("input", updateTotal);
	});
	
	// 🔥 체크 변경 시
	document.querySelectorAll(".selectItem").forEach(check => {
	    check.addEventListener("change", updateTotal);
	});
	
	// 🔥 선택 구매 버튼
	document.getElementById("buyBtn").addEventListener("click", function () {
	
	    let selected = [];
	
	    document.querySelectorAll(".selectItem:checked").forEach(cb => {
	        selected.push(cb.value);
	    });
	
	    if (selected.length === 0) {
	        alert("구매할 항목을 선택하세요!");
	        return;
	    }
	
	    // ⭐ purchase로 이동
	    location.href = "/basket/buy?basketIds=" + selected.join(",");
	});
	
	// 최초 실행
	updateTotal();
	</script>