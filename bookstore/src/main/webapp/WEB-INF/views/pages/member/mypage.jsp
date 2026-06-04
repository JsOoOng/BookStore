<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:if test="${not empty addressAlert}">
    <div class="alert alert-warning border-0 mb-4 text-center shadow-sm" 
         style="background: rgba(255, 159, 26, 0.15); color: #d35400; border-radius: 12px; font-weight: bold; padding: 15px; font-size: 1rem;">
        ⚠️ 보안 및 물류 관제 고지: ${addressAlert}<br>
        <span style="font-size: 0.85rem; font-weight: normal; opacity: 0.9;">우측 상단의 [⚙️ 개인 정보 수정] 버튼을 눌러 유효한 보급지 주소를 업데이트해 주세요.</span>
    </div>
</c:if>

<div class="mypage-container">
    <%-- 🪐 1. 상단 프로필 카드 섹션 --%>
    <section class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <span class="avatar-icon">👨‍🚀</span>
            </div>
            <div class="profile-info" style="flex: 1;">
                <h2 class="profile-name">
                    ${loginMember.name} 대원 
                    <span class="badge bg-primary ms-2" style="font-size: 0.8rem; padding: 4px 10px; border-radius: 20px;">
                        ${loginMember.reg_status}
                    </span>
                </h2>
                <p class="profile-role text-muted small mb-1">
                    ID: <span class="fw-bold text-dark">${loginMember.id}</span> | 
                    ✉️ ${not empty loginMember.email ? loginMember.email : '통신 주소 미등록'}
                </p>
                
                <p class="profile-address mb-2 small text-secondary">
                    🏠 물류 보급지: 
                    <c:choose>
                        <c:when test="${loginMember.address eq '은하계 미지정 구역'}">
                            <span class="text-danger fw-bold" style="background: rgba(255,71,87,0.1); padding: 2px 6px; border-radius: 4px;">⚠️ ${loginMember.address}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="text-dark fw-bold">${loginMember.address}</span>
                        </c:otherwise>
                    </c:choose>
                </p>

                <div class="d-flex align-items-center gap-4 mt-2">
                    <p class="profile-date mb-0 small text-secondary">🚀 입성일: <fmt:formatDate value="${loginMember.regDate}" pattern="yyyy-MM-dd"/></p>
                    <p class="profile-points mb-0 small" style="color: #5d5fef; font-weight: bold;">
                        💰 보유 적립금: <fmt:formatNumber value="${loginMember.points}" pattern="#,###"/> P
                    </p>
                </div>
            </div>
            <div class="profile-actions">
                <a href="${pageContext.request.contextPath}/member/edit" class="btn-cosmic btn-edit" style="white-space: nowrap;">
                    ⚙️ 개인 정보 수정
                </a>
            </div>
        </div>
    </section>

    <%-- 🪐 2. 하단 양옆 분할 콘텐츠 그리드 (style.css 내의 커스텀 플렉스 매핑) --%>
    <div class="mypage-content-row">
        
        <%-- 🛒 좌측 분역: 현재 장바구니 카드 --%>
        <div style="flex: 1;">
            <section class="mypage-section basket-section h-100">
                <h3 class="section-title">📦 현재 장바구니 (${basketList.size()})</h3>
                <div class="scroll-area">
                    <c:choose>
                        <c:when test="${not empty basketList}">
                            <c:forEach var="basket" items="${basketList}">
                                <div class="mini-item-card" onclick="location.href='${pageContext.request.contextPath}/basket' " style="cursor: pointer;">
                                    <img src="${basket.image.startsWith('http') ? basket.image : pageContext.request.contextPath.concat(basket.image)}" 
                                         class="mini-img" onerror="this.src='https://via.placeholder.com/50x75?text=No+Img' ">
                                    <div class="mini-info">
                                        <p class="mini-title text-truncate" style="max-width: 180px;">${basket.title}</p>
                                        <p class="mini-price"><fmt:formatNumber value="${basket.price}" pattern="#,###"/> 원</p>
                                    </div>
                                    <span class="arrow-icon">➔</span>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-msg">담긴 도서가 없습니다.</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>
        </div>

        <%-- 📜 우측 분역: 도서 구매 기록 카드 --%>
        <div style="flex: 1;">
            <section class="mypage-section purchase-section h-100">
                <h3 class="section-title">📜 도서 구매 기록 (${purchaseList.size()})</h3>
                <div class="scroll-area">
                    <c:choose>
                        <c:when test="${not empty purchaseList}">
                            <c:forEach var="pur" items="${purchaseList}">
                                <div class="history-item-card">
                                    <div class="history-date">
                                        <fmt:formatDate value="${pur.purchaseDate}" pattern="MM.dd HH:mm"/>
                                    </div>
                                    <div class="history-main">
                                        <img src="${pur.image.startsWith('http') ? pur.image : pageContext.request.contextPath.concat(pur.image)}" 
                                             class="history-img" onerror="this.src='https://via.placeholder.com/50x75?text=No+Img' ">
                                        <div class="history-info">
                                            <p class="history-title text-truncate" style="max-width: 160px;">${pur.title}</p>
                                            <p class="history-meta">수량: ${pur.quantity} | 결제액: <fmt:formatNumber value="${pur.totalPrice}" pattern="#,###"/> 원</p>
                                        </div>
                                        
                                        <%-- 🌟 [배송 상태 분기] SHIPPING 상태일 때 가독성이 극대화된 커스텀 배지 클래스 장착 --%>
                                        <c:choose>
                                            <c:when test="${pur.status eq 'SHIPPING'}">
                                                <span class="status-badge shipping">SHIPPING</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge status-done">${pur.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-msg">아직 도서 구매 기록이 없습니다.</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>
        </div>

    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    // 🪐 페이지 로딩 시 결제 방어선 경고문이 넘어왔다면 브라우저 팝업 알림 레이더 가동
    $(document).ready(function() {
        <c:if test="${not empty addressAlert}">
            alert("🔒 안전 관제 공지:\n${addressAlert}\n\n[개인 정보 수정] 메뉴에서 주소를 업데이트해 주셔야 정상적인 주문 처리가 승인됩니다.");
        </c:if>
    });
</script>