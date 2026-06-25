<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="navbar navbar-expand-lg navbar-light bg-white navbar-cosmic sticky-top">
    <div class="container-fluid px-4">
        <a class="logo-text" href="${pageContext.request.contextPath}/">cosmic library</a>
        
        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#cosmicNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="cosmicNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 align-items-center">
                <li class="nav-item">
                    <a class="nav-link fw-bold text-dark" href="${pageContext.request.contextPath}/book/list">도서목록</a>
                </li>
                <li class="nav-item">
                    <%-- 💥 상단 바의 링크를 누르거나 우측 하단 챗 버튼을 누르거나 동일하게 작동하도록 일원화 가능 --%>
                    <a class="nav-link fw-bold text-dark" href="javascript:void(0);" onclick="toggleCosmicPanel()">
                        실시간 상담 <span id="chatAlarmBadge" class="badge bg-danger ms-1" style="display:none; font-size: 0.65rem;">New</span>
                    </a>
                </li>

                <c:if test="${not empty sessionScope.loginAdmin}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle fw-bold text-dark" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            사령부 메뉴
                        </a>
                        <ul class="dropdown-menu shadow-sm border-0" aria-labelledby="adminDropdown">
                            <c:if test="${sessionScope.loginAdmin.role eq 'SUPER'}">
                                <li><a class="dropdown-item fw-bold text-danger" href="${pageContext.request.contextPath}/admin/userControl">대원 통제 센터</a></li>
                                <li><a class="dropdown-item fw-bold text-secondary" href="${pageContext.request.contextPath}/admin/adminControl">사령부 관리 패널</a></li>
                                <li><hr class="dropdown-divider"></li>
                            </c:if>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/inquiries">📨 문의 사항 확인</a></li>
                            <c:if test="${sessionScope.loginAdmin.role eq 'SUPER' or sessionScope.loginAdmin.role eq 'BOOK_ADMIN'}">
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item fw-bold text-primary" href="${pageContext.request.contextPath}/book/insert">➕ 신규 도서 추가</a></li>
                            </c:if>
                        </ul>
                    </li>
                </c:if>
            </ul>

            <div class="search-naver-wrapper mx-auto">
                <form action="${pageContext.request.contextPath}/book/find" method="get" class="search-frame-naver">
                    <input type="text" name="title" class="input-naver shadow-none" placeholder="지식 탐험..." autocomplete="off" aria-label="Search">
                    <button class="btn-search-nav" type="submit">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>
                    </button>
                </form>
            </div>
            
            <ul class="navbar-nav ms-auto align-items-center">
                <c:choose>
                    <c:when test="${not empty sessionScope.loginAdmin}">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold" href="#" id="adminProfileDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false" style="color: #ff4757;">
                                🛡️ ${sessionScope.loginAdmin.adminName} [${sessionScope.loginAdmin.role}]
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="adminProfileDropdown">
                                <c:if test="${sessionScope.loginAdmin.role eq 'SUPER'}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/userControl">통제 패널</a></li>
                                </c:if>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger fw-bold" href="${pageContext.request.contextPath}/member/logout">사령부 로그아웃</a></li>
                            </ul>
                        </li>
                    </c:when>
            
                    <c:when test="${not empty sessionScope.loginMember}">
                        <li class="nav-item me-2">
                            <a class="nav-link fw-bold text-dark" href="${pageContext.request.contextPath}/basket">🛒 장바구니</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold text-dark" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                ${sessionScope.loginMember.name} 대원님
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="userDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/member/mypage">마이페이지</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger fw-bold" href="${pageContext.request.contextPath}/member/logout">로그아웃</a></li>
                            </ul>
                        </li>
                    </c:when>
            
                    <c:when test="${not empty sessionScope.loginVendor}">
                        <li class="nav-item me-2">
                            <a class="nav-link fw-bold text-primary" href="${pageContext.request.contextPath}/vendor/dashboard">🚀 파트너 대시보드</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold text-dark" href="#" id="vendorDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                ${sessionScope.loginVendor.bizName}
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="vendorDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vendor/dashboard">물류 관리소</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger fw-bold" href="${pageContext.request.contextPath}/vendor/logout">로그아웃</a></li>
                            </ul>
                        </li>
                    </c:when>
            
                    <c:otherwise>
						<li class="nav-item">
						    <c:choose>
						        <c:when test="${not empty sessionScope.loginMember}">
						            <a class="nav-link fw-bold text-dark px-3" href="${pageContext.request.contextPath}/basket">장바구니</a>
						        </c:when>
						        <c:otherwise>
						            <a class="nav-link fw-bold text-dark px-3" href="${pageContext.request.contextPath}/cookie/basket/list">장바구니</a>
						        </c:otherwise>
						    </c:choose>
						</li>
                        <li class="nav-item">
                            <a class="nav-link fw-bold text-dark px-3" href="${pageContext.request.contextPath}/member/login">로그인</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle fw-bold text-dark px-3" href="#" id="joinDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">회원가입</a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0" aria-labelledby="joinDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/member/join">👨‍🚀 일반 대원 가입</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vendor/join">🏢 파트너사 입점 신청</a></li>
                            </ul>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<style>
    .dropdown-menu.cosmic-force-show { display: block !important; animation: cosmicDrop 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
    @keyframes cosmicDrop { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
</style>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
        dropdownToggles.forEach(toggle => {
            toggle.addEventListener('click', function(e) {
                e.preventDefault(); e.stopPropagation();
                const menu = this.nextElementSibling;
                if (menu && menu.classList.contains('dropdown-menu')) {
                    const isShowing = menu.classList.contains('cosmic-force-show');
                    document.querySelectorAll('.dropdown-menu.cosmic-force-show').forEach(m => { m.classList.remove('cosmic-force-show'); });
                    if (!isShowing) { menu.classList.add('cosmic-force-show'); }
                }
            });
        });
        document.addEventListener('click', function(e) {
            if (!e.target.matches('.dropdown-toggle')) {
                document.querySelectorAll('.dropdown-menu.cosmic-force-show').forEach(m => { m.classList.remove('cosmic-force-show'); });
            }
        });
    });
</script>