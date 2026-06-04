<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="form-container">
    <div class="update-header">
        <img src="${book.image}" alt="Current Cover" onerror="this.src='https://via.placeholder.com/120x170?text=No+Image'">
        <h2 class="fw-bold" style="color: #5d5fef;">🛰️ 데이터 동기화 (수정)</h2>
    </div>

    <form action="${pageContext.request.contextPath}/book/update" method="POST">
        <div class="input-group-cosmic">
            <label>행성 고유 식별 ID</label>
            <input type="text" name="id" value="${book.id}" readonly>
        </div>

        <div class="input-group-cosmic">
            <label>도서 제목</label>
            <input type="text" name="title" value="${book.title}" required>
        </div>

        <div class="input-group-cosmic">
            <label>저자 명</label>
            <input type="text" name="writer" value="${book.writer}" required>
        </div>

        <div class="row">
            <div class="col-md-6 input-group-cosmic">
                <label>출판사</label>
                <input type="text" name="publisher" value="${book.publisher}">
            </div>
            <div class="col-md-6 input-group-cosmic">
                <label>ISBN (우주 식별 번호)</label>
                <input type="text" name="isbn" value="${book.isbn}">
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 input-group-cosmic">
                <label>장르 (은하계)</label>
                <input type="text" name="genre" value="${book.genre}">
            </div>
            <div class="col-md-6 input-group-cosmic">
                <label>최초 출판 우주 시기 (출판일)</label>
                <input type="date" name="pubDate" value="${book.pubDate}" required>
            </div>
        </div>

        <div class="input-group-cosmic">
            <label for="language">기록 언어</label>
            <select id="language" name="language" required>
                <option value="Korean" ${book.language eq 'Korean' ? 'selected' : ''}>Korean</option>
                <option value="English" ${book.language eq 'English' ? 'selected' : ''}>English</option>
                <option value="Japanese" ${book.language eq 'Japanese' ? 'selected' : ''}>Japanese</option>
                <option value="Chinese" ${book.language eq 'Chinese' ? 'selected' : ''}>Chinese</option>
                <option value="German" ${book.language eq 'German' ? 'selected' : ''}>German</option>
                <option value="French" ${book.language eq 'French' ? 'selected' : ''}>French</option>
            </select>
        </div>

        <div class="input-group-cosmic">
            <label>데이터 칩 이미지 (URL)</label>
            <input type="text" name="image" value="${book.image}">
        </div>

        <div class="form-actions">
            <button type="submit" class="btn-confirm">동기화 사항 반영</button>
            <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/book/view?id=${book.id}'">동기화 중단</button>
        </div>
    </form>
</div>