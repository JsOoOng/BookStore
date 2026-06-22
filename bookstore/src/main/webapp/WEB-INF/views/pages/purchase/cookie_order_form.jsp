<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5">
    <h2>주문서 작성</h2>
    <hr>
    
    <form action="${pageContext.request.contextPath}/cookie/purchase/buy" method="post">
        
        <c:if test="${isGuest}">
            <div class="card mb-4">
                <div class="card-header">배송 정보 입력</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label>받으시는 분</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>연락처</label>
                        <input type="text" name="phone" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>배송지 주소</label>
                        <input type="text" name="address" class="form-control" required>
                    </div>
                </div>
            </div>
        </c:if>

        <div class="card mb-4">
            <div class="card-header">주문 상품</div>
            <div class="card-body">
                <table class="table">
                    <thead>
                        <tr>
                            <th>상품명</th>
                            <th>수량</th>
                            <th>가격</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:set var="totalPrice" value="0" />
                        <c:forEach items="${purchaseList}" var="item" varStatus="status">
                            <tr>
                                <td>${item.title}</td>
                                <td>${item.quantity}개</td>
                                <td>${item.price * item.quantity}원</td>
                            </tr>
                            <c:set var="totalPrice" value="${totalPrice + (item.price * item.quantity)}" />
                            
                            <input type="hidden" name="items[${status.index}].saleId" value="${item.saleId}">
                            <input type="hidden" name="items[${status.index}].quantity" value="${item.quantity}">
                            <input type="hidden" name="items[${status.index}].price" value="${item.price}">
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="text-right">
            <h3>총 결제 금액: ${totalPrice}원</h3>
            <input type="hidden" name="totalPrice" value="${totalPrice}">
            <button type="submit" class="btn btn-primary btn-lg">결제하기</button>
        </div>
    </form>
</div>