<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="admin-sales-page">

    <div class="admin-sales-header">
        <div>
            <h2>📊 전체 판매 매출 통계</h2>
            <p>SUPER / VENDOR_ADMIN 전용 전체 협력업체 판매 매출 통계입니다.</p>
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
                <option value="productTypeCount">판매 상품 종류 수</option>
            </select>
        </div>

        <div class="admin-sales-filter-group">
            <label>회사 선택</label>
            <select id="vendorSelect">
                <option value="0">전체 회사</option>
            </select>
        </div>

        <div class="admin-sales-filter-group">
            <label>비교 회사</label>
            <select id="compareVendorSelect">
                <option value="0">비교 안 함</option>
            </select>
        </div>

        <button type="button" class="admin-sales-search-btn" onclick="loadAdminSalesDashboard()">
            조회
        </button>

    </div>

    <!-- 상단 요약 카드 -->
    <div class="admin-sales-summary-grid">

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
            <span class="summary-label">참여 협력업체 수</span>
            <strong id="vendorCount">0곳</strong>
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
            <h3>📈 기간별 통계 그래프</h3>
            <p id="chartDescription">선택한 기간의 매출 흐름을 확인합니다.</p>
        </div>

        <div class="admin-sales-chart-area">
            <canvas id="adminSalesChart"></canvas>
        </div>

        <p id="chartEmptyMessage" class="admin-sales-empty" style="display:none;">
            표시할 통계 데이터가 없습니다.
        </p>
    </div>

    <!-- 특정 기간 판매 상품 목록 -->
    <div class="admin-sales-table-card">
        <div class="admin-sales-section-title">
            <h3>📚 특정 기간 판매 상품 목록</h3>
            <p>선택한 기간 동안 실제로 판매된 상품만 표시합니다.</p>
        </div>
        
        <div class="admin-sales-product-vendor-filter">
		    <div class="product-vendor-filter-head">
		        <strong>협력업체 표시</strong>
		        <div class="product-vendor-filter-actions">
		            <button type="button" onclick="checkAllProductVendors(true)">전체 선택</button>
		            <button type="button" onclick="checkAllProductVendors(false)">전체 해제</button>
		        </div>
		    </div>
		
		    <div id="productVendorCheckboxes" class="product-vendor-checkboxes">
		        <span class="product-vendor-empty">판매 상품 데이터를 조회하면 협력업체 필터가 표시됩니다.</span>
		    </div>
		</div>

        <div class="admin-sales-table-wrap">
            <table class="admin-sales-table">
                <thead>
                    <tr>
					    <th>판매날짜</th>
					    <th>판매상품번호</th>
					    <th>도서번호</th>
					    <th>도서명</th>
					    <th>협력업체</th>
					    <th>판매 수량</th>
					    <th>매출액</th>
					    <th>주문 건 수</th>
					</tr>
                </thead>
                <tbody id="soldProductBody">
                    <tr>
                        <td colspan="8" class="admin-sales-empty-cell">
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
    let adminSalesChart = null;
    let allSoldProducts = [];

    const moneyFormatter = new Intl.NumberFormat('ko-KR');
    const numberFormatter = new Intl.NumberFormat('ko-KR');

    document.addEventListener("DOMContentLoaded", async function () {
        setDefaultDates();
        await loadVendorOptions();
        await loadAdminSalesDashboard();
    });

    function setDefaultDates() {
        const today = new Date();
        const endDate = today.toISOString().slice(0, 10);

        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        const startDate = firstDay.toISOString().slice(0, 10);

        document.getElementById("startDate").value = startDate;
        document.getElementById("endDate").value = endDate;
    }

    async function loadVendorOptions() {
        const url = contextPath + "/admin/purchase/salesvolume/vendors";

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error("협력업체 목록 API 오류: " + response.status);
        }

        const data = await response.json();

        console.log("✅ vendor options data =", data);

        const vendorSelect = document.getElementById("vendorSelect");
        const compareVendorSelect = document.getElementById("compareVendorSelect");

        vendorSelect.innerHTML = '<option value="0">전체 회사</option>';
        compareVendorSelect.innerHTML = '<option value="0">비교 안 함</option>';

        data.forEach(vendor => {
            const vendorRegNum = getVendorRegNum(vendor);
            const vendorName = vendor.vendorName || vendor.bizName || vendor.name || "업체명 없음";

            console.log("✅ vendor option:", vendorRegNum, vendorName);

            if (!vendorRegNum) {
                return;
            }

            const option1 = document.createElement("option");
            option1.value = vendorRegNum;
            option1.textContent = vendorName;
            vendorSelect.appendChild(option1);

            const option2 = document.createElement("option");
            option2.value = vendorRegNum;
            option2.textContent = vendorName;
            compareVendorSelect.appendChild(option2);
        });
    }

    function getVendorRegNum(vendor) {
        return vendor.vregNum
            || vendor.vRegNum
            || vendor.VRegNum
            || vendor.vendorRegNum
            || vendor.vendor_reg_num
            || vendor.v_reg_num;
    }

    function getVendorRegNum(vendor) {
        return vendor.vregNum || vendor.vRegNum || vendor.VRegNum || vendor.vendorRegNum;
    }

    async function loadAdminSalesDashboard() {
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
        const vRegNum = document.getElementById("vendorSelect").value;

        const url = contextPath
            + "/admin/purchase/salesvolume/summary"
            + "?startDate=" + encodeURIComponent(startDate)
            + "&endDate=" + encodeURIComponent(endDate)
            + "&vRegNum=" + encodeURIComponent(vRegNum);

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

        document.getElementById("vendorCount").textContent =
            numberFormatter.format(data.vendorCount || 0) + "곳";

        document.getElementById("productTypeCount").textContent =
            numberFormatter.format(data.productTypeCount || 0) + "종";

        document.getElementById("avgOrderPrice").textContent =
            moneyFormatter.format(data.avgOrderPrice || 0) + "원";
    }

    async function loadTrend(period, startDate, endDate) {
        const vRegNum = document.getElementById("vendorSelect").value;
        const compareVendor = document.getElementById("compareVendorSelect").value;
        const metric = document.getElementById("metricSelect").value;

        if (compareVendor && compareVendor !== "0") {
            if (vRegNum === "0") {
                alert("두 회사 비교를 하려면 첫 번째 회사도 선택해야 합니다.");
                return;
            }

            if (vRegNum === compareVendor) {
                alert("같은 회사끼리는 비교할 수 없습니다.");
                return;
            }

            await loadCompareTrend(period, startDate, endDate, metric, vRegNum, compareVendor);
            return;
        }

        const url = contextPath
            + "/admin/purchase/salesvolume/trend"
            + "?period=" + encodeURIComponent(period)
            + "&startDate=" + encodeURIComponent(startDate)
            + "&endDate=" + encodeURIComponent(endDate)
            + "&vRegNum=" + encodeURIComponent(vRegNum);

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error("그래프 통계 API 오류: " + response.status);
        }

        const data = await response.json();
        renderChart(data);
    }

    async function loadCompareTrend(period, startDate, endDate, metric, vendorA, vendorB) {
        const url = contextPath
            + "/admin/purchase/salesvolume/compare"
            + "?period=" + encodeURIComponent(period)
            + "&startDate=" + encodeURIComponent(startDate)
            + "&endDate=" + encodeURIComponent(endDate)
            + "&metric=" + encodeURIComponent(metric)
            + "&vendorA=" + encodeURIComponent(vendorA)
            + "&vendorB=" + encodeURIComponent(vendorB);

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error("비교 그래프 API 오류: " + response.status);
        }

        const data = await response.json();
        renderCompareChart(data);
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

        const ctx = document.getElementById("adminSalesChart").getContext("2d");

        adminSalesChart = new Chart(ctx, {
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

    function renderCompareChart(data) {
        const metric = document.getElementById("metricSelect").value;
        const metricInfo = getMetricInfo(metric);
        const emptyMessage = document.getElementById("chartEmptyMessage");

        if (!data || data.length === 0) {
            emptyMessage.style.display = "block";
            destroyChart();
            return;
        }

        emptyMessage.style.display = "none";

        const vendorSelect = document.getElementById("vendorSelect");
        const compareVendorSelect = document.getElementById("compareVendorSelect");

        const vendorAName = vendorSelect.options[vendorSelect.selectedIndex].text;
        const vendorBName = compareVendorSelect.options[compareVendorSelect.selectedIndex].text;

        document.getElementById("chartDescription").textContent =
            vendorAName + " / " + vendorBName + "의 " + metricInfo.label + " 비교입니다.";

        const labels = data.map(item => item.label);
        const vendorAValues = data.map(item => item.vendorAValue || item.vendorAvalue || 0);
        const vendorBValues = data.map(item => item.vendorBValue || item.vendorBvalue || 0);

        destroyChart();

        const ctx = document.getElementById("adminSalesChart").getContext("2d");

        adminSalesChart = new Chart(ctx, {
            type: "line",
            data: {
                labels: labels,
                datasets: [
                    {
                        label: vendorAName,
                        data: vendorAValues,
                        tension: 0.35,
                        borderWidth: 2
                    },
                    {
                        label: vendorBName,
                        data: vendorBValues,
                        tension: 0.35,
                        borderWidth: 2
                    }
                ]
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
                            return context.dataset.label + ": " + formatMetricValue(metric, context.raw);
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
        if (adminSalesChart !== null) {
            adminSalesChart.destroy();
            adminSalesChart = null;
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

        if (metric === "productTypeCount") {
            return { label: "판매 상품 종류 수" };
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

        if (metric === "productTypeCount") {
            return formatted + "종";
        }

        return formatted;
    }

    async function loadSoldProducts(startDate, endDate) {
        const vRegNum = document.getElementById("vendorSelect").value;

        const url = contextPath
            + "/admin/purchase/salesvolume/products"
            + "?startDate=" + encodeURIComponent(startDate)
            + "&endDate=" + encodeURIComponent(endDate)
            + "&vRegNum=" + encodeURIComponent(vRegNum);

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error("판매 상품 목록 API 오류: " + response.status);
        }

        const data = await response.json();

        allSoldProducts = data || [];

        renderProductVendorCheckboxes(allSoldProducts);
        renderSoldProducts(allSoldProducts);
    }
    
    function renderProductVendorCheckboxes(data) {
        const box = document.getElementById("productVendorCheckboxes");
        box.innerHTML = "";

        if (!data || data.length === 0) {
            box.innerHTML = '<span class="product-vendor-empty">판매 상품 데이터가 없습니다.</span>';
            return;
        }

        const vendorMap = new Map();

        data.forEach(item => {
            const vRegNum = getSoldProductVRegNum(item);
            const vendorName = item.vendorName || "업체명 없음";

            if (vRegNum) {
                vendorMap.set(String(vRegNum), vendorName);
            }
        });

        if (vendorMap.size === 0) {
            box.innerHTML = '<span class="product-vendor-empty">협력업체 정보가 없습니다.</span>';
            return;
        }

        vendorMap.forEach((vendorName, vRegNum) => {
            const label = document.createElement("label");
            label.className = "product-vendor-check-label";

            const input = document.createElement("input");
            input.type = "checkbox";
            input.className = "product-vendor-check";
            input.value = vRegNum;
            input.checked = true;

            input.addEventListener("change", function () {
                renderSoldProducts(allSoldProducts);
            });

            const span = document.createElement("span");
            span.textContent = vendorName;

            label.appendChild(input);
            label.appendChild(span);

            box.appendChild(label);
        });
    }

    function getSoldProductVRegNum(item) {
        return item.vregNum
            || item.vRegNum
            || item.VRegNum
            || item.vendorRegNum
            || item.vendor_reg_num
            || item.v_reg_num;
    }

    function getSelectedProductVendorRegNums() {
        const checkedList = document.querySelectorAll(".product-vendor-check:checked");

        return Array.from(checkedList).map(input => String(input.value));
    }

    function checkAllProductVendors(checked) {
        const checkboxes = document.querySelectorAll(".product-vendor-check");

        checkboxes.forEach(input => {
            input.checked = checked;
        });

        renderSoldProducts(allSoldProducts);
    }

    function renderSoldProducts(data) {
        const tbody = document.getElementById("soldProductBody");
        tbody.innerHTML = "";

        if (!data || data.length === 0) {
            tbody.innerHTML =
                '<tr><td colspan="8" class="admin-sales-empty-cell">조회된 판매 상품이 없습니다.</td></tr>';
            return;
        }

        const selectedVendors = getSelectedProductVendorRegNums();

        if (selectedVendors.length === 0) {
            tbody.innerHTML =
                '<tr><td colspan="8" class="admin-sales-empty-cell">선택된 협력업체가 없습니다.</td></tr>';
            return;
        }

        const filteredData = data.filter(item => {
            const itemVRegNum = String(getSoldProductVRegNum(item));
            return selectedVendors.includes(itemVRegNum);
        });

        if (filteredData.length === 0) {
            tbody.innerHTML =
                '<tr><td colspan="8" class="admin-sales-empty-cell">선택한 협력업체의 판매 상품이 없습니다.</td></tr>';
            return;
        }

        filteredData.forEach(item => {
            const tr = document.createElement("tr");

            tr.innerHTML =
                "<td>" + escapeHtml(item.saleDate || "") + "</td>" +
                "<td>" + item.saleId + "</td>" +
                "<td>" + item.bookId + "</td>" +
                "<td class='book-title-cell'>" + escapeHtml(item.bookTitle || "") + "</td>" +
                "<td>" + escapeHtml(item.vendorName || "") + "</td>" +
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

    document.getElementById("vendorSelect").addEventListener("change", function () {
        const compareVendorSelect = document.getElementById("compareVendorSelect");

        if (this.value === "0") {
            compareVendorSelect.value = "0";
        }

        loadAdminSalesDashboard();
    });

    document.getElementById("compareVendorSelect").addEventListener("change", function () {
        const startDate = document.getElementById("startDate").value;
        const endDate = document.getElementById("endDate").value;
        const period = document.getElementById("periodSelect").value;

        loadTrend(period, startDate, endDate);
    });
</script>