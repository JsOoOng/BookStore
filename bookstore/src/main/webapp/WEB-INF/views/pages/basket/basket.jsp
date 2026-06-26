<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container mt-4 mb-5">

    <%-- 🌌 헤더 타이틀 구역 --%>
    <div class="cosmic-title-section mb-4 border-0">
        <span class="cosmic-logo-icon">🛒</span>
        <h2 class="cosmic-main-title text-primary-cosmic">Cosmic Basket</h2>
        <p class="cosmic-subtitle-text">🚀 ${loginMember.name} 대원의 장바구니 보관소입니다.</p>
    </div>

    <%-- ⚙️ 상단 제어 바 --%>
    <div class="cosmic-basket-top-bar">
        <div class="cosmic-check-group">
            <input type="checkbox" id="selectAll" class="cosmic-checkbox">
            <label for="selectAll">전체 선택</label>
        </div>
        
        <div class="cosmic-basket-btn-group">
            <button type="button" class="btn-cancel-cosmic btn-sm" onclick="confirmDelete()">선택 삭제</button>
        </div>
    </div>

    <%-- 📚 장바구니 도서 목록 폼 --%>
    <form action="${pageContext.request.contextPath}/basket/delete" method="post" id="deleteForm">
        <div class="cosmic-basket-list">
            <c:choose>
                <c:when test="${not empty basketList}">
                    <c:forEach var="vo" items="${basketList}">
                        <div class="cosmic-basket-card book-item">
                            <div class="basket-checkbox-wrap">
                                <%-- 모든 항목 기본 체크 --%>
                                <input type="checkbox" name="ids" value="${vo.basketId}" class="selectItem cosmic-checkbox" checked>
                            </div>

                            <img src="${vo.image}" class="basket-item-img" onerror="this.onerror=null; this.src='https://via.placeholder.com/100x150?text=No+Img';">

                            <div class="basket-item-info">
                                <h3 class="basket-item-title">${vo.title}</h3>
                                <p class="basket-item-author">👨‍🚀 ${vo.writer}</p>

                                <div class="basket-price-qty-row">
                                    <div class="qty-control">
                                        <label>수량:</label>
                                        <input type="number" value="${vo.quantity}" min="1" class="quantity cosmic-qty-input" data-price="${vo.price}">
                                    </div>
                                    <div class="book-price totalPrice">
                                        💫 0 원
                                    </div>
                                </div>

                                <div class="basket-item-actions">
                                    <button type="button" class="btn-cancel-cosmic btn-sm" onclick="deleteOne(${vo.basketId})">🗑 삭제</button>
                                    <button type="button" class="btn-confirm-cosmic btn-sm" onclick="checkAddressBeforeOrder('single', '${vo.basketId}')">🚀 바로 구매</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="cosmic-empty-basket text-center">
                        <span class="empty-icon">🕳️</span>
                        <p>장바구니가 우주의 진공 상태처럼 비어있습니다.</p>
                        <a href="${pageContext.request.contextPath}/book/list" class="btn-confirm-cosmic mt-3 d-inline-block text-decoration-none">도서 탐색하러 가기</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        
        <%-- 💳 총 결제 금액 패널 --%>
        <div class="cosmic-total-panel mt-4">
            <span class="total-label">💳 총 결제 예정 금액:</span>
            <span class="total-amount"><span id="totalPrice">0</span> 원</span>
            
            <button type="button" class="btn-checkout-cosmic" onclick="checkAddressBeforeOrder('multiple', null)">
                결제하기 ➔
            </button>
        </div>
    </form>
</div>

