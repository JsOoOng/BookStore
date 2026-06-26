<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 🚀 1. 풀와이드 히어로 배너 --%>
<div class="univ-hero-section">
    <div class="univ-hero-overlay"></div>
    <div class="univ-hero-content">
        <h1 class="hero-main-title">우주 도서관에 오신 것을 환영합니다</h1>
        <p class="hero-sub-desc">
            우리는 항상, 더 높은 이상을 꿈꿉니다.<br>
            지식의 은하계를 탐험하고 원하는 도서를 대여해 보세요.
        </p>
        <div class="hero-btn-group">
            <a href="${pageContext.request.contextPath}/book/list" class="btn-hero-primary">지식 탐험 시작하기</a>
        </div>
    </div>
</div>

<%-- 🌌 통합 도서 큐레이션 섹션 관제구역 --%>
<div class="univ-new-books-section">
    <div class="univ-section-container">
        
        <%-- ==========================================
             TRK 1. 신규 입고 도서 슬라이더
             ========================================== --%>
        <div class="cosmic-slider-wrapper">
            <div class="section-title-group">
                <h4 class="cosmic-slider-tag">NEW ARRIVALS</h4>
                <h2 class="section-main-title">이번 주에 새로 보급된 <span>지식 자산</span></h2>
            </div>
            
            <div class="cosmic-carousel-container">
                <button type="button" class="carousel-nav-btn prev-btn" onclick="moveCosmicSlider('track-recent', -1)">❮</button>
                <div class="carousel-window">
                    <div class="carousel-track" id="track-recent">
                        <c:forEach var="book" items="${recentBooks}">
                            <div class="showcase-card" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
                                <div class="showcase-img-box">
                                    <img src="${book.image}" onerror="this.onerror=null; this.src='https://via.placeholder.com/150x220?text=No+Cover';">
                                </div>
                                <div class="showcase-book-title">${book.title}</div>
                                <div class="showcase-book-writer">${book.writer}</div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                <button type="button" class="carousel-nav-btn next-btn" onclick="moveCosmicSlider('track-recent', 1)">❯</button>
            </div>
        </div>

        <%-- ==========================================
             TRK 2. 거장 스페셜 슬라이더 (한강 작가 테마)
             ========================================== --%>
        <div class="cosmic-slider-wrapper mt-5">
            <div class="section-title-group">
                <h4 class="cosmic-slider-tag" style="color: #ff4757;">NOBEL LAUREATE</h4>
                <h2 class="section-main-title">시대의 눈물과 숨결을 읽다, <span>한강 스페셜</span></h2>
            </div>
            
            <div class="cosmic-carousel-container">
                <button type="button" class="carousel-nav-btn prev-btn" onclick="moveCosmicSlider('track-hangang', -1)">❮</button>
                <div class="carousel-window">
                    <div class="carousel-track" id="track-hangang">
                        <c:choose>
                            <c:when test="${empty hankangBooks}">
                                <div class="text-center w-100 py-5 text-muted"><small>현재 기지에 한강 작가의 데이터가 입고 대기 중입니다.</small></div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="book" items="${hankangBooks}">
                                    <div class="showcase-card" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
                                        <div class="showcase-img-box">
                                            <img src="${book.image}" onerror="this.onerror=null; this.src='https://via.placeholder.com/150x220?text=No+Cover';">
                                        </div>
                                        <div class="showcase-book-title">${book.title}</div>
                                        <div class="showcase-book-writer">${book.writer}</div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <button type="button" class="carousel-nav-btn next-btn" onclick="moveCosmicSlider('track-hangang', 1)">❯</button>
            </div>
        </div>

        <%-- ==========================================
             TRK 3. 우주 천체 과학 슬라이더
             ========================================== --%>
        <div class="cosmic-slider-wrapper mt-5">
            <div class="section-title-group">
                <h4 class="cosmic-slider-tag" style="color: #17a2b8;">COSMIC SCIENCE</h4>
                <h2 class="section-main-title">미지의 우주와 <span>천체 스펙트럼</span></h2>
            </div>
            
            <div class="cosmic-carousel-container">
                <button type="button" class="carousel-nav-btn prev-btn" onclick="moveCosmicSlider('track-space', -1)">❮</button>
                <div class="carousel-window">
                    <div class="carousel-track" id="track-space">
                        <c:choose>
                            <c:when test="${empty spaceBooks}">
                                <div class="text-center w-100 py-5 text-muted"><small>천체 과학 지식 원천 소스가 부재합니다.</small></div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="book" items="${spaceBooks}">
                                    <div class="showcase-card" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
                                        <div class="showcase-img-box">
                                            <img src="${book.image}" onerror="this.onerror=null; this.src='https://via.placeholder.com/150x220?text=No+Cover';">
                                        </div>
                                        <div class="showcase-book-title">${book.title}</div>
                                        <div class="showcase-book-writer">${book.writer}</div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <button type="button" class="carousel-nav-btn next-btn" onclick="moveCosmicSlider('track-space', 1)">❯</button>
            </div>
        </div>

    </div>
