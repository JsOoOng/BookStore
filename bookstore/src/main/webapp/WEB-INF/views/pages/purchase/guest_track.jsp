<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white text-center">
                    <h4 class="mb-0">📦 비회원 주문 조회</h4>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted text-center mb-4">주문 번호와 수령인 이름을 입력하여 주문 내역을 확인하세요.</p>
                    
                    <form action="${pageContext.request.contextPath}/cookie/purchase/trackDetail" method="POST">
                        <div class="mb-3">
                            <label class="form-label">주문 번호 (Purchase ID)</label>
                            <input type="text" name="purchaseId" class="form-control" placeholder="주문 번호를 입력하세요" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">수령인 이름 (Guest Name)</label>
                           <input type="text" name="name" class="form-control" placeholder="이름을 입력하세요" required>
                        </div>
                        
                        <div class="d-grid mt-4">
                            <button type="submit" class="btn btn-primary btn-lg">조회하기</button>
                        </div>
                    </form>
                </div>
                <div class="card-footer text-center">
                    <small class="text-muted">회원 주문 내역은 마이페이지에서 확인 가능합니다.</small>
                </div>
            </div>
        </div>
    </div>
</div>