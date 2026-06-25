<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container vendor-dashboard-container mt-4 mb-5">
    
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

    <div class="row g-4 vendor-grid-row">
        <div class="col-xl-3 col-lg-4">
            <div class="card cosmic-vendor-info-card h-100">
                <div class="card-header info-card-header">🏢 파트너십 가입 정보</div>
                <div class="card-body info-card-body">
                    <div class="info-row"><small class="info-label">파트너 계정 ID</small><span class="info-value text-white">${sessionScope.loginVendor.vendorId}</span></div>
                    <div class="info-row"><small class="info-label">공식 상호명</small><span class="info-value text-warning">${sessionScope.loginVendor.bizName}</span></div>
                    <div class="info-row"><small class="info-label">사업자 등록 번호</small><span class="info-value text-light">${sessionScope.loginVendor.bizNo}</span></div>
                    <div class="info-row"><small class="info-label">대표자 연락처</small><span class="info-value text-light">${sessionScope.loginVendor.contact}</span></div>
                    <div class="info-row-last border-0 pb-0 mb-0"><small class="info-label">활동 승인 번호</small><span class="badge-approval">No. ${sessionScope.loginVendor.vendorRegNum}</span></div>
                </div>
            </div>
        </div>

        <div class="col-xl-9 col-lg-8">
            <div class="card cosmic-vendor-main-card h-100">
                <div class="card-header main-card-header">
                    <span class="main-card-title">🚚 입점 파트너 정규 회원 주문 관제탑</span>
                </div>
                
                <div class="card-body p-0 main-card-body">
                    <div class="table-responsive vendor-table-wrap">
                        <%-- 💥 [1단계] 메인 테이블 구역: 오직 <tr>과 <td>만 존재해야 한다! --%>
                        <table class="cosmic-table vendor-order-table text-center mb-0">
                            <thead>
                                <tr>
                                    <th>주문 번호</th>
                                    <th>주문자명</th>
                                    <th>총 결제액</th>
                                    <th>주문 일시</th>
                                    <th>현재 상태</th>
                                    <th>관제 제어</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty groupedOrders}">
                                        <c:forEach var="entry" items="${groupedOrders}">
                                            <c:set var="purchaseId" value="${entry.key}" />
                                            <c:set var="details" value="${entry.value}" />
                                            <c:set var="firstDetail" value="${details[0]}" />
                                            
                                            <%-- 상태 연산 --%>
                                            <c:set var="masterTotal" value="0"/>
                                            <c:set var="hasReady" value="false"/>
                                            <c:set var="hasShipping" value="false"/>
                                            
                                            <c:forEach var="d" items="${details}">
                                                <c:set var="masterTotal" value="${masterTotal + d.totalPrice}"/>
                                                <c:if test="${d.status eq 'READY'}"><c:set var="hasReady" value="true"/></c:if>
                                                <c:if test="${d.status eq 'SHIPPING'}"><c:set var="hasShipping" value="true"/></c:if>
                                            </c:forEach>

                                            <tr class="vendor-order-row">
                                                <td class="fw-bold text-primary"># ${purchaseId}</td>
                                                <td><span class="badge bg-secondary">${firstDetail.userName}</span> 대원</td>
                                                <td class="fw-bold text-dark"><fmt:formatNumber value="${masterTotal}" pattern="#,###"/> 원</td>
                                                <td><fmt:formatDate value="${firstDetail.purchaseDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${hasReady}">
                                                            <span class="badge-status-vendor status-ready">🚀 배송 대기중</span>
                                                        </c:when>
                                                        <c:when test="${hasShipping}">
                                                            <span class="badge-status-vendor status-shipping">🌌 배송 진행중</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status-vendor" style="background:#2ed573; color:white;">✅ 배송 완료</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <button type="button" class="btn btn-sm btn-dark" data-bs-toggle="modal" data-bs-target="#receiptModal-${purchaseId}">
                                                        🧾 영수증 확인
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="py-5 text-muted">인입된 회원 도서 주문 내역이 존재하지 않습니다.</td>
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

<%-- 💥 [2단계] 모달 창 구역: 테이블 바깥(안전 지대)으로 완전 격리! --%>
<c:if test="${not empty groupedOrders}">
    <c:forEach var="entry" items="${groupedOrders}">
        <c:set var="purchaseId" value="${entry.key}" />
        <c:set var="details" value="${entry.value}" />
        <c:set var="firstDetail" value="${details[0]}" />
        
        <c:set var="masterTotal" value="0"/>
        <c:forEach var="d" items="${details}">
            <c:set var="masterTotal" value="${masterTotal + d.totalPrice}"/>
        </c:forEach>

        <div class="modal fade" id="receiptModal-${purchaseId}" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-centered" style="max-width: 70%;">
                <div class="modal-content">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title">🧾 상세 영수증 (주문번호: # ${purchaseId})</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <strong>주문자:</strong> ${firstDetail.userName} | 
                            <strong>주문일시:</strong> <fmt:formatDate value="${firstDetail.purchaseDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                        </div>
                        <table class="table table-bordered text-center align-middle">
                            <thead class="table-light" style="white-space: nowrap; word-break: keep-all;">
                                <tr>
                                    <th style="width: 10%; min-width: 80px;">상세번호</th>
							        <th style="width: auto; min-width: 300px;">도서 정보</th>
							        <th style="width: 8%; min-width: 60px;">수량</th>
							        <th style="width: 12%; min-width: 100px;">결제액</th>
							        <th style="width: 10%; min-width: 80px;">상태</th>
							        <th style="width: 10%; min-width: 90px;">제어</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="order" items="${details}">
                                    <tr>
                                        <td># ${order.id}</td>
                                        <td class="text-start">
                                            <img src="${order.image}" alt="cover" style="width:40px; height:60px; object-fit:cover; border-radius:4px; margin-right:10px;" onerror="this.onerror=null; this.src='https://placehold.co/150x220/f8fafc/a4b0be?text=No+Cover';">
                                            ${order.title}
                                        </td>
                                        <td>${order.quantity}</td>
                                        <td><fmt:formatNumber value="${order.totalPrice}" pattern="#,###"/>원</td>
                                        <td>
                                            <c:if test="${order.status eq 'READY'}"><span class="badge bg-warning text-dark">배송대기</span></c:if>
                                            <c:if test="${order.status eq 'SHIPPING'}"><span class="badge bg-info text-dark">배송중</span></c:if>
                                            <c:if test="${order.status eq 'DELIVERED'}"><span class="badge bg-success">배송완료</span></c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${order.status eq 'READY'}">
                                                    <button class="btn btn-sm btn-primary" onclick="shipOrder('${order.id}')">🚚 배송하기</button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn btn-sm btn-secondary" disabled>완료됨</button>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        <div class="text-end mt-2 fs-5">
                            <strong>총 청구 금액 : <span class="text-primary"><fmt:formatNumber value="${masterTotal}" pattern="#,###"/> 원</span></strong>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:forEach>
</c:if>

<script>
function shipOrder(detailId) { 
    if (!confirm("해당 도서의 전송(배송)을 시작하시겠습니까?")) return;
    
    var formData = new URLSearchParams();
    formData.append("purchaseId", detailId);

    fetch("${pageContext.request.contextPath}/vendor/purchase/ship", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: formData
    })
    .then(response => response.text())
    .then(data => {
        if (data.trim() === "ok") {
            alert("🌌 배송 출발! 영수증 상태가 업데이트되었습니다.");
            location.reload(); 
        } else {
            alert("🚨 승인 실패.");
        }
    })
    .catch(error => console.error("Error:", error));
}

document.addEventListener("DOMContentLoaded", function() {
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