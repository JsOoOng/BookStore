<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold"><span class="me-2">📨</span>수신된 문의 신호함</h2>
        <span class="badge bg-primary rounded-pill">총 ${inquiries.size()}건</span>
    </div>

    <div class="table-responsive shadow-sm rounded-4 overflow-hidden">
        <table class="table table-hover align-middle mb-0" style="background: white;">
            <thead class="table-dark">
                <tr>
                    <th class="ps-4">ID</th>
                    <th>분류</th>
                    <th>제목</th>
                    <th>발신 대원</th> <th class="text-center">상태</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="qna" items="${inquiries}">
                    <tr onclick="location.href='${pageContext.request.contextPath}/admin/inquiryDetail?id=${qna.id}'" style="cursor:pointer;">
                        <td class="ps-4 text-muted">${qna.id}</td>
                        <td><span class="badge bg-light text-dark border">${qna.inquiry}</span></td>
                        <td class="fw-bold">${qna.title}</td>
                        
                        <td>${qna.name}</td>

                        <td class="text-center">
                            <c:choose>
                                <c:when test="${empty qna.answer}">
                                    <span class="badge bg-warning text-dark">미응답</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-success">응답 완료</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty inquiries}">
                    <tr>
                        <td colspan="5" class="text-center py-5 text-muted">현재 수신된 신호가 없습니다.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<%-- 페이지 최하단 script 구역 --%>
<c:if test="${param.replySuccess eq 'true'}">
    <script>
        // 🛰️ 사령부 업무 보고!
        alert("✨ 답변이 성공적으로 저장 및 전송되었습니다.");
        
        // 주소창에서 ?replySuccess=true를 제거하여 깔끔하게 정화합니다.
        if (typeof history.replaceState == 'function') {
            history.replaceState({}, null, location.pathname);
        }
    </script>
</c:if>