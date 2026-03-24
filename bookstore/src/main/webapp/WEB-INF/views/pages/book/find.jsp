<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="search-result-header text-center">
    <h2 class="fw-bold mb-2">🔭 탐색 결과 보고서</h2>
    <p class="lead mb-0">"<span class="text-warning fw-bold">${searchKeyword}</span>" 키워드로 발견된 행성들</p>
</div>

<div class="row g-4">
    <c:choose>
        <c:when test="${not empty bookList}">
            <c:forEach var="book" items="${bookList}">
                <div class="col-lg-3 col-md-4 col-sm-6">
                    <div class="card book-card" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
                        <div class="book-img-wrapper">
                            <img src="${not empty book.image ? book.image : 'https://via.placeholder.com/200x300'}" 
                                 onerror="this.src='https://via.placeholder.com/200x300?text=No+Image'">
                        </div>
                        <div class="card-body">
                            <span class="genre-badge mb-2">${not empty book.genre ? book.genre : '미분류'}</span>
                            <h5 class="card-title fw-bold text-truncate">${book.title}</h5>
                            <p class="text-muted small mb-3">${book.writer} | ${book.publisher}</p>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="book-price text-danger fw-bold"><fmt:formatNumber value="${book.price}" pattern="#,###"/>원</span>
                                <button class="btn btn-sm btn-outline-primary rounded-pill">상세보기</button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        
        <c:otherwise>
            <div class="col-12 text-center py-5">
                <h4 class="text-muted">우주 어딘가에도 해당 데이터가 존재하지 않습니다.</h4>
                <a href="${pageContext.request.contextPath}/book/list" class="btn btn-primary rounded-pill px-5 mt-3">전체 목록으로</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<c:if test="${not empty bookList}">
    <nav aria-label="Cosmic Search Navigation" class="mt-5">
        <ul class="pagination justify-content-center cosmic-pagination">
            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link" href="?title=${searchKeyword}&page=${currentPage - 1}">&laquo; 이전</a>
            </li>
            <c:forEach var="i" begin="1" end="${totalPages}">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                    <a class="page-link" href="?title=${searchKeyword}&page=${i}">${i}</a>
                </li>
            </c:forEach>
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link" href="?title=${searchKeyword}&page=${currentPage + 1}">다음 &raquo;</a>
            </li>
        </ul>
    </nav>
</c:if>

<div class="text-center my-5">
    <a href="${pageContext.request.contextPath}/" class="btn btn-secondary rounded-pill px-5">메인 본부로 돌아가기</a>
</div>