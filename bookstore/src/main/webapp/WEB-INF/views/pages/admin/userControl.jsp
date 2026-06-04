<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 🪐 웅장한 가로폭 대확장을 위해 최상위를 admin-wide-container로 래핑 --%>
<div class="admin-wide-container mt-4">

    <h2 class="mb-2 fw-bold" style="color: #5d5fef;">👑 대원 통합 관리 시스템 (Command Center)</h2>
    <p class="text-muted mb-4">기지에 등록된 모든 일반 대원의 활동 상태를 제어하고 명단을 관리합니다.</p>
    
    <%-- 📊 대원 관제 데이터 테이블 카드 구역 (style.css 마스터 팩 연동) --%>
    <div class="main-content p-0 border-0 admin-table-card">
        <table class="table table-hover admin-table mb-0 align-middle text-center">
            <thead class="table-dark">
                <tr>
                    <th class="py-3" style="width: 12%; border-top-left-radius: 20px;">등록 번호</th>
                    <th style="width: 15%;">대원 식별 ID</th>
                    <th style="width: 15%;">대원 성명</th>
                    <th style="width: 20%;">가입 일자</th>
                    <th style="width: 15%;">현재 상태</th>
                    <th style="width: 23%; border-top-right-radius: 20px;">상태 조정 / 조치 프로토콜</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty memberList}">
                        <c:forEach var="m" items="${memberList}">
                            <tr class="member-row">
                                <%-- 1. 활동 등록 고유 번호 --%>
                                <td class="fw-bold text-secondary"># ${m.user_reg_num}</td>
                                
                                <%-- 2. 식별 ID 및 성명 --%>
                                <td class="fw-bold text-dark">${m.id}</td>
                                <td class="text-secondary">${m.name}</td>
                                
                                <%-- 3. 가입 일자 --%>
                                <td class="text-muted"><fmt:formatDate value="${m.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                
                                <%-- 4. 현재 활동 상태 배지 표시 --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${m.reg_status eq 'ACTIVE'}">
                                            <span class="badge rounded-pill bg-success px-3 shadow-sm" style="font-size: 0.85rem; padding-top: 5px; padding-bottom: 5px;">ACTIVE</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge rounded-pill bg-secondary px-3 shadow-sm" style="font-size: 0.85rem; padding-top: 5px; padding-bottom: 5px;">${m.reg_status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <%-- 5. 통제 프로토콜 콤보박스 및 액션 버튼 --%>
                                <td>
                                    <div class="d-flex justify-content-center align-items-center gap-2">
                                        <%-- 상태 선택 셀렉트 박스 --%>
                                        <select id="statusSelect_${m.id}" class="form-select form-select-sm" style="width: 130px; border-radius: 10px;">
                                            <option value="ACTIVE" ${m.reg_status eq 'ACTIVE' ? 'selected' : ''}>정상 (ACTIVE)</option>
                                            <option value="BLOCK" ${m.reg_status eq 'BLOCK' ? 'selected' : ''}>정지 (BLOCK)</option>
                                        </select>
                    
                                        <%-- 변경 적용 버튼 --%>
                                        <button class="btn btn-sm btn-primary px-3 fw-bold" style="border-radius: 10px; font-size: 0.8rem;" 
                                                onclick="applyStatusChange('${m.id}')">적용</button>
                    
                                        <%-- 구분선 및 제명 버튼 --%>
                                        <div class="vr mx-1" style="color: rgba(0,0,0,0.3); height: 18px;"></div> 
                                        <button class="btn btn-sm btn-outline-danger fw-bold" style="border-radius: 10px; font-size: 0.8rem;"
                                                onclick="kickConfirm('${m.id}')">제명</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted small fw-bold">
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