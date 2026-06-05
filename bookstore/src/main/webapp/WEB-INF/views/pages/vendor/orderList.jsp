<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 🪐 대시보드와 완벽하게 동일한 와이드 컨테이너 장착 --%>
<div class="admin-wide-container vendor-dashboard-container mt-4 mb-5">
    
    <%-- 🚀 상단 파트너십 관제탑 타이틀 라인 --%>
    <div class="vendor-dashboard-header">
        <div class="header-title-group">
            <h2 class="vendor-main-title">🛰️ Partner Dashboard</h2>
            <%-- 💥 세션 메모리에서 업체명 직접 호출! --%>
            <p class="vendor-sub-desc">업체명: <span class="text-white fw-bold">${sessionScope.loginVendor.bizName}</span> | 오픈마켓 물류 관제소</p>
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
                        <span class="badge-approval">No. ${sessionScope.vRegNum}</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- 📦 우측: 주문 배송 관제탑 메인 보드 --%>
        <div class="col-xl-9 col-lg-8">
            <div class="card cosmic-vendor-main-card h-100">
                
                <%-- 헤더 컨트롤러 액션 바인딩 구역 --%>
                <div class="card-header main-card-header">
                    <span class="main-card-title">🚚 입점 파트너 주문 배송 관제탑</span>
                    <div class="main-card-actions">
                        <%-- 🔙 다시 메인 상품 관리(dashboard)로 돌아가는 탭 버튼 --%>
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
                                    <th class="th-order-num">주문 번호</th>
                                    <th class="th-book-info text-start">도서 정보</th>
                                    <th class="th-order-qty">수량</th>
                                    <th class="th-total-price text-end">결제 총액</th>
                                    <th class="th-order-date">주문 일시</th>
                                    <th class="th-order-status">현재 상태</th>
                                    <th class="th-order-control">관제 제어</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <%-- 들어온 주문이 있을 때 --%>
                                    <c:when test="${not empty orderList}">
                                        <c:forEach var="order" items="${orderList}">
                                            <tr class="vendor-order-row">
                                                <td class="td-order-num"># ${order.id}</td>
                                                <td class="td-book-info" style="vertical-align: middle;">
												    <div class="vendor-order-book-item" style="display: flex; align-items: center; gap: 10px; white-space: nowrap;">
												        <c:choose>
												            <c:when test="${not empty order.image}">
												                <%-- 🚀 이미지 경로 결합 및 엑스박스 방어 코드 --%>
												                <img src="${pageContext.request.contextPath}${order.image}" 
												                     alt="${order.title}" 
												                     style="width: 40px; height: 60px; object-fit: cover; border-radius: 4px;"
												                     onerror="this.src='https://via.placeholder.com/40x60?text=No+Img';">
												            </c:when>
												            <c:otherwise>
												                <div style="width: 40px; height: 60px; background: #eee; display: flex; align-items: center; justify-content: center; font-size: 9px; color: #999;">No Image</div>
												            </c:otherwise>
												        </c:choose>
												        <%-- 💥 제목이 길어도 넘치지 않게 말줄임표 처리 --%>
												        <span class="vendor-order-book-title" style="overflow: hidden; text-overflow: ellipsis; max-width: 250px;">
												            ${order.title}
												        </span>
												    </div>
												</td>
												<td class="td-order-qty align-middle">${order.quantity} 권</td>
												<td class="td-total-price text-end align-middle">
												    <fmt:formatNumber value="${order.totalPrice}" pattern="#,###"/> 원
												</td>
												<td class="td-order-date align-middle">
												    <fmt:formatDate value="${order.purchaseDate}" pattern="yyyy-MM-dd HH:mm"/>
												</td>
												<td class="td-order-status align-middle">
												    <c:choose>
												        <%-- 💥 2. 상태 코드 검문소 'READY'로 교체! --%>
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
												<td class="td-order-control align-middle">
												    <c:choose>
												        <%-- 💥 3. 상태 코드 검문소 'READY'로 교체하여 배송 버튼 봉인 해제! --%>
												        <c:when test="${order.status eq 'READY'}">
												            <button type="button" class="btn-vendor-action-ship" onclick="shipOrder('${order.id}')">
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
                                    
                                    <%-- 들어온 주문이 하나도 없을 때 --%>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="td-empty-state">
                                                <div class="cosmic-empty-state py-5">
                                                    <div class="empty-icon-large" style="color: #a4b0be;">📡</div>
                                                    <h4 class="empty-title" style="color: #7f8c8d;">인입된 도서 주문 내역이 존재하지 않습니다.</h4>
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
</script>