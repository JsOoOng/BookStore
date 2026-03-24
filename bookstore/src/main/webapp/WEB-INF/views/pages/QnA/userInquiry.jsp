<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="form-container" style="max-width: 650px; margin-top: 50px;">
    <div class="text-center mb-5">
        <h1 style="font-size: 3rem;">📡</h1>
        <h2 class="fw-bold" style="color: #5d5fef;">Cosmic Inquiry</h2>
        <p class="text-muted">문의 사항을 남겨주시면 모든 사령관(Admin)이 검토 후 답변해 드립니다.</p>
    </div>

    <form action="${pageContext.request.contextPath}/user/submitInquiry" method="post" class="cosmic-form">
        <input type="hidden" name="mail" value="${sessionScope.loginMember.id}" />

        <div class="input-group-cosmic">
            <label>문의 제목 <span class="text-danger">*</span></label>
            <input type="text" name="title" placeholder="간결하고 명확한 제목을 입력하세요" required />
        </div>

        <div class="input-group-cosmic mt-3">
            <label>문의 종류</label>
            <select name="inquiry" class="form-select border-0 shadow-sm" style="border-radius: 12px; padding: 12px;">
                <option value="책에 대해서">📚 도서 관련</option>
                <option value="배달 관련">🛸 배송/수령</option>
                <option value="계정/보안">🛡️ 계정/보안</option>
                <option value="기타">🛰️ 기타 문의</option>
            </select>
        </div>

        <div class="input-group-cosmic mt-3">
            <label>문의 상세 내용 <span class="text-danger">*</span></label>
            <textarea name="detail" rows="6" placeholder="사령관들에게 전달할 내용을 자세히 적어주세요." required></textarea>
        </div>

        <div class="mt-4">
            <button type="submit" class="btn-confirm w-100 shadow-lg">신호 전송 (Send Inquiry)</button>
        </div>
    </form>
</div>