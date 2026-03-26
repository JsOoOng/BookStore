<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">

<div class="container mt-4">
    <h1>${loginMember.name}대원님의 장바구니</h1>
    
      <!-- 홈 버튼 -->
    <div class="mt-4">
        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">
            🏠 홈으로 돌아가기
        </a>
    </div>

    <form action="${pageContext.request.contextPath}/busket/delete" method="post" id="deleteForm">
    
     <!-- 상단 버튼 -->
        <div class="d-flex justify-content-between mt-3">

            <!-- 선택 삭제 -->
            <button type="submit"
                    class="btn btn-danger"
                    onclick="return checkDelete();">
                선택 삭제
            </button>

            <!-- 선택 구매 -->
            <button type="button"
                    class="btn btn-primary"
                    id="buyBtn">
                선택 구매
            </button>

        </div>
        
        <table class="table table-striped mt-3">
            <thead>
                <tr>
                    <th><input type="checkbox" id="selectAll"></th>
                    <th>책 표지</th>
                    <th>제목</th>
                    <th>작가</th>
                    <th>수량</th>
                    <th>가격</th>
                    <th>개별 삭제</th>
                    <th>개별 구매</th>
                </tr>
            </thead>

            <tbody>
                <c:forEach var="vo" items="${busketList}">
                    <tr>
                        <!-- 체크박스 -->
                        <td>
                            <input type="checkbox" name="ids" value="${vo.busketId}" class="selectItem">
                        </td>

                        <!-- 이미지 -->
                        <td>
                            <img src="${vo.image}" style="width:60px;">
                        </td>

                        <td>${vo.title}</td>
                        <td>${vo.writer}</td>

                        <!-- 수량 -->
                        <td>
                            <input type="number"
                                   value="${vo.quantity}"
                                   min="1"
                                   class="quantity"
                                   data-price="${vo.price}">
                        </td>

                        <!-- 총 가격 -->
                        <td class="totalPrice">
                            <fmt:formatNumber value="${vo.quantity * vo.price}" pattern="#,###"/>
                        </td>

                        <!-- 개별 삭제 -->
                        <td>
                            <button type="button"
                                    class="btn btn-sm btn-danger"
                                    onclick="deleteOne(${vo.busketId})">
                                삭제
                            </button>
                        </td>

                        <!-- 개별 구매 -->
                        <td>
                            <button type="button"
                                    class="btn btn-sm btn-success"
                                    onclick="location.href='${pageContext.request.contextPath}/busket/buy?busketIds=${vo.busketId}'">
                                구매
                            </button>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

       
    </form>

  
</div>

<!-- ================= JS ================= -->

<script>
// 전체 선택
document.getElementById('selectAll').addEventListener('change', function() {
    document.querySelectorAll('.selectItem').forEach(cb => cb.checked = this.checked);
});

// 선택 구매
document.getElementById('buyBtn').addEventListener('click', function() {
    let selected = Array.from(document.querySelectorAll('.selectItem:checked'))
                        .map(cb => cb.value)
                        .join(',');

    if(selected.length === 0){
        alert("선택된 항목이 없습니다.");
        return;
    }

    location.href = "${pageContext.request.contextPath}/busket/buy?busketIds=" + selected;
});

// 개별 삭제
function deleteOne(id) {
    if (!confirm('정말 삭제하시겠습니까?')) return;

    const form = document.getElementById('deleteForm');

    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'busketId';
    input.value = id;

    form.appendChild(input);
    form.submit();
}

// 선택 삭제
function checkDelete() {
    const checked = document.querySelectorAll('input[name="ids"]:checked');

    if (checked.length === 0) {
        alert('삭제할 항목을 선택하세요.');
        return false;
    }

    return confirm('선택한 항목을 삭제하시겠습니까?');
}

// 수량 변경 시 가격 변경
document.querySelectorAll('.quantity').forEach(input => {
    input.addEventListener('input', function() {
        const price = parseInt(this.dataset.price);
        const quantity = parseInt(this.value);

        const total = price * quantity;

        const row = this.closest('tr');
        const totalCell = row.querySelector('.totalPrice');

        totalCell.innerText = total.toLocaleString();
    });
});
</script>