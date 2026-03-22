<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container" style="max-width: 500px; margin-top: 50px;">
    <div class="text-center mb-5">
        <h1 style="font-size: 3rem;">🛠️</h1>
        <h2 class="fw-bold" style="color: #5d5fef;">Profile Sync</h2>
        <p class="text-muted">대원님의 식별 정보 및 보안 코드를 업데이트합니다.</p>
    </div>

    <form action="${pageContext.request.contextPath}/member/edit" method="POST">
        <div class="input-group-cosmic">
            <label>대원 식별 ID (변경 불가)</label>
            <input type="text" name="id" value="${loginMember.id}" readonly 
                   style="background: rgba(0,0,0,0.05); cursor: not-allowed; color: #777;">
        </div>

        <div class="input-group-cosmic">
            <label for="name">대원 성명</label>
            <input type="text" id="name" name="name" value="${loginMember.name}" required>
        </div>

        <div class="input-group-cosmic">
            <label for="pw">새 보안 코드 (PW)</label>
            <input type="password" id="pw" name="pw" placeholder="새로운 비밀번호를 입력하세요" required>
        </div>

        <div class="d-grid gap-3 mt-4">
            <button type="submit" class="btn-confirm shadow-lg">정보 동기화 완료</button>
            <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/'">
                수정 취소
            </button>
        </div>
    </form>

    <div class="text-center mt-5 pt-4 border-top border-light">
        <p class="text-muted small">더 이상 탐사를 계속할 수 없나요?</p>
        <a href="javascript:void(0);" onclick="withdrawConfirm()" 
           class="text-danger text-decoration-none small fw-bold">지식 기지 탈퇴 신청 (Withdraw) →</a>
    </div>
</div>

<script>
    function withdrawConfirm() {
        if(confirm("정말 기지를 떠나시겠습니까?\n모든 탐사 기록이 말소됩니다.")) {
            location.href = "${pageContext.request.contextPath}/member/withdraw";
        }
    }
</script>