<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="mypage-container">
    <section class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <span class="avatar-icon">👨‍🚀</span>
            </div>
            <div class="profile-info">
                <h2 class="profile-name">${loginMember.name} 대원</h2>
                <p class="profile-role">
                    <span class="badge-role">${loginMember.role}</span> | ID: ${loginMember.id}
                </p>
                <p class="profile-date">입성일: <fmt:formatDate value="${loginMember.regDate}" pattern="yyyy-MM-dd"/></p>
            </div>
            <div class="profile-actions">
                <a href="${pageContext.request.contextPath}/member/edit" class="btn-cosmic btn-edit">
                    ⚙️ 개인 정보 수정
                </a>
            </div>
        </div>
    </section>

    <div class="mypage-content-grid">
        <section class="mypage-section basket-section">
            <h3 class="section-title">📦 현재 장바구니 (${basketList.size()})</h3>
            <div class="scroll-area">
                <c:choose>
                    <c:when test="${not empty basketList}">
                        <c:forEach var="basket" items="${basketList}">
                            <div class="mini-item-card" onclick="location.href='${pageContext.request.contextPath}/basket'">
                                <img src="${pageContext.request.contextPath}${basket.image}" class="mini-img">
                                <div class="mini-info">
                                    <p class="mini-title">${basket.title}</p>
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

        <section class="mypage-section purchase-section">
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
                                    <img src="${pageContext.request.contextPath}${pur.image}" class="history-img">
                                    <div class="history-info">
                                        <p class="history-title">${pur.title}</p>
                                        <p class="history-meta">수량: ${pur.quantity} | 결제액: <fmt:formatNumber value="${pur.totalPrice}" pattern="#,###"/> 원</p>
                                    </div>
                                    <span class="status-badge status-done">${pur.status}</span>
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