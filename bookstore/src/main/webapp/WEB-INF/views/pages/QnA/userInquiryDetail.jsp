<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5" style="max-width: 800px;">
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/user/myInquiries" class="text-decoration-none text-muted small">← 목록으로 돌아가기</a>
        <h3 class="fw-bold mt-2">🛰️ 문의 및 답변 확인</h3>
    </div>

    <div class="card border-0 shadow-sm mb-4 rounded-4">
        <div class="card-header bg-white py-3 border-bottom">
            <span class="badge bg-info text-dark mb-2">${inquiry.inquiry}</span>
            <h4 class="fw-bold">${inquiry.title}</h4>
        </div>
        <div class="card-body p-4">
            <p class="card-text" style="white-space: pre-wrap;">${inquiry.detail}</p>
        </div>
    </div>

    <div class="card border-0 shadow-sm rounded-4 overflow-hidden" style="background: #f0f3ff; border-left: 5px solid #5d5fef !important;">
        <div class="card-body p-4">
            <h5 class="fw-bold text-primary mb-3">👨‍🚀 사령관의 응답 (Official Reply)</h5>
            <c:choose>
                <c:when test="${not empty inquiry.answer}">
                    <div class="p-3 bg-white rounded-3 shadow-sm" style="white-space: pre-wrap; min-height: 100px;">${inquiry.answer}</div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4 text-muted">
                        <p class="mb-0">사령부에서 신호를 분석 중입니다.</p>
                        <small>답변이 등록될 때까지 조금만 기다려 주세요!</small>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="text-center mt-5">
        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary rounded-pill px-5">메인 본부로 돌아가기</a>
    </div>
</div>