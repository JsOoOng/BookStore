<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container mt-4">

    <div class="mb-4 pb-2 border-bottom border-secondary">
        <h2 class="fw-bold text-dark" style="font-size: 1.8rem; letter-spacing: -0.5px;">🪐 코스믹 도서 아카이브</h2>
        <p class="text-secondary mb-0 fw-bold" style="font-size: 0.95rem;">
            우주 연합의 모든 도서 원천 정보와 실제 입점 상점의 판매 리스트를 통합 관제합니다.
        </p>
    </div>

    <ul class="nav nav-pills nav-justified cosmic-tabs mb-4" id="bookCatalogTabs" role="tablist" style="gap: 10px;">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-bold py-3" id="book-list-tab" data-bs-toggle="tab" data-bs-target="#book-list-pane" type="button" role="tab" aria-controls="book-list-pane" aria-selected="true" style="font-size: 1.05rem; border-radius: 12px;">
                📚 전체 도서 도감 (원천 정보)
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold py-3" id="vendor-shop-tab" type="button" role="tab" style="font-size: 1.05rem; border-radius: 12px; background-color: rgba(93, 95, 239, 0.1); color: #5d5fef;"
                    onclick="location.href='${pageContext.request.contextPath}/vendor/shop'">
                🛒 실시간 판매 중인 상점 (구매/장바구니 가능)
            </button>
        </li>
    </ul>

    <div class="tab-content" id="bookCatalogTabsContent">
        
        <div class="tab-pane fade show active" id="book-list-pane" role="tabpanel" aria-labelledby="book-list-tab" tabindex="0">
            
            <div class="alert alert-info border-0 shadow-sm mb-4 fw-bold" style="background-color: rgba(93, 95, 239, 0.05); color: #5d5fef; border-radius: 12px;">
                💡 <b>안내대원 조언:</b> 이곳은 우주 도서의 원천 카탈로그입니다. 실제 도서를 장바구니에 담아 주문하시려면 상단의 <b>[실시간 판매 중인 상점]</b> 탭을 터치해 주세요!
            </div>

            <div class="book-list">
                <c:forEach var="book" items="${bookList}">
                    <div class="book-item" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
                        <img src="${book.image}" alt="Cover" class="book-img" onerror="this.src='https://via.placeholder.com/100x140?text=No+Image'">
                        <div class="book-info">
                            <h3 class="book-title">${book.title}</h3>
                            <p class="text-muted small mb-1">개척자: ${book.writer} | ${book.publisher}</p>
                            
                            <p class="book-meta small text-secondary mb-0">출판 우주 시기: ${book.pubDate}</p>
                            <span class="badge" style="background-color: #5d5fef; color: white; font-size: 0.75rem; padding: 3px 8px; border-radius: 4px;">
                                ${book.language}
                            </span>
                            
                            <div class="mt-2 d-flex gap-2">
                                <%-- 🔐 오직 관리자(ADMIN) 또는 사령관(SUPER)만 수정/삭제 가능 --%>
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
            </</nav>

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