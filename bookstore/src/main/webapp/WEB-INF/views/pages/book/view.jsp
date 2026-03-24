<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="view-container">
    <div class="cosmic-card-detail">
        <div class="book-image-large">
            <img src="${not empty book.image ? book.image : 'https://via.placeholder.com/300x420?text=No+Image'}" 
                 onerror="this.src='https://via.placeholder.com/300x420?text=No+Image'">
        </div>
        
        <div class="book-info" style="flex:1;">
            <c:if test="${sessionScope.member.role eq 'ADMIN' or sessionScope.member.role eq 'SUPER'}">
                <div class="top-action-bar">
                    <button class="btn-cosmic btn-edit btn-sm" onclick="location.href='${pageContext.request.contextPath}/book/update?id=${book.id}'">✏️ 정보 수정</button>
                    <button class="btn-cosmic btn-delete btn-sm" onclick="delConfirm(${book.id})">🗑️ 데이터 말소</button>
                </div>
            </c:if>
            
            <h1 class="view-title" style="color: #5d5fef;">${book.title}</h1>
            <div class="rating">★★★★★ <span style="color:#2f3542;">4.8</span></div>
            
            <div class="view-content" style="font-size: 0.95rem;">
                <b>🚀 탐사 개척자(저자)</b> : ${book.writer}<br>
                <b>🛰️ 소속 은하계(장르)</b> : ${not empty book.genre ? book.genre : '미분류'}<br>
                <b>📅 관측 기록일</b> : <fmt:formatDate value="${book.regDate}" pattern="yyyy-MM-dd"/>
            </div>
            
            <div class="view-price mt-3">
                <fmt:formatNumber value="${book.price}" pattern="#,###"/> 원
            </div>
            
	        <div class="form-actions mt-5 d-flex gap-3">
			    <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/book/list'">
			        목록으로 돌아가기
			    </button>
			
			    <%-- 🔐 여기도 동일하게 권한 체크 적용 --%>
			    <c:if test="${loginMember.role eq 'ADMIN' or loginMember.role eq 'SUPER'}">
			        <button type="button" class="btn-confirm" 
			                onclick="location.href='${pageContext.request.contextPath}/book/update?id=${book.id}'">
			            ✏️ 기록 수정
			        </button>
			        <button type="button" class="btn-cosmic btn-delete" style="flex: 1;"
			                onclick="delConfirm(${book.id})">
			            🗑️ 데이터 말소
			        </button>
			    </c:if>
			</div>
			
			<script>
			    function delConfirm(id) {
			        if (confirm("정말 이 도서 데이터를 우주 저편으로 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.")) {
			            location.href = "${pageContext.request.contextPath}/book/delete?id=" + id;
			        }
			    }
			</script>
        </div>
    </div>

    <h3 class="section-title">🛰️ 행성 관측 데이터</h3>
    <div class="meta-dashboard">
        <div class="meta-item">
            <span class="meta-label">우주 식별 번호 (ISBN)</span>
            <span class="meta-value">${not empty book.isbn ? book.isbn : '식별 번호 미부여'}</span>
        </div>
        <div class="meta-item">
            <span class="meta-label">현재 상태</span>
            <span class="meta-value status-active">관측 완료 및 배송 가능</span>
        </div>
        <div class="meta-item" style="grid-column: span 2;">
            <span class="meta-label">탐사 상세 기록</span>
            <p class="mt-2" style="line-height: 1.8;">${book.content}</p>
        </div>
    </div>

    <h3 class="section-title">🌌 탐사선이 발견한 다른 지식</h3>
    <div class="recommend-list">
        <c:forEach var="recBook" items="${recommendList}">
            <a href="${pageContext.request.contextPath}/book/view?id=${recBook.id}" class="recommend-card">
                <img src="${recBook.image}" onerror="this.src='https://via.placeholder.com/120x170?text=No+Image'">
                <span class="recommend-title">${recBook.title}</span>
            </a>
        </c:forEach>
    </div>
</div>

<script>
    function delConfirm(id) {
        if (confirm("정말 이 도서 데이터를 우주 저편으로 삭제하시겠습니까?")) {
            location.href = "${pageContext.request.contextPath}/book/delete?id=" + id;
        }
    }
</script>