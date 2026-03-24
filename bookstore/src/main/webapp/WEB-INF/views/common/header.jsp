<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🚀 Cosmic Library</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/book/list">도서목록</a></li>
                
                <%-- 로그인한 대원의 세션 정보(loginMember)에서 role을 꺼내와야 합니다 --%>
				<c:if test="${sessionScope.loginMember.role eq 'SUPER'}">
				    <li class="nav-item">
				        <a class="nav-link text-warning fw-bold" href="${pageContext.request.contextPath}/super/userControl">
				            👑 사령실(Admin)
				        </a>
				    </li>
				    <li class="nav-item">
				        <a class="nav-link text-info fw-bold" href="${pageContext.request.contextPath}/admin/inquiries">
				            📨 문의 사항 확인
				        </a>
				    </li>
				</c:if>
            </ul>
            
            <ul class="navbar-nav">
			    <c:choose>
			        <%-- 로그인 전: 로그인/회원가입 버튼 노출 --%>
			        <c:when test="${empty sessionScope.loginMember}">
			            <li class="nav-item">
			                <a class="nav-link" href="${pageContext.request.contextPath}/member/login">🚀 로그인</a>
			            </li>
			            <li class="nav-item">
			                <a class="nav-link" href="${pageContext.request.contextPath}/member/join">신규 대원 등록</a>
			            </li>
			        </c:when>
			        
			        <%-- 로그인 후: 대원 이름 및 로그아웃 버튼 노출 --%>
			        <c:otherwise>
			            <li class="nav-item">
			                <span class="nav-link text-primary fw-bold">✨ ${loginMember.name} 대원님</span>
			            </li>
			            <li class="nav-item">
			                <a class="nav-link" href="${pageContext.request.contextPath}/member/edit">정보 수정</a>
			            </li>
			            <li class="nav-item">
			                <a class="nav-link text-danger" href="${pageContext.request.contextPath}/member/logout">로그아웃</a>
			            </li>
			        </c:otherwise>
			    </c:choose>
			</ul>
        </div>
    </div>
</nav>