<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 🪐 85% 와이드 선체 개방 컨테이너 이식 --%>
<div class="admin-wide-container mt-4">
    
    <%-- 🚀 [스타일 격리] 외부 파일로 싹 분리하여 완벽하게 정돈된 헤더 라인 --%>
    <div class="vendor-hero-section">
        <span class="vendor-kicker-brand d-block">COSMIC VENDOR LOGISTICS</span>
        <h2 class="fw-bold text-dark vendor-main-title">📦 입점 파트너 주문 배송 관제탑</h2>
        <p class="text-secondary mb-0 fw-bold vendor-desc-text">
            대원들이 주문한 도서 데이터의 전송 상태를 관리합니다. <br>
            <span class="text-danger">[배송하기]</span>를 누르면 대원의 마이페이지 상태가 실시간으로 워프합니다.
        </p>
    </div>

    <%-- 📊 물류 관제 데이터 테이블 카드 구역 (style.css 마스터 팩 클래스 조합) --%>
    <div class="main-content p-0 border-0 admin-table-card">
        <table class="table table-hover admin-table mb-0 align-middle text-center">
            <thead class="table-dark">
                <tr>
                    <th class="py-3 col-order-num" style="border-top-left-radius: 20px;">주문 번호</th>
                    <th class="text-start col-book-info">도서 정보</th>
                    <th class="col-order-qty">주문 수량</th>
                    <th class="text-end col-total-price">결제 총액</th>
                    <th class="col-order-date">주문 일시</th>
                    <th class="col-order-status">현재 상태</th>
                    <th class="col-order-control" style="border-top-right-radius: 20px;">관제 제어</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <%-- 들어온 주문이 있을 때 (List View) --%>
                    <c:when test="${not empty orderList}">
                        <c:forEach var="order" items="${orderList}">
                            <tr class="admin-row">
                                <%-- 주문 고유 번호 --%>
                                <td class="fw-bold text-dark"># ${order.id}</td>
                                
                                <%-- 도서 상세 정보 --%>
                                <td>
								    <div class="d-flex align-items-center gap-3 text-start">
								        <c:choose>
								            <c:when test="${not empty order.image}">
								                <img src="${pageContext.request.contextPath}${order.image}" alt="${order.title}" class="rounded shadow-sm vendor-book-thumb">
								            </c:when>
								            <c:otherwise>
								                <div class="bg-secondary text-white rounded d-flex align-items-center justify-content-center shadow-sm vendor-book-no-image">No Image</div>
								            </c:otherwise>
								        </c:choose> <span class="fw-bold text-dark text-truncate d-inline-block" style="max-width: 250px;">${order.title}</span>
								    </div>
								</td>
                                
                                <%-- 주문 수량 --%>
                                <td class="fw-bold text-secondary">${order.quantity} 권</td>
                                
                                <%-- 결제 총액 --%>
                                <td class="text-end fw-bold col-total-price">
                                    <fmt:formatNumber value="${order.totalPrice}" pattern="#,###"/> 원
                                </td>
                                
                                <%-- 주문 일시 --%>
                                <td class="text-muted">
                                    <fmt:formatDate value="${order.purchaseDate}" pattern="yyyy-MM-dd HH:mm"/>
                                </td>
                                
                                <%-- 현재 상태 배지화 --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${order.status eq 'ORDERED'}">
                                            <span class="badge bg-warning text-dark rounded-pill px-3 py-1 fw-bold">🚀 전송대기</span>
                                        </c:when>
                                        <c:when test="${order.status eq 'SHIPPING'}">
                                            <span class="badge bg-info text-dark rounded-pill px-3 py-1 fw-bold">🌌 전송중</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary text-white rounded-pill px-3 py-1 fw-bold">${order.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <%-- 관제 버튼 --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${order.status eq 'ORDERED'}">
                                            <button type="button" class="btn btn-sm btn-danger rounded-pill px-3 fw-bold shadow-sm"
                                                    onclick="shipOrder('${order.id}')">
                                                🚚 배송하기
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn btn-sm btn-secondary rounded-pill px-3 fw-bold" disabled style="opacity: 0.6;">
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
                            <td colspan="7" class="text-center py-5 text-muted small fw-bold">
                                📡 현재 이 입점 상점으로 인입된 도서 주문 내역이 존재하지 않습니다.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
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
</script>