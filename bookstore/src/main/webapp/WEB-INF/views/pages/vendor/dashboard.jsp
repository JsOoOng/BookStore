<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- 🪐 [대개편] 75% 메인 레이아웃 안에서 양옆 가두리를 싹 찢어 넓게 쓰는 와이드 컨테이너 장착 --%>
<div class="admin-wide-container mt-4" style="overflow: visible;">
    
    <%-- 🚀 상단 파트너십 관제탑 타이틀 라인 --%>
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom border-secondary pb-3">
        <div>
            <h2 class="fw-bold text-info mb-0" style="letter-spacing: -0.5px;">🛰️ Partner Dashboard</h2>
            <p class="text-muted small mb-0 mt-1">업체명: <span class="text-white fw-bold">${vendorInfo.bizName}</span> | 오픈마켓 물류 관제소</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/vendor/logout" class="btn btn-outline-danger btn-sm fw-bold rounded-pill px-3 shadow-sm">
                🔒 안전 로그아웃
            </a>
        </div>
    </div>

    <%-- 📊 메인 그리드 레이아웃 (공간의 밸런스를 3:9에서 4:8로 다듬거나 넓게 정돈) --%>
    <div class="row g-4" style="overflow: visible;">
        
        <%-- 🏢 좌측: 파트너 기지 정보 마스터 카드 --%>
        <div class="col-xl-3 col-lg-4">
            <div class="card text-white border-0 shadow-sm h-100" style="border-radius: 20px; background: rgba(43, 43, 54, 0.85); backdrop-filter: blur(4px);">
                <div class="card-header fw-bold text-info py-3" style="background: rgba(255,255,255,0.03); border-bottom: 1px solid rgba(255,255,255,0.08); border-top-left-radius: 20px; border-top-right-radius: 20px;">
                    🏢 파트너십 가입 정보
                </div>
                <div class="card-body p-4">
                    <div class="mb-3 pb-2 border-bottom border-dark">
                        <small class="text-muted d-block fw-bold small mb-1">파트너 계정 ID</small>
                        <span class="fs-6 text-white fw-bold">${vendorInfo.vendorId}</span>
                    </div>
                    <div class="mb-3 pb-2 border-bottom border-dark">
                        <small class="text-muted d-block fw-bold small mb-1">공식 상호명</small>
                        <span class="fs-6 text-warning fw-bold">${vendorInfo.bizName}</span>
                    </div>
                    <div class="mb-3 pb-2 border-bottom border-dark">
                        <small class="text-muted d-block fw-bold small mb-1">사업자 등록 번호</small>
                        <span class="text-light fw-bold">${vendorInfo.bizNo}</span>
                    </div>
                    <div class="mb-3 pb-2 border-bottom border-dark">
                        <small class="text-muted d-block fw-bold small mb-1">대표자 연락처</small>
                        <span class="text-light fw-bold">${vendorInfo.contact}</span>
                    </div>
                    <div>
                        <small class="text-muted d-block fw-bold small mb-1">활동 승인 번호</small>
                        <span class="badge rounded-pill bg-info text-dark fw-bold px-3 py-1 mt-1 shadow-sm" style="font-size: 0.8rem;">No. ${sessionScope.vRegNum}</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- 📦 우측: 오픈마켓 판매 관리 대시보드 실시간 상황판 --%>
        <div class="col-xl-9 col-lg-8" style="overflow: visible;">
            <%-- 🛠️ [버그 격파] 기존의 부트스트랩 무식한 카드 스타일을 지워내고 admin-table-card 인프라로 대통합! --%>
            <div class="card border-0 admin-table-card h-100" style="overflow: visible !important;">
                
                <%-- 헤더 컨트롤러 액션 바인딩 구역 --%>
                <div class="card-header table-dark d-flex justify-content-between align-items-center py-3" style="border-top-left-radius: 20px; border-top-right-radius: 20px;">
                    <span class="text-warning fw-bold">📦 오픈마켓 물류 공급 및 상품 관리</span>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/vendor/purchase/list" class="btn btn-outline-info btn-sm fw-bold rounded-pill px-3 shadow">
                            🚚 주문·배송 관제탑 ➔
                        </a>
                        <a href="${pageContext.request.contextPath}/vendor/product/register" class="btn btn-info btn-sm text-dark fw-bold rounded-pill px-3 shadow">
                            ➕ 신규 판매 상품 등록
                        </a>
                    </div>
                </div>
                
                <div class="card-body p-0" style="overflow: visible !important;">
                    <c:choose>
                        <%-- 등록된 상품이 없을 때 (Empty) --%>
                        <c:when test="${empty productList}">
                            <div class="d-flex flex-column justify-content-center align-items-center text-center py-5">
                                <div class="mb-3"><span class="display-3">🛰️</span></div>
                                <h4 class="fw-bold text-danger">현재 오픈마켓에 공급 중인 상품이 없습니다.</h4>
                                <p class="text-muted small max-width-500 fw-bold">
                                    기지 내부 창고에 입고된 도서(`STOCK_IN`) 데이터를 기반으로<br>
                                    우주 마켓에 소비자 판매가와 재고를 설정해 상품을 론칭해 보세요!
                                </p>
                            </div>
                        </c:when>
                        
                        <%-- 등록된 상품이 존재할 때 (List View) --%>
                        <c:otherwise>
                            <div class="table-responsive" style="overflow: visible !important;">
                                <table class="table table-hover admin-table mb-0 align-middle text-center">
                                    <thead class="table-secondary text-dark fw-bold">
                                        <tr>
                                            <th class="py-3" style="width: 12%;">이미지</th>
                                            <th class="text-start" style="width: 33%;">도서 정보</th>
                                            <th style="width: 18%;">소비자 판매가</th>
                                            <th style="width: 13%;">실시간 재고</th>
                                            <th style="width: 12%;">마켓 상태</th>
                                            <th style="width: 12%;">관제</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="product" items="${productList}">
                                            <tr>
                                                <%-- 도서 이미지 --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty product.image}">
                                                            <img src="${product.image}" alt="cover" class="rounded shadow" style="width: 48px; height: 68px; object-fit: cover;">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="bg-secondary text-white rounded d-flex align-items-center justify-content-center mx-auto shadow-sm" style="width: 48px; height: 68px; font-size: 0.7rem; font-weight: bold;">No Image</div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <%-- 도서 상세 정보 --%>
                                                <td class="text-start">
                                                    <div class="fw-bold text-dark mb-1 text-truncate" style="max-width: 250px; font-size: 0.95rem;">${product.title}</div>
                                                    <small class="text-secondary d-block fw-bold">${product.writer} | ${product.publisher}</small>
                                                </td>
                                                <%-- 판매 가격 --%>
                                                <td class="fw-bold style-price" style="color: #e67e22; font-size: 0.95rem;">
                                                    <fmt:formatNumber value="${product.price}" type="number"/>원
                                                </td>
                                                <%-- 재고 수량 --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${product.stockQty eq 0}">
                                                            <span class="badge bg-danger rounded-pill px-3 py-1 fw-bold" style="font-size: 0.8rem;">품절</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-primary rounded-pill px-3 py-1 fw-bold text-white" style="font-size: 0.8rem;">${product.stockQty}개</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <%-- 판매 상태 배지 --%>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${product.saleStatus eq 'ON'}">
                                                            <span class="badge bg-success rounded-pill px-3 py-1 fw-bold" style="font-size: 0.8rem;">판매중</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary rounded-pill px-3 py-1 fw-bold" style="font-size: 0.8rem;">판매중지</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <%-- 관리 단추 --%>
                                                <td>
                                                    <div class="btn-group btn-group-sm shadow-sm" style="border-radius: 8px; overflow: hidden;">
                                                        <button type="button" class="btn btn-dark fw-bold px-2" style="font-size: 0.75rem;"
                                                                onclick="openUpdateModal('${product.saleId}', '${fn:escapeXml(product.title)}', '${product.price}', '${product.stockQty}', '${product.saleStatus}')">
                                                            수정
                                                        </button>
                                                        <button type="button" class="btn btn-outline-danger fw-bold px-2" style="font-size: 0.75rem;" 
                                                                onclick="confirmDelete('${product.saleId}', '${fn:escapeXml(product.title)}')">
                                                            삭제
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>
    </div>
