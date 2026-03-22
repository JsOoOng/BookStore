<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<h2 class="mb-4 text-center fw-bold">✨ 지식 탐험하기</h2>

<div class="mb-5">
    <form action="${pageContext.request.contextPath}/book/find" class="d-flex justify-content-center gap-2">
	    <input type="text" name="title" class="form-control rounded-pill w-50" placeholder="어떤 지식을 탐험하고 싶으신가요?">
	    <button type="submit" class="btn btn-cosmic btn-search">검색</button>
	</form>
</div>

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
        
        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
            <a class="page-link" href="?page=${currentPage - 1}" aria-label="Previous">
                <span aria-hidden="true">&laquo; 이전</span>
            </a>
        </li>

        <c:forEach var="i" begin="1" end="${totalPages}">
            <li class="page-item ${currentPage == i ? 'active' : ''}">
                <a class="page-link" href="?page=${i}">${i}</a>
            </li>
        </c:forEach>

        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
            <a class="page-link" href="?page=${currentPage + 1}" aria-label="Next">
                <span aria-hidden="true">다음 &raquo;</span>
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
