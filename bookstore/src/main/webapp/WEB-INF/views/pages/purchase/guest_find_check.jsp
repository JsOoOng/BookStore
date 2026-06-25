<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container py-5 text-center">
    <div class="card shadow-sm p-5" style="max-width: 500px; margin: 0 auto;">
        <c:choose>
            <%-- 1. 리스트가 비어있지 않은 경우 (성공) --%>
            <c:when test="${not empty foundPurchaseIds}">
                <h3 class="text-primary">조회 결과</h3>
                <p>입력하신 정보와 일치하는 주문번호 목록입니다.</p>
                
                <%-- 주문번호 리스트 출력 --%>
                <div class="my-4">
                    <c:forEach var="pid" items="${foundPurchaseIds}">
                        <div class="alert alert-success fs-5 fw-bold py-2 my-2">
                            ${pid}
                        </div>
                    </c:forEach>
                </div>
                
                <a href="${pageContext.request.contextPath}/cookie/purchase/track" class="btn btn-primary">상세 주문 조회하러 가기</a>
            </c:when>
            
            <%-- 2. 리스트가 비어있는 경우 (실패) --%>
            <c:otherwise>
                <h3 class="text-danger">조회 실패</h3>
                <p>일치하는 정보를 찾을 수 없습니다.</p>
                <a href="${pageContext.request.contextPath}/cookie/purchase/find" class="btn btn-secondary">다시 시도하기</a>
            </c:otherwise>
        </c:choose>
    </div>
</div>