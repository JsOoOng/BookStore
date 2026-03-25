<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="form-container">
    <h2 class="text-center mb-5 fw-bold" style="color: #5d5fef;">🚀 신규 행성 탐색 (도서 등록)</h2>
    
    <form id="bookForm" action="${pageContext.request.contextPath}/book/insert" method="POST">
        
        <div class="input-group-cosmic">
            <label for="title">도서명</label>
            <input type="text" id="title" name="title" placeholder="탐사할 행성의 이름을 지어주세요" required>
        </div>

        <div class="input-group-cosmic">
            <label for="writer">저자</label>
            <input type="text" id="writer" name="writer" placeholder="지식의 개척자(저자)를 입력하세요" required>
        </div>

        <!-- 🔥 추가: 출판사 -->
        <div class="input-group-cosmic">
            <label for="publisher">출판사</label>
            <input type="text" id="publisher" name="publisher" placeholder="출판사를 입력하세요" required>
        </div>

        <!-- 🔥 추가: ISBN -->
        <div class="input-group-cosmic">
            <label for="isbn">ISBN</label>
            <input type="text" id="isbn" name="isbn" placeholder="ISBN 번호를 입력하세요" required>
        </div>

        <div class="input-group-cosmic">
            <label for="price">탐사 비용 (가격)</label>
            <input type="number" id="price" name="price" placeholder="숫자만 입력하세요" required>
        </div>

        <!-- 🔥 추가: 장르 선택 -->
        <div class="input-group-cosmic">
            <label for="genre">장르</label>
            <select id="genre" name="genre" required>
                <option value="">장르 선택</option>
                <option value="공학">공학</option>
                <option value="기술">기술</option>
                <option value="물리">물리</option>
                <option value="법률">법률</option>
                <option value="생물">생물</option>
                <option value="안전">안전</option>
                <option value="에세이">에세이</option>
                <option value="여행">여행</option>
                <option value="역사">역사</option>
                <option value="요리">요리</option>
                <option value="자연">자연</option>
                <option value="철학">철학</option>
                <option value="학술">학술</option>
                <option value="항해">항해</option>
                <option value="기타">기타</option>
            </select>
        </div>

        <div class="input-group-cosmic">
            <label for="content">행성 상세 기록 (요약)</label>
            <textarea id="content" name="content" rows="5" placeholder="책의 핵심적인 지식을 기록해 주세요"></textarea>
        </div>

        <div class="input-group-cosmic">
            <label for="image">데이터 칩 이미지 (URL)</label>
            <input type="text" id="image" name="image" placeholder="https:// 이미지 주소를 입력하세요" required>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn-confirm">지식 베이스에 추가</button>
            <button type="button" class="btn-cancel" onclick="location.href='${pageContext.request.contextPath}/book/list'">탐사 취소</button>
        </div>
    </form>
</div>