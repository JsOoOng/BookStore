<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="admin-wide-container mt-5 mb-5">
    <div class="cosmic-form-wrapper vendor-theme mx-auto">
        
        <%-- 🌌 파트너 론칭 전용 헤더 로고 --%>
        <div class="text-center mb-4">
            <div class="vendor-icon-large">🚀</div>
            <h2 class="vendor-form-title">Market Product Launch</h2>
            <p class="vendor-form-desc">도서 창고 데이터를 기반으로 우주 마켓에 신규 상품을 공급합니다.</p>
        </div>

        <form action="${pageContext.request.contextPath}/vendor/product/register" method="post" id="productRegisterForm" class="cosmic-form-box">
            
            <%-- 📖 1. 원천 도서 매핑 식별 구역 (수동 입력 필드 철거 -> 모달 자동 매핑 시스템) --%>
            <div class="input-group-cosmic vendor-input-group">
                <label>📖 론칭 대상 원천 도서 선택</label>
                <div class="vendor-id-check-row">
                    <%-- 실제 서버 컨트롤러로 전송될 히든 식별 ID --%>
                    <input type="hidden" id="bookId" name="bookId" required>
                    <%-- 대원의 눈으로 확인할 읽기 전용 타이틀 디스플레이 --%>
                    <%-- 대원의 눈으로 확인할 읽기 전용 타이틀 디스플레이 (클릭 시 모달 개방 기능 추가!) --%>
					<input type="text" id="bookTitleDisplay" placeholder="이곳을 클릭하거나 우측 버튼을 눌러 도서를 검색하세요" 
					       readonly required data-bs-toggle="modal" data-bs-target="#bookSearchModal">
                    <button type="button" class="btn-cosmic-inline btn-vendor-check-inline" data-bs-toggle="modal" data-bs-target="#bookSearchModal">도서 찾기</button>
                </div>
                <small class="vendor-form-sub-text">※ 은하 아카이브에 등록된 원천 도서 정보를 검색하여 연동합니다.</small>
            </div>

            <div class="vendor-form-row">
                <%-- 💰 2. 소비자 판매가 설정 구역 --%>
                <div class="input-group-cosmic vendor-input-group flex-1">
                    <label for="price">💰 마켓 판매가 (Price)</label>
                    <div class="cosmic-input-unit-wrap">
                        <input type="number" id="price" name="price" class="text-end-input" required min="0" placeholder="0">
                        <span class="input-unit-text">원</span>
                    </div>
                </div>

                <%-- 📉 3. 초기 공급 재고 수량 구역 --%>
                <div class="input-group-cosmic vendor-input-group flex-1">
                    <label for="stockQty">📉 초기 공급 재고 (Stock)</label>
                    <div class="cosmic-input-unit-wrap">
                        <input type="number" id="stockQty" name="stockQty" class="text-end-input" required min="1" placeholder="10">
                        <span class="input-unit-text">개</span>
                    </div>
                </div>
            </div>

            <%-- 🛰️ 4. 마켓 판매 상태 초기값 구역 --%>
            <div class="input-group-cosmic vendor-input-group mb-4">
                <label for="saleStatus">🛰️ 마켓 출시 상태</label>
                <div class="cosmic-select-wrapper">
                    <select id="saleStatus" name="saleStatus" class="cosmic-select-box">
                        <option value="ON" selected>Option :: ON (즉시 판매 시작 - 메인 상점 노출)</option>
                        <option value="OFF">Option :: OFF (판매 대기/숨김 - 대시보드만 보관)</option>
                    </select>
                </div>
            </div>

            <%-- 🛠️ 제어 제너럴 버튼 세트 --%>
            <div class="vendor-action-btn-row mt-4">
                <a href="${pageContext.request.contextPath}/vendor/dashboard" class="btn-vendor-cancel-action">취소</a>
                <button type="submit" class="btn-vendor-submit">🚀 마켓 론칭 승인</button>
            </div>
        </form>

    </div>
</div>

