<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<h2 class="mb-4 fw-bold" style="color: #5d5fef;">👑 대원 통합 관리 시스템 (Command Center)</h2>
<p class="text-muted mb-4">기지에 등록된 모든 대원의 권한을 제어하고 명단을 관리합니다.</p>

<div class="main-content p-0 shadow-sm border-0 overflow-hidden" style="border-radius: 20px; background: rgba(255,255,255,0.7);">
    <table class="table table-hover mb-0 align-middle text-center">
        <thead class="table-dark">
            <tr>
                <th class="py-3">식별 ID</th>
                <th>대원 성명</th>
                <th>현재 계급</th>
                <th>가입 일자</th>
                <th>권한 조정 / 조치</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="m" items="${memberList}">
                <tr>
                    <td class="fw-bold">${m.id}</td>
                    <td>${m.name}</td>
                    <td>
                        <c:choose>
                            <c:when test="${m.role eq 'SUPER'}">
                                <span class="badge rounded-pill bg-danger px-3">사령관 (SUPER)</span>
                            </c:when>
                            <c:when test="${m.role eq 'ADMIN'}">
                                <span class="badge rounded-pill bg-primary px-3">관리자 (ADMIN)</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge rounded-pill bg-secondary px-3">대원 (USER)</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td><fmt:formatDate value="${m.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                    <td>
                        <div class="btn-group">
                            <c:if test="${m.role ne 'SUPER'}">
                                <%-- 계급 조정 버튼 --%>
                                <c:if test="${m.role eq 'USER'}">
                                    <button class="btn btn-sm btn-outline-primary" 
                                            onclick="location.href='changeRole?id=${m.id}&role=ADMIN'">ADMIN 임명</button>
                                </c:if>
                                <c:if test="${m.role eq 'ADMIN'}">
                                    <button class="btn btn-sm btn-outline-secondary" 
                                            onclick="location.href='changeRole?id=${m.id}&role=USER'">USER 강등</button>
                                </c:if>
                                
                                <%-- 대원 제명 버튼 --%>
                                <button class="btn btn-sm btn-danger ms-2" 
                                        onclick="kickConfirm('${m.id}')">제명</button>
                            </c:if>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<script>
    function kickConfirm(id) {
        if(confirm("정말 이 대원을 기지에서 영구 제명하시겠습니까?")) {
            location.href = "kick?id=" + id;
        }
    }
</script>