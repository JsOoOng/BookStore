<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="basket-header">
    <h2 class="cosmic-title">
        🚀 ${loginMember.name} 대원의 장바구니
    </h2>
</div>

<div class="right-buttons">
    <div class="top-action-bar">
        <div class="left-actions" style="display: flex; align-items: center; gap: 8px;">
            <input type="checkbox" id="selectAll" style="width: 18px; height: 18px; cursor: pointer;">
            <label for="selectAll" style="cursor: pointer; color: #fff; margin-bottom: 0;">전체 선택</label>
        </div>
        
        <div class="right-buttons">
            <button type="submit" form="deleteForm" class="btn-cosmic btn-delete btn-unified">
                선택 삭제
            </button>
            <button type="button" class="btn-cosmic btn-confirm btn-unified" id="buyBtn">
                🛒 선택 구매
            </button>
            <a href="/" class="btn-home">🪐 홈</a>
        </div>
    </div>
</div>

<form action="${pageContext.request.contextPath}/basket/delete" method="post" id="deleteForm">
    <div class="book-list">
        <c:forEach var="vo" items="${basketList}">
            <div class="book-item">
                <div style="margin-right:10px;">
                    <input type="checkbox" name="ids" value="${vo.basketId}" class="selectItem">
                </div>

                <img src="${pageContext.request.contextPath}${vo.image}" class="book-img">

                <div class="book-info">
                    <h3 class="book-title">${vo.title}</h3>

                    <p class="book-author">👨‍🚀 ${vo.writer}</p>

                    <div style="display:flex; align-items:center; gap:15px; flex-wrap:wrap;">
                        <div>
                            수량:
                            <input type="number" value="${vo.quantity}" min="1" class="quantity" data-price="${vo.price}" style="width:60px;">
                        </div>

                        <div class="book-price totalPrice">
                            💫 <fmt:formatNumber value="${vo.quantity * vo.price}" pattern="#,###"/> 원
                        </div>
                    </div>

                    <div class="form-actions" style="margin-top:20px;">
                        <button type="button" class="btn-cosmic btn-delete" onclick="deleteOne(${vo.basketId})">
                            🗑 삭제
                        </button>

                        <button type="button" class="btn-cosmic btn-confirm" onclick="checkAddressBeforeOrder('single', '${vo.basketId}')">
                            🚀 바로 구매
                        </button>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    
    <div class="total-box">
        💳 총 결제 금액: <span id="totalPrice">0</span> 원
    </div>
</form>

<div class="modal fade" id="addressModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addressModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark text-white border-secondary">
            <div class="modal-header border-secondary">
                <h5 class="modal-title fw-bold" id="addressModalLabel">🌌 물류 보급지 배송 주소 설정</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="text-secondary small">안전하고 정확한 광속 지식 보급을 위해 대원님의 실제 거주지 또는 보급 좌표(주소) 입력을 완료해 주세요.</p>
                <div class="mt-3">
                    <label for="modalAddressInput" class="form-label text-info fw-bold">🏠 보급품 수령 주소</label>
                    <input type="text" id="modalAddressInput" class="form-control bg-secondary text-white border-0" placeholder="예: 경기도 고양시 일산동구 ...">
                </div>
            </div>
            <div class="modal-footer border-secondary">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">정선 회항</button>
                <button type="button" class="btn btn-info btn-sm fw-bold text-dark" onclick="submitAddressAjax()">주소 확정 및 결제선 진입</button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

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
                'background': 'rgba(0, 0, 0, 0.7)' // 부트스트랩 백드롭 대신 직접 어두운 장막 투사
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
        $('[data-bs-dismiss="modal"]').data('click', function() {
            closeCosmicModal();
        });
        
        // 정선 회항 버튼에도 명시적 바인딩
        $('.modal-footer .btn-outline-secondary').data('click', function() {
            closeCosmicModal();
        });
    });
    
    // 최초 합산 기동
    updateTotal();
</script>