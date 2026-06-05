<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="admin-wide-container mt-5 mb-5">
    <div class="cosmic-form-wrapper cosmic-edit-wrapper mx-auto">
        
        <%-- 🌌 헤더 타이틀 구역 --%>
        <div class="cosmic-title-section text-center mb-5 border-0">
            <span class="cosmic-logo-icon">🛠️</span>
            <h2 class="cosmic-main-title text-primary-cosmic">Profile Sync</h2>
            <p class="cosmic-subtitle-text">대원님의 식별 정보 및 보안 코드를 업데이트합니다.</p>
        </div>

        <%-- 🚨 보안 코드 불일치 경고 배너 --%>
        <c:if test="${param.error == 'pw_mismatch'}">
            <div class="cosmic-alert-banner alert-danger-cosmic mb-4 text-center">
                ⚠️ 현재 보안 코드가 일치하지 않습니다. 본인 확인에 실패했습니다.
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/member/edit" method="POST" onsubmit="return validateEditForm()">
            
            <%-- 대원 식별 ID (고정/읽기 전용) --%>
            <div class="input-group-cosmic">
                <label>대원 식별 ID (고정)</label>
                <input type="text" name="id" value="${loginMember.id}" readonly class="cosmic-readonly-input">
            </div>

            <%-- 대원 성명 --%>
            <div class="input-group-cosmic">
                <label for="name">대원 성명</label>
                <input type="text" id="name" name="name" value="${loginMember.name}" required placeholder="수정할 성명을 입력하세요">
            </div>

            <%-- 통신 이메일 --%>
            <div class="input-group-cosmic">
                <label for="email">통신 이메일 주소</label>
                <input type="email" id="email" name="email" value="${loginMember.email}" required placeholder="example@cosmic.com">
                <small class="form-desc-text">기지 주요 공지 및 보급 소식을 전송받을 주소입니다.</small>
            </div>

            <%-- 배송지 주소 --%>
            <div class="input-group-cosmic">
                <label for="address">🌌 물류 보급 배송지 주소</label>
                <input type="text" id="address" name="address" value="${loginMember.address}" required placeholder="보급품을 전달받을 주소를 입력하세요">
                <small class="form-desc-text">주문 결제를 진행하기 위해 반드시 실제 주소 형식으로 기입해 주셔야 합니다.</small>
            </div>

            <hr class="cosmic-divider my-4">

            <%-- 현재 보안 코드 --%>
            <div class="input-group-cosmic">
                <label for="currentPw">현재 보안 코드 <span class="text-danger">*</span></label>
                <input type="password" id="currentPw" name="currentPw" placeholder="현재 비밀번호를 입력해야 수정이 가능합니다" required>
                <small class="form-desc-text">안전한 정보 수정을 위해 현재 비밀번호를 입력해주세요.</small>
            </div>

            <%-- 새 보안 코드 --%>
            <div class="input-group-cosmic mt-4">
                <label for="newPw">새 보안 코드 (변경 시에만 입력)</label>
                <input type="password" id="newPw" name="newPw" placeholder="바꾸실 경우에만 입력하세요">
            </div>

            <%-- 새 보안 코드 확인 --%>
            <div class="input-group-cosmic">
                <label for="newPwConfirm">새 보안 코드 확인</label>
                <input type="password" id="newPwConfirm" placeholder="한 번 더 입력하세요">
                <small id="pw_match_msg" class="form-msg-text"></small>
            </div>

            <%-- 제어 버튼 구역 --%>
            <div class="form-actions-cosmic mt-5">
                <button type="submit" class="btn-confirm-cosmic" style="flex: 2;">정보 동기화 승인</button>
                <button type="button" class="btn-cancel-cosmic" style="flex: 1;" onclick="location.href='${pageContext.request.contextPath}/'">수정 취소</button>
            </div>
        </form>

        <%-- 🚨 위험 구역: 탈퇴 링크 --%>
        <div class="cosmic-edit-footer text-center mt-5">
            <p class="form-desc-text mb-2">더 이상 탐사를 계속할 수 없나요?</p>
            <a href="javascript:void(0);" onclick="withdrawConfirm()" class="btn-withdraw-link">
                지식 기지 탈퇴 신청 (Withdraw) &rarr;
            </a>
        </div>
    </div>
</div>

<%-- 📡 jQuery 및 스크립트 통신망 (무결성 보존) --%>
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
                msg.text("새 보안 코드가 서로 일치합니다. ✨").removeClass("msg-error").addClass("msg-success");
            } else {
                msg.text("새 보안 코드가 일치하지 않습니다. ⛔").removeClass("msg-success").addClass("msg-error");
            }
        });
    });

    // 폼 제출 전 최종 검증
    function validateEditForm() {
        const newPw = $("#newPw").val();
        const confirm = $("#newPwConfirm").val();
        const address = $("#address").val().trim();

        if (newPw !== "" && newPw !== confirm) {
            alert("새로 입력한 보안 코드가 서로 일치하지 않습니다. 다시 확인해주세요.");
            $("#newPwConfirm").focus();
            return false;
        }

        // 🪐 [주소 유효성 방어선] 공백이나 기본값으로 수정을 시도하는 행위 차단
        if (address === "" || address === "은하계 미지정 구역") {
            alert("보급을 전송받을 유효한 배송지 주소를 정확히 기입해 주세요.");
            $("#address").focus();
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