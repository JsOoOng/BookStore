<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container">

    <%-- 상단 타이틀 섹션 (list.jsp와 완벽 동기화) --%>
    <div class="cosmic-title-section">
        <h2 class="cosmic-main-title">cosmic book archive</h2>
        <p class="cosmic-subtitle-text">
            우주 연합의 모든 도서 원천 정보와 실제 입점 상점의 판매 리스트를 관제합니다.
        </p>
    </div>

    <%-- 🎯 미니 탭 존 (교보문고 스타일 좌측 상단 소형 탭) --%>
    <div class="cosmic-mini-tab-zone">
        <button class="btn-mini-tab" id="book-list-tab" type="button" role="tab"
                onclick="location.href='${pageContext.request.contextPath}/book/list'">
            전체 도서 도감 (원천 정보)
        </button>
        <button class="btn-mini-tab active" id="vendor-shop-tab" data-bs-toggle="tab" data-bs-target="#vendor-shop-pane" type="button" role="tab" aria-controls="vendor-shop-pane" aria-selected="true">
            실시간 판매 중인 상점
        </button>
    </div>

    <div class="tab-content" id="bookCatalogTabsContent">
        
        <div class="tab-pane fade show active" id="vendor-shop-pane" role="tabpanel" aria-labelledby="vendor-shop-tab" tabindex="0">
            
            <%-- 🎯 미니멀 안내 배너 (상점 전용 시안 테마) --%>
            <div class="cosmic-notice-banner vendor-shop-banner">
                🚀 <b>물류 창고 안내:</b> 이곳은 실제 입점 파트너들이 수량을 공급하여 판매 중인 마켓입니다. 원하는 지식 서적을 장바구니에 담아 결제할 수 있습니다!
            </div>

            <%-- 🎯 2열 도서 리스트 그리드 이식 --%>
            <div class="book-list">
                <c:choose>
                    <%-- 📭 상품이 없을 때 --%>
                    <c:when test="${empty marketProducts}">
                        <div style="grid-column: 1 / -1;" class="text-center py-5">
                            <span class="display-1">📭</span>
                            <h4 class="fw-bold text-warning mt-3">현재 은하 상점에 개설된 상품이 없습니다.</h4>
                            <p class="text-secondary small">잠시 후 파트너사들의 물류 공급이 시작되면 리스트가 갱신됩니다.</p>
                        </div>
                    </c:when>

                    <%-- 🛒 상품이 존재할 때 --%>
                    <c:otherwise>
                        <c:forEach var="product" items="${marketProducts}">
                            <%-- 🎯 카드 본체 클릭 이벤트 (list.jsp 스타일 가로 레이아웃 적용) --%>
                            <div class="book-item" 
                                 onclick="location.href='${pageContext.request.contextPath}/book/view?id=${product.bookId}&saleId=${product.saleId}&price=${product.price}&stockQty=${product.stockQty}&bizName=${product.bizName}'">
                                
                                <%-- 도서 표지 및 업체 배지 래퍼 --%>
                                <div class="shop-img-wrapper">
                                    <c:choose>
                                        <c:when test="${not empty product.image}">
                                            <img src="${product.image}" class="book-img" alt="cover" onerror="this.onerror=null; this.src='https://via.placeholder.com/100x140?text=No+Image';">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="book-img bg-secondary text-white d-flex align-items-center justify-content-center" style="font-size: 11px; font-weight: bold;">No Image</div>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="badge-vendor-cosmic">🏢 ${product.bizName}</span>
                                </div>

                                <%-- 도서 텍스트 정보 존 --%>
                                <div class="book-info">
                                    <h3 class="book-title text-truncate" style="max-width: 250px;">${product.title}</h3>
                                    <p class="book-author">개척자: ${product.writer} | ${product.publisher}</p>
                                    
                                    <%-- 상점 전용: 재고 및 가격 정보 라인 --%>
                                    <div class="shop-price-row">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <span class="price-label-mini">실시간 잔여 재고</span>
                                            <span class="badge-stock-left">${product.stockQty}개 남음</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="price-label-mini">우주 할인가</span>
                                            <span class="shop-price-value"><fmt:formatNumber value="${product.price}" type="number"/>원</span>
                                        </div>
                                    </div>
                                    
                                    <%-- 장바구니 제어 밸브 (이벤트 버블링 차단 장착!) --%>
                                    <div class="book-action-row w-100 mt-0">
                                        <button type="button" class="btn-cosmic btn-shop-cart w-100" 
                                                onclick="event.stopPropagation(); addBasket('${product.saleId}', '${product.title}')">
                                            🛒 장바구니 담기
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
            
        </div>
    </div>
</div>

<%-- 📡 통신 관제 스크립트 (무결성 보존) --%>
<script>
function addBasket(saleId, title) {
    var formData = new URLSearchParams();
    formData.append("saleId", saleId);
    formData.append("qty", 1); 
    
    fetch("${pageContext.request.contextPath}/basket/addMarketProduct", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: formData
    })
    .then(function(response) { 
        return response.text(); 
    })
    .then(function(data) {
        var result = data.trim();
        
        // 💥 [수리 완료] 회원과 비회원의 궤도를 완벽하게 분리 타격!
        if (result === "ok") {
            if (confirm("🪐 [" + title + "] 상품이 장바구니 궤도에 안착했습니다!\n지금 장바구니 화면으로 워프하시겠습니까?")) {
                location.href = "${pageContext.request.contextPath}/basket"; 
            }
        } else if (result === "ok_cookie") {
            if (confirm("🍪 비회원 보관소에 상품이 담겼습니다.\n임시 보관소를 확인하시겠습니까?")) {
                location.href = "${pageContext.request.contextPath}/cookie/basket/list"; 
            }
        } else if (result === "NOT_LOGIN") {
            alert("🔒 로그인 후 수행 가능합니다.");
            location.href = "${pageContext.request.contextPath}/member/login";
        } else {
            alert("🚨 장바구니 담기 실패: " + result);
        }
    })
    .catch(function(error) {
        console.error("Error:", error);
        alert("🛰️ 사령부 서버와 통신이 두절되었습니다.");
    });
}

document.addEventListener("DOMContentLoaded", function() {
    var wideContainer = document.querySelector('.admin-wide-container');
    if (wideContainer) {
        var parent = wideContainer.parentElement;
        while (parent && parent.tagName !== 'BODY') {
            parent.style.maxWidth = '100%';
            parent.style.width = '100%';
            if(parent.classList.contains('form-container') || parent.className.includes('container')) {
                parent.style.maxWidth = '1500px'; 
                parent.style.margin = '0 auto';
                parent.style.padding = '0';
            }
            parent = parent.parentElement;
        }
    }
});
</script>