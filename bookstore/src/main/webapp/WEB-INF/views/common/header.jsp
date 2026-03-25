<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🚀 Cosmic Library</a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#cosmicNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="cosmicNavbar">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/book/list">도서목록</a></li>

                <%-- 실시간 상담 버튼 (항상 노출, 클릭 시 컨트롤러에서 비로그인 튕겨냄) --%>
                <li class="nav-item">
                    <a class="nav-link text-success fw-bold" href="${pageContext.request.contextPath}/qna/chat">
                        💬 실시간 상담
                    </a>
                </li>

                <%-- 관리자 전용 메뉴 --%>
                <c:if test="${sessionScope.loginMember.role eq 'SUPER' or sessionScope.loginMember.role eq 'QNAadmin'}">
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

            <form action="${pageContext.request.contextPath}/book/find" method="get" class="d-flex mx-auto" style="width: 35%;">
                <input type="text" name="title" class="form-control rounded-pill me-2 bg-dark text-white border-secondary" 
                       placeholder="어떤 지식을 탐험할까요?" aria-label="Search">
                <button class="btn btn-search-nav" type="submit">Search</button>
            </form>
            
            <ul class="navbar-nav ms-auto">
                <c:choose>
                    <c:when test="${empty sessionScope.loginMember}">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/member/login">🚀 로그인</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/member/join">신규 대원 등록</a>
                        </li>
                    </c:when>
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