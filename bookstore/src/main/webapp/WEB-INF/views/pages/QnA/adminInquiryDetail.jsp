<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5" style="max-width: 900px;">
    <div class="d-flex align-items-center mb-4">
        <a href="${pageContext.request.contextPath}/admin/inquiries" class="btn btn-outline-secondary btn-sm me-3 rounded-circle">←</a>
        <h3 class="fw-bold mb-0">🔎 문의 상세 분석 보고서</h3>
    </div>

    <div class="card border-0 shadow-sm mb-4 rounded-4">
        <div class="card-header bg-white py-3 border-bottom">
            <div class="d-flex justify-content-between align-items-center">
                <span class="badge bg-info text-dark">${inquiry.inquiry}</span>
                <small class="text-muted">No. ${inquiry.id}</small>
            </div>
            <h4 class="mt-2 fw-bold">${inquiry.title}</h4>
            <div class="text-muted small">발신 대원: <strong>${inquiry.name}</strong></div>
        </div>
        <div class="card-body p-4" style="min-height: 200px; background-color: #f8f9fa;">
            <p class="card-text" style="white-space: pre-wrap;">${inquiry.detail}</p>
        </div>
    </div>

    <div class="card border-0 shadow-lg rounded-4 overflow-hidden bg-dark text-white">
        <div class="card-body p-4">
            <h5 class="fw-bold mb-3">📡 사령부 응답 (Reply)</h5>
            <form action="${pageContext.request.contextPath}/admin/replyInquiry" method="post">
                <input type="hidden" name="id" value="${inquiry.id}">
                
                <textarea id="answerArea" name="answer" class="form-control mb-3 border-0" rows="6" 
                          placeholder="대원에게 보낼 답변을 입력하세요..." 
                          ${not empty inquiry.answer ? 'readonly' : ''}
                          style="background: rgba(255,255,255,0.1); color: white; border-radius: 12px; transition: 0.3s;">${inquiry.answer}</textarea>
                
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <c:choose>
                            <c:when test="${not empty inquiry.answer}">
                                <button type="button" id="editBtn" class="btn btn-info px-4 rounded-pill me-2" onclick="enableEdit()">수정하기</button>
                                <button type="submit" id="saveBtn" class="btn btn-primary px-4 rounded-pill" style="display: none;">답변 갱신 및 저장</button>
                            </c:when>
                            <c:otherwise>
                                <button type="submit" class="btn btn-primary px-4 rounded-pill">답변 저장 및 전송</button>
                            </c:otherwise>
                        </c:choose>
                        
                        <button type="button" class="btn btn-link text-white-50 text-decoration-none ms-2" 
                                onclick="location.href='${pageContext.request.contextPath}/admin/inquiries'">취소</button>
                    </div>
                    <button type="button" class="btn btn-outline-danger btn-sm rounded-pill" onclick="deleteQnA()">신호 삭제</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // 🔐 답변 수정 활성화 프로토콜
    function enableEdit() {
        if(confirm("이미 전송된 답변이 있습니다. 답변 내용을 수정하시겠습니까?")) {
            const area = document.getElementById('answerArea');
            const editBtn = document.getElementById('editBtn');
            const saveBtn = document.getElementById('saveBtn');
            
            // 🔓 잠금 해제 및 강조
            area.readOnly = false;
            area.style.background = "rgba(255,255,255,0.2)"; // 입력 가능함을 시각적으로 표시
            area.focus();
            
            // 🔄 버튼 교체
            editBtn.style.display = 'none';
            saveBtn.style.display = 'inline-block';
        }
    }

    // 🛡️ 신호 삭제 프로토콜
    function deleteQnA() {
        if(confirm("이 문의 내역을 우주 공간에서 영구 삭제하시겠습니까?")) {
            const form = document.createElement('form');
            form.method = 'post';
            form.action = '${pageContext.request.contextPath}/admin/deleteInquiry?id=${inquiry.id}';
            document.body.appendChild(form);
            form.submit();
        }
    }

    // ✨ 답변 전송 성공 알림 프로토콜
    <c:if test="${param.replySuccess eq 'true'}">
        alert("✨ 답변이 성공적으로 처리되었습니다.");
        if (typeof history.replaceState == 'function') {
            history.replaceState({}, null, location.pathname + "?id=${inquiry.id}");
        }
    </c:if>
</script>