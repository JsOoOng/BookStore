<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="main-content">
    <div class="purchase-container">

        <section class="purchase-hero">
            <span class="purchase-kicker">COSMIC CHECKOUT</span>
            <h2 class="purchase-title">한 권의 책으로, 우린 하나의 우주가 됩니다</h2>
            <p class="purchase-subtitle">
                선택한 도서를 최종 확인하고 결제를 진행하세요.
                복잡하지 않게, 그러나 조금은 신비롭게.
            </p>
        </section>

        <div class="purchase-layout">
            <!-- 좌측: 도서 정보 -->
            <section class="purchase-book">
                <div class="purchase-cover-wrap">
                    <img src="${pageContext.request.contextPath}${book.image}" alt="${book.title}" class="purchase-img">
                </div>

                <div class="purchase-info">
                    <div class="purchase-badge-row">
                        <span class="purchase-badge">🚀 구매 준비 완료</span>
                        <span class="purchase-badge">📦 안전 포장 배송</span>
                        <span class="purchase-badge">🪐 우주 도서관 셀렉션</span>
                    </div>

                    <h3>${book.title}</h3>

                    <div class="purchase-meta">
                        <span><strong>저자</strong> ${book.writer}</span>
                        <span><strong>출판사</strong> ${book.publisher}</span>
                        <span><strong>장르</strong> ${not empty book.genre ? book.genre : '미분류'}</span>
                        <span><strong>ISBN</strong> ${book.isbn}</span>
                    </div>

                    <div class="purchase-price-box">
                        <span class="purchase-price-label">상품 금액</span>
                        <p class="purchase-price">
                            <fmt:formatNumber value="${book.price}" pattern="#,###"/> 원
                        </p>
                    </div>

                    <div class="purchase-desc">
                        ${book.content}
                    </div>
                </div>
            </section>

            <!-- 우측: 결제 요약 -->
            <aside class="purchase-summary-card">
                <h3 class="purchase-summary-title">결제 요약</h3>

                <form action="${pageContext.request.contextPath}/purchase/buy" method="post">
                    <input type="hidden" name="bookId" value="${book.id}">

                    <div class="purchase-summary">
                        <div class="summary-row">
                            <span>상품 금액</span>
                            <span><fmt:formatNumber value="${book.price}" pattern="#,###"/> 원</span>
                        </div>

                        <div class="summary-row">
                            <span>배송비</span>
                            <span>무료</span>
                        </div>

                        <div class="summary-total">
                            <span>총 결제 금액</span>
                            <strong><fmt:formatNumber value="${book.price}" pattern="#,###"/> 원</strong>
                        </div>
                    </div>

                    <div class="purchase-note">
                        결제 단계는 아직 구현 예정이지만, 현재는 구매 흐름과 화면 구성을 우선 완성하는 단계입니다.
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn-confirm">💳 구매하기</button>
                        <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
                    </div>
                </form>
            </aside>
        </div>

    </div>
</div>