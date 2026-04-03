<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="book-list">
    <c:forEach var="book" items="${bookList}">
        <div class="book-item" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">
            <img src="${book.image}" alt="Cover" class="book-img" onerror="this.src='https://via.placeholder.com/100x140?text=No+Image'">
            <div class="book-info">
                <h3 class="book-title">${book.title}</h3>
                <p class="text-muted small">${book.writer}</p>
                <p class="book-price"><fmt:formatNumber value="${book.price}" pattern="#,###"/>원</p>
                
                <div class="mt-2 d-flex gap-2">
				    <%-- 🔐 오직 관리자(ADMIN) 또는 사령관(SUPER)만 수정/삭제 가능 --%>
				    <c:if test="${loginMember.role eq 'ADMIN' or loginMember.role eq 'SUPER'}">
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
        
        <%-- 1. [이전 블록] 현재 시작페이지가 1이면 이전 블록이 없으므로 disabled --%>
        <li class="page-item ${startPage == 1 ? 'disabled' : ''}">
            <%-- 🚀 클릭 시 이전 블록의 마지막 페이지(startPage - 1)로 이동 --%>
            <a class="page-link" href="?page=${startPage - 1}${not empty searchKeyword ? '&title=' : ''}${searchKeyword}" aria-label="Previous Block">
                <span aria-hidden="true">&laquo; 이전 블록</span>
            </a>
        </li>

        <%-- 2. [페이지 번호] 현재 블록의 번호들만 출력 --%>
        <c:forEach var="i" begin="${startPage}" end="${endPage}">
            <li class="page-item ${currentPage == i ? 'active' : ''}">
                <a class="page-link" href="?page=${i}${not empty searchKeyword ? '&title=' : ''}${searchKeyword}">${i}</a>
            </li>
        </c:forEach>

        <%-- 3. [다음 블록] 현재 끝페이지가 전체페이지와 같으면 다음 블록이 없으므로 disabled --%>
        <li class="page-item ${endPage == totalPages ? 'disabled' : ''}">
            <%-- 🚀 클릭 시 다음 블록의 첫 번째 페이지(endPage + 1)로 이동 --%>
            <a class="page-link" href="?page=${endPage + 1}${not empty searchKeyword ? '&title=' : ''}${searchKeyword}" aria-label="Next Block">
                <span aria-hidden="true">다음 블록 &raquo;</span>
            </a>
        </li>
        
    </ul>
</nav>
<div class="text-center mt-3 text-muted small">
    현재 탐사 위치: ${currentPage} / ${totalPages} 은하계
</div>

<script>
    function delConfirm(id) {
        if (confirm("정말 이 도서 데이터를 우주 저편으로 삭제하시겠습니까?")) {
            // 삭제 컨트롤러로 이동
            location.href = "${pageContext.request.contextPath}/book/delete?id=" + id;
        }
    }
</script>
