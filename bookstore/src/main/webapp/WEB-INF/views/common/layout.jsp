<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>우주 도서관 (Cosmic Library)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css?ver=1">
    
    <%-- 🌟 부트스트랩 JS 번들 헤드 전진 배치 유지 --%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>

    <c:import url="/WEB-INF/views/common/header.jsp" />

    <%-- 🌌 본문 선체 크기 제어 --%>
    <main class="main-content" style="min-height: 70vh; padding-bottom: 50px;">
        <jsp:include page="/WEB-INF/views/${pageName}.jsp" />
    </main>

    <c:import url="/WEB-INF/views/common/footer.jsp" />

    <%-- 🪐 구조 안전지대: 미니멀 스퀘어 폼 스타일 클래스(cosmic-minimal-modal) 장착 완공 --%>
    <div class="modal fade cosmic-minimal-modal" id="productUpdateModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true" style="display: none;">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="modalBookTitle">도서 수정 관제</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/vendor/product/update" method="post">
                    <div class="modal-body">
                        <%-- 고유 saleId 히든 필드 --%>
                        <input type="hidden" id="modalSaleId" name="saleId">
    
                        <div class="mb-3">
                            <label for="modalPrice" class="form-label fw-bold">PRICE / 마켓 판매가 변경</label>
                            <div class="input-group">
                                <input type="number" class="form-control text-end" id="modalPrice" name="price" required min="0">
                                <span class="input-group-text">원</span>
                            </div>
                        </div>
    
                        <div class="mb-3">
                            <label for="modalStockQty" class="form-label fw-bold">STOCK / 실시간 공급 재고 조정</label>
                            <div class="input-group">
                                <input type="number" class="form-control text-end" id="modalStockQty" name="stockQty" required min="0">
                                <span class="input-group-text">개</span>
                            </div>
                        </div>
    
                        <div>
                            <label for="modalSaleStatus" class="form-label fw-bold">STATUS / 마켓 노출 상태</label>
                            <select class="form-select" id="modalSaleStatus" name="saleStatus">
                                <option value="ON">ON (마켓 즉시 노출)</option>
                                <option value="OFF">OFF (마켓 노출 중지)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-close-modal" data-bs-dismiss="modal">닫기</button>
                        <button type="submit" class="btn btn-submit-modal fw-bold">변경사항 동기화</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
</body>
</html>