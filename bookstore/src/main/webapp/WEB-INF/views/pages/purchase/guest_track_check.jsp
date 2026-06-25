<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5">
    <h2>비회원 주문 상세 확인</h2>
    <hr>

    <%-- 1. 주문 기본 정보 --%>
    <c:if test="${not empty trackList}">
        <div class="card mb-4">
            <div class="card-body">
                <p><strong>주문번호:</strong> ${trackList[0].purchaseId}</p>
                <p><strong>수령인 이름:</strong> ${trackList[0].name}</p>
                <p><strong>받는 주소:</strong> ${trackList[0].address}</p>
                <p><strong>연락처:</strong> ${trackList[0].phone}</p>
            </div>
        </div>
    </c:if>

    <%-- 2. 상품 상세 내역 테이블 (저자 항목 추가) --%>
    <table class="table table-hover align-middle">
        <thead class="table-light">
            <tr>
                <th>책 사진</th>
                <th>책 이름</th>
                <th>저자</th>
                <th>수량</th>
                <th>가격</th>
                <th>상태</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${trackList}" var="order">
                <tr>
                    <td><img src="${order.image}" alt="책 표지" style="width: 80px; height: 110px;"></td>
                    <td>${order.title}</td>
                    <td>${order.writer}</td> <%-- 💥 저자 정보 출력 --%>
                    <td>${order.quantity}</td>
                    <td>${order.unitPrice}원</td>
                    <td><span class="badge bg-primary">${order.status}</span></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <%-- 3. 상담 정보 --%>
    <div class="mt-5 p-3 border-top text-muted">
        <p><strong>비회원 상담원:</strong> 황선오 | <strong>연락처:</strong> 010-0000-0000 | <strong>E-mail:</strong> cosmic@cosmic.com</p>
    </div>

    <div class="mt-3">
        <a href="${pageContext.request.contextPath}/cookie/purchase/track" class="btn btn-secondary">다시 조회하기</a>
    </div>
</div>