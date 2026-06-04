<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="view-container">
    <div class="cosmic-card-detail">
        <div class="book-image-large">
            <img src="${not empty book.image ? book.image : 'https://via.placeholder.com/300x420?text=No+Image'}" 
                 onerror="this.src='https://via.placeholder.com/300x420?text=No+Image'">
        </div>
        
        <div class="book-info" style="flex:1;">
            <%-- 🔐 관리자/사령관 권한 제어선 (아까 튜닝해둔 안전핀 적용) --%>
            <c:if test="${not empty loginAdmin and (loginAdmin.role eq 'ADMIN' or loginAdmin.role eq 'SUPER')}">
                <div class="top-action-bar" style="margin-bottom: 15px; display: flex; gap: 10px;">
                    <button class="btn-cosmic btn-edit btn-sm" onclick="location.href='${pageContext.request.contextPath}/book/update?id=${book.id}'">✏️ 정보 수정</button>
                    <button class="btn-cosmic btn-delete btn-sm" onclick="delConfirm(${book.id})">🗑️ 데이터 말소</button>
                </div>
            </c:if>
            
            <h1 class="view-title" style="color: #5d5fef; font-size: 2rem; font-weight: bold; margin-bottom: 10px;">${book.title}</h1>
            <div class="rating" style="margin-bottom: 20px;">★★★★★ <span style="color:#2f3542;">4.8</span></div>
            
            <div class="view-content" style="font-size: 0.95rem; line-height: 2;">
                <b>🚀 탐사 개척자(저자)</b> : ${book.writer}<br>
                <b>🏢 발굴 기관(출판사)</b> : ${book.publisher}<br>
                <b>🛰️ 소속 은하계(장르)</b> : ${not empty book.genre ? book.genre : '미분류'}<br>
                <b>🌐 기록 언어</b> : ${book.language}
            </div>
            
            <%-- 💰 [동적 밸런스 패치 1] 마켓을 타고 왔을 때만 실시간 공급처 및 가격 노출 --%>
            <div class="view-price mt-4" style="font-size: 1.2rem; font-weight: bold;">
                <c:choose>
                    <c:when test="${not empty market}">
                        <span class="text-secondary" style="font-size: 0.95rem; display: block; margin-bottom: 5px;">🏢 공급 파트너: ${market.bizName}</span>
                        <span style="color: #e67e22;">우주 할인가 : <fmt:formatNumber value="${market.price}" type="number"/>원</span>
                        <span class="badge bg-dark border border-info text-info ms-2" style="font-size: 0.8rem;">${market.stockQty}개 남음</span>
                    </c:when>
                    <c:otherwise>
                        <span style="color: #5d5fef;">📢 입점 업체별 판매 준비 중</span>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <%-- 🎛️ [동적 밸런스 패치 2] 자물쇠 해제 분기 모듈 가동 --%>
            <div class="form-actions mt-4 d-flex gap-3">
                <c:choose>
                    <%-- 마켓 데이터를 품고 들어왔고 잔여 재고가 1개 이상 존재할 때 --%>
                    <c:when test="${not empty market and market.stockQty > 0}">
                        <button type="button" class="btn-confirm" style="background-color: #2ed573; color: white;"
						        onclick="checkAddressBeforeOrder('${book.id}', '${market.saleId}', '${market.price}')">
						    ⚡ 즉시 구매하기
						</button>
                        <button type="button" class="btn-cosmic" style="background-color: #5d5fef; color: white;"
                                onclick="addBasketFromDetail('${market.saleId}', '${book.title}')">
                            🛒 장바구니 담기
                        </button>
                    </c:when>
                    <c:otherwise>
                        <%-- 일반 원천 도감 리스트에서 들어왔을 때는 안전하게 락다운 상태 고정 --%>
                        <button type="button" class="btn-confirm" disabled style="background-color: #ccc; cursor: not-allowed; color: #666;">
                            🔒 판매 준비 중
                        </button>
                        <button type="button" class="btn-cosmic" disabled style="background-color: #ccc; cursor: not-allowed; color: #666;">
                            🔒 장바구니 불가
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <div class="form-actions mt-4 d-flex gap-3">
                <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/book/list'">
                    목록으로 돌아가기
                </button>
            </div>
        </div>
    </div>

    <h3 class="section-title" style="margin-top: 40px; font-weight: bold;">🛰️ 행성 관측 데이터</h3>
    <div class="meta-dashboard" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin-top: 15px;">
        <div class="meta-item" style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
            <span class="meta-label" style="display: block; font-size: 0.85rem; color: #6c757d;">우주 식별 번호 (ISBN)</span>
            <span class="meta-value" style="font-weight: bold; font-size: 1.05rem;">${not empty book.isbn ? book.isbn : '식별 번호 미부여'}</span>
        </div>
        <div class="meta-item" style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
            <span class="meta-label" style="display: block; font-size: 0.85rem; color: #6c757d;">최초 출판 우주 시기</span>
            <span class="meta-value" style="font-weight: bold; font-size: 1.05rem;">${book.pubDate}</span>
        </div>
        <div class="meta-item" style="background: #f8f9fa; padding: 15px; border-radius: 8px; grid-column: span 2;">
            <span class="meta-label" style="display: block; font-size: 0.85rem; color: #6c757d;">현재 상태</span>
            <span class="meta-value status-active" style="color: #2ed573; font-weight: bold;">원천 지식 기지 등록 완료</span>
        </div>
    </div>

    <h3 class="section-title" style="margin-top: 40px; font-weight: bold;">🌌 탐사선이 발견한 다른 지식</h3>
    <div class="recommend-list" style="display: flex; gap: 15px; margin-top: 15px; overflow-x: auto; padding-bottom: 10px;">
        <c:forEach var="recBook" items="${recommendList}">
            <a href="${pageContext.request.contextPath}/book/view?id=${recBook.id}" class="recommend-card" style="text-decoration: none; color: inherit; text-align: center; min-width: 120px;">
                <img src="${recBook.image}" onerror="this.src='https://via.placeholder.com/120x170?text=No+Image'" style="width: 120px; height: 170px; object-fit: cover; border-radius: 6px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <span class="recommend-title" style="display: block; font-size: 0.85rem; margin-top: 5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${recBook.title}</span>
            </a>
        </c:forEach>
    </div>
