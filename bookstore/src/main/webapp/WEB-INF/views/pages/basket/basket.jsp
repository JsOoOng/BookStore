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

    <%-- ⚙️ 상단 제어 바 (전체선택 및 일괄 조치) --%>
    <div class="cosmic-basket-top-bar">
        <div class="cosmic-check-group">
            <input type="checkbox" id="selectAll" class="cosmic-checkbox">
            <label for="selectAll">전체 선택</label>
        </div>
        
        <div class="cosmic-basket-btn-group">
            <button type="submit" form="deleteForm" class="btn-cancel-cosmic btn-sm">선택 삭제</button>
            <button type="button" class="btn-confirm-cosmic btn-sm" id="buyBtn">🛒 선택 구매</button>
            <a href="${pageContext.request.contextPath}/" class="btn-cancel-cosmic btn-sm">🪐 홈</a>
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
                                <input type="checkbox" name="ids" value="${vo.basketId}" class="selectItem cosmic-checkbox">
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
                                        💫 <fmt:formatNumber value="${vo.quantity * vo.price}" pattern="#,###"/> 원
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
            
            <%-- 💥 새로 추가된 결제 마스터 버튼 (상단 '선택 구매'와 동일한 로직 호출) --%>
            <button type="button" class="btn-checkout-cosmic" onclick="checkAddressBeforeOrder('multiple', null)">
                결제하기 ➔
            </button>
        </div>
    </form>
</div>

