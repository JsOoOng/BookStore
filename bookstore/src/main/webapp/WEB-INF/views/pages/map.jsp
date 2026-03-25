<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<div class="form-container">
    <h2 class="text-center mb-5 fw-bold" style="color: #5d5fef;">
        📍 우주 도서관 위치 안내
    </h2>

    <!-- 지도 영역 -->
    <div class="map-container">
    <!-- https://www.google.com/maps?q=원하는주소&output=embed -->
    <iframe 
        src="https://www.google.com/maps?q=서울특별시 중랑구 서일대학교&output=embed"
        width="100%" 
        height="450" 
        style="border:0; border-radius:20px;"
        allowfullscreen 
        loading="lazy">
    </iframe>
</div>

    <!-- 주소 정보 -->
    <div class="location-info">
        <h4>🚀 본부 위치</h4>
        <p>서울특별시 중랑구 서일대학교</p>
        <p>지식 탐사를 위한 우주 도서관입니다.</p>
    </div>

    <!-- 버튼 -->
    <div class="form-actions">
        <button class="btn-confirm"
            onclick="window.open('https://www.google.com/maps?q=서울특별시 중랑구 서일대학교')">
            길찾기 (Google Maps)
        </button>

        <button class="btn-cancel"
            onclick="location.href='${pageContext.request.contextPath}/book/list'">
            돌아가기
        </button>
    </div>
</div>