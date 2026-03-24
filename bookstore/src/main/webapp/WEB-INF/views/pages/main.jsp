<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="p-5 mb-4 bg-light rounded-3 shadow-sm">
    <div class="container-fluid py-5 text-center">
        <h1 class="display-5 fw-bold">🚀 우주 도서관에 오신 것을 환영합니다</h1>
        <p class="col-md-12 fs-4 mt-3">
            지식의 은하계를 탐험하고 원하는 도서를 대여해 보세요.<br>
            현재 모든 시스템이 정상 가동 중입니다.
        </p>
        <hr class="my-4">
        <div class="d-grid gap-2 d-sm-flex justify-content-sm-center">
            <a href="${pageContext.request.contextPath}/book/list" class="btn btn-primary btn-lg px-4 gap-3">도서 둘러보기</a>
            <button type="button" class="btn btn-outline-secondary btn-lg px-4">이용 안내</button>
        </div>
    </div>
</div>

<div class="row align-items-md-stretch">
    <div class="col-md-6">
        <div class="h-100 p-5 text-white bg-dark rounded-3">
            <h2>신규 입고 도서</h2>
            <p>이번 주에 새로 들어온 은하계 베스트셀러들을 확인하세요.</p>
        </div>
    </div>
    <div class="col-md-6">
        <div class="h-100 p-5 bg-light border rounded-3">
            <h2>공지사항</h2>
            <p>도서관 이용 규칙 및 연체 관련 안내사항입니다.</p>
        </div>
    </div>
</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    $(document).ready(function() {
        // 1. 현재 주소창의 파라미터 분석
        const urlParams = new URLSearchParams(window.location.search);

        // 2. 정보 수정 성공 시 (MemberController에서 보낸 신호)
        if (urlParams.get('editSuccess') === 'true') {
            Swal.fire({
                title: '✨ 프로필 동기화 완료',
                text: '대원님의 정보가 성공적으로 업데이트되었습니다.',
                icon: 'success',
                confirmButtonColor: '#5d5fef',
                confirmButtonText: '확인'
            });
            // 알림 후 URL 깔끔하게 정리 (새로고침 시 다시 뜨는 것 방지)
            history.replaceState({}, null, location.pathname);
        }

        // 3. 회원가입 성공 시
        if (urlParams.get('joinSuccess') === 'true') {
            Swal.fire({
                title: '🚀 신규 대원 입성!',
                text: '성공적으로 가입되었습니다. 이제 로그인을 진행해 주세요.',
                icon: 'info',
                confirmButtonColor: '#5d5fef',
                confirmButtonText: '확인'
            });
            history.replaceState({}, null, location.pathname);
        }
    });
</script>