<%-- 🌌 물류 보급지 배송 주소 설정 모달 (검푸른 라이트 테마 재사용) --%>
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
    const selectAll = document.getElementById("selectAll");
    const itemCheckboxes = document.querySelectorAll(".selectItem");
    
    selectAll.addEventListener("change", function() {
        itemCheckboxes.forEach(cb => {
            cb.checked = selectAll.checked;
        });
        updateTotal();
    });
    
    itemCheckboxes.forEach(check => {
        check.addEventListener("change", function() {
            const checkedCount = document.querySelectorAll(".selectItem:checked").length;
            const totalCount = itemCheckboxes.length;
            selectAll.checked = (checkedCount === totalCount);
            updateTotal();
        });
    });
    
    function updateTotal() {
        let total = 0;
        document.querySelectorAll(".book-item").forEach(item => {
            const checkbox = item.querySelector(".selectItem");
            const quantity = item.querySelector(".quantity");
            const price = parseInt(quantity.dataset.price);
    
            if (checkbox.checked) {
                total += price * quantity.value;
            }
            const priceBox = item.querySelector(".totalPrice");
            priceBox.innerText = "💫 " + (price * quantity.value).toLocaleString() + " 원";
        });
        document.getElementById("totalPrice").innerText = total.toLocaleString();
    }
    
    document.querySelectorAll(".quantity").forEach(input => {
        input.addEventListener("change", function() {
            const quantityInput = this;
            const qty = parseInt(quantityInput.value);
            
            if (qty < 1 || isNaN(qty)) {
                quantityInput.value = 1;
                updateTotal();
                return;
            }
            
            const bookItem = quantityInput.closest(".book-item");
            const basketId = bookItem.querySelector(".selectItem").value;
            
            var formData = new URLSearchParams();
            formData.append("basketId", basketId);
            formData.append("qty", qty);
            
            fetch("${pageContext.request.contextPath}/basket/updateQty", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(response => response.text())
            .then(data => {
                if (data.trim() === "ok") {
                    updateTotal();
                } else if (data.trim() === "NOT_LOGIN") {
                    alert("🔒 세션이 만료되었습니다. 로그인 페이지로 워프합니다.");
                    location.href = "${pageContext.request.contextPath}/member/login";
                } else {
                    alert("🚨 수량 동기화 실패. 다시 시도해 주세요.");
                }
            })
            .catch(error => {
                console.error("Error:", error);
                alert("🛰️ 사령부 서버와 통신이 두절되었습니다.");
            });
        });
    });
    
    document.querySelectorAll(".selectItem").forEach(check => {
        check.addEventListener("change", updateTotal);
    });
    
 // -------------------------------------------------------------
    // 🪐 [암전 현상 완벽 박멸] 순수 제이쿼리 기반 주소 검문소 엔진
    // -------------------------------------------------------------
    let orderMode = ""; 
    let currentBasketIds = "";

    function checkAddressBeforeOrder(mode, singleId) {
        orderMode = mode;

        if (orderMode === 'single') {
            currentBasketIds = singleId;
        } else {
            let selected = [];
            document.querySelectorAll(".selectItem:checked").forEach(cb => {
                selected.push(cb.value);
            });

            if (selected.length === 0) {
                alert("구매할 항목을 선택하세요!");
                return;
            }
            currentBasketIds = selected.join(",");
        }

        const currentAddress = "${loginMember.address}";

        // 주소가 없거나 은하계 미지정 구역일 때
        if (!currentAddress || currentAddress.trim() === "" || currentAddress === "은하계 미지정 구역") {
            // 🚨 라이브러리 충돌을 우회하여 CSS 강제 제어로 모달을 우아하게 개방!
            $('#addressModal').addClass('show').css({
                'display': 'block',
                'background': 'rgba(11, 19, 43, 0.5)' // 부트스트랩 백드롭 대신 코스믹 다크 배경 투사
            });
            $('body').addClass('modal-open');
        } else {
            proceedToPurchase();
        }
    }

    function submitAddressAjax() {
        const inputAddress = document.getElementById('modalAddressInput').value.trim();

        if (inputAddress === "" || inputAddress === "은하계 미지정 구역") {
            alert("보급품을 정상 전달받을 유효한 주소를 입력해 주세요!");
            document.getElementById('modalAddressInput').focus();
            return;
        }

        var formData = new URLSearchParams();
        formData.append("address", inputAddress);

        fetch("${pageContext.request.contextPath}/member/updateAddressAjax", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "OK") {
                alert("🏠 배송지 주소가 은하 네트워크에 성공적으로 등록되었습니다!\n결제서 작성실로 도약합니다.");
                
                // 💥 모달을 완벽히 끄고 클렌징
                closeCosmicModal();
                proceedToPurchase();
            } else if (data.trim() === "NOT_LOGIN") {
                alert("🔒 인증 세션이 만료되었습니다. 다시 로그인해 주세요.");
                location.href = "${pageContext.request.contextPath}/member/login";
            } else {
                alert("🚨 시스템 통신 장애로 주소 등록에 실패했습니다.");
            }
        })
        .catch(err => alert("🛰️ 사령부 메인 서버 인프라 통신 두절"));
    }

    // 🪐 모달 강제 폐쇄 및 바디 락 해제 함수
    function closeCosmicModal() {
        $('#addressModal').removeClass('show').css('display', 'none');
        $('.modal-backdrop').remove(); // 혹시라도 생겼을 부트스트랩 백드롭 파괴
        $('body').removeClass('modal-open');
    }

    function proceedToPurchase() {
        // 결제창 워프 전 완벽 소독
        closeCosmicModal();
        
        // 궤도 진입 실행
        location.href = "${pageContext.request.contextPath}/basket/buy?basketIds=" + currentBasketIds;
    }

    // [🛒 선택 구매] 마스터 버튼 이벤트 리스너 리다이렉션
    document.getElementById("buyBtn").addEventListener("click", function () {
        checkAddressBeforeOrder('multiple', null);
    });

    // 🪐 모달창 우측 상단 X 버튼이나 [정선 회항] 버튼을 눌렀을 때 닫히도록 바인딩
    $(document).ready(function() {
        $('[data-bs-dismiss="modal"]').on('click', function() {
            closeCosmicModal();
        });
        
        // 정선 회항 버튼에도 명시적 바인딩 (on click으로 문법 교정)
        $('.modal-footer .btn-cancel-cosmic').on('click', function() {
            closeCosmicModal();
        });
    });
    
    // 최초 합산 기동
    updateTotal();
</script>