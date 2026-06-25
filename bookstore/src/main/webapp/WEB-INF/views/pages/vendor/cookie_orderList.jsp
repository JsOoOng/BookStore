<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 🪐 대시보드와 완벽하게 동일한 와이드 컨테이너 장착 --%>
<div class="admin-wide-container vendor-dashboard-container mt-4 mb-5">
    
    <%-- 🚀 상단 타이틀 라인 --%>
    <div class="vendor-dashboard-header">
        <div class="header-title-group">
            <h2 class="vendor-main-title">🛰️ Partner Dashboard</h2>
            <p class="vendor-sub-desc">업체명: <span class="text-white fw-bold">${sessionScope.loginVendor.bizName}</span> | 오픈마켓 물류 관제소</p>
        </div>
        <div class="header-action-group">
            <a href="${pageContext.request.contextPath}/vendor/logout" class="btn-logout-vendor">
                🔒 안전 로그아웃
            </a>
        </div>
    </div>

    <%-- 📊 메인 레이아웃 --%>
    <div class="row g-4 vendor-grid-row">
        
        <%-- 🏢 좌측 기지 카드 --%>
        <div class="col-xl-3 col-lg-4">
            <div class="card cosmic-vendor-info-card h-100">
                <div class="card-header info-card-header">
                    🏢 파트너십 가입 정보
                </div>
                <div class="card-body info-card-body">
                    <div class="info-row">
                        <small class="info-label">파트너 계정 ID</small>
                        <span class="info-value text-white">${sessionScope.loginVendor.vendorId}</span>
                    </div>
                    <div class="info-row">
                        <small class="info-label">공식 상호명</small>
                        <span class="info-value text-warning">${sessionScope.loginVendor.bizName}</span>
                    </div>
                    <div class="info-row">
                        <small class="info-label">사업자 등록 번호</small>
                        <span class="info-value text-light">${sessionScope.loginVendor.bizNo}</span>
                    </div>
                    <div class="info-row">
                        <small class="info-label">대표자 연락처</small>
                        <span class="info-value text-light">${sessionScope.loginVendor.contact}</span>
                    </div>
                    <div class="info-row-last border-0 pb-0 mb-0">
                        <small class="info-label">활동 승인 번호</small>
                        <span class="badge-approval">No. ${sessionScope.loginVendor.vendorRegNum}</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- 📦 우측 메인 보드 --%>
        <div class="col-xl-9 col-lg-8">
            <div class="card cosmic-vendor-main-card h-100">
                
                <div class="card-header main-card-header">
                    <span class="main-card-title">🚚 입점 파트너 비회원 주문 관제탑</span>
                    <div class="main-card-actions">
                        <a href="${pageContext.request.contextPath}/vendor/dashboard" class="btn-vendor-sub">
                            🔙 상품 관리 대시보드
                        </a>
                    </div>
                </div>
                
                <div class="card-body p-0 main-card-body">
                    <div class="table-responsive vendor-table-wrap">
                        <table class="cosmic-table vendor-order-table">
                            <thead>
                                <tr>
                                    <th class="th-order-num">비회원 주문 번호</th>
                                    <th class="th-book-info text-start">도서 정보</th>
                                    <th class="th-order-qty">수량</th>
                                    <th class="th-total-price text-end">품목 결제액</th>
                                    <th class="th-order-date">주문 일시</th>
                                    <th class="th-order-status">현재 상태</th>
                                    <th class="th-order-control">관제 제어</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty orderList}">
                                        <c:forEach var="order" items="${orderList}">
                                            <tr class="vendor-order-row">
                                                <%-- 💥 [수리 완료] order.id에서 정규화된 order.purchaseId 스펙으로 전면 체인지 --%>
                                                <td class="td-order-num" style="font-size: 12px; font-weight: 700; color: #5d5fef;">
                                                    ${order.purchaseId}
                                                </td>
                                                <td class="td-book-info">
                                                    <div class="vendor-order-book-item">
                                                        <c:choose>
                                                            <c:when test="${not empty order.image}">
                                                                <%-- 📡 [하이브리드 스마트 바인더] 네이버 표지 연동 및 안전 플레이스홀더 교체 --%>
                                                                <img src="${order.image.startsWith('http') ? order.image : pageContext.request.contextPath.concat(order.image)}" 
                                                                     alt="${order.title}" 
                                                                     class="vendor-book-thumb-img" 
                                                                     onerror="this.onerror=null; this.src='https://placehold.co/150x220/f8fafc/a4b0be?text=No+Cover';">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="vendor-book-no-img">No Cover</div>
                                                            </c:otherwise>
                                                        </c:choose> 
                                                        <span class="vendor-order-book-title" title="${order.title}">
                                                            ${order.title}
                                                        </span>
                                                    </div>
                                                </td>
                                                <td class="td-order-qty">${order.quantity} 권</td>
                                                <td class="td-total-price text-end fw-bold text-dark">
                                                    <%-- 💥 [연산 엔진 정밀 정비] 마스터 총액이 아닌 해당 품목 단가 * 수량으로 제어 --%>
                                                    <fmt:formatNumber value="${order.unitPrice * order.quantity}" pattern="#,###"/> 원
                                                </td>
                                                <td class="td-order-date">
												    <div style="line-height: 1.4;">
												        <div style="font-weight: 600; color: #2f3542;">
												            <fmt:formatDate value="${order.purchaseDate}" pattern="yyyy-MM-dd"/>
												        </div>
												        <div style="font-size: 11px; color: #7f8c8d;">
												            <fmt:formatDate value="${order.purchaseDate}" pattern="HH:mm"/>
												        </div>
												    </div>
												</td>
                                                <td class="td-order-status">
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'READY'}">
                                                            <span class="badge-status-vendor status-ready">🚀 배송대기</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'SHIPPING'}">
                                                            <span class="badge-status-vendor status-shipping">🌌 배송중</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status-vendor status-etc">${order.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="td-order-control">
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'READY'}">
                                                            <%-- 💥 [수리 완료] 비동기 함수 파라미터 타격을 정규화된 purchaseId로 변경 --%>
                                                            <button type="button" class="btn-vendor-action-ship" onclick="shipOrder('${order.purchaseId}')">
                                                                🚚 배송하기
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn-vendor-action-complete" disabled>
                                                                완료됨
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="td-empty-state">
                                                <div class="cosmic-empty-state py-5">
                                                    <div class="empty-icon-large" style="color: #a4b0be;">📡</div>
                                                    <h4 class="empty-title">인입된 비회원 도서 주문 내역이 존재하지 않습니다.</h4>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<script>