</div>

<script>
var productUpdateModalObj = null;

document.addEventListener("DOMContentLoaded", function() {
    var modalEl = document.getElementById('productUpdateModal');
    if (modalEl) {
        productUpdateModalObj = new bootstrap.Modal(modalEl);
        
        // 부트스트랩 모달의 백드롭이 레이아웃을 덮어치지 않도록 루트 사령부 격리 조치 이식
        modalEl.addEventListener('show.bs.modal', function () {
            document.body.appendChild(modalEl);
        });
    }
});

function confirmDelete(saleId, title) {
    if (confirm("🪐 [" + title + "] 상품을 은하 마켓에서 완전히 내리시겠습니까?\n삭제 후에는 물류 복구가 불가능합니다.")) {
        location.href = "${pageContext.request.contextPath}/vendor/product/delete?saleId=" + saleId;
    }
}

function openUpdateModal(saleId, title, price, stockQty, saleStatus) {
    document.getElementById("modalBookTitle").innerText = "📝 [" + title + "] 물류 제어 시스템";
    document.getElementById("modalSaleId").value = saleId;
    document.getElementById("modalPrice").value = price;
    document.getElementById("modalStockQty").value = stockQty;
    document.getElementById("modalSaleStatus").value = saleStatus;
    
    if (productUpdateModalObj) {
        productUpdateModalObj.show();
    }
}
</script>

<style>
/* 모달창이 터졌을 때 안전 레이어 확보 및 드롭다운/입력창 스타일 연동 */
.modal {
    z-index: 1060 !important;
}
.modal-backdrop {
    z-index: 1050 !important;
}
.modal-content input, .modal-content select {
    background-color: #2b3035 !important;
    color: #fff !important;
}
</style>