</div>

<style>
/* ==========================================================================
   🌌 교보문고 스타일 무한 루프 슬라이더 CSS 엔진
   ========================================================================== */
.cosmic-slider-wrapper {
    position: relative;
    margin-bottom: 60px;
}
.cosmic-slider-tag {
    font-size: 12px;
    font-weight: 800;
    color: #5d5fef;
    letter-spacing: 1.5px;
    margin-bottom: 5px;
}
.carousel-nav-btn {
    position: absolute;
    top: 40%;
    transform: translateY(-50%);
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: #ffffff;
    border: 1px solid #edeff2;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    font-size: 16px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10;
    transition: all 0.2s;
}
.carousel-nav-btn:hover {
    background: #0b132b;
    color: #ffffff;
    border-color: #0b132b;
}
.prev-btn { left: -22px; }
.next-btn { right: -22px; }

/* 핵심 레이어 윈도우 */
.carousel-window {
    width: 100%;
    overflow: hidden;
    padding: 10px 0;
}
.carousel-track {
    display: flex;
    gap: 24px;
    transition: transform 0.45s cubic-bezier(0.25, 1, 0.5, 1);
    will-change: transform;
}

/* 📚 교보문고 실사 축소 카드 디자인 */
.showcase-card {
    flex: 0 0 calc(20% - 20px); /* 한 화면에 정밀하게 5권씩 노출 균형 균등 분할 */
    min-width: 170px;
    cursor: pointer;
    transition: transform 0.25s ease;
}
.showcase-card:hover {
    transform: translateY(-6px);
}
.showcase-img-box {
    width: 100%;
    height: 240px;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 6px 18px rgba(0,0,0,0.07);
    border: 1px solid #edeff2;
    background: #fcfcfd;
    margin-bottom: 12px;
}
.showcase-img-box img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
.showcase-book-title {
    font-size: 14px;
    font-weight: 700;
    color: #0b132b;
    margin-bottom: 4px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.showcase-book-writer {
    font-size: 12px;
    color: #7f8c8d;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    // 🪐 전역 슬라이더 인덱스 계측소
    var sliderPositions = {};

    function moveCosmicSlider(trackId, direction) {
        var track = document.getElementById(trackId);
        if(!track) return;
        
        var cards = track.getElementsByClassName('showcase-card');
        if(cards.length === 0) return;

        // 카드 한 장의 실제 가로 스텝 크기 계산 (너비 + gap)
        var cardWidth = cards[0].getBoundingClientRect().width;
        var gap = 24; 
        var step = cardWidth + gap;
        
        // 한 화면에 표출되는 카드 수 계산 및 최대 한계 인덱스 도출
        var windowWidth = track.parentElement.getBoundingClientRect().width;
        var visibleCards = Math.round(windowWidth / step);
        var maxIdx = cards.length - visibleCards;
        if(maxIdx < 0) maxIdx = 0;

        // 인덱스 첫 초기화
        if (sliderPositions[trackId] === undefined) {
            sliderPositions[trackId] = 0;
        }

        // 포지션 인덱스 증감 제어
        sliderPositions[trackId] += direction;

        // 💥 [핵심 미션] 마지막 도달 시 첫 번째로 회귀, 첫 번째에서 역방향 시 마지막으로 워프!
        if (sliderPositions[trackId] > maxIdx) {
            sliderPositions[trackId] = 0; // 무한 회귀 루프 가동!
        } else if (sliderPositions[trackId] < 0) {
            sliderPositions[trackId] = maxIdx; // 백워드 워프 가동!
        }

        // 트랙 최종 변환 매핑
        var translateX = -(sliderPositions[trackId] * step);
        track.style.transform = "translateX(" + translateX + "px)";
    }

    $(document).ready(function() {
        // 프로필 및 가입 알림 창 복구 제어부
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('editSuccess') === 'true') {
            Swal.fire({
                title: '✨ 프로필 동기화 완료',
                text: '대원님의 정보가 성공적으로 업데이트되었습니다.',
                icon: 'success', confirmButtonColor: '#0b132b', confirmButtonText: '확인'
            });
            history.replaceState({}, null, location.pathname);
        }
        if (urlParams.get('joinSuccess') === 'true') {
            Swal.fire({
                title: '🚀 신규 대원 입성!',
                text: '성공적으로 가입되었습니다. 이제 로그인을 진행해 주세요.',
                icon: 'info', confirmButtonColor: '#0b132b', confirmButtonText: '확인'
            });
            history.replaceState({}, null, location.pathname);
        }
    });
</script>