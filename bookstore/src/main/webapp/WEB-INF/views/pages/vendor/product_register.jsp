<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="card bg-dark text-white shadow-lg border-secondary">
                <div class="card-header border-secondary bg-gradient py-3">
                    <h4 class="fw-bold mb-0 text-info">📦 신규 판매 상품 마켓 론칭</h4>
                    <p class="text-secondary small mb-0 mt-1">도서 창고 데이터를 기반으로 우주 마켓에 상품을 공급합니다.</p>
                </div>
                <div class="card-body p-4">
                    
                    <form action="${pageContext.request.contextPath}/vendor/product/register" method="post" id="productRegisterForm">
                        
                        <%-- 1. 원천 도서 매핑 식별 번호 --%>
                        <div class="mb-3">
                            <label for="bookId" class="form-label text-info">📖 원천 도서 식별 번호 (Book ID)</label>
                            <input type="number" class="form-control bg-secondary text-white border-secondary" 
                                   id="bookId" name="bookId" required placeholder="등록할 도서의 고유 ID 번호를 입력하세요 (예: 1, 2)">
                            <div class="form-text text-secondary">※ 현재는 프로토타입 단계로 도서 번호를 직접 매핑합니다.</div>
                        </div>

                        <div class="row">
                            <%-- 2. 소비자 판매가 설정 --%>
                            <div class="col-md-6 mb-3">
                                <label for="price" class="form-label text-info">💰 마켓 판매가 (Price)</label>
                                <div class="input-group">
                                    <input type="number" class="form-control bg-secondary text-white border-secondary text-end" 
                                           id="price" name="price" required min="0" placeholder="0">
                                    <span class="input-group-text bg-dark text-secondary border-secondary">원</span>
                                </div>
                            </div>

                            <%-- 3. 초기 공급 재고 수량 --%>
                            <div class="col-md-6 mb-3">
                                <label for="stockQty" class="form-label text-info">📉 초기 공급 재고 (Stock)</label>
                                <div class="input-group">
                                    <input type="number" class="form-control bg-secondary text-white border-secondary text-end" 
                                           id="stockQty" name="stockQty" required min="1" placeholder="10">
                                    <span class="input-group-text bg-dark text-secondary border-secondary">개</span>
                                </div>
                            </div>
                        </div>

                        <%-- 4. 마켓 판매 상태 초기값 --%>
                        <div class="mb-4">
                            <label for="saleStatus" class="form-label text-info">🛰️ 마켓 출시 상태</label>
                            <select class="form-select bg-secondary text-white border-secondary" id="saleStatus" name="saleStatus">
                                <option value="ON" selected>🪐 ON (즉시 판매 시작 - 메인 상점 노출)</option>
                                <option value="OFF">💤 OFF (판매 대기/숨김 - 대시보드만 보관)</option>
                            </select>
                        </div>

                        <%-- 제어 버튼 세트 --%>
                        <div class="d-flex justify-content-end gap-2 border-top border-secondary pt-3">
                            <a href="${pageContext.request.contextPath}/vendor/dashboard" class="btn btn-outline-secondary text-white px-4">취소</a>
                            <button type="submit" class="btn btn-info text-dark fw-bold px-4">🚀 마켓 론칭 승인</button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

<script>
// 간단한 전송 전 폼 유효성 검증 관제
document.getElementById("productRegisterForm").addEventListener("submit", function(e) {
    var price = document.getElementById("price").value;
    var stock = document.getElementById("stockQty").value;

    if (price < 0) {
        alert("판매가는 0원 이상이어야 합니다!");
        e.preventDefault();
    }
    if (stock < 1) {
        alert("최초 공급 재고는 최소 1개 이상이어야 마켓에 등록 가능합니다!");
        e.preventDefault();
    }
});
</script>