</div>
<div class="modal fade" id="addressModal" database-backdrop="static" tabindex="-1" aria-labelledby="addressModalLabel" aria-hidden="true">
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
<script>
    function delConfirm(id) {
        if (confirm("정말 이 도서 데이터를 우주 저편으로 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.")) {
            location.href = "${pageContext.request.contextPath}/book/delete?id=" + id;
        }
    }
    
    function addBasketFromDetail(saleId, title) {
        var formData = new URLSearchParams();
        formData.append("saleId", saleId);
        formData.append("qty", 1); 
        
        fetch("${pageContext.request.contextPath}/basket/addMarketProduct", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "ok") {
                if (confirm("🪐 [" + title + "] 상품이 장바구니 궤도에 안착했습니다!\n지금 장바구니 화면으로 워프하시겠습니까?")) {
                    location.href = "${pageContext.request.contextPath}/basket"; 
                }
            } else if (data.trim() === "NOT_LOGIN") {
                alert("🔒 이 임무는 일반 대원 로그인 후 수행 가능합니다.");
                location.href = "${pageContext.request.contextPath}/member/login";
            } else {
                alert("🚨 장바구니 담기에 실패했습니다.");
            }
        })
        .catch(err => alert("🛰️ 사령부 통신 두절"));
    }
    
 // 전역 변수로 현재 구매 타겟 데이터 임시 홀딩용 버퍼 베이스 마련
    let currentOrderParam = { bookId: '', saleId: '', price: '' };

    // 📡 [검문소 1단계] 구매 버튼 클릭 시 주소 상태 정밀 진단
    function checkAddressBeforeOrder(bookId, saleId, price) {
        // 현재 주문 정보를 전역 버퍼 변수에 세이브
        currentOrderParam.bookId = bookId;
        currentOrderParam.saleId = saleId;
        currentOrderParam.price = price;

        const currentAddress = "${loginMember.address}";

        // 만약 로그인 세션 정보의 주소가 없거나 미지정 상태라면 자물쇠 모달 레이어 기동!
        if (!currentAddress || currentAddress.trim() === "" || currentAddress === "은하계 미지정 구역") {
            // 부트스트랩 모달 강제 팝업 작동
            var myModal = new bootstrap.Modal(document.getElementById('addressModal'));
            myModal.show();
        } else {
            // 이미 주소가 정갈하게 등록되어 있다면, 검문소 프리패스 후 주문서로 직행 워프!
            proceedToPurchasePage();
        }
    }

    // 📡 [검문소 2단계] 모달창에서 주소 입력 후 승인 버튼 눌렀을 때 비동기 인프라 가동
    function submitAddressAjax() {
        const inputAddress = document.getElementById('modalAddressInput').value.trim();

        if (inputAddress === "" || inputAddress === "은하계 미지정 구역") {
            alert("보급품을 정상 전달받을 유효한 주소를 입력해 주세요!");
            document.getElementById('modalAddressInput').focus();
            return;
        }

        var formData = new URLSearchParams();
        formData.append("address", inputAddress);

        // 아까 고쳐둔 회원 컨트롤러 AJAX 링크로 신호 발사!
        fetch("${pageContext.request.contextPath}/member/updateAddressAjax", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "OK") {
                alert("🏠 배송지 주소가 은하 네트워크에 성공적으로 등록되었습니다!\n주문서 페이지로 도약합니다.");
                
                // 모달 닫기 유도 후 결제창 프리패스 워프 실행
                proceedToPurchasePage();
            } else if (data.trim() === "NOT_LOGIN") {
                alert("🔒 인증 세션이 만료되었습니다. 다시 로그인해 주세요.");
                location.href = "${pageContext.request.contextPath}/member/login";
            } else {
                alert("🚨 시스템 통신 장애로 주소 등록에 실패했습니다.");
            }
        })
        .catch(err => alert("🛰️ 사령부 메인 서버 인프라 통신 두절"));
    }

    // 📡 [최종 관문] 패스포트 들고 실제 결제 대기실로 워프 추진
    function proceedToPurchasePage() {
        location.href = "${pageContext.request.contextPath}/purchase/view?bookId=" 
            + currentOrderParam.bookId 
            + "&saleId=" + currentOrderParam.saleId 
            + "&price=" + currentOrderParam.price;
    }
</script>