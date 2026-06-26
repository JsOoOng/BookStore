<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="admin-sales-page vendor-sales-page">

    <div class="admin-sales-header">
        <div>
            <h2>📊 협력업체 판매 매출 통계</h2>
            <p>로그인한 협력업체의 실제 주문 데이터를 기준으로 판매 매출과 판매 수량을 확인합니다.</p>
        </div>
    </div>

    <!-- 검색 조건 -->
    <div class="admin-sales-filter-card">

        <div class="admin-sales-filter-group">
            <label>시작일</label>
            <input type="date" id="startDate">
        </div>

        <div class="admin-sales-filter-group">
            <label>종료일</label>
            <input type="date" id="endDate">
        </div>

        <div class="admin-sales-filter-group">
            <label>통계 단위</label>
            <select id="periodSelect">
                <option value="day">일별</option>
                <option value="week">주별</option>
                <option value="month">월별</option>
                <option value="year">연별</option>
            </select>
        </div>

        <div class="admin-sales-filter-group">
            <label>그래프 기준</label>
            <select id="metricSelect">
                <option value="totalRevenue">매출액</option>
                <option value="orderCount">주문 건 수</option>
                <option value="totalBookQty">판매 책 수</option>
            </select>
        </div>

        <button type="button" class="admin-sales-search-btn" onclick="loadVendorSalesDashboard()">
            조회
        </button>

    </div>

    <!-- 상단 요약 카드 -->
    <div class="admin-sales-summary-grid vendor-sales-summary-grid">

        <div class="admin-sales-summary-card">
            <span class="summary-label">전체 매출액</span>
            <strong id="totalRevenue">0원</strong>
        </div>

        <div class="admin-sales-summary-card">
            <span class="summary-label">전체 주문 건 수</span>
            <strong id="orderCount">0건</strong>
        </div>

        <div class="admin-sales-summary-card">
            <span class="summary-label">전체 판매 책 수</span>
            <strong id="totalBookQty">0권</strong>
        </div>

        <div class="admin-sales-summary-card">
            <span class="summary-label">판매 상품 종류 수</span>
            <strong id="productTypeCount">0종</strong>
        </div>

        <div class="admin-sales-summary-card">
            <span class="summary-label">평균 주문 금액</span>
            <strong id="avgOrderPrice">0원</strong>
        </div>

    </div>

    <!-- 그래프 -->
    <div class="admin-sales-chart-card">
        <div class="admin-sales-section-title">
            <h3>📈 기간별 판매 통계 그래프</h3>
            <p id="chartDescription">선택한 기간의 매출 흐름을 확인합니다.</p>
        </div>

        <div class="admin-sales-chart-area">
            <canvas id="vendorSalesChart"></canvas>
        </div>

        <p id="chartEmptyMessage" class="admin-sales-empty" style="display:none;">
            표시할 통계 데이터가 없습니다.
        </p>
    </div>

    <!-- 특정 기간 판매 상품 목록 -->
    <div class="admin-sales-table-card">
        <div class="admin-sales-section-title">
            <h3>📚 특정 기간 판매 상품 목록</h3>
            <p>선택한 기간 동안 실제로 판매된 내 상품만 표시합니다.</p>
        </div>

        <div class="admin-sales-table-wrap">
            <table class="admin-sales-table">
                <thead>
                    <tr>
					    <th>판매날짜</th>
					    <th>판매상품번호</th>
					    <th>도서번호</th>
					    <th>도서명</th>
					    <th>판매 수량</th>
					    <th>매출액</th>
					    <th>주문 건 수</th>
					</tr>
                </thead>
                <tbody id="soldProductBody">
                    <tr>
                        <td colspan="7" class="admin-sales-empty-cell">
                            조회된 판매 상품이 없습니다.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    let vendorSalesChart = null;

    const moneyFormatter = new Intl.NumberFormat('ko-KR');
    const numberFormatter = new Intl.NumberFormat('ko-KR');

    document.addEventListener("DOMContentLoaded", async function () {
        setDefaultDates();
        await loadVendorSalesDashboard();
    });

    function setDefaultDates() {
        const today = new Date();
        const endDate = today.toISOString().slice(0, 10);

        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        const startDate = firstDay.toISOString().slice(0, 10);

        document.getElementById("startDate").value = startDate;
        document.getElementById("endDate").value = endDate;
    }

    async function loadVendorSalesDashboard() {
        const startDate = document.getElementById("startDate").value;
        const endDate = document.getElementById("endDate").value;
        const period = document.getElementById("periodSelect").value;

        if (!startDate || !endDate) {
            alert("시작일과 종료일을 선택하세요.");
            return;
        }

        if (startDate > endDate) {
            alert("시작일은 종료일보다 늦을 수 없습니다.");
            return;
        }

        try {
            await loadSummary(startDate, endDate);
            await loadTrend(period, startDate, endDate);
            await loadSoldProducts(startDate, endDate);
        } catch (error) {
            console.error(error);
            alert("판매 통계 데이터를 불러오지 못했습니다. 콘솔과 서버 로그를 확인하세요.");
        }
    }

    async function loadSummary(startDate, endDate) {
        const url = contextPath
            + "/vendor/purchase/salesvolume/summary"
            + "?startDate=" + encodeURIComponent(startDate)
            + "&endDate=" + encodeURIComponent(endDate);

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error("요약 통계 API 오류: " + response.status);
        }

        const data = await response.json();

        document.getElementById("totalRevenue").textContent =
            moneyFormatter.format(data.totalRevenue || 0) + "원";

        document.getElementById("orderCount").textContent =
            numberFormatter.format(data.orderCount || 0) + "건";

        document.getElementById("totalBookQty").textContent =
            numberFormatter.format(data.totalBookQty || 0) + "권";

        document.getElementById("productTypeCount").textContent =
            numberFormatter.format(data.productTypeCount || 0) + "종";

        document.getElementById("avgOrderPrice").textContent =
            moneyFormatter.format(data.avgOrderPrice || 0) + "원";
    }

    async function loadTrend(period, startDate, endDate) {
        const url = contextPath
            + "/vendor/purchase/salesvolume/trend"
            + "?period=" + encodeURIComponent(period)
            + "&startDate=" + encodeURIComponent(startDate)
            + "&endDate=" + encodeURIComponent(endDate);

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error("그래프 통계 API 오류: " + response.status);
        }

        const data = await response.json();
        renderChart(data);
    }

    function renderChart(data) {
        const metric = document.getElementById("metricSelect").value;
        const metricInfo = getMetricInfo(metric);
        const emptyMessage = document.getElementById("chartEmptyMessage");

        if (!data || data.length === 0) {
            emptyMessage.style.display = "block";
            destroyChart();
            return;
        }

        emptyMessage.style.display = "none";

        const labels = data.map(item => item.label);
        const values = data.map(item => item[metric] || 0);

        document.getElementById("chartDescription").textContent =
            "선택한 기간의 " + metricInfo.label + " 흐름을 확인합니다.";

        destroyChart();

        const ctx = document.getElementById("vendorSalesChart").getContext("2d");

        vendorSalesChart = new Chart(ctx, {
            type: "bar",
            data: {
                labels: labels,
                datasets: [{
                    label: metricInfo.label,
                    data: values,
                    borderWidth: 2,
                    borderRadius: 8
                }]
            },
            options: getChartOptions(metric, metricInfo)
        });
    }

    function getChartOptions(metric, metricInfo) {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return metricInfo.label + ": " + formatMetricValue(metric, context.raw);
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        precision: 0,
                        callback: function(value) {
                            return formatMetricValue(metric, value);
                        }
                    }
                }
            }
        };
    }

    function destroyChart() {
        if (vendorSalesChart !== null) {
            vendorSalesChart.destroy();
            vendorSalesChart = null;
        }
    }

    function getMetricInfo(metric) {
        if (metric === "totalRevenue") {
            return { label: "매출액" };
        }

        if (metric === "orderCount") {
            return { label: "주문 건 수" };
        }

        if (metric === "totalBookQty") {
            return { label: "판매 책 수" };
        }

        return { label: "통계" };
    }

    function formatMetricValue(metric, value) {
        const formatted = numberFormatter.format(value || 0);

        if (metric === "totalRevenue") {
            return formatted + "원";
        }

        if (metric === "orderCount") {
            return formatted + "건";
        }

        if (metric === "totalBookQty") {
            return formatted + "권";
        }

        return formatted;
    }

    async function loadSoldProducts(startDate, endDate) {
        const url = contextPath
            + "/vendor/purchase/salesvolume/products"
            + "?startDate=" + encodeURIComponent(startDate)
            + "&endDate=" + encodeURIComponent(endDate);

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error("판매 상품 목록 API 오류: " + response.status);
        }

        const data = await response.json();
        renderSoldProducts(data);
    }

    function renderSoldProducts(data) {
        const tbody = document.getElementById("soldProductBody");
        tbody.innerHTML = "";

        if (!data || data.length === 0) {
            tbody.innerHTML =
                '<tr><td colspan="7" class="admin-sales-empty-cell">조회된 판매 상품이 없습니다.</td></tr>';
            return;
        }

        data.forEach(item => {
            const tr = document.createElement("tr");

            tr.innerHTML =
                "<td>" + escapeHtml(item.saleDate || "") + "</td>" +
                "<td>" + item.saleId + "</td>" +
                "<td>" + item.bookId + "</td>" +
                "<td class='book-title-cell'>" + escapeHtml(item.bookTitle || "") + "</td>" +
                "<td>" + numberFormatter.format(item.totalQty || 0) + "권</td>" +
                "<td>" + moneyFormatter.format(item.totalRevenue || 0) + "원</td>" +
                "<td>" + numberFormatter.format(item.orderCount || 0) + "건</td>";

            tbody.appendChild(tr);
        });
    }

    function escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    document.getElementById("metricSelect").addEventListener("change", function () {
        const startDate = document.getElementById("startDate").value;
        const endDate = document.getElementById("endDate").value;
        const period = document.getElementById("periodSelect").value;

        loadTrend(period, startDate, endDate);
    });

    document.getElementById("periodSelect").addEventListener("change", function () {
        const startDate = document.getElementById("startDate").value;
        const endDate = document.getElementById("endDate").value;
        const period = document.getElementById("periodSelect").value;

        loadTrend(period, startDate, endDate);
    });
</script>