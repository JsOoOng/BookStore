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
                            <c:when test="${m.role eq 'QNAadmin'}">
					            <span class="badge rounded-pill bg-success px-3">상담원 (QNAadmin)</span>
					        </c:when>
                            <c:otherwise>
                                <span class="badge rounded-pill bg-secondary px-3">대원 (USER)</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td><fmt:formatDate value="${m.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                    <td>
					    <div class="d-flex justify-content-center align-items-center gap-2">
					        <c:if test="${m.role ne 'SUPER'}">
					            <%-- 1. 권한 선택 셀렉트 박스 --%>
					            <select id="roleSelect_${m.id}" class="form-select form-select-sm" style="width: 130px; border-radius: 10px;">
					                <option value="USER" ${m.role eq 'USER' ? 'selected' : ''}>대원 (USER)</option>
					                <option value="ADMIN" ${m.role eq 'ADMIN' ? 'selected' : ''}>관리자 (ADMIN)</option>
					                <option value="QNAadmin" ${m.role eq 'QNAadmin' ? 'selected' : ''}>상담원 (QNA)</option>
					            </select>
					
					            <%-- 2. 변경 적용 버튼 --%>
					            <button class="btn btn-sm btn-primary" style="border-radius: 10px;" 
					                    onclick="applyRoleChange('${m.id}')">적용</button>
					
					            <%-- 3. 구분선 및 제명 버튼 --%>
					            <div class="vr mx-1"></div> 
					            <button class="btn btn-sm btn-outline-danger" style="border-radius: 10px;"
					                    onclick="kickConfirm('${m.id}')">제명</button>
					        </c:if>
					        
					        <c:if test="${m.role eq 'SUPER'}">
					            <span class="text-muted small">수정 불가</span>
					        </c:if>
					    </div>
					</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>


<script>
    // 권한 변경 적용 함수
    function applyRoleChange(memberId) {
        const selectElement = document.getElementById('roleSelect_' + memberId);
        const selectedRole = selectElement.value;
        
        if(confirm(memberId + " 대원의 권한을 [" + selectedRole + "](으)로 변경하시겠습니까?")) {
            location.href = "changeRole?id=" + memberId + "&role=" + selectedRole;
        }
    }

    // 기존 제명 함수 (유지)
    function kickConfirm(id) {
        if(confirm("정말 이 대원을 도서관에서 영구 제명하시겠습니까?")) {
            location.href = "kick?id=" + id;
        }
    }
</script>