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
		
		    <div class="cosmic-id-check-row">
		        <input type="email"
		               id="email"
		               name="email"
		               placeholder="example@cosmic.com"
		               required>
		
		        <button type="button"
		                id="btn_email_auth"
		                class="btn-cosmic-inline">
		            인증코드 보내기
		        </button>
		    </div>
		
		    <div class="cosmic-id-check-row mt-2">
		        <input type="text"
		               id="emailAuthCode"
		               placeholder="인증코드 입력"
		               disabled>
		               
		               <button type="button"
				        id="btn_verify_auth"
				        class="btn-cosmic-inline">
						    인증확인
						</button>
		
		        <span id="authTimer"
		              style="display:none; min-width:60px; line-height:40px;">
		            05:00
		        </span>
		    </div>
		
		    <small id="email_auth_msg"
		           class="form-msg-text msg-ready">
		        이메일 인증이 필요합니다.
		    </small>
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
let idChecked = false;
let emailVerified = false;

let timerInterval = null;
let remainSeconds = 300;

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

	    if(!emailVerified){
	        alert("이메일 인증을 완료해주세요.");
	        return false;
	    }
	
	    const pw = document.getElementById('pw').value;
	    const pwConfirm = document.getElementById('pw_confirm').value;
	
	    if (pw !== pwConfirm) {
	
	        document.getElementById('pw_error').style.display = 'block';
	
	        return false;
	    }
	
	    return true;
	}
    
    $("#btn_email_auth").click(function() {

        const email = $("#email").val().trim();

        if(email === ""){
            alert("이메일을 입력해주세요.");
            return;
        }

        $.ajax({
            url : "${pageContext.request.contextPath}/emailauth/send",
            type : "POST",
            data : {
                email : email
            },

            success : function(){

                $("#emailAuthCode").prop("disabled", false);

                $("#authTimer").show();

                startAuthTimer();

                $("#email_auth_msg")
                    .text("인증코드가 발송되었습니다.")
                    .removeClass("msg-error")
                    .addClass("msg-success");
            },

            error : function(){
                alert("인증코드 발송 실패");
            }
        });

    });
    
    function startAuthTimer(){

        clearInterval(timerInterval);

        remainSeconds = 300;

        timerInterval = setInterval(function(){

            let minute = Math.floor(remainSeconds / 60);
            let second = remainSeconds % 60;

            $("#authTimer").text(
                String(minute).padStart(2,'0')
                + ":"
                + String(second).padStart(2,'0')
            );

            remainSeconds--;

            if(remainSeconds < 0){

                clearInterval(timerInterval);

                $("#authTimer").text("만료");

                $("#emailAuthCode").prop("disabled", true);

                emailVerified = false;

            }

        },1000);
    }
    
    $("#btn_verify_auth").click(function(){

        const email = $("#email").val().trim();
        const code = $("#emailAuthCode").val().trim();

        if(code === ""){
            alert("인증코드를 입력해주세요.");
            return;
        }

        $.ajax({

            url : "${pageContext.request.contextPath}/emailauth/verify",

            type : "POST",

            data : {
                email : email,
                authCode : code
            },

            success : function(res){

                if(res === "Y"){

                    emailVerified = true;

                    clearInterval(timerInterval);

                    $("#authTimer").text("인증완료");

                    $("#emailAuthCode").prop("disabled", true);

                    $("#email_auth_msg")
                        .text("이메일 인증이 완료되었습니다.")
                        .removeClass("msg-error")
                        .addClass("msg-success");

                }else{

                    $("#email_auth_msg")
                        .text("인증코드가 올바르지 않습니다.")
                        .removeClass("msg-success")
                        .addClass("msg-error");

                }

            }

        });

    });
    
    $("#email").on("input", function(){

        emailVerified = false;

        $("#emailAuthCode").val("");

        $("#emailAuthCode").prop("disabled", true);

        clearInterval(timerInterval);

        $("#authTimer").hide();

        $("#email_auth_msg")
            .text("이메일 인증이 필요합니다.")
            .removeClass("msg-success msg-error")
            .addClass("msg-ready");

    });
</script>