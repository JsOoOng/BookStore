<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container" style="max-width: 480px; margin-top: 50px;">
    <div class="text-center mb-5">
        <h1 style="font-size: 3rem;">🛰️</h1>
        <h2 class="fw-bold" style="color: #5d5fef; letter-spacing: -1px;">Cosmic Login</h2>
        <p class="text-muted">지식의 은하계에 접속하기 위해 인증이 필요합니다.</p>
    </div>

    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger border-0 mb-4 text-center" 
             style="background: rgba(255, 71, 87, 0.1); color: #ff4757; border-radius: 15px; font-weight: bold;">
            🚀 신호 오류: 아이디 또는 보안 코드가 일치하지 않습니다.
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/member/login" method="POST">
        <div class="input-group-cosmic">
            <label for="id">대원 식별 ID</label>
            <input type="text" id="id" name="id" placeholder="ID를 입력하세요" required autofocus>
        </div>

        <div class="input-group-cosmic">
            <label for="pw">보안 코드 (PW)</label>
            <input type="password" id="pw" name="pw" placeholder="Password를 입력하세요" required>
        </div>

        <div class="mt-4">
            <button type="submit" class="btn-confirm w-100 shadow-lg">우주선 탑승 (Login)</button>
        </div>

        <div class="text-center mt-4 pt-3 border-top border-light">
            <p class="text-muted small">아직 탐사대원이 아니신가요?</p>
            <a href="${pageContext.request.contextPath}/member/join" 
               class="text-decoration-none fw-bold" style="color: #5d5fef;">신규 대원 등록 (Sign Up) →</a>
        </div>
    </form>
</div>