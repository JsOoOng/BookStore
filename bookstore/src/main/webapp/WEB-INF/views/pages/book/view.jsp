<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="view-container">
    <%-- 메인 레이아웃 세션 (외부 CSS의 .cosmic-card-detail 적용) --%>
    <div class="cosmic-card-detail">
        <div class="book-image-large">
		    <img src="${not empty book.image ? book.image : 'https://via.placeholder.com/300x420?text=No+Image'}" 
		         onerror="this.onerror=null; this.src='https://via.placeholder.com/300x420?text=No+Image';">
		</div>
        
        <div class="book-info-area">
            <%-- 🔐 관리자/사령관 권한 제어 바 (기능 100% 보존) --%>
            <c:if test="${not empty loginAdmin and (loginAdmin.role eq 'ADMIN' or loginAdmin.role eq 'SUPER')}">
                <div class="top-action-bar">
                    <button class="btn-cosmic btn-edit btn-sm" onclick="location.href='${pageContext.request.contextPath}/book/update?id=${book.id}'">정보 수정</button>
                    <button class="btn-cosmic btn-delete btn-sm" onclick="delConfirm(${book.id})">데이터 말소</button>
                </div>
            </c:if>
            
            <%-- 미니멀 전용 헤드 라인 --%>
            <h1 class="view-title">${book.title}</h1>
            <div class="view-rating">★★★★★ <span class="rating-num">4.8</span></div>
            
            <%-- 도서 기본 스펙 카탈로그 구역 --%>
            <div class="view-content-specs">
                <div class="spec-row"><strong>author / 저자</strong> <span>${book.writer}</span></div>
                <div class="spec-row"><strong>publisher / 출판사</strong> <span>${book.publisher}</span></div>
                <div class="spec-row"><strong>genre / 장르</strong> <span>${not empty book.genre ? book.genre : '미분류'}</span></div>
                <div class="spec-row"><strong>language / 언어</strong> <span>${book.language}</span></div>
            </div>
            
            <%-- 💰 [동적 판매 정보 분기 기믹] --%>
            <div class="view-price-box">
                <c:choose>
                    <c:when test="${not empty market}">
                        <span class="partner-label">supply partner: ${market.bizName}</span>
                        <div class="price-row">
                            <span class="price-value">우주 할인가 : <fmt:formatNumber value="${market.price}" type="number"/>원</span>
                            <span class="badge badge-stock-alert">${market.stockQty}개 남음</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <span class="partner-preparing-text">📢 입점 업체별 판매 준비 중</span>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <%-- 🎛️ 구매/장바구니 제어 모듈 가동 구역 (인라인 스타일 완전 삭제) --%>
            <div class="purchase-actions-group">
                <c:choose>
                    <c:when test="${not empty market and market.stockQty > 0}">
                        <button type="button" class="btn-confirm btn-instant-buy" 
                                onclick="checkAddressBeforeOrder('${book.id}', '${market.saleId}', '${market.price}')">
                            ⚡ 즉시 구매하기
                        </button>
                        <button type="button" class="btn-cosmic btn-add-basket" 
						        data-saleid="${market.saleId}"
						        data-title="${fn:escapeXml(book.title)}"
						        onclick="addBasketFromDetail(this.dataset.saleid, this.dataset.title)">
						    🛒 장바구니 담기
						</button>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="btn-confirm btn-disabled-lock" disabled>
                            🔒 판매 준비 중
                        </button>
                        <button type="button" class="btn-cosmic btn-disabled-lock" disabled>
                            🔒 장바구니 불가
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <div class="navigation-actions-group">
                <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/book/list'">
                    목록으로 돌아가기
                </button>
            </div>
        </div>
    </div>

    <%-- 하단 서브 서지 정보 그리드 대시보드 구역 --%>
    <h3 class="view-section-title">🛰️ 행성 관측 데이터</h3>
    <div class="meta-dashboard">
        <div class="meta-item">
            <span class="meta-label">우주 식별 번호 (ISBN)</span>
            <span class="meta-value">${not empty book.isbn ? book.isbn : '식별 번호 미부여'}</span>
        </div>
        <div class="meta-item">
            <span class="meta-label">최초 출판 우주 시기</span>
            <span class="meta-value">${book.pubDate}</span>
        </div>
        <div class="meta-item meta-item-wide">
            <span class="meta-label">현재 상태</span>
            <span class="meta-value status-active">원천 지식 기지 등록 완료</span>
        </div>
    </div>

    <%-- 하단 가로 스크롤 추천 시스템 구역 --%>
    <h3 class="view-section-title">🌌 탐사선이 발견한 다른 지식</h3>
    <div class="recommend-list">
        <c:forEach var="recBook" items="${recommendList}">
            <a href="${pageContext.request.contextPath}/book/view?id=${recBook.id}" class="recommend-card">
                <%-- 💥 수정 후: 추천 도서 목록도 무한 루프에 빠지지 않도록 방어막 전개! --%>
				<div class="recommend-img-wrap">
				    <img src="${recBook.image}" 
				         onerror="this.onerror=null; this.src='https://via.placeholder.com/120x170?text=No+Image';">
				</div>
                <span class="recommend-title">${recBook.title}</span>
            </a>
        </c:forEach>
    </div>
</div>

<%-- 🏠 물류 보급지 배송 주소 설정 모달창 (다크 클래스 완전 소독 및 미니멀 스퀘어화 클래스 적용) --%>
<div class="modal fade cosmic-minimal-modal" id="addressModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addressModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="addressModalLabel">SHIPPING / 물류 보급지 주소 설정</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="modal-notice-text">안전하고 정확한 광속 지식 보급을 위해 대원님의 실제 거주지 또는 보급 좌표(주소) 입력을 완료해 주세요.</p>
                <div class="input-group-cosmic mt-4">
                    <label for="modalAddressInput" class="form-label fw-bold">ADDRESS / 보급품 수령 주소</label>
                    <input type="text" id="modalAddressInput" placeholder="예: 경기도 고양시 일산동구 ...">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-close-modal" data-bs-dismiss="modal">정선 회항</button>
                <button type="button" class="btn btn-submit-modal fw-bold" onclick="submitAddressAjax()">주소 확정 및 결제선 진입</button>
            </div>
        </div>
    </div>
</div>

<%-- 스크립트 트랜잭션 파이프라인 (무결성 유지) --%>
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
    
    let currentOrderParam = { bookId: '', saleId: '', price: '' };

    function checkAddressBeforeOrder(bookId, saleId, price) {
        currentOrderParam.bookId = bookId;
        currentOrderParam.saleId = saleId;
        currentOrderParam.price = price;

        const currentAddress = "${loginMember.address}";

        if (!currentAddress || currentAddress.trim() === "" || currentAddress === "은하계 미지정 구역") {
            var myModal = new bootstrap.Modal(document.getElementById('addressModal'));
            myModal.show();
        } else {
            proceedToPurchasePage();
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
                alert("🏠 배송지 주소가 은하 네트워크에 성공적으로 등록되었습니다!\n주문서 페이지로 도약합니다.");
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

    function proceedToPurchasePage() {
        location.href = "${pageContext.request.contextPath}/purchase/view?bookId=" 
            + currentOrderParam.bookId 
            + "&saleId=" + currentOrderParam.saleId 
            + "&price=" + currentOrderParam.price;
    }
</script>