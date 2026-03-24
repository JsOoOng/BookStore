<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container" style="max-width: 500px; margin-top: 50px;">
    <div class="text-center mb-5">
        <h1 style="font-size: 3rem;">👨‍🚀</h1>
        <h2 class="fw-bold" style="color: #5d5fef;">Cosmic Join</h2>
        <p class="text-muted">새로운 탐사대원으로 등록하여 지식을 공유하세요.</p>
    </div>

    <form id="joinForm" action="${pageContext.request.contextPath}/member/join" method="POST" onsubmit="return validateForm()">
        
        <div class="input-group-cosmic">
            <label for="id">대원 식별 ID</label>
            <div class="d-flex gap-2">
                <input type="text" id="id" name="id" placeholder="사용할 ID를 입력하세요" required autocomplete="off">
                <button type="button" id="btn_check" class="btn btn-outline-info rounded-pill" style="min-width: 110px; font-weight: bold;">중복 확인</button>
            </div>
            <small id="id_msg" class="mt-2 d-block" style="font-weight: bold; color: #747d8c;">아이디 중복 확인이 필요합니다.</small>
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
            <small id="pw_error" class="text-danger mt-2" style="display:none; font-weight: bold;">⚠️ 보안 코드가 일치하지 않습니다.</small>
        </div>

        <div class="mt-4">
            <button type="submit" id="btn_submit" class="btn-confirm w-100 shadow-lg" disabled>대원 등록 신청</button>
        </div>

        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/member/login" class="text-muted small">이미 대원이신가요? 로그인하기</a>
        </div>
    </form>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    $(document).ready(function() {
        // 아이디 입력값이 변경되면 즉시 가입 버튼을 다시 잠그고 확인 메시지를 초기화합니다.
        // (확인 버튼 누른 후 아이디를 살짝 바꾸는 행위를 방지)
        $("#id").on("input", function() {
            $("#btn_submit").attr("disabled", true); 
            $("#id_msg").text("아이디 중복 확인이 필요합니다.").css("color", "#747d8c");
        });

        // [아이디 중복 확인] 버튼 클릭 이벤트
        $("#btn_check").click(function() {
            const userId = $("#id").val().trim();
            
            if(userId === "") {
                alert("아이디를 먼저 입력해주세요.");
                $("#id").focus();
                return;
            }

            // 컨트롤러로 비동기 신호 전송
            $.ajax({
                url: "${pageContext.request.contextPath}/member/checkId",
                type: "GET",
                data: { "id": userId },
                success: function(res) {
                    if(res === "Y") {
                        // 사용 가능할 때 (Green Light)
                        $("#id_msg").text("사용 가능한 멋진 ID입니다! ✨").css("color", "#10ac84");
                        $("#btn_submit").attr("disabled", false); // 🔓 등록 버튼 활성화
                    } else {
                        // 중복일 때 (Red Light)
                        $("#id_msg").text("이미 은하계에 존재하는 ID입니다. ⛔").css("color", "#ff4757");
                        $("#btn_submit").attr("disabled", true);  // 🔒 버튼 유지
                    }
                },
                error: function() {
                    alert("통신 관제소(서버) 응답에 실패했습니다.");
                }
            });
        });
    });

    // 폼 제출 전 최종 관문 (비밀번호 일치 여부 확인)
    function validateForm() {
        const pw = document.getElementById('pw').value;
        const pwConfirm = document.getElementById('pw_confirm').value;
        const errorMsg = document.getElementById('pw_error');

        if (pw !== pwConfirm) {
            errorMsg.style.display = 'block';
            document.getElementById('pw_confirm').focus();
            return false; // 폼 전송 중단
        }
        
        errorMsg.style.display = 'none';
        return true; // 최종 승인
    }
</script>