<%-- 🛰️ [신규 이식] 도서 검색 전용 코스믹 모달 인프라 구축 --%>
<div class="modal fade" id="bookSearchModal" tabindex="-1" aria-labelledby="bookSearchModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content cosmic-modal-content">
            <div class="modal-header cosmic-modal-header">
                <h5 class="modal-title fw-bold text-info" id="bookSearchModalLabel">🔍 은하 도서 아카이브 검색 시스템</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body cosmic-modal-body p-4">
                <%-- 검색 조작 입력창 --%>
                <div class="cosmic-modal-search-box mb-4">
                    <div class="vendor-id-check-row">
                        <input type="text" id="modalSearchKeyword" placeholder="도서 제목 또는 저자명을 입력하세요..." autocomplete="off">
                        <button type="button" id="btnModalSearch" class="btn-vendor-submit">검색</button>
                    </div>
                </div>
                
                <%-- 실시간 스캔 결과 뷰포트 --%>
                <div class="modal-search-result-wrap">
                    <div id="modalSearchResultList" class="modal-book-list-container">
					    <div class="modal-empty-state-cosmic">
					        <span class="icon">📡</span>
					        <span class="fw-bold">검색어를 입력하고 검색 시스템을 가동하세요.</span>
					    </div>
					</div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // 1. 부트스트랩 모달 백드롭 꼬임 차단 격리책
    var modalEl = document.getElementById('bookSearchModal');
    if (modalEl) {
        modalEl.addEventListener('show.bs.modal', function () {
            document.body.appendChild(modalEl);
        });
    }

    // 2. 모달 내 실시간 비동기 검색 관제 스크립트
    const btnModalSearch = document.getElementById("btnModalSearch");
    const modalSearchKeyword = document.getElementById("modalSearchKeyword");
    const modalSearchResultList = document.getElementById("modalSearchResultList");

    // 엔터키 누르면 즉시 검색 터지도록 바인딩
    modalSearchKeyword.addEventListener("keypress", function(e) {
        if (e.key === "Enter") {
            e.preventDefault();
            btnModalSearch.click();
        }
    });

    btnModalSearch.addEventListener("click", function() {
        const keyword = modalSearchKeyword.value.trim();
        if (keyword === "") {
            alert("검색어를 입력해 주세요!");
            modalSearchKeyword.focus();
            return;
        }

        // 스캔 애니메이션 대기 상태 가동
		modalSearchResultList.innerHTML = '<div class="modal-empty-state-cosmic" style="border-color:#17a2b8; color:#17a2b8;"><span class="icon">🛰️</span><span class="fw-bold">아카이브 데이터 실시간 스캔 중...</span></div>';

        // 백엔드 개설 엔드포인트로 무선 전송
        fetch("${pageContext.request.contextPath}/vendor/product/searchBook?keyword=" + encodeURIComponent(keyword))
            .then(response => response.json())
            .then(data => {
                modalSearchResultList.innerHTML = "";
                
                if (data.length === 0) {
                    modalSearchResultList.innerHTML = '<div class="modal-empty-state-cosmic" style="border-color:#ff4757; color:#ff4757;"><span class="icon">⛔</span><span class="fw-bold">조건과 일치하는 도서 정보가 아카이브에 없습니다.</span></div>';
                    return;
                }

             // 응답 데이터 그리드 동적 렌더링
                data.forEach(book => {
                    const item = document.createElement("div");
                    item.className = "modal-book-item";
                    
                    // 💥 수정 1: 외부 사이트 대신 사령부 로컬 기본 이미지(no_image.jpg) 사용
                    const fallbackImg = "${pageContext.request.contextPath}/resources/images/books/no_image.jpg";
                    const imgUrl = (book.image && book.image.trim() !== "") ? book.image : fallbackImg;
                    
                    // 💥 수정 2: this.onerror=null; 을 추가하여 무한 루프 에러 폭주 완벽 차단!
                    item.innerHTML = `
                        <img src="\${imgUrl}" alt="cover" class="modal-book-img" onerror="this.onerror=null; this.src='\${fallbackImg}';">
                        <div class="modal-book-info">
                            <h4 class="modal-book-title">\${book.title}</h4>
                            <p class="modal-book-meta">개척자: \${book.writer} | 출판사: \${book.publisher}</p>
                            <p class="modal-book-sub-meta">장르: \${book.genre} | 언어: \${book.language}</p>
                        </div>
                    `;
                    
                    // 🎯 검색된 도서 클릭 시 메인 폼에 하이브리드 자동 연동 후 자폭(닫기)
                    item.addEventListener("click", function() {
                        document.getElementById("bookId").value = book.id;
                        document.getElementById("bookTitleDisplay").value = book.title;
                        
                        // 모달 닫기
                        const modalInstance = bootstrap.Modal.getInstance(modalEl);
                        if (modalInstance) {
                            modalInstance.hide();
                        }
                    });
                    
                    modalSearchResultList.appendChild(item);
                });
            })
            .catch(err => {
                console.error("Search Fail:", err);
                modalSearchResultList.innerHTML = '<p class="text-center text-danger py-4 fw-bold mb-0">🚨 아카이브 통신 연결 실패.</p>';
            });
    });

    // 3. 기존 가격 및 공급 재고 폼 유효성 검증 관제 (사령관 로직 100% 보존)
    document.getElementById("productRegisterForm").addEventListener("submit", function(e) {
        var price = document.getElementById("price").value;
        var stock = document.getElementById("stockQty").value;

        if (price < 0) {
            alert("판매가는 0원 이상이어야 합니다!");
            e.preventDefault();
        }
        if (stock < 1) {
            alert("최초 공급 재고는 최소 1개 이상이어야 마켓에 등록 가능합니다!");
            e.preventDefault();
        }
    });
});

//1. 모달이 열릴 때: 배경을 물리적으로 잠그고 조작 방지
modalEl.addEventListener('show.bs.modal', function () {
    document.body.style.overflow = 'hidden'; // 배경 스크롤 차단
    // 메인 콘텐츠 영역에 클릭 차단 레이어 활성화 (만약 있다면)
});

// 2. 검색 결과 클릭 시: 모달 닫기 + 배경 초기화 (이벤트 기반)
item.addEventListener("click", function() {
    document.getElementById("bookId").value = book.id;
    document.getElementById("bookTitleDisplay").value = book.title;

    // 모달 닫기 실행
    const modalInstance = bootstrap.Modal.getInstance(modalEl);
    if (modalInstance) {
        modalInstance.hide();
    }
    
    // 💥 핵심: 모달이 완전히 숨겨진 직후에만 잠금을 풀어라!
    modalEl.addEventListener('hidden.bs.modal', function () {
        document.body.style.overflow = ''; // 스크롤 잠금 해제
        document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
    }, { once: true }); // 딱 한 번만 실행하고 소멸
});
</script>