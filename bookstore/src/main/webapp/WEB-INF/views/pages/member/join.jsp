<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container" style="max-width: 500px; margin-top: 50px;">
    <div class="text-center mb-5">
        <h1 style="font-size: 3rem;">👨‍🚀</h1>
        <h2 class="fw-bold" style="color: #5d5fef;">Cosmic Join</h2>
        <p class="text-muted">새로운 탐사대원으로 등록하여 지식을 공유하세요.</p>
    </div>

    <c:if test="${param.error == 'id_exists'}">
        <div class="alert alert-warning border-0 mb-4 text-center" style="border-radius: 15px;">
            🛸 이미 사용 중인 대원 ID입니다. 다른 ID를 선택하세요.
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/member/join" method="POST" onsubmit="return validateForm()">
        <div class="input-group-cosmic">
            <label for="id">대원 식별 ID</label>
            <input type="text" id="id" name="id" placeholder="사용할 ID를 입력하세요" required>
        </div>

        <div class="input-group-cosmic">
            <label for="name">대원 성명</label>
            <input type="text" id="name" name="name" placeholder="실명을 입력하세요" required>
        </div>

        <div class="input-group-cosmic">
            <label for="pw">보안 코드 (PW)</label>
            <input type="password" id="pw" name="pw" placeholder="비밀번호를 입력하세요" required>
        </div>

        <div class="input-group-cosmic">
            <label for="pw_confirm">보안 코드 확인</label>
            <input type="password" id="pw_confirm" placeholder="비밀번호를 한 번 더 입력하세요" required>
            <small id="pw_error" class="text-danger" style="display:none;">비밀번호가 일치하지 않습니다.</small>
        </div>

        <div class="mt-4">
            <button type="submit" class="btn-confirm w-100 shadow-lg">대원 등록 신청</button>
        </div>

        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/member/login" class="text-muted small">이미 대원이신가요? 로그인하기</a>
        </div>
    </form>
</div>

<script>
    // 자바스크립트를 이용한 간단한 폼 검증
    function validateForm() {
        const pw = document.getElementById('pw').value;
        const pwConfirm = document.getElementById('pw_confirm').value;
        const errorMsg = document.getElementById('pw_error');

        if (pw !== pwConfirm) {
            errorMsg.style.display = 'block';
            return false; // 폼 전송 중단
        }
        return true; // 폼 전송 승인
    }
</script>