<%-- 🌌 물류 보급지 배송 주소 설정 모달 --%>
<div class="modal fade" id="addressModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addressModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content cosmic-admin-modal">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title admin-modal-title" id="addressModalLabel">🌌 물류 보급지 배송 주소 설정</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body pt-4">
                <p class="form-desc-text mb-4 text-center">안전하고 정확한 광속 지식 보급을 위해 대원님의 실제 거주지 또는 보급 좌표(주소) 입력을 완료해 주세요.</p>
                <div class="input-group-cosmic">
                    <label for="modalAddressInput">🏠 보급품 수령 주소</label>
                    <input type="text" id="modalAddressInput" placeholder="예: 경기도 고양시 일산동구 ...">
                </div>
            </div>
            <div class="modal-footer border-top-0 pt-0 d-flex gap-2">
                <button type="button" class="btn-cancel-cosmic flex-fill" data-bs-dismiss="modal">정선 회항</button>
                <button type="button" class="btn-submit-admin flex-fill" onclick="submitAddressAjax()">주소 확정 및 결제선 진입</button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    // 🗑 [삭제 엔진] 선택 삭제 확인
    function confirmDelete() {
        let selected = [];
        document.querySelectorAll(".selectItem:checked").forEach(cb => { selected.push(cb.value); });
        if (selected.length === 0) { alert("삭제할 항목을 선택해 주세요."); return; }
        if (confirm("선택하신 " + selected.length + "개의 항목을 삭제하시겠습니까?")) {
            document.getElementById("deleteForm").submit();
        }
    }

    // 🗑 [단일 삭제]
    function deleteOne(basketId) {
        if (confirm("해당 도서를 장바구니에서 삭제하시겠습니까?")) {
            const form = document.getElementById("deleteForm");
            const input = document.createElement("input");
            input.type = "hidden"; input.name = "basketId"; input.value = basketId;
            form.appendChild(input);
            form.submit();
        }
    }

    // ⚙️ [체크박스 제어]
    const selectAll = document.getElementById("selectAll");
    
    selectAll.addEventListener("change", function() {
        document.querySelectorAll(".selectItem").forEach(cb => { cb.checked = selectAll.checked; });
        updateTotal();
    });
    
    function updateSelectAllCheckbox() {
        const items = document.querySelectorAll(".selectItem");
        const checkedItems = document.querySelectorAll(".selectItem:checked");
        selectAll.checked = (items.length > 0 && items.length === checkedItems.length);
    }

    document.querySelectorAll(".selectItem").forEach(cb => {
        cb.addEventListener("change", function() {
            updateTotal();
            updateSelectAllCheckbox();
        });
    });

    // 💰 [금액 계산 엔진]
    function updateTotal() {
        let total = 0;
        document.querySelectorAll(".book-item").forEach(item => {
            const checkbox = item.querySelector(".selectItem");
            const quantity = item.querySelector(".quantity");
            const price = parseInt(quantity.dataset.price);
            if (checkbox.checked) {
                total += price * quantity.value;
                item.querySelector(".totalPrice").innerText = "💫 " + (price * quantity.value).toLocaleString() + " 원";
            } else {
                item.querySelector(".totalPrice").innerText = "💫 0 원";
            }
        });
        document.getElementById("totalPrice").innerText = total.toLocaleString();
    }

    // 🔢 [수량 변경]
    document.querySelectorAll(".quantity").forEach(input => {
        input.addEventListener("change", function() {
            const qty = parseInt(this.value);
            if (qty < 1 || isNaN(qty)) { this.value = 1; updateTotal(); return; }
            const basketId = this.closest(".book-item").querySelector(".selectItem").value;
            let formData = new URLSearchParams();
            formData.append("basketId", basketId); formData.append("qty", qty);
            
            fetch("${pageContext.request.contextPath}/basket/updateQty", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            }).then(res => res.text()).then(data => {
                if (data.trim() === "ok") updateTotal();
            });
        });
    });

    // 🚀 [주소 및 구매 로직]
    let orderMode = "", currentBasketIds = "";

    function checkAddressBeforeOrder(mode, singleId) {
        orderMode = mode;
        if (orderMode === 'single') {
            currentBasketIds = singleId;
        } else {
            let selected = [];
            document.querySelectorAll(".selectItem:checked").forEach(cb => { selected.push(cb.value); });
            if (selected.length === 0) { alert("구매할 항목을 선택하세요!"); return; }
            currentBasketIds = selected.join(",");
        }

        const currentAddress = "${loginMember.address}";
        if (!currentAddress || currentAddress.trim() === "" || currentAddress === "은하계 미지정 구역") {
            $('#addressModal').addClass('show').css({'display': 'block', 'background': 'rgba(11, 19, 43, 0.5)'});
            $('body').addClass('modal-open');
        } else {
            proceedToPurchase();
        }
    }

    function submitAddressAjax() {
        const inputAddress = document.getElementById('modalAddressInput').value.trim();
        if (inputAddress === "") { alert("주소를 입력해 주세요!"); return; }
        let formData = new URLSearchParams();
        formData.append("address", inputAddress);

        fetch("${pageContext.request.contextPath}/member/updateAddressAjax", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        }).then(res => res.text()).then(data => {
            if (data.trim() === "OK") { closeCosmicModal(); proceedToPurchase(); }
        });
    }

    function closeCosmicModal() {
        $('#addressModal').removeClass('show').css('display', 'none');
        $('.modal-backdrop').remove();
        $('body').removeClass('modal-open');
    }

    function proceedToPurchase() {
        location.href = "${pageContext.request.contextPath}/basket/buy?basketIds=" + currentBasketIds;
    }

    $(document).ready(function() {
        updateTotal();
        updateSelectAllCheckbox();
    });
</script>