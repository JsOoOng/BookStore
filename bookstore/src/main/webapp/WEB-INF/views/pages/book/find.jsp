<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="admin-wide-container mt-4">

    <%-- 🔭 탐색 결과 헤더 --%>
    <div class="cosmic-title-section">
        <h2 class="cosmic-main-title">🔭 탐색 결과 보고서</h2>
        <p class="cosmic-subtitle-text">
            "<span class="cosmic-highlight-keyword">${searchKeyword}</span>" 키워드로 발견된 은하계 지식들입니다.
        </p>
    </div>

    <%-- 🎯 리스트 컨테이너 --%>
    <div class="row g-4">
        <c:choose>
            <c:when test="${not empty bookList}">
                <div class="book-list">
                    <c:forEach var="book" items="${bookList}">
                        <div class="book-item" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
                            <img src="${not empty book.image ? book.image : 'https://via.placeholder.com/100x160?text=No+Image'}" 
                                 class="book-img" 
                                 onerror="this.src='https://via.placeholder.com/100x160?text=No+Image'" alt="Cover">
                            
                            <div class="book-info">
                                <h3 class="book-title">${book.title}</h3>
                                <p class="book-author">개척자: ${book.writer} | ${book.publisher}</p>
                                <p class="book-date">출판 우주 시기: ${book.pubDate}</p>
                                
                                <div class="book-badge-row">
                                    <span class="badge-language-cosmic">${not empty book.genre ? book.genre : '미분류'}</span>
                                    <span class="badge-language-cosmic ms-1">${book.language}</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            
            <%-- 🌌 검색 결과 없음 (Empty State) --%>
            <c:otherwise>
                <div class="cosmic-notice-banner empty-state-banner">
                    <h4 class="empty-state-title">우주 어딘가에도 해당 데이터가 존재하지 않습니다.</h4>
                    <p class="empty-state-desc">다른 키워드로 탐색을 시도하거나 전체 목록으로 귀환하십시오.</p>
                    <button class="btn-cancel btn-empty-return" onclick="location.href='${pageContext.request.contextPath}/book/list'">
                        전체 목록으로 귀환
                    </button>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 🎯 페이징 내비게이션 --%>
    <c:if test="${not empty bookList}">
        <nav aria-label="Cosmic Search Navigation" class="mt-5">
            <ul class="pagination justify-content-center cosmic-pagination">
                
                <%-- 1. [이전 페이지] 현재 페이지가 1일 때만 방어벽(잠금) 가동 --%>
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?title=${searchKeyword}&page=${currentPage - 1}" aria-label="Previous Page">
                        <span aria-hidden="true">&laquo; 이전</span>
                    </a>
                </li>

                <%-- 2. [페이지 번호] 블록 단위 출력 --%>
                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="?title=${searchKeyword}&page=${i}">${i}</a>
                    </li>
                </c:forEach>

                <%-- 3. [다음 페이지] 현재 페이지가 우주의 끝(totalPages)일 때만 방어벽(잠금) 가동 --%>
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?title=${searchKeyword}&page=${currentPage + 1}" aria-label="Next Page">
                        <span aria-hidden="true">다음 &raquo;</span>
                    </a>
                </li>
                
            </ul>
        </nav>
    </c:if>

</div>