<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="admin-wide-container mt-4">
    
    <%-- 🚀 레이아웃 상단 통제 헤더 구역 --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold" style="color: #ff4757; margin-bottom: 5px;">👑 사령부 고위 관리자 제어 패널</h2>
            <p class="text-muted mb-0">테이블 헤더의 직무 필터로 분류하고, 관리자 배지를 클릭하여 권한을 즉시 제어합니다.</p>
        </div>
        
        <button class="btn btn-danger rounded-pill px-4 fw-bold shadow-lg" data-bs-toggle="modal" data-bs-target="#adminRegisterModal" style="white-space: nowrap;">
            ➕ 신규 관리자 임명
        </button>
    </div>

    <%-- 🎉 사령부 액션 피드백 알림 배너 --%>
    <c:if test="${param.regSuccess eq 'true'}">
        <div class="alert alert-success border-0 mb-4 text-center rounded-pill fw-bold shadow-sm" style="background: rgba(46, 213, 115, 0.1); color: #2ed573;">
            🎉 신규 사령부 관리자 임명 령이 성공적으로 데이터베이스에 하달되었습니다!
        </div>
    </c:if>
    <c:if test="${param.error eq 'self_mutation_blocked'}">
        <div class="alert alert-warning border-0 mb-4 text-center rounded-pill fw-bold shadow-sm" style="background: rgba(255, 165, 0, 0.1); color: #ffa500;">
            ⚠️ 프로토콜 오류: 최고 사령관 본인의 권한은 스스로 변경할 수 없습니다.
        </div>
    </c:if>

    <%-- 📊 관리자 관제 데이터 테이블 카드 구역 --%>
    <div class="main-content p-0 border-0 admin-table-card">
        <table class="table table-hover admin-table mb-0 align-middle text-center">
            <thead class="table-dark">
                <tr>
                    <th class="py-3" style="width: 15%; border-top-left-radius: 20px;">관리자 고유 ID</th>
                    <th style="width: 15%;">관리자 호칭</th>
                    <th style="width: 18%;">임명 일자</th>
                    
                    <%-- 🌟 테이블 헤더 내장형 드롭다운 필터 (디폴트: 전체보기) --%>
                    <th style="width: 34%;">
                        <div class="dropdown d-inline-block">
                            <span class="dropdown-toggle text-warning fw-bold" id="tableHeaderFilterBtn" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer; font-size: 1rem;">
                                🛡️ 현재 직무 (필터: 전체보기)
                            </span>
                            <ul class="dropdown-menu dropdown-menu-dark shadow" aria-labelledby="tableHeaderFilterBtn" style="border-radius: 12px;">
                                <li><a class="dropdown-item active filter-item" href="#" onclick="filterAdminRole('ALL', '전체보기')">🌐 전체 보기 (디폴트)</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('SUPER', '최고 사령관')">🛡️ 최고 사령관 (SUPER)</a></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('BOOK_ADMIN', '도서 관리자')">📚 도서 관리자 (BOOK)</a></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('MEMBER_ADMIN', '대원 관리자')">👥 대원 관리자 (MEMBER)</a></li>
                                <li><a class="dropdown-item filter-item" href="#" onclick="filterAdminRole('VENDOR_ADMIN', '기업 관리자')">🏢 기업 관리자 (VENDOR)</a></li>
                            </ul>
                        </div>
                    </th>
                    
                    <th style="width: 18%; border-top-right-radius: 20px;">조치 프로토콜</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="a" items="${adminList}">
                    <tr class="admin-row" data-role="${a.role}">
                        <td class="fw-bold text-dark">${a.adminId}</td>
                        <td class="text-secondary">${a.adminName}</td>
                        <td class="text-muted"><fmt:formatDate value="${a.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                        
                        <%-- 🎭 현재 직무 변경 인라인 드롭다운 배지 부역 --%>
                        <td>
                            <c:choose>
                                <%-- CASE 1: 타인 계정인 경우 변경 인라인 드롭다운 가동 --%>
                                <c:when test="${a.adminId ne sessionScope.loginAdmin.adminId}">
                                    <div class="dropdown d-inline-block">
                                        
                                        <c:choose>
                                            <c:when test="${a.role eq 'SUPER'}">
                                                <button class="btn btn-sm dropdown-toggle rounded-pill px-3 fw-bold shadow-sm text-white" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="background-color: #ff4757;">🛡️ 최고 사령관 (SUPER)</button>
                                            </c:when>
                                            <c:when test="${a.role eq 'BOOK_ADMIN'}">
                                                <button class="btn btn-sm dropdown-toggle rounded-pill px-3 fw-bold shadow-sm text-white" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="background-color: #5d5fef;">📚 도서 관리 (BOOK)</button>
                                            </c:when>
                                            <c:when test="${a.role eq 'MEMBER_ADMIN'}">
                                                <button class="btn btn-sm dropdown-toggle rounded-pill px-3 fw-bold shadow-sm text-white" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="background-color: #2ed573;">👥 대원 관리 (MEMBER)</button>
                                            </c:when>
                                            <c:when test="${a.role eq 'VENDOR_ADMIN'}">
                                                <button class="btn btn-sm dropdown-toggle rounded-pill px-3 fw-bold shadow-sm text-white" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="background-color: #ffa500;">🏢 기업 관리 (VENDOR)</button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-sm dropdown-toggle rounded-pill px-3 fw-bold shadow-sm bg-secondary text-white" type="button" data-bs-toggle="dropdown" aria-expanded="false">${a.role}</button>
                                            </c:otherwise>
                                        </c:choose>

                                        <ul class="dropdown-menu dropdown-menu-dark shadow" style="border-radius: 10px;">
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'SUPER')">🛡️ 최고 사령관 (SUPER)</a></li>
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'BOOK_ADMIN')">📚 도서 관리자 (BOOK)</a></li>
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'MEMBER_ADMIN')">👥 대원 관리자 (MEMBER)</a></li>
                                            <li><a class="dropdown-item small" href="#" onclick="applyAdminInlineChange('${a.adminId}', '${a.adminName}', 'VENDOR_ADMIN')">🏢 기업 관리자 (VENDOR)</a></li>
                                        </ul>
                                    </div>
                                </c:when>
                                
                                <%-- CASE 2: 사령관 자기 자신 계정 보호 --%>
                                <c:otherwise>
                                    <span class="badge rounded-pill bg-danger px-3 shadow-sm" style="font-size: 0.85rem; padding-top: 6px; padding-bottom: 6px;">
                                        🛡️ 최고 사령관 (SUPER)
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        
                        <%-- 🚫 조치 기능 부역 --%>
                        <td>
                            <c:choose>
                                <c:when test="${a.adminId ne sessionScope.loginAdmin.adminId}">
                                    <button class="btn btn-sm btn-outline-dark fw-bold px-3" style="border-radius: 10px; font-size: 0.8rem;" 
                                            onclick="fireConfirm('${a.adminId}', '${a.adminName}')">🚫 영구 해임</button>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted small fw-bold">⚙️ 변경 불가</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="adminRegisterModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content text-white" style="background: #2b2b36; border-radius: 20px; border: 1px solid rgba(255,71,87,0.2);">
            <div class="modal-header border-secondary">
                <h5 class="modal-title fw-bold text-danger">🛰️ 신규 기지 관리자 임명 명 발령</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/registerAdmin" method="POST" autocomplete="off">
                <div class="modal-body admin-theme">
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">고유 식별 ID</label>
                        <input type="text" name="adminId" class="form-control bg-dark text-white border-secondary" placeholder="접속에 사용할 고유 ID 입력" required style="border-radius: 10px;">
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">초기 보안 코드 (PW)</label>
                        <input type="password" name="adminPw" class="form-control bg-dark text-white border-secondary" placeholder="초기 접속 비밀번호 입력" required style="border-radius: 10px;">
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">관리자 성명 / 관제명</label>
                        <input type="text" name="adminName" class="form-control bg-dark text-white border-secondary" placeholder="예: 홍길동 대위" required style="border-radius: 10px;">
                    </div>
                    <div class="mb-2">
                        <label class="form-label text-muted small fw-bold">할당할 전문 직무(Role)</label>
                        <select name="role" class="form-select bg-dark text-white border-secondary" style="border-radius: 10px;">
                            <option value="BOOK_ADMIN">도서 관리자 (BOOK_ADMIN)</option>
                            <option value="MEMBER_ADMIN">대원 관리자 (MEMBER_ADMIN)</option>
                            <option value="VENDOR_ADMIN">기업 관리자 (VENDOR_ADMIN)</option>
                            <option value="SUPER">최고 사령관 (SUPER)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-top-0 d-flex gap-2">
                    <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">조율 취소</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4 fw-bold">임명장 발령 (Insert)</button>
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
    // 🪐 [하얀 박스 가두리 격파 치트키] 부모 엘리먼트들의 max-width 제약 체계를 원천 파괴
    document.addEventListener("DOMContentLoaded", function() {
        // 1. 모달 빽드롭 탈출 기존 코드 유지
        var myModal = document.getElementById('adminRegisterModal');
        if (myModal) {
            myModal.addEventListener('show.bs.modal', function () {
                document.body.appendChild(myModal);
            });
        }

        // 2. 🔥 [신설] admin-wide-container의 조상(부모) 태그들을 역추적해서 가로폭 강제 개방!
        var wideContainer = document.querySelector('.admin-wide-container');
        if (wideContainer) {
            var parent = wideContainer.parentElement;
            
            // body 태그에 도달할 때까지 위로 올라가며 하얀 박스 성향을 가진 부모들의 빗장을 다 풀어버림
            while (parent && parent.tagName !== 'BODY') {
                // 부모의 클래스나 스타일에 max-width가 걸려있다면 100% 와이드로 강제 변경!
                parent.style.maxWidth = '100%';
                parent.style.width = '100%';
                
                // 만약 부모 엘리먼트 중에 패딩이나 마진 때문에 좁아 보인다면 조율
                if(parent.classList.contains('form-container') || parent.className.includes('container')) {
                    parent.style.maxWidth = '1400px'; // 전체 레이아웃의 상한선 배정
                    parent.style.margin = '0 auto';
                }
                
                parent = parent.parentElement;
            }
        }
    });
</script>