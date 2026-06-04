<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>우주 도서관 (Cosmic Library)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    
    <%-- 🌟 [수정포인트 1] 부트스트랩 JS 번들 파일을 head 영역으로 전진 배치! --%>
    <%-- 이렇게 해야 하위 jsp(dashboard) 내부 스크립트가 부트스트랩 모달 객체를 완벽하게 인식하고 제어합니다. --%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <style>
    /* 🌟 [수정포인트 2] 부트스트랩 모달 포커스 및 레이어 강제 교정 스타일 추가 */
    .modal {
        z-index: 1060 !important;
    }
    .modal-backdrop {
        z-index: 1050 !important;
    }
    </style>
</head>
<body>

    <c:import url="/WEB-INF/views/common/header.jsp" />

    <main class="main-content" style="min-height: 65vh; padding-bottom: 50px;">
        <jsp:include page="/WEB-INF/views/${pageName}.jsp" />
    </main>

    <c:import url="/WEB-INF/views/common/footer.jsp" />

    <%-- 기존에 맨 아래 있던 bootstrap.bundle.min.js 태그는 삭제되었습니다 --%>
    
    <%-- 🪐 구조 안전지대: 전체 큰 레이아웃 div 바깥 최하단에 단독 배치하여 레이어 꼬임 원천 차단 --%>
	<div class="modal fade" id="productUpdateModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true" style="display: none;">
	    <div class="modal-dialog modal-dialog-centered">
	        <div class="modal-content bg-dark text-white border-secondary shadow-lg">
	            <div class="modal-header border-secondary bg-gradient">
	                <h5 class="modal-title text-info fw-bold" id="modalBookTitle">도서 수정 관제</h5>
	                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
	            </div>
	            <form action="${pageContext.request.contextPath}/vendor/product/update" method="post">
	                <div class="modal-body">
	                    <%-- 숨겨서 가져갈 고유 saleId 히든 필드 --%>
	                    <input type="hidden" id="modalSaleId" name="saleId">
	
	                    <div class="mb-3">
	                        <label for="modalPrice" class="form-label text-warning small fw-bold">💰 마켓 판매가 변경</label>
	                        <div class="input-group">
	                            <input type="number" class="form-control bg-secondary text-white border-secondary text-end" id="modalPrice" name="price" required min="0">
	                            <span class="input-group-text bg-dark text-secondary border-secondary">원</span>
	                        </div>
	                    </div>
	
	                    <div class="mb-3">
	                        <label for="modalStockQty" class="form-label text-info small fw-bold">📉 실시간 공급 재고 조정</label>
	                        <div class="input-group">
	                            <input type="number" class="form-control bg-secondary text-white border-secondary text-end" id="modalStockQty" name="stockQty" required min="0">
	                            <span class="input-group-text bg-dark text-secondary border-secondary">개</span>
	                        </div>
	                    </div>
	
	                    <div>
	                        <label for="modalSaleStatus" class="form-label text-secondary small fw-bold">🛰️ 마켓 노출 상태</label>
	                        <select class="form-select bg-secondary text-white border-secondary" id="modalSaleStatus" name="saleStatus">
	                            <option value="ON">🪐 ON (마켓에 즉시 노출)</option>
	                            <option value="OFF">💤 OFF (마켓에서 숨김/중지)</option>
	                        </select>
	                    </div>
	                </div>
	                <div class="modal-footer border-secondary">
	                    <button type="button" class="btn btn-outline-secondary text-white btn-sm px-3" data-bs-dismiss="modal">닫기</button>
	                    <button type="submit" class="btn btn-info text-dark fw-bold btn-sm px-4">🛸 변경사항 동기화</button>
	                </div>
	            </form>
	        </div>
	    </div>
	</div>
    
</body>
</html>