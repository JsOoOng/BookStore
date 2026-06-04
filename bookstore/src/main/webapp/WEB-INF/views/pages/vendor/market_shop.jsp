<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container mt-4">

    <div class="mb-4 pb-2 border-bottom border-secondary">
        <h2 class="fw-bold text-dark" style="font-size: 1.8rem; letter-spacing: -0.5px;">🪐 코스믹 도서 아카이브</h2>
        <p class="text-secondary mb-0 fw-bold" style="font-size: 0.95rem;">
            우주 연합의 모든 도서 원천 정보와 실제 입점 상점의 판매 리스트를 통합 관제합니다.
        </p>
    </div>

    <ul class="nav nav-pills nav-justified cosmic-tabs mb-4" id="bookCatalogTabs" role="tablist" style="gap: 10px;">
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold py-3" id="book-list-tab" type="button" role="tab" style="font-size: 1.05rem; border-radius: 12px; background-color: rgba(93, 95, 239, 0.1); color: #5d5fef;"
                    onclick="location.href='${pageContext.request.contextPath}/book/list'">
                📚 전체 도서 도감 (원천 정보)
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-bold py-3" id="vendor-shop-tab" data-bs-toggle="tab" data-bs-target="#vendor-shop-pane" type="button" role="tab" aria-controls="vendor-shop-pane" aria-selected="true" style="font-size: 1.05rem; border-radius: 12px;">
                🛒 실시간 판매 중인 상점 (구매/장바구니 가능)
            </button>
        </li>
    </ul>

    <div class="tab-content" id="bookCatalogTabsContent">
        
        <div class="tab-pane fade show active" id="vendor-shop-pane" role="tabpanel" aria-labelledby="vendor-shop-tab" tabindex="0">
            
            <div class="alert alert-success border-0 shadow-sm mb-4 fw-bold" style="background-color: rgba(13, 202, 240, 0.05); color: #0dcaf0; border-radius: 12px;">
                🚀 <b>물류 창고 안내:</b> 이곳은 실제 입점 파트너들이 수량을 공급하여 판매 중인 마켓입니다. 원하는 지식 서적을 장바구니에 담아 결제할 수 있습니다!
            </div>

            <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4">
                <c:choose>
                    <%-- 🌟 사령관의 원래 세션 데이터 변수명 marketProducts 완벽 매핑 --%>
                    <c:when test="${empty marketProducts}">
                        <div class="col-12 text-center py-5">
                            <span class="display-1">📭</span>
                            <h4 class="fw-bold text-warning mt-3">현재 은하 상점에 개설된 상품이 없습니다.</h4>
                            <p class="text-secondary small">잠시 후 파트너사들의 물류 공급이 시작되면 리스트가 갱신됩니다.</p>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <c:forEach var="product" items="${marketProducts}">
                            <div class="col">
                                <div class="card bg-dark text-white shadow h-100 border-secondary hover-shadow">
                                    
                                    <%-- 🗺️ 1. 이미지 클릭 구역: 닫는 괄호 '>' 교정 및 하이브리드 파라미터 풀 패키지 탑재 --%>
                                    <div class="position-relative text-center p-3 bg-gradient" 
                                         style="background: rgba(255,255,255,0.03); cursor: pointer;"
                                         onclick="location.href='${pageContext.request.contextPath}/book/view?id=${product.bookId}&saleId=${product.saleId}&price=${product.price}&stockQty=${product.stockQty}&bizName=${product.bizName}'">
                                        
                                        <c:choose>
                                            <c:when test="${not empty product.image}">
                                                <img src="${product.image}" class="card-img-top rounded shadow shop-book-cover" alt="cover" style="width: 130px; height: 185px; object-fit: cover;">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="bg-secondary rounded d-flex align-items-center justify-content-center text-dark mx-auto shadow shop-book-no-cover" style="width: 130px; height: 185px; font-weight: bold;">No Image</div>
                                            </c:otherwise>
                                        </c:choose>
                                        
                                        <span class="badge bg-info text-dark position-absolute top-0 start-0 m-2 fw-bold">
                                            🏢 ${product.bizName}
                                        </span>
                                    </div>

                                    <div class="card-body d-flex flex-column justify-content-between p-3">
                                        <div class="mb-2">
                                            <%-- 🗺️ 2. 도서 제목 클릭 구역: 호버 이펙트 및 하이브리드 파라미터 풀 패키지 탑재 --%>
                                            <h5 class="card-title fw-bold text-white text-truncate mb-1" 
                                                title="${product.title}"
                                                style="cursor: pointer; transition: color 0.2s;"
                                                onmouseover="this.style.color='#0dcaf0'" 
                                                onmouseout="this.style.color='#fff'"
                                                onclick="location.href='${pageContext.request.contextPath}/book/view?id=${product.bookId}&saleId=${product.saleId}&price=${product.price}&stockQty=${product.stockQty}&bizName=${product.bizName}'">
                                                ${product.title}
                                            </h5>
                                            <small class="text-secondary d-block text-truncate">${product.writer} | ${product.publisher}</small>
                                        </div>

                                        <div class="mt-3 border-top border-secondary pt-2">
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <span class="text-secondary small">실시간 잔여 재고</span>
                                                <span class="badge bg-dark border border-info text-info fw-bold">${product.stockQty}개 남음</span>
                                            </div>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <span class="text-secondary small">우주 할인가</span>
                                                <h4 class="text-warning fw-bold mb-0">
                                                    <fmt:formatNumber value="${product.price}" type="number"/>원
                                                </h4>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="card-footer bg-transparent border-secondary p-3 d-grid gap-2">
                                        <button type="button" class="btn btn-outline-info btn-sm fw-bold py-2" 
                                                onclick="addBasket('${product.saleId}', '${product.title}')">
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

<script>
// 🛒 장바구니 담기 비동기 통신 관제 함수
function addBasket(saleId, title) {
    var formData = new URLSearchParams();
    formData.append("saleId", saleId);
    formData.append("qty", 1); 
    
    fetch("${pageContext.request.contextPath}/basket/addMarketProduct", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: formData
    })
    .then(function(response) { 
        return response.text(); 
    })
    .then(function(data) {
        if (data.trim() === "ok") {
            if (confirm("🪐 [" + title + "] 상품이 장바구니 궤도에 안착했습니다!\n지금 장바구니 화면으로 워프하시겠습니까?")) {
                location.href = "${pageContext.request.contextPath}/basket"; 
            }
        } else if (data.trim() === "NOT_LOGIN") {
            alert("🔒 이 임무는 일반 대원 로그인 후 수행 가능합니다.\n로그인 행성으로 이동해 주세요.");
            location.href = "${pageContext.request.contextPath}/member/login";
        } else {
            alert("🚨 장바구니 담기 실패 또는 시스템 장애가 발생했습니다.");
        }
    })
    .catch(function(error) {
        console.error("Error:", error);
        alert("🛰️ 사령부 서버와 통신이 두절되었습니다.");
    });
}
</script>