<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 💥 [타격 지점] 고유 ID 부여 및 공통 레이아웃 맞춤형 렌더링 컨테이너 --%>
<div id="cosmic-guest-success-container" class="container mt-5 mb-5">
    <div class="success-card text-center">
        
        <h2 class="form-main-title mb-4">🎉 결제가 성공적으로 완료되었습니다!</h2>
        
        <%-- 🧾 비회원 주문번호 하이라이트 박스 --%>
        <div class="order-number-box p-4 mb-4">
            <h5 class="text-muted fw-bold mb-3">비회원 주문번호</h5>
            <h2 id="orderNumber" class="display-6 fw-bold text-dark mb-3 tracking-wide">${orderId}</h2>
            
            <button type="button" onclick="copyOrderNumber()" class="btn-cosmic-ghost">
                📋 주문번호 복사하기
            </button>
        </div>
        
        <%-- ⚠️ 경고 및 안내 문구 --%>
        <p class="warning-text mb-5">
            비회원님은 주문번호를 분실할 경우, 도서의 배송 조회가 불가능합니다.<br>
            제대로 확인 후 <strong class="text-danger-glow">반드시 메모장에 복사 및 기입</strong>해 두시기 바랍니다.
        </p>
        
        <%-- 🎛️ 네비게이션 제어 버튼 --%>
        <div class="action-buttons-group d-flex justify-content-center gap-3">
            <a href="${pageContext.request.contextPath}/" class="btn-cosmic-secondary px-4 py-3">
                🏠 메인 화면으로
            </a>
            <a href="${pageContext.request.contextPath}/cookie/purchase/track" class="btn-cosmic-submit px-4 py-3">
                🚚 주문 조회
            </a>
        </div>
        
    </div>
</div>

<script>
    // 📋 주문번호 안전 복사 파이프라인
    function copyOrderNumber() {
        const text = document.getElementById("orderNumber").innerText;

        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(text)
                .then(() => alert("📋 주문번호가 안전하게 복사되었습니다!"))
                .catch(err => {
                    console.error(err);
                    fallbackCopy(text);
                });
        } else {
            fallbackCopy(text);
        }
    }
    
    // 복사 실패 시 예비 동작 모듈
    function fallbackCopy(text) {
        const temp = document.createElement("textarea");
        temp.value = text;
        document.body.appendChild(temp);
        temp.select();

        try {
            document.execCommand("copy");
            alert("📋 주문번호가 안전하게 복사되었습니다!");
        } catch (err) {
            alert("🚨 복사에 실패했습니다. 번호를 직접 드래그하여 복사해 주세요.");
            console.error(err);
        }

        document.body.removeChild(temp);
    }
</script>