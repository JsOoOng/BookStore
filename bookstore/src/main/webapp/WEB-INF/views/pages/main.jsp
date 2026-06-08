<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- =========================================================
     화면 출력부: 위(히어로 배너) -> 아래(도서 섹션) 순서 고정
     ========================================================= --%>

<%-- 🚀 1. 풀와이드 히어로 배너 (최상단) --%>
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

<%-- 🌌 2. 신규 입고 도서 섹션 (스크롤 하단) --%>
<div class="univ-new-books-section">
    <div class="univ-section-container">
        
        <div class="section-title-group">
            <h2 class="section-main-title">
                우주를 읽을 수 있는 <span>혜안</span>과<br>
                미래를 개척할 <span>지식</span>을<br>
                전하고 싶습니다.
            </h2>
            <p class="section-sub-title"><b>신규 입고 도서</b> | 이번 주에 새로 들어온 은하계 베스트셀러들을 확인하세요.</p>
        </div>

        <%-- 도서 쇼케이스 --%>
        <div class="new-books-showcase">
            <div class="showcase-card">
                <div class="showcase-img-box">📖</div>
                <div class="showcase-text">신규 지식 데이터 1</div>
            </div>
            <div class="showcase-card">
                <div class="showcase-img-box">📖</div>
                <div class="showcase-text">신규 지식 데이터 2</div>
            </div>
            <div class="showcase-card">
                <div class="showcase-img-box">📖</div>
                <div class="showcase-text">신규 지식 데이터 3</div>
            </div>
            <div class="showcase-card">
                <div class="showcase-img-box">📖</div>
                <div class="showcase-text">신규 지식 데이터 4</div>
            </div>
        </div>

    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    $(document).ready(function() {
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