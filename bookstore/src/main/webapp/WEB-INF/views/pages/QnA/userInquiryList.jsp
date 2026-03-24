<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold"><span class="me-2">📋</span>내 문의 내역 보고서</h2>
        <a href="${pageContext.request.contextPath}/user/inquiry" class="btn btn-primary rounded-pill px-4">새 문의 보내기</a>
    </div>

    <div class="table-responsive shadow-sm rounded-4 overflow-hidden">
        <table class="table table-hover align-middle mb-0" style="background: white;">
            <thead class="table-dark">
                <tr>
                    <th class="ps-4">번호</th>
                    <th>분류</th>
                    <th>문의 제목</th>
                    <th>작성자(ID)</th>
                    <th class="text-center">처리 상태</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="my" items="${myList}">
                    <tr onclick="location.href='${pageContext.request.contextPath}/user/myInquiryDetail?id=${my.id}'" style="cursor:pointer;">
                        <td class="ps-4 text-muted">${my.id}</td>
                        <td><span class="badge bg-light text-dark border">${my.inquiry}</span></td>
                        <td class="fw-bold">${my.title}</td>
                        
                        <td>${my.name}</td>

                        <td class="text-center">
                            <c:choose>
                                <c:when test="${empty my.answer}">
                                    <span class="badge bg-secondary">📡 수신 대기중</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-success">✨ 답변 완료</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty myList}">
                    <tr>
                        <td colspan="5" class="text-center py-5 text-muted">
                            보낸 문의 내역이 없습니다. 궁금한 점이 있다면 사령부에 신호를 보내보세요!
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<%-- 페이지 최하단 스크립트 구역에 추가 --%>
<c:if test="${param.sendSuccess eq 'true'}">
    <script>
        // 🛰️ 사령부 통신 보고!
        alert("✨ 문의 신호가 성공적으로 전송되었습니다!\n사령관들이 내용을 분석한 후 답변을 드릴 예정입니다.");
        
        // 주소창에서 ?sendSuccess=true를 지워 새로고침 시 알림이 다시 뜨지 않게 정화합니다.
        if (typeof history.replaceState == 'function') {
            history.replaceState({}, null, location.pathname);
        }
    </script>
</c:if>