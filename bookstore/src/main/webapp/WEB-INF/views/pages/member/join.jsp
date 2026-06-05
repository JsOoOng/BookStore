<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="admin-wide-container mt-5 mb-5">
    <div class="cosmic-form-wrapper cosmic-join-wrapper mx-auto">
        
        <%-- 🌌 헤더 타이틀 구역 --%>
        <div class="cosmic-title-section text-center mb-5 border-0">
            <span class="cosmic-logo-icon">👨‍🚀</span>
            <h2 class="cosmic-main-title text-primary-cosmic">Cosmic Join</h2>
            <p class="cosmic-subtitle-text">새로운 탐사대원으로 등록하여 지식을 공유하세요.</p>
        </div>

        <form id="joinForm" action="${pageContext.request.contextPath}/member/join" method="POST" onsubmit="return validateForm()">
            
            <%-- 대원 식별 ID (중복 확인 라인 포함) --%>
            <div class="input-group-cosmic">
                <label for="id">대원 식별 ID</label>
                <div class="cosmic-id-check-row">
                    <input type="text" id="id" name="id" placeholder="사용할 ID를 입력하세요" required autocomplete="off">
                    <button type="button" id="btn_check" class="btn-cosmic-inline">중복 확인</button>
                </div>
                <small id="id_msg" class="form-msg-text msg-ready">아이디 중복 확인이 필요합니다.</small>
            </div>

            <%-- 대원 성명 --%>
            <div class="input-group-cosmic">
                <label for="name">대원 성명</label>
                <input type="text" id="name" name="name" placeholder="실명을 입력하세요" required>
            </div>

            <%-- 통신 이메일 --%>
            <div class="input-group-cosmic">
                <label for="email">통신 이메일 주소</label>
                <input type="email" id="email" name="email" placeholder="example@cosmic.com" required>
                <small class="form-desc-text">기지 주요 공지 및 보급 현황이 전송되는 통신 주소입니다.</small>
            </div>

            <%-- 배송지 주소 --%>
            <div class="input-group-cosmic">
                <label for="address">🌌 물류 보급 배송지 주소</label>
                <input type="text" id="address" name="address" placeholder="지식 서적을 보급받을 실제 주소를 기입하세요">
                <small class="form-desc-text">미기입 시 결제 프로세스 진입 전 마이페이지에서 강제 등록 절차를 밟게 됩니다.</small>
            </div>

            <%-- 보안 코드 --%>
            <div class="input-group-cosmic">
                <label for="pw">보안 코드 (PW)</label>
                <input type="password" id="pw" name="pw" placeholder="비밀번호를 입력하세요" required>
            </div>

            <%-- 보안 코드 확인 --%>
            <div class="input-group-cosmic">
                <label for="pw_confirm">보안 코드 확인</label>
                <input type="password" id="pw_confirm" placeholder="비밀번호를 한 번 더 입력하세요" required>
                <small id="pw_error" class="cosmic-error-msg">⚠️ 보안 코드가 일치하지 않습니다.</small>
            </div>

            <%-- 가입 완료 버튼 구역 --%>
            <div class="form-actions-cosmic mt-4">
                <button type="submit" id="btn_submit" class="btn-confirm-cosmic btn-join-submit" disabled>대원 등록 신청</button>
            </div>

            <%-- 가이드 전환 링크 --%>
            <div class="login-footer-links text-center mt-4">
                <a href="${pageContext.request.contextPath}/member/login" class="login-redirect-link text-muted">이미 대원이신가요? 로그인하기</a>
            </div>
        </form>
    </div>
</div>

<%-- 📡 jQuery 통신 릴레이 로드 --%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    $(document).ready(function() {
        // 아이디 입력값이 변경되면 즉시 가입 버튼을 다시 잠그고 확인 메시지를 초기화합니다.
        $("#id").on("input", function() {
            $("#btn_submit").attr("disabled", true); 
            $("#id_msg").text("아이디 중복 확인이 필요합니다.").removeClass("msg-success msg-error").addClass("msg-ready");
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
                    const result = res.trim(); 
                    
                    if(result === "Y") {
                        $("#id_msg").text("사용 가능한 멋진 ID입니다! ✨").removeClass("msg-ready msg-error").addClass("msg-success");
                        $("#btn_submit").attr("disabled", false); // 🔓 등록 버튼 활성화
                    } else {
                        $("#id_msg").text("이미 은하계에 존재하는 ID입니다. ⛔").removeClass("msg-ready msg-success").addClass("msg-error");
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
            errorMsg.style.display = 'block'; // 스크립트 제어용 속성 보존
            document.getElementById('pw_confirm').focus();
            return false; 
        }
        
        errorMsg.style.display = 'none';
        return true; 
    }
</script>