function shipOrder(purchaseId) {
    if (!confirm("해당 도서의 전송(배송)을 시작하시겠습니까?")) return;
    
    // 💥 [타격 정밀 튜닝] 컨트롤러 수신 규격에 완벽 매핑되도록 처리
    var formData = new URLSearchParams();
    formData.append("purchaseId", purchaseId);

    fetch("${pageContext.request.contextPath}/vendor/purchase/ship", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: formData
    })
    .then(response => response.text())
    .then(data => {
        if (data.trim() === "ok") {
            alert("🌌 전송 통로 개방! 배송 버스트가 시작되었습니다.");
            location.reload(); 
        } else {
            alert("🚨 관제탑 승인 실패. 다시 시도해 주세요.");
        }
    })
    .catch(error => {
        console.error("Error:", error);
        alert("🛰️ 사령부 서버와 통신이 두절되었습니다.");
    });
}

document.addEventListener("DOMContentLoaded", function() {
    // 🔥 하얀 박스 가두리 격파 치트키 작동 유지
    var wideContainer = document.querySelector('.admin-wide-container');
    if (wideContainer) {
        var parent = wideContainer.parentElement;
        while (parent && parent.tagName !== 'BODY') {
            parent.style.maxWidth = '100%';
            parent.style.width = '100%';
            if(parent.classList.contains('form-container') || parent.className.includes('container')) {
                parent.style.maxWidth = '1650px'; 
                parent.style.margin = '0 auto';
                parent.style.padding = '0 20px';
            }
            parent = parent.parentElement;
        }
    }
});
</script>