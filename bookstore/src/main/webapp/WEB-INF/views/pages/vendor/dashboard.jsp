<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- 🪐 와이드 컨테이너 장착 --%>
<div class="admin-wide-container vendor-dashboard-container mt-4 mb-5">
    
    <%-- 🚀 상단 파트너십 관제탑 타이틀 라인 --%>
    <div class="vendor-dashboard-header">
        <div class="header-title-group">
            <h2 class="vendor-main-title">🛰️ Partner Dashboard</h2>
            <p class="vendor-sub-desc">업체명: <span class="text-white fw-bold">${vendorInfo.bizName}</span> | 오픈마켓 물류 관제소</p>
        </div>
        <div class="header-action-group">
            <a href="${pageContext.request.contextPath}/vendor/logout" class="btn-logout-vendor">
                🔒 안전 로그아웃
            </a>
        </div>
    </div>

    <%-- 📊 메인 그리드 레이아웃 --%>
    <div class="row g-4 vendor-grid-row">
        
        <%-- 🏢 좌측: 파트너 기지 정보 마스터 카드 --%>
        <div class="col-xl-3 col-lg-4">
            <div class="card cosmic-vendor-info-card h-100">
                <div class="card-header info-card-header">
                    🏢 파트너십 가입 정보
                </div>
                <div class="card-body info-card-body">
                    <div class="info-row">
                        <small class="info-label">파트너 계정 ID</small>
                        <span class="info-value text-white">${vendorInfo.vendorId}</span>
                    </div>
                    <div class="info-row">
                        <small class="info-label">공식 상호명</small>
                        <span class="info-value text-warning">${vendorInfo.bizName}</span>
                    </div>
                    <div class="info-row">
                        <small class="info-label">사업자 등록 번호</small>
                        <span class="info-value text-light">${vendorInfo.bizNo}</span>
                    </div>
                    <div class="info-row">
                        <small class="info-label">대표자 연락처</small>
                        <span class="info-value text-light">${vendorInfo.contact}</span>
                    </div>
                    <div class="info-row-last border-0 pb-0 mb-0">
                        <small class="info-label">활동 승인 번호</small>
                        <span class="badge-approval">No. ${sessionScope.vRegNum}</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- 📦 우측: 오픈마켓 판매 관리 대시보드 실시간 상황판 --%>
        <div class="col-xl-9 col-lg-8">
            <div class="card cosmic-vendor-main-card h-100">
                
                <%-- 헤더 컨트롤러 액션 바인딩 구역 --%>
                <div class="card-header main-card-header">
                    <span class="main-card-title">📦 오픈마켓 물류 공급 및 상품 관리</span>
                    <div class="main-card-actions">

					    <a href="${pageContext.request.contextPath}/vendor/purchase/salesvolume" class="btn-vendor-salesvolume">
					        📊 도서 판매량
					    </a>
					
					    <a href="${pageContext.request.contextPath}/vendor/purchase/list" class="btn-vendor-sub">
					        🚚 주문·배송 관제탑 ➔
					    </a>
					
					    <a href="${pageContext.request.contextPath}/vendor/product/register" class="btn-vendor-primary">
					        ➕ 신규 판매 상품 등록
					    </a>
					
					</div>
                </div>
                
                <div class="card-body p-0 main-card-body">
                    <c:choose>
                        <%-- 등록된 상품이 없을 때 (Empty) --%>
                        <c:when test="${empty productList}">
                            <div class="cosmic-empty-state">
                                <div class="empty-icon-large">🛰️</div>
                                <h4 class="empty-title">현재 오픈마켓에 공급 중인 상품이 없습니다.</h4>
                                <p class="empty-desc">
                                    기지 내부 창고에 입고된 도서(`STOCK_IN`) 데이터를 기반으로<br>
                                    우주 마켓에 소비자 판매가와 재고를 설정해 상품을 론칭해 보세요!
                                </p>
                            </div>
                        </c:when>
                        
                        <%-- 등록된 상품이 존재할 때 (List View) --%>
                        <c:otherwise>
                            <div class="table-responsive vendor-table-wrap">
                                <table class="cosmic-table vendor-table">
                                    <thead>
                                        <tr>
                                            <th class="th-img">이미지</th>
                                            <th class="th-info text-start">도서 정보</th>
                                            <th class="th-price">소비자 판매가</th>
                                            <th class="th-stock">실시간 재고</th>
                                            <th class="th-status">마켓 상태</th>
                                            <th class="th-control">관제</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="product" items="${productList}">
                                            <tr class="vendor-row">
                                                <%-- 도서 이미지 --%>
                                                <td class="td-img">
                                                    <c:choose>
                                                        <c:when test="${not empty product.image}">
                                                            <img src="${product.image}" alt="cover" class="product-thumb-img" onerror="this.onerror=null; this.src='https://via.placeholder.com/100x140?text=No+Image';">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="product-no-img">No Image</div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <%-- 도서 상세 정보 --%>
                                                <td class="td-info text-start">
                                                    <div class="product-title-text text-truncate">${product.title}</div>
                                                    <small class="product-meta-text">${product.writer} | ${product.publisher}</small>
                                                </td>
                                                <%-- 판매 가격 --%>
                                                <td class="td-price">
                                                    <fmt:formatNumber value="${product.price}" type="number"/>원
                                                </td>
                                                <%-- 재고 수량 --%>
                                                <td class="td-stock">
                                                    <c:choose>
                                                        <c:when test="${product.stockQty eq 0}">
                                                            <span class="badge-stock badge-soldout">품절</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-stock badge-instock">${product.stockQty}개</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <%-- 판매 상태 배지 --%>
                                                <td class="td-status">
                                                    <c:choose>
                                                        <c:when test="${product.saleStatus eq 'ON'}">
                                                            <span class="badge-sale badge-on">판매중</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-sale badge-off">판매중지</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <%-- 관리 단추 --%>
                                                <td class="td-control">
                                                    <div class="vendor-btn-group">
                                                        <button type="button" class="btn-vendor-edit" 
                                                                onclick="openUpdateModal('${product.saleId}', '${fn:escapeXml(product.title)}', '${product.price}', '${product.stockQty}', '${product.saleStatus}')">
                                                            수정
                                                        </button>
                                                        <button type="button" class="btn-vendor-delete" 
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

    // 🔥 [하얀 박스 가두리 격파 치트키] 페이지 로드 시 상위 부모 레이아웃의 max-width 강제 해제
    var wideContainer = document.querySelector('.admin-wide-container');
    if (wideContainer) {
        var parent = wideContainer.parentElement;
        while (parent && parent.tagName !== 'BODY') {
            parent.style.maxWidth = '100%';
            parent.style.width = '100%';
            if(parent.classList.contains('form-container') || parent.className.includes('container')) {
                parent.style.maxWidth = '1400px'; 
                parent.style.margin = '0 auto';
            }
            parent = parent.parentElement;
        }
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