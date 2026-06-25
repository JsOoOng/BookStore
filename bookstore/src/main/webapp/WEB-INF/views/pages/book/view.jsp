<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="view-container">
    <%-- 메인 레이아웃 세션 (외부 CSS의 .cosmic-card-detail 적용) --%>
    <div class="cosmic-card-detail">
        <div class="book-image-large">
		    <img src="${not empty book.image ? book.image : 'https://via.placeholder.com/300x420?text=No+Image'}" 
		         onerror="this.onerror=null; this.src='https://via.placeholder.com/300x420?text=No+Image';">
		</div>
        
        <div class="book-info-area">
            <%-- 🔐 관리자/사령관 권한 제어 바 (기능 100% 보존) --%>
            <c:if test="${not empty loginAdmin and (loginAdmin.role eq 'ADMIN' or loginAdmin.role eq 'SUPER')}">
                <div class="top-action-bar">
                    <button class="btn-cosmic btn-edit btn-sm" onclick="location.href='${pageContext.request.contextPath}/book/update?id=${book.id}'">정보 수정</button>
                    <button class="btn-cosmic btn-delete btn-sm" onclick="delConfirm(${book.id})">데이터 말소</button>
                </div>
            </c:if>
            
            <%-- 미니멀 전용 헤드 라인 --%>
            <h1 class="view-title">${book.title}</h1>
            <div class="view-rating">
   				 ⭐ ${avgRating}
  				  <span class="rating-num">
     			   (${reviewCount}건)
   				 </span>
			</div>
            
            <%-- 도서 기본 스펙 카탈로그 구역 --%>
            <div class="view-content-specs">
                <div class="spec-row"><strong>author / 저자</strong> <span>${book.writer}</span></div>
                <div class="spec-row"><strong>publisher / 출판사</strong> <span>${book.publisher}</span></div>
                <div class="spec-row"><strong>genre / 장르</strong> <span>${not empty book.genre ? book.genre : '미분류'}</span></div>
                <div class="spec-row"><strong>language / 언어</strong> <span>${book.language}</span></div>
            </div>
            
            <%-- 💰 [동적 판매 정보 분기 기믹] --%>
            <div class="view-price-box">
                <c:choose>
                    <c:when test="${not empty market}">
                        <span class="partner-label">supply partner: ${market.bizName}</span>
                        <div class="price-row">
                            <span class="price-value">우주 할인가 : <fmt:formatNumber value="${market.price}" type="number"/>원</span>
                            <span class="badge badge-stock-alert">${market.stockQty}개 남음</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <span class="partner-preparing-text">📢 입점 업체별 판매 준비 중</span>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <%-- 🎛️ 구매/장바구니 제어 모듈 가동 구역 (인라인 스타일 완전 삭제) --%>
            <div class="purchase-actions-group">
                <c:choose>
                    <c:when test="${not empty market and market.stockQty > 0}">
                        <button type="button" class="btn-confirm btn-instant-buy" 
                                onclick="checkAddressBeforeOrder('${book.id}', '${market.saleId}', '${market.price}')">
                            ⚡ 즉시 구매하기
                        </button>
                        <button type="button" class="btn-cosmic btn-add-basket" 
						        data-saleid="${market.saleId}"
						        data-title="${fn:escapeXml(book.title)}"
						        onclick="addBasketFromDetail(this.dataset.saleid, this.dataset.title)">
						    🛒 장바구니 담기
						</button>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="btn-confirm btn-disabled-lock" disabled>
                            🔒 판매 준비 중
                        </button>
                        <button type="button" class="btn-cosmic btn-disabled-lock" disabled>
                            🔒 장바구니 불가
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <div class="navigation-actions-group">
                <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/book/list'">
                    목록으로 돌아가기
                </button>
            </div>
        </div>
    </div>

    <%-- 하단 서브 서지 정보 그리드 대시보드 구역 --%>
    <h3 class="view-section-title">🛰️ 행성 관측 데이터</h3>
    <div class="meta-dashboard">
        <div class="meta-item">
            <span class="meta-label">우주 식별 번호 (ISBN)</span>
            <span class="meta-value">${not empty book.isbn ? book.isbn : '식별 번호 미부여'}</span>
        </div>
        <div class="meta-item">
            <span class="meta-label">최초 출판 우주 시기</span>
            <span class="meta-value">${book.pubDate}</span>
        </div>
        <div class="meta-item meta-item-wide">
            <span class="meta-label">현재 상태</span>
            <span class="meta-value status-active">원천 지식 기지 등록 완료</span>
        </div>
    </div>

    <%-- 하단 가로 스크롤 추천 시스템 구역 --%>
    <h3 class="view-section-title">🌌 탐사선이 발견한 다른 지식</h3>
    <div class="recommend-list">
        <c:forEach var="recBook" items="${recommendList}">
            <a href="${pageContext.request.contextPath}/book/view?id=${recBook.id}" class="recommend-card">
                <%-- 💥 수정 후: 추천 도서 목록도 무한 루프에 빠지지 않도록 방어막 전개! --%>
				<div class="recommend-img-wrap">
				    <img src="${recBook.image}" 
				         onerror="this.onerror=null; this.src='https://via.placeholder.com/120x170?text=No+Image';">
				</div>
                <span class="recommend-title">${recBook.title}</span>
            </a>
        </c:forEach>
    </div>
    
    
    
    
    <!-- 구매 리뷰 -->
