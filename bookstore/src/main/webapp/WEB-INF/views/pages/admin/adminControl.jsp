<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container mt-4 mb-5">
    
    <%-- 🚀 레이아웃 상단 통제 헤더 구역 --%>
    <div class="admin-control-header">
        <div class="header-text-group">
            <h2 class="cosmic-admin-title">👑 사령부 고위 관리자 제어 패널</h2>
            <p class="cosmic-admin-desc">테이블 헤더의 직무 필터로 분류하고, 관리자 배지를 클릭하여 권한을 즉시 제어합니다.</p>
        </div>
        
        <button class="btn-cosmic-danger btn-add-admin" data-bs-toggle="modal" data-bs-target="#adminRegisterModal">
            ➕ 신규 관리자 임명
        </button>
    </div>

    <%-- 🎉 사령부 액션 피드백 알림 배너 --%>
    <c:if test="${param.regSuccess eq 'true'}">
        <div class="cosmic-alert-banner alert-success-cosmic text-center mb-4">
            🎉 신규 사령부 관리자 임명 령이 성공적으로 데이터베이스에 하달되었습니다!
        </div>
    </c:if>
    <c:if test="${param.error eq 'self_mutation_blocked'}">
        <div class="cosmic-alert-banner alert-warning-cosmic text-center mb-4">
            ⚠️ 프로토콜 오류: 최고 사령관 본인의 권한은 스스로 변경할 수 없습니다.
        </div>
    </c:if>

    <%-- 📊 관리자 관제 데이터 테이블 카드 구역 --%>
    <div class="cosmic-table-wrapper">
        <table class="cosmic-table">
            <thead>
                <tr>
                    <th class="th-id">관리자 고유 ID</th>
                    <th class="th-name">관리자 호칭</th>
                    <th class="th-date">임명 일자</th>
                    
                    <%-- 🌟 테이블 헤더 내장형 드롭다운 필터 --%>
                    <th class="th-role">
                        <div class="dropdown d-inline-block">
                            <span class="dropdown-toggle filter-toggle-btn" id="tableHeaderFilterBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                🛡️ 현재 직무 (필터: 전체보기)
                            </span>
                            <ul class="dropdown-menu cosmic-dropdown-menu shadow" aria-labelledby="tableHeaderFilterBtn">
                                <li><a class="dropdown-item active filter-item" href="#" onclick="filterAdminRole('ALL', '전체보기')">🌐 전체 보기 (디폴트)</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('SUPER', '최고 사령관')">🛡️ 최고 사령관 (SUPER)</a></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('BOOK_ADMIN', '도서 관리자')">📚 도서 관리자 (BOOK)</a></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('MEMBER_ADMIN', '대원 관리자')">👥 대원 관리자 (MEMBER)</a></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('VENDOR_ADMIN', '기업 관리자')">🏢 기업 관리자 (VENDOR)</a></li>
                            </ul>
                        </div>
                    </th>
                    
                    <th class="th-action">조치 프로토콜</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="a" items="${adminList}">
                    <tr class="admin-row" data-role="${a.role}">
                        <td class="td-id">${a.adminId}</td>
                        <td class="td-name">${a.adminName}</td>
                        <td class="td-date"><fmt:formatDate value="${a.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                        
                        <%-- 🎭 현재 직무 변경 인라인 드롭다운 배지 부역 --%>
                        <td class="td-role">
                            <c:choose>
                                <%-- CASE 1: 타인 계정인 경우 변경 인라인 드롭다운 가동 --%>
                                <c:when test="${a.adminId ne sessionScope.loginAdmin.adminId}">
                                    <div class="dropdown d-inline-block">
                                        
                                        <c:choose>
                                            <c:when test="${a.role eq 'SUPER'}">
                                                <button class="btn dropdown-toggle btn-role-badge btn-role-super" type="button" data-bs-toggle="dropdown" aria-expanded="false">🛡️ 최고 사령관 (SUPER)</button>
                                            </c:when>
                                            <c:when test="${a.role eq 'BOOK_ADMIN'}">
                                                <button class="btn dropdown-toggle btn-role-badge btn-role-book" type="button" data-bs-toggle="dropdown" aria-expanded="false">📚 도서 관리 (BOOK)</button>
                                            </c:when>
                                            <c:when test="${a.role eq 'MEMBER_ADMIN'}">
                                                <button class="btn dropdown-toggle btn-role-badge btn-role-member" type="button" data-bs-toggle="dropdown" aria-expanded="false">👥 대원 관리 (MEMBER)</button>
                                            </c:when>
                                            <c:when test="${a.role eq 'VENDOR_ADMIN'}">
                                                <button class="btn dropdown-toggle btn-role-badge btn-role-vendor" type="button" data-bs-toggle="dropdown" aria-expanded="false">🏢 기업 관리 (VENDOR)</button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn dropdown-toggle btn-role-badge btn-role-default" type="button" data-bs-toggle="dropdown" aria-expanded="false">${a.role}</button>
                                            </c:otherwise>
                                        </c:choose>

                                        <ul class="dropdown-menu cosmic-dropdown-menu shadow">
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'SUPER')">🛡️ 최고 사령관 (SUPER)</a></li>
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'BOOK_ADMIN')">📚 도서 관리자 (BOOK)</a></li>
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'MEMBER_ADMIN')">👥 대원 관리자 (MEMBER)</a></li>
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'VENDOR_ADMIN')">🏢 기업 관리자 (VENDOR)</a></li>
                                        </ul>
                                    </div>
                                </c:when>
                                
                                <%-- CASE 2: 사령관 자기 자신 계정 보호 --%>
                                <c:otherwise>
                                    <span class="badge-role-protected">🛡️ 최고 사령관 (SUPER)</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        
                        <%-- 🚫 조치 기능 부역 --%>
                        <td class="td-action">
                            <c:choose>
                                <c:when test="${a.adminId ne sessionScope.loginAdmin.adminId}">
                                    <button class="btn-fire-admin" onclick="fireConfirm('${a.adminId}', '${a.adminName}')">🚫 영구 해임</button>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-locked-action">⚙️ 변경 불가</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%-- 🛸 신규 사령부 관리자 임명 모달 (코스믹 미니멀 스타일 적용 대기) --%>
