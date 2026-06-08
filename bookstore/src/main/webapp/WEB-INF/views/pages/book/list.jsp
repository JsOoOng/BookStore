<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container">

    <%-- 상단 타이틀 섹션 (인라인 스타일 완전 소독) --%>
    <div class="cosmic-title-section">
        <h2 class="cosmic-main-title">cosmic book archive</h2>
        <p class="cosmic-subtitle-text">
            우주 연합의 모든 도서 원천 정보와 실제 입점 상점의 판매 리스트를 관제합니다.
        </p>
    </div>

    <%-- 🎯 [사령관 조건 1] 거대 알약 버튼 철거 -> 교보문고 스타일 좌측 상단 소형 탭 --%>
    <div class="cosmic-mini-tab-zone">
        <button class="btn-mini-tab active" id="book-list-tab" data-bs-toggle="tab" data-bs-target="#book-list-pane" type="button" role="tab" aria-controls="book-list-pane" aria-selected="true">
            전체 도서 도감 (원천 정보)
        </button>
        <button class="btn-mini-tab" id="vendor-shop-tab" type="button" role="tab"
                onclick="location.href='${pageContext.request.contextPath}/vendor/shop'">
            실시간 판매 중인 상점
        </button>
    </div>

    <div class="tab-content" id="bookCatalogTabsContent">
        <div class="tab-pane fade show active" id="book-list-pane" role="tabpanel" aria-labelledby="book-list-tab" tabindex="0">
            
            <%-- 🎯 미니멀 안내 배너 --%>
            <div class="cosmic-notice-banner">
                💡 <b>안내대원 조언:</b> 이곳은 우주 도서의 원천 카탈로그입니다. 실제 도서를 장바구니에 담아 주문하시려면 상단의 <b>[실시간 판매 중인 상점]</b> 탭을 터치해 주세요!
            </div>

            <%-- 🎯 [사령관 조건 2] 도서 무한 다단 그리드 (가로 2열, 정보 강조 프레임) --%>
            <div class="book-list">
                <c:forEach var="book" items="${bookList}">
                    <div class="book-item" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
                        <c:choose>
						    <c:when test="${not empty book.image}">
						        <%-- 🚀 [방어막 1] 하이브리드 경로 탐색 및 [방어막 2] onerror 무한 루프 절단! --%>
						        <img src="${book.image.startsWith('http') ? book.image : pageContext.request.contextPath.concat(book.image)}" 
						             alt="Cover" 
						             class="book-img" 
						             onerror="this.onerror=null; this.src='https://via.placeholder.com/100x140?text=No+Cover';">
						    </c:when>
						    <c:otherwise>
						        <img src="https://via.placeholder.com/100x140?text=No+Cover" alt="No Cover" class="book-img">
						    </c:otherwise>
						</c:choose>
                        <div class="book-info">
                            <h3 class="book-title">${book.title}</h3>
                            <p class="book-author">개척자: ${book.writer} | ${book.publisher}</p>
                            <p class="book-date">출판 우주 시기: ${book.pubDate}</p>
                            
                            <div class="book-badge-row">
                                <span class="badge-language-cosmic">
                                    ${book.language}
                                </span>
                            </div>
                            
                            <%-- 관리자 제어 밸브 (기능 무결성 보존) --%>
                            <div class="book-action-row">
                                <c:if test="${not empty loginAdmin and (loginAdmin.role eq 'ADMIN' or loginAdmin.role eq 'SUPER')}">
                                    <button type="button" class="btn-cosmic btn-edit btn-sm" 
                                            onclick="event.stopPropagation(); location.href='${pageContext.request.contextPath}/book/update?id=${book.id}'">
                                        수정
                                    </button>
                                    <button type="button" class="btn-cosmic btn-delete btn-sm" 
                                            onclick="event.stopPropagation(); delConfirm(${book.id})">
                                        삭제
                                    </button>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>    
            </div> 

            <%-- 페이징 영역 --%>
            <nav aria-label="Cosmic Page Navigation" class="mt-5">
                <ul class="pagination justify-content-center cosmic-pagination">
                    <li class="page-item ${startPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${startPage - 1}${not empty searchKeyword ? '&title=' : ''}${searchKeyword}" aria-label="Previous Block">
                            <span aria-hidden="true">&laquo; 이전 블록</span>
                        </a>
                    </li>
                    <c:forEach var="i" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}${not empty searchKeyword ? '&title=' : ''}${searchKeyword}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${endPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${endPage + 1}${not empty searchKeyword ? '&title=' : ''}${searchKeyword}" aria-label="Next Block">
                            <span aria-hidden="true">다음 블록 &raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>

            <div class="text-center mt-3 text-muted small">
                현재 탐사 위치: ${currentPage} / ${totalPages} 은하계
            </div>
            
        </div>
    </div>
</div>

<script>
    function delConfirm(id) {
        if (confirm("정말 이 도서 데이터를 우주 저편으로 삭제하시겠습니까?")) {
            location.href = "${pageContext.request.contextPath}/book/delete?id=" + id;
        }
    }
</script>