<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container" style="max-width: 500px; margin-top: 50px;">
    
    <%-- 🌌 파트너 전용 코스믹 헤더 로고 (일반 대원과 아이덴티티 통일) --%>
    <div class="text-center mb-5">
        <h1 style="font-size: 3rem;">🏢</h1>
        <h2 class="fw-bold" style="color: #17a2b8;">Cosmic Partner</h2>
        <p class="text-muted">오픈마켓 공급 파트너사로 신청하여 물류 유통 임무를 조율하세요.</p>
    </div>

    <form id="vendorJoinForm" action="${pageContext.request.contextPath}/vendor/join" method="POST">
        
        <%-- 🛸 1. 파트너 식별 ID 구역 --%>
        <div class="input-group-cosmic">
            <label for="vendorId" style="color: #17a2b8 !important;">파트너 식별 ID</label>
            <div class="d-flex gap-2">
                <input type="text" id="vendorId" name="vendorId" placeholder="사용할 파트너 ID를 입력하세요" required autocomplete="off">
                <button type="button" id="btnCheckId" class="btn btn-outline-info rounded-pill" style="min-width: 110px; font-weight: bold;">중복 확인</button>
            </div>
            <small id="idCheckResult" class="mt-2 d-block" style="font-weight: bold; color: #747d8c;">아이디 중복 확인이 필요합니다.</small>
        </div>

        <%-- 🔒 2. 물류 보안 코드 (PW) 구역 --%>
        <div class="input-group-cosmic">
            <label for="vendorPw" style="color: #17a2b8 !important;">물류 암호 보안 코드 (PW)</label>
            <input type="password" id="vendorPw" name="vendorPw" placeholder="안전한 비밀번호를 입력하세요" required>
        </div>

        <%-- 🏢 3. 상호명 / 업체명 구역 --%>
        <div class="input-group-cosmic">
            <label for="bizName" style="color: #17a2b8 !important;">상호명 (업체명)</label>
            <input type="text" id="bizName" name="bizName" placeholder="예: 은하서점, 우주출판사" required>
        </div>

        <%-- 📜 4. 사업자 등록 번호 구역 --%>
        <div class="input-group-cosmic">
            <label for="bizNo" style="color: #17a2b8 !important;">사업자 등록 번호</label>
            <input type="text" id="bizNo" name="bizNo" placeholder="000-00-00000" required>
        </div>

        <%-- 📞 5. 대표 연락처 구역 --%>
        <div class="input-group-cosmic">
            <label for="contact" style="color: #17a2b8 !important;">대표 연락처</label>
            <input type="text" id="contact" name="contact" placeholder="예: 02-1234-5678" required>
        </div>

        <%-- 🚀 등록 버튼 연동 (민트/시안 그라데이션) --%>
        <div class="mt-4">
            <button type="submit" id="btnSubmit" class="btn-confirm w-100 shadow-lg" style="background: linear-gradient(135deg, #17a2b8 0%, #117a8b 100%) !important;" disabled>
                파트너십 입점 신청
            </button>
        </div>

        <%-- 🚪 로그인 복귀 주소 정화 --%>
        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/member/login" class="text-muted small">이미 파트너이신가요? 통합 로그인하기</a>
        </div>
    </form>
</div>

<%-- 스크립트 관제 제어 장치 (무결성 연동) --%>
<script>
document.addEventListener("DOMContentLoaded", function() {
    var isIdChecked = false; // 중복 체크 통과 여부 스위치
    
    var btnCheckId = document.getElementById("btnCheckId");
    var vendorIdInput = document.getElementById("vendorId");
    var idCheckResult = document.getElementById("idCheckResult");
    var btnSubmit = document.getElementById("btnSubmit");

    // 아이디를 다시 타이핑하면 중복체크 스위치 리셋 및 알림 고도화
    vendorIdInput.addEventListener("input", function() {
        isIdChecked = false;
        idCheckResult.textContent = "아이디 변경됨 - 중복 확인 필요";
        idCheckResult.style.color = "#ffa500"; // 주황색 경고
        btnSubmit.disabled = true;
    });

    // 중복 확인 Fetch AJAX 통신
    btnCheckId.addEventListener("click", function() {
        var vendorId = vendorIdInput.value.trim();
        if (vendorId === "") {
            alert("파트너 ID를 먼저 입력해 주세요!");
            vendorIdInput.focus();
            return;
        }

        fetch("${pageContext.request.contextPath}/vendor/checkId?vendorId=" + encodeURIComponent(vendorId))
            .then(function(response) { return response.text(); })
            .then(function(data) {
                if (data.trim() === "Y") {
                    isIdChecked = true;
                    idCheckResult.textContent = "사용 가능한 파트너 ID입니다! ✨";
                    idCheckResult.style.color = "#10ac84"; // 민트색 통과
                    btnSubmit.disabled = false; // 🔓 서브밋 버튼 봉인 해제
                } else {
                    isIdChecked = false;
                    idCheckResult.textContent = "이미 등록된 파트너 ID입니다. ⛔";
                    idCheckResult.style.color = "#ff4757"; // 빨간색 불통
                    btnSubmit.disabled = true;
                }
            })
            .catch(function(err) {
                alert("통신 관제소(서버) 응답에 실패했습니다.");
                console.error("오류내역:", err);
            });
    });

    // 폼 최종 제출 검문소
    document.getElementById("vendorJoinForm").addEventListener("submit", function(e) {
        if (!isIdChecked) {
            e.preventDefault();
            alert("파트너 ID 중복 확인을 진행해 주세요!");
        }
    });
});
</script>