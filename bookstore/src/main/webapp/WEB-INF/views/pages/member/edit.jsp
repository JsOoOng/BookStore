<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container" style="max-width: 500px; margin-top: 50px;">
    <div class="text-center mb-5">
        <h1 style="font-size: 3rem;">🛠️</h1>
        <h2 class="fw-bold" style="color: #5d5fef;">Profile Sync</h2>
        <p class="text-muted">대원님의 식별 정보 및 보안 코드를 업데이트합니다.</p>
    </div>

    <c:if test="${param.error == 'pw_mismatch'}">
        <div class="alert alert-danger border-0 mb-4 text-center" style="border-radius: 15px;">
            ⚠️ 현재 보안 코드가 일치하지 않습니다. 본인 확인에 실패했습니다.
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/member/edit" method="POST" onsubmit="return validateEditForm()">
        <div class="input-group-cosmic">
            <label>대원 식별 ID (고정)</label>
            <input type="text" name="id" value="${loginMember.id}" readonly 
                   style="background: rgba(0,0,0,0.05); cursor: not-allowed; color: #777;">
        </div>

        <div class="input-group-cosmic">
            <label for="name">대원 성명</label>
            <input type="text" id="name" name="name" value="${loginMember.name}" required placeholder="수정할 성명을 입력하세요">
        </div>

        <hr class="my-4" style="opacity: 0.1;">

        <div class="input-group-cosmic">
            <label for="currentPw">현재 보안 코드 <span class="text-danger">*</span></label>
            <input type="password" id="currentPw" name="currentPw" placeholder="현재 비밀번호를 입력해야 수정이 가능합니다" required>
            <small class="text-muted" style="font-size: 0.8rem;">안전한 정보 수정을 위해 현재 비밀번호를 입력해주세요.</small>
        </div>

        <div class="input-group-cosmic mt-4">
            <label for="newPw">새 보안 코드 (변경 시에만 입력)</label>
            <input type="password" id="newPw" name="newPw" placeholder="바꾸실 경우에만 입력하세요">
        </div>

        <div class="input-group-cosmic">
            <label for="newPwConfirm">새 보안 코드 확인</label>
            <input type="password" id="newPwConfirm" placeholder="한 번 더 입력하세요">
            <small id="pw_match_msg" class="mt-2 d-block" style="font-weight: bold;"></small>
        </div>

        <div class="d-grid gap-3 mt-5">
            <button type="submit" class="btn-confirm shadow-lg">정보 동기화 승인</button>
            <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/'">
                수정 취소 및 복귀
            </button>
        </div>
    </form>

    <div class="text-center mt-5 pt-4 border-top border-light">
        <p class="text-muted small">더 이상 탐사를 계속할 수 없나요?</p>
        <a href="javascript:void(0);" onclick="withdrawConfirm()" 
           class="text-danger text-decoration-none small fw-bold">지식 기지 탈퇴 신청 (Withdraw) →</a>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    $(document).ready(function() {
        // 새 비밀번호 일치 여부 실시간 체크 로직
        $("#newPw, #newPwConfirm").on("keyup", function() {
            const newPw = $("#newPw").val();
            const confirm = $("#newPwConfirm").val();
            const msg = $("#pw_match_msg");

            if (newPw === "" && confirm === "") {
                msg.text("");
                return;
            }

            if (newPw === confirm) {
                msg.text("새 보안 코드가 서로 일치합니다. ✨").css("color", "#10ac84");
            } else {
                msg.text("새 보안 코드가 일치하지 않습니다. ⛔").css("color", "#ff4757");
            }
        });
    });

    // 폼 제출 전 최종 검증
    function validateEditForm() {
        const newPw = $("#newPw").val();
        const confirm = $("#newPwConfirm").val();

        // 새 비밀번호를 입력했는데 확인란과 다를 경우
        if (newPw !== "" && newPw !== confirm) {
            alert("새로 입력한 보안 코드가 서로 일치하지 않습니다. 다시 확인해주세요.");
            $("#newPwConfirm").focus();
            return false;
        }

        if(!confirm("입력하신 정보로 기지 데이터를 동기화하시겠습니까?")) {
            return false;
        }
        
        return true; 
    }

    function withdrawConfirm() {
        if(confirm("정말 기지를 떠나시겠습니까?\n지금까지의 모든 탐사 기록과 등급이 영구 말소됩니다.")) {
            location.href = "${pageContext.request.contextPath}/member/withdraw";
        }
    }
</script>