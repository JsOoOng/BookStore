<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 🪐 웅장한 가로폭 대확장을 위해 최상위를 admin-wide-container로 래핑 --%>
<div class="admin-wide-container mt-4 mb-5">

    <%-- 🚀 레이아웃 상단 통제 헤더 구역 --%>
    <div class="admin-control-header">
        <div class="header-text-group">
            <h2 class="cosmic-member-title">👑 대원 통합 관리 시스템 (Command Center)</h2>
            <p class="cosmic-admin-desc">기지에 등록된 모든 일반 대원의 활동 상태를 제어하고 명단을 관리합니다.</p>
        </div>
    </div>
    
    <%-- 📊 대원 관제 데이터 테이블 카드 구역 --%>
    <div class="cosmic-table-wrapper">
        <table class="cosmic-table">
            <thead>
                <tr>
                    <th class="th-reg">등록 번호</th>
                    <th class="th-id">대원 식별 ID</th>
                    <th class="th-name">대원 성명</th>
                    <th class="th-date">가입 일자</th>
                    <th class="th-status">현재 상태</th>
                    <th class="th-action">상태 조정 / 조치 프로토콜</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty memberList}">
                        <c:forEach var="m" items="${memberList}">
                            <tr class="member-row">
                                <%-- 1. 활동 등록 고유 번호 --%>
                                <td class="td-reg"># ${m.user_reg_num}</td>
                                
                                <%-- 2. 식별 ID 및 성명 --%>
                                <td class="td-id">${m.id}</td>
                                <td class="td-name">${m.name}</td>
                                
                                <%-- 3. 가입 일자 --%>
                                <td class="td-date"><fmt:formatDate value="${m.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                
                                <%-- 4. 현재 활동 상태 배지 표시 --%>
                                <td class="td-status">
                                    <c:choose>
                                        <c:when test="${m.reg_status eq 'ACTIVE'}">
                                            <span class="badge-status badge-active">ACTIVE</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status badge-disabled">${m.reg_status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <%-- 5. 통제 프로토콜 콤보박스 및 액션 버튼 --%>
                                <td class="td-action">
                                    <div class="action-control-group">
                                        <%-- 상태 선택 셀렉트 박스 --%>
                                        <select id="statusSelect_${m.id}" class="cosmic-select-inline">
                                            <option value="ACTIVE" ${m.reg_status eq 'ACTIVE' ? 'selected' : ''}>정상 (ACTIVE)</option>
                                            <option value="BLOCK" ${m.reg_status eq 'BLOCK' ? 'selected' : ''}>정지 (BLOCK)</option>
                                        </select>
                    
                                        <%-- 변경 적용 버튼 --%>
                                        <button class="btn-action-apply" onclick="applyStatusChange('${m.id}')">적용</button>
                    
                                        <%-- 구분선 및 제명 버튼 --%>
                                        <div class="cosmic-vr"></div> 
                                        <button class="btn-action-kick" onclick="kickConfirm('${m.id}')">제명</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="6" class="td-empty-state">
                                🛰️ 기지에 등록된 일반 탐사대원이 존재하지 않습니다.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<script>
    // ⚙️ 대원 상태 변경 적용 함수 (컨트롤러 /admin/changeStatus 경로 연동)
    function applyStatusChange(memberId) {
        const selectElement = document.getElementById('statusSelect_' + memberId);
        const selectedStatus = selectElement.value;
        
        if(confirm(memberId + " 대원의 상태를 [" + selectedStatus + "](으)로 변경하시겠습니까?")) {
            location.href = "${pageContext.request.contextPath}/admin/changeStatus?id=" + memberId + "&status=" + selectedStatus;
        }
    }

    // ❌ 불량 대원 블랙홀 제명 함수 (컨트롤러 /admin/kick 경로 연동)
    function kickConfirm(id) {
        if(confirm("🚨 [최종 경고]\n정말 이 대원을 기지에서 영구 제명하시겠습니까?\n삭제 시 자식 테이블의 모든 활동 기록이 영구 말소됩니다.")) {
            location.href = "${pageContext.request.contextPath}/admin/kick?id=" + id;
        }
    }

    // 🔥 [하얀 박스 가두리 격파 치트키] 페이지 로드 시 상위 부모 레이아웃의 max-width 강제 해제
    document.addEventListener("DOMContentLoaded", function() {
        var wideContainer = document.querySelector('.admin-wide-container');
        if (wideContainer) {
            var parent = wideContainer.parentElement;
            
            // BODY 태그에 닿을 때까지 올라가며 조상들의 가로 한계선을 폭파
            while (parent && parent.tagName !== 'BODY') {
                parent.style.maxWidth = '100%';
                parent.style.width = '100%';
                
                // 공통 레이아웃의 하얀색 카드 틀 컨테이너 조율
                if(parent.classList.contains('form-container') || parent.className.includes('container')) {
                    parent.style.maxWidth = '1400px'; 
                    parent.style.margin = '0 auto';
                }
                
                parent = parent.parentElement;
            }
        }
    });
</script>