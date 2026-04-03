<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="main-content">
    <div class="purchase-container">

        <section class="purchase-hero">
            <span class="purchase-kicker">COSMIC CHECKOUT</span>
            <h2 class="purchase-title">지식의 항해를 시작하기 전, 최종 점검</h2>
            <p class="purchase-subtitle">
                선택하신 ${purchaseList.size()}개의 행성(도서) 데이터를 확인해 주세요.<br>
                승인 버튼을 누르는 순간, 지식 베이스로의 전송이 시작됩니다.
            </p>
        </section>

        <div class="purchase-layout">
            
            <section class="purchase-book-list">
                <c:forEach var="book" items="${purchaseList}">
                    <div class="purchase-item-card">
                        <div class="purchase-cover-wrap">
                            <img src="${pageContext.request.contextPath}${book.image}" alt="${book.title}" class="purchase-img">
                        </div>

                        <div class="purchase-info">
                            <div class="purchase-badge-row">
                                <span class="purchase-badge">🚀 전송 대기 중</span>
                                <span class="purchase-badge">${book.genre}</span>
                            </div>

                            <h3 class="item-title">${book.title}</h3>

                            <div class="purchase-meta">
                                <span><strong>저자</strong> ${book.writer}</span>
                                <span><strong>출판사</strong> ${book.publisher}</span>
                                <span><strong>ISBN</strong> ${book.isbn}</span>
                                <span><strong>수량</strong> ${book.quantity} 권</span>
                            </div>

                            <div class="purchase-price-row">
                                <span class="price-label">데이터 가치</span>
                                <span class="item-price">
                                    <fmt:formatNumber value="${book.price}" pattern="#,###"/> 원
                                </span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </section>

            <aside class="purchase-summary-card">
                <div class="summary-inner">
                    <h3 class="purchase-summary-title">결제 요약</h3>

                    <form action="${pageContext.request.contextPath}/purchase/buy" method="post">
                        <c:choose>
						    <%-- 장바구니에서 넘어온 경우 --%>
						    <c:when test="${not empty basketIds}">
						        <input type="hidden" name="basketIds" value="${basketIds}">
						    </c:when>
						    <%-- 상세페이지에서 바로구매로 넘어온 경우 --%>
						    <c:otherwise>
						        <input type="hidden" name="bookId" value="${purchaseList[0].bookId}">
						    </c:otherwise>
						</c:choose>

                        <div class="purchase-summary-details">
                            <div class="summary-row">
                                <span>선택된 지식 수</span>
                                <span>${purchaseList.size()} 권</span>
                            </div>

                            <div class="summary-row">
                                <span>전송료(배송비)</span>
                                <span class="free-text">FREE</span>
                            </div>

                            <div class="summary-divider"></div>

                            <div class="summary-total">
                                <span>총 결제 금액</span>
                                <strong class="total-amount">
                                    <fmt:formatNumber value="${totalPrice}" pattern="#,###"/> 원
                                </strong>
                            </div>
                        </div>

                        <div class="purchase-note">
                            🛡️ 본 결제는 보안 프로토콜에 따라 암호화되어 안전하게 처리됩니다.
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn-confirm">💳 결제</button>
                            <button type="button" class="btn-cancel" onclick="history.back()">탐사 취소</button>
                        </div>
                    </form>
                </div>
            </aside>
        </div>

    </div>
</div>