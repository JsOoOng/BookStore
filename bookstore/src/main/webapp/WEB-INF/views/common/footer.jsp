<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<footer class="footer-cosmic mt-auto">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-md-6 text-center text-md-start">
                <%-- 레퍼런스 스타일의 소문자 미니멀 타이틀 연동 --%>
                <h5 class="footer-brand-text">cosmic library</h5>
                <p class="footer-desc-text">지식의 은하계를 탐험하는 대원들을 위한 안식처입니다.</p>
            </div>
            <div class="col-md-6 text-center text-md-end mt-4 mt-md-0">
                
                <%-- 일반 대원(회원) 문의 기능 연동망 (원천 기능 100% 유지) --%>
                <c:if test="${not empty sessionScope.loginMember}">
                    <div class="d-flex flex-column flex-md-row justify-content-md-end gap-2 mb-3">
                        <a href="${pageContext.request.contextPath}/user/inquiry" class="btn btn-footer-nav">
                            사령부에 문의하기 (QnA)
                        </a>
                        <a href="${pageContext.request.contextPath}/user/myInquiries" class="btn btn-footer-nav">
                            내 문의 내역
                        </a>
                    </div>
                </c:if>
                
                <p class="mb-2"><a href="${pageContext.request.contextPath}/map" class="btn btn-footer-nav">찾아오는 길</a></p>
                <p class="footer-copy-text">© 2026 Cosmic Library Project. All Rights Reserved.</p>
            </div>
        </div>
    </div>
</footer>