<div class="modal fade" id="adminRegisterModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content cosmic-admin-modal">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title admin-modal-title">🛰️ 신규 기지 관리자 임명 발령</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/registerAdmin" method="POST" autocomplete="off">
                <div class="modal-body pt-4">
                    <div class="input-group-cosmic mb-3">
                        <label>고유 식별 ID</label>
                        <input type="text" name="adminId" placeholder="접속에 사용할 고유 ID 입력" required>
                    </div>
                    <div class="input-group-cosmic mb-3">
                        <label>초기 보안 코드 (PW)</label>
                        <input type="password" name="adminPw" placeholder="초기 접속 비밀번호 입력" required>
                    </div>
                    <div class="input-group-cosmic mb-3">
                        <label>관리자 성명 / 관제명</label>
                        <input type="text" name="adminName" placeholder="예: 홍길동 대위" required>
                    </div>
                    <div class="input-group-cosmic mb-2">
                        <label>할당할 전문 직무(Role)</label>
                        <select name="role" required>
                            <option value="BOOK_ADMIN">도서 관리자 (BOOK_ADMIN)</option>
                            <option value="MEMBER_ADMIN">대원 관리자 (MEMBER_ADMIN)</option>
                            <option value="VENDOR_ADMIN">기업 관리자 (VENDOR_ADMIN)</option>
                            <option value="SUPER">최고 사령관 (SUPER)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 d-flex gap-2">
                    <button type="button" class="btn-cancel-cosmic flex-fill" data-bs-dismiss="modal">조율 취소</button>
                    <button type="submit" class="btn-confirm-cosmic btn-submit-admin flex-fill">임명장 발령</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // 🌐 테이블 헤더 내장형 실시간 카테고리 필터링 알고리즘
    function filterAdminRole(role, roleName) {
        if(event) event.preventDefault();

        var rows = document.querySelectorAll('.admin-row');
        rows.forEach(function(row) {
            var rowRole = row.getAttribute('data-role');
            if (role === 'ALL' || rowRole === role) {
                row.style.display = ''; 
            } else {
                row.style.display = 'none';
            }
        });

        var headerBtn = document.getElementById('tableHeaderFilterBtn');
        if (headerBtn) {
            headerBtn.innerHTML = "🛡️ 현재 직무 (필터: " + roleName + ")";
        }

        var items = document.querySelectorAll('.filter-item');
        items.forEach(function(item) {
            item.classList.remove('active');
        });
        
        if(event && event.currentTarget) {
            event.currentTarget.classList.add('active');
        }
    }

    // ⚡ 인라인 직무 배지 드롭다운 선택 시 즉시 실탄 발사 프로토콜
    function applyAdminInlineChange(adminId, adminName, selectedRole) {
        if(event) event.preventDefault();
        
        if(confirm("👑 [사령부 권한 고속 통제]\n" + adminName + " 관리자의 직무 권한을 [" + selectedRole + "](으)로 즉시 변경하시겠습니까?")) {
            location.href = "${pageContext.request.contextPath}/admin/changeAdminRole?adminId=" + adminId + "&role=" + selectedRole;
        }
    }

    // ❌ 관리자 영구 제명 프로토콜
    function fireConfirm(adminId, adminName) {
        if(confirm("🚨 [관리자 영구 제명]\n정말 " + adminName + " 님을 사령부 직무에서 영구 해임하시겠습니까?")) {
            location.href = "${pageContext.request.contextPath}/admin/fireAdmin?adminId=" + adminId;
        }
    }

    // 🪐 모달 빽드롭 차단 격파 및 최상위 래핑
    document.addEventListener("DOMContentLoaded", function() {
        var myModal = document.getElementById('adminRegisterModal');
        if (myModal) {
            myModal.addEventListener('show.bs.modal', function () {
                document.body.appendChild(myModal);
            });
        }

        var wideContainer = document.querySelector('.admin-wide-container');
        if (wideContainer) {
            var parent = wideContainer.parentElement;
            
            while (parent && parent.tagName !== 'BODY') {
                parent.style.maxWidth = '100%';
                parent.style.width = '100%';
                
                if(parent.classList.contains('form-container') || parent.className.includes('container')) {
                    parent.style.maxWidth = '1400px'; 
                    parent.style.margin = '0 auto';
                }
                
                parent = parent.parentElement;
            }
        }
    });
</script>