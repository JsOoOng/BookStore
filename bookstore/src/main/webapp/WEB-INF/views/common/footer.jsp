<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<footer class="bg-dark text-white py-5 mt-auto">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-md-6 text-center text-md-start">
                <h5 class="fw-bold">🚀 Cosmic Library</h5>
                <p class="small mb-0" style="color: #DCDCDC;">지식의 은하계를 탐험하는 대원들을 위한 안식처입니다.</p>
            </div>
            <div class="col-md-6 text-center text-md-end mt-4 mt-md-0">
                
                <c:if test="${not empty sessionScope.loginMember}">
                    <div class="d-flex flex-column flex-md-row justify-content-md-end gap-2">
                        <a href="${pageContext.request.contextPath}/user/inquiry" class="btn btn-outline-light rounded-pill px-4">
                            📡 사령부에 문의하기 (QnA)
                        </a>
                        <a href="${pageContext.request.contextPath}/user/myInquiries" class="btn btn-outline-info rounded-pill px-4">
                            📋 내 문의 내역
                        </a>
                    </div>
                </c:if>
                
                <p><a href="${pageContext.request.contextPath}/map" class="btn btn-outline-info rounded-pill px-4">찾아오는 길</a></p>
                <p class="small mt-2" style="color: #DCDCDC;">© 2026 Cosmic Library Project. All Rights Reserved.</p>
            </div>
        </div>
    </div>
</footer>