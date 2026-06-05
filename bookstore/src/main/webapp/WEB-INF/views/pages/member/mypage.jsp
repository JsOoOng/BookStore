<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 🚨 미지정 주소 경고 배너 --%>
<c:if test="${not empty addressAlert}">
    <div class="cosmic-alert-banner alert-warning-cosmic text-center">
        ⚠️ 보안 및 물류 관제 고지: ${addressAlert}<br>
        <span class="alert-sub-text">우측 상단의 [⚙️ 개인 정보 수정] 버튼을 눌러 유효한 보급지 주소를 업데이트해 주세요.</span>
    </div>
</c:if>

<div class="admin-wide-container mt-4 mb-5">
    
    <%-- 🪐 1. 상단 프로필 카드 섹션 --%>
    <section class="cosmic-profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <span class="avatar-icon">👨‍🚀</span>
            </div>
            <div class="profile-info">
                <h2 class="profile-name">
                    ${loginMember.name} 대원 
                    <span class="badge-status-reg">${loginMember.reg_status}</span>
                </h2>
                <p class="profile-role">
                    ID: <span class="fw-bold text-dark">${loginMember.id}</span> | 
                    ✉️ ${not empty loginMember.email ? loginMember.email : '통신 주소 미등록'}
                </p>
                
                <p class="profile-address">
                    🏠 물류 보급지: 
                    <c:choose>
                        <c:when test="${loginMember.address eq '은하계 미지정 구역'}">
                            <span class="address-warning-badge">⚠️ ${loginMember.address}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="address-normal-text">${loginMember.address}</span>
                        </c:otherwise>
                    </c:choose>
                </p>

                <div class="profile-meta-row">
                    <p class="profile-date">🚀 입성일: <fmt:formatDate value="${loginMember.regDate}" pattern="yyyy-MM-dd"/></p>
                    <p class="profile-points">
                        💰 보유 적립금: <fmt:formatNumber value="${loginMember.points}" pattern="#,###"/> P
                    </p>
                </div>
            </div>
            <div class="profile-actions">
                <button type="button" class="btn-cosmic btn-edit-profile" onclick="location.href='${pageContext.request.contextPath}/member/edit'">
                    ⚙️ 개인 정보 수정
                </button>
            </div>
        </div>
    </section>

    <%-- 🪐 2. 하단 양옆 분할 콘텐츠 그리드 --%>
    <div class="mypage-content-row mt-4">
        
        <%-- 🛒 좌측 분역: 현재 장바구니 카드 --%>
        <div class="mypage-half-col">
            <section class="mypage-dashboard-section h-100">
                <h3 class="dashboard-section-title">📦 현재 장바구니 (${basketList.size()})</h3>
                <div class="dashboard-scroll-area">
                    <c:choose>
                        <c:when test="${not empty basketList}">
                            <c:forEach var="basket" items="${basketList}">
                                <div class="dashboard-mini-card clickable-card" onclick="location.href='${pageContext.request.contextPath}/basket'">
                                    <img src="${basket.image}" class="dashboard-mini-img" onerror="this.onerror=null; this.src='https://via.placeholder.com/50x75?text=No+Img'">
                                    <div class="dashboard-mini-info">
                                        <p class="dashboard-item-title">${basket.title}</p>
                                        <p class="dashboard-item-price"><fmt:formatNumber value="${basket.price}" pattern="#,###"/> 원</p>
                                    </div>
                                    <span class="dashboard-arrow-icon">➔</span>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="dashboard-empty-msg">담긴 도서가 없습니다.</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>
        </div>

        <%-- 📜 우측 분역: 도서 구매 기록 카드 --%>
        <div class="mypage-half-col">
            <section class="mypage-dashboard-section h-100">
                <h3 class="dashboard-section-title">📜 도서 구매 기록 (${purchaseList.size()})</h3>
                <div class="dashboard-scroll-area">
                    <c:choose>
                        <c:when test="${not empty purchaseList}">
                            <c:forEach var="pur" items="${purchaseList}">
                                <div class="dashboard-mini-card">
                                    <div class="dashboard-history-date">
                                        <fmt:formatDate value="${pur.purchaseDate}" pattern="MM.dd HH:mm"/>
                                    </div>
                                    <div class="dashboard-history-main">
                                        <img src="${pur.image}" class="dashboard-mini-img" onerror="this.onerror=null; this.src='https://via.placeholder.com/50x75?text=No+Img'">
                                        <div class="dashboard-mini-info">
                                            <p class="dashboard-item-title history-title">${pur.title}</p>
                                            <p class="dashboard-item-meta">수량: ${pur.quantity} | 결제액: <fmt:formatNumber value="${pur.totalPrice}" pattern="#,###"/> 원</p>
                                        </div>
                                        
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
                            <div class="dashboard-empty-msg">아직 도서 구매 기록이 없습니다.</div>
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