<h3 class="view-section-title">⭐ 구매 리뷰</h3>

<div class="review-section">

    <c:choose>

        <c:when test="${not empty reviewList}">

            <c:forEach var="review" items="${reviewList}">
    <div class="review-card">
    	<div class="review-writer">
                ${fn:substring(review.userid,0,2)}****
        </div>
    
        <div class="review-header">
			
            <div class="review-star"
                 data-rating="${review.star}">
            </div>
            
        </div>

        <div class="review-content">
            ${review.review}
        </div>
        
        <c:if test="${loginMember.id eq review.userid}">
    <div class="review-actions">

    <button class="review-btn edit"
            onclick="openEditModal(${review.id}, `${fn:escapeXml(review.review)}`, ${review.star})">
        ✏ 수정
    </button>

    <button class="review-btn delete"
            onclick="openDeleteModal(${review.id})">
        🗑 삭제
    </button>

</div>
</c:if>


    </div>
</c:forEach>

        </c:when>

        <c:otherwise>

            <div class="review-empty">
                아직 등록된 구매 리뷰가 없습니다.
            </div>

        </c:otherwise>

    </c:choose>

</div>


<div class="review-write-area">
<c:if test="${not userAlreadyReviewed}">
    <button type="button"
            class="btn-cosmic btn-review-write"
            onclick="openReviewModal()">
        ✍ 리뷰 작성하기
    </button>
</c:if>
</div>
    
</div>

<%-- 🏠 물류 보급지 배송 주소 설정 모달창 (다크 클래스 완전 소독 및 미니멀 스퀘어화 클래스 적용) --%>
<div class="modal fade cosmic-minimal-modal" id="addressModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addressModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="addressModalLabel">SHIPPING / 물류 보급지 주소 설정</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="modal-notice-text">안전하고 정확한 광속 지식 보급을 위해 대원님의 실제 거주지 또는 보급 좌표(주소) 입력을 완료해 주세요.</p>
                <div class="input-group-cosmic mt-4">
                    <label for="modalAddressInput" class="form-label fw-bold">ADDRESS / 보급품 수령 주소</label>
                    <input type="text" id="modalAddressInput" placeholder="예: 경기도 고양시 일산동구 ...">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-close-modal" data-bs-dismiss="modal">정선 회항</button>
                <button type="button" class="btn btn-submit-modal fw-bold" onclick="submitAddressAjax()">주소 확정 및 결제선 진입</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="reviewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">리뷰 작성</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div id="ratingSelector"></div>
        <textarea id="reviewContent" placeholder="리뷰를 입력하세요..." class="form-control mt-2"></textarea>
        <input type="hidden" id="reviewRating" value="5">
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" onclick="submitReview()">작성 완료</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">리뷰 삭제</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        정말 이 리뷰를 삭제하시겠습니까?
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button class="btn btn-danger" onclick="confirmDelete()">삭제</button>
      </div>

    </div>
  </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">리뷰 수정</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

        <div id="editRatingSelector"></div>

        <textarea id="editContent" class="form-control mt-2"></textarea>

        <input type="hidden" id="editRating">
        <input type="hidden" id="editId">

      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button class="btn btn-primary" onclick="submitEdit()">수정</button>
      </div>

    </div>
  </div>
</div>

<%-- 스크립트 트랜잭션 파이프라인 (무결성 유지) --%>
<script>
    function delConfirm(id) {
        if (confirm("정말 이 도서 데이터를 우주 저편으로 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.")) {
            location.href = "${pageContext.request.contextPath}/book/delete?id=" + id;
        }
    }
    
    function addBasketFromDetail(saleId, title) {
        var formData = new URLSearchParams();
        formData.append("saleId", saleId);
        formData.append("qty", 1); 
        
        fetch("${pageContext.request.contextPath}/basket/addMarketProduct", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
        .then(res => res.text())
        .then(data => {
            let response = data.trim();
            
            // 1. 회원 장바구니 성공 시
            if (response === "ok") {
                if (confirm("🪐 [" + title + "] 상품이 장바구니 궤도에 안착했습니다!\n지금 장바구니 화면으로 워프하시겠습니까?")) {
                    location.href = "${pageContext.request.contextPath}/basket"; 
                }
            } 
            // 2. 비회원(쿠키) 장바구니 성공 시 (서버가 보내준 'ok_cookie' 처리)
            else if (response === "ok_cookie") {
                if (confirm("🍪 비회원 보관소에 상품이 담겼습니다.\n임시 보관소를 확인하시겠습니까?")) {
                    location.href = "${pageContext.request.contextPath}/cookie/basket/list"; 
                }
            }
            // 3. 로그인이 필요한 경우
            else if (response === "NOT_LOGIN") {
                addBasketToCookie(saleId, title);
            } 
            else {
                alert("🚨 장바구니 담기 실패 (서버 응답: " + response + ")");
            }
        })
        .catch(err => {
            alert("🛰️ 사령부 통신 두절");
            console.error(err);
        });
    }

    // 🪐 비회원 전용 쿠키 장바구니 추가 함수
    function addBasketToCookie(saleId, title) {
        var formData = new URLSearchParams();
        formData.append("saleId", saleId);
        formData.append("qty", 1);

        fetch("${pageContext.request.contextPath}/cookie/basket/add", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "ok") {
                if (confirm("🍪 비회원 보관소에 상품이 담겼습니다.\n임시 보관소를 확인하시겠습니까?")) {
                    location.href = "${pageContext.request.contextPath}/cookie/basket/list"; 
                }
            } else {
                alert("🚨 비회원 보관함 동기화 실패");
            }
        })
        .catch(err => alert("🛰️ 시스템 통신 오류"));
    }
    
    let currentOrderParam = { bookId: '', saleId: '', price: '' };

    function checkAddressBeforeOrder(bookId, saleId, price) {
        currentOrderParam.bookId = bookId;
        currentOrderParam.saleId = saleId;
        currentOrderParam.price = price;

        const currentAddress = "${loginMember.address}";

        if (!currentAddress || currentAddress.trim() === "" || currentAddress === "은하계 미지정 구역") {
            var myModal = new bootstrap.Modal(document.getElementById('addressModal'));
            myModal.show();
        } else {
            proceedToPurchasePage();
        }
    }

    function submitAddressAjax() {
        const inputAddress = document.getElementById('modalAddressInput').value.trim();

        if (inputAddress === "" || inputAddress === "은하계 미지정 구역") {
            alert("보급품을 정상 전달받을 유효한 주소를 입력해 주세요!");
            return;
        }

        var formData = new URLSearchParams();
        formData.append("address", inputAddress);

        fetch("${pageContext.request.contextPath}/member/updateAddressAjax", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "OK") {
                alert("🏠 배송지 주소 등록 완료! 주문서 페이지로 도약합니다.");
                proceedToPurchasePage();
            } else {
                alert("🚨 주소 등록 실패");
            }
        })
        .catch(err => alert("🛰️ 통신 두절"));
    }

    function proceedToPurchasePage() {
        location.href = "${pageContext.request.contextPath}/purchase/view?bookId=" 
            + currentOrderParam.bookId 
            + "&saleId=" + currentOrderParam.saleId 
            + "&price=" + currentOrderParam.price;
    }
    
    
    document.addEventListener("DOMContentLoaded", function(){

        document.querySelectorAll(".review-star").forEach(starBox => {

            const rating = parseFloat(starBox.dataset.rating);

            let html = "";

            for(let i=1;i<=5;i++){

                if(rating >= i){

                    html += '<span style="color:#ffc107;">★</span>';

                }
                else if(rating >= i-0.5){

                    html += `<span style="
                        background:linear-gradient(
                        to right,
                        #ffc107 50%,
                        #ccc 50%);
                        -webkit-background-clip:text;
                        -webkit-text-fill-color:transparent;
                    ">★</span>`;
                }
                else{

                    html += '<span style="color:#ccc;">★</span>';

                }
            }

            starBox.innerHTML = html;

        });

    });
    
    function openReviewModal() {

        const isLogin = ${not empty loginMember};

        if(!isLogin) {

            if(confirm("리뷰 작성은 로그인 후 이용 가능합니다.\n로그인 페이지로 이동하시겠습니까?")) {
                location.href = "${pageContext.request.contextPath}/member/login";
            }

            return;
        }

        new bootstrap.Modal(
            document.getElementById("reviewModal")
        ).show();
    }
    
    document.addEventListener("DOMContentLoaded", function() {

        const selector =
            document.getElementById("ratingSelector");

        if(!selector) return;

        let currentRating = 5.0;

        renderRating(currentRating);

        function renderRating(rating){
            selector.innerHTML = "";
            for(let i=1;i<=5;i++){
                const star = document.createElement("span");
                star.dataset.value = i;  // 클릭 시 기준 점수
                star.style.cursor = "pointer";
                star.style.fontSize = "28px";
                star.style.marginRight = "2px";

                if(rating >= i){
                    star.innerHTML = "★";   // 전체 별
                    star.style.color = "#ffc107";
                } else if(rating >= i - 0.5){
                    // 반별
                    star.innerHTML = "★";
                    star.style.background = "linear-gradient(to right,#ffc107 50%,#ccc 50%)";
                    star.style.webkitBackgroundClip = "text";
                    star.style.webkitTextFillColor = "transparent";
                } else{
                    star.innerHTML = "★";
                    star.style.color = "#ccc";
                }

                // 클릭 시 0.5 단위 계산
                star.onclick = function(e){
                    const rect = this.getBoundingClientRect();
                    const clickX = e.clientX - rect.left;
                    const half = clickX < rect.width / 2 ? 0.5 : 1;
                    const newRating = i - 1 + half;
                    currentRating = newRating;
                    document.getElementById("reviewRating").value = currentRating;
                    renderRating(currentRating);
                };

                selector.appendChild(star);
            }
        }
    });
    
    
    function submitReview(){

        const rating =
            document.getElementById("reviewRating").value;

        const content =
            document.getElementById("reviewContent").value.trim();

        if(content === ""){

            alert("리뷰 내용을 입력해주세요.");
            return;
        }

        const formData = new URLSearchParams();

        formData.append("bookId", "${book.id}");
        formData.append("rating", rating);
        formData.append("content", content);

        fetch(
            "${pageContext.request.contextPath}/review/write",
            {
                method:"POST",
                headers:{
                    "Content-Type":
                    "application/x-www-form-urlencoded"
                },
                body:formData
            }
        )
        .then(res => res.text())
        .then(data => {

            if(data === "OK"){

                alert("리뷰가 등록되었습니다.");

                location.reload();

            }else if(data === "NOT_LOGIN"){

                alert("로그인이 필요합니다.");

                location.href =
                    "${pageContext.request.contextPath}/member/login";

            }else{

                alert("리뷰 등록 실패");
            }

        });
    }
    
    let deleteTargetId = null;

    function openDeleteModal(id){
        deleteTargetId = id;
        new bootstrap.Modal(document.getElementById("deleteModal")).show();
    }

    function confirmDelete(){

        fetch("${pageContext.request.contextPath}/review/delete", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: "reviewId=" + deleteTargetId
        })
        .then(res => res.text())
        .then(data => {
            if(data === "OK"){
                location.reload();
            } else {
                alert("삭제 실패");
            }
        });
    }
    
    function openEditModal(id, content, star){

        document.getElementById("editId").value = id;
        document.getElementById("editContent").value = content;

        document.getElementById("editRating").value = star;

        renderEditRating(star); // ⭐ 이거 반드시 호출

        new bootstrap.Modal(
            document.getElementById("editModal")
        ).show();
    }
    
    function submitEdit(){

        const id = document.getElementById("editId").value;
        const content = document.getElementById("editContent").value;
        const rating = document.getElementById("editRating").value;

        fetch("${pageContext.request.contextPath}/review/update", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body:
                "reviewId=" + id +
                "&content=" + encodeURIComponent(content) +
                "&rating=" + rating
        })
        .then(res => res.text())
        .then(data => {
            if(data === "OK"){
                location.reload();
            } else {
                alert("수정 실패");
            }
        });
    }
    
    function renderEditRating(rating){

        const selector = document.getElementById("editRatingSelector");
        selector.innerHTML = "";

        for(let i=1;i<=5;i++){

            const star = document.createElement("span");
            star.style.cursor = "pointer";
            star.style.fontSize = "28px";
            star.style.marginRight = "2px";

            if(rating >= i){
                star.innerHTML = "★";
                star.style.color = "#ffc107";

            } else if(rating >= i - 0.5){
                star.innerHTML = "★";
                star.style.background =
                    "linear-gradient(to right,#ffc107 50%,#ccc 50%)";
                star.style.webkitBackgroundClip = "text";
                star.style.webkitTextFillColor = "transparent";

            } else {
                star.innerHTML = "★";
                star.style.color = "#ccc";
            }

            // ⭐ 클릭 이벤트 (핵심)
            star.onclick = function(e){
                const rect = this.getBoundingClientRect();
                const clickX = e.clientX - rect.left;
                const half = clickX < rect.width / 2 ? 0.5 : 1;

                const newRating = i - 1 + half;

                document.getElementById("editRating").value = newRating;

                renderEditRating(newRating);
            };

            selector.appendChild(star);
        }
    }	
    
</script>