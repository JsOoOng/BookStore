<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="vendor-salesvolume-page">

    <div class="salesvolume-card">

        <div class="salesvolume-top">
            <div>
                <h2>📊 도서 판매량 통계</h2>
                <p>파트너사가 등록한 판매 상품 수량 기준 통계입니다.</p>
            </div>

            <select id="periodSelect" class="salesvolume-select">
                <option value="hour">시간별</option>
                <option value="day">일별</option>
                <option value="week">주별</option>
                <option value="month">월별</option>
                <option value="year">년별</option>
            </select>
        </div>

        <div class="chart-area">
            <canvas id="salesVolumeChart"></canvas>
        </div>

    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    let salesVolumeChart = null;

    const periodSelect = document.getElementById("periodSelect");

    periodSelect.addEventListener("change", function () {
        loadSalesVolumeChart(this.value);
    });

    async function loadSalesVolumeChart(period) {
        try {
            const response = await fetch(contextPath + "/vendor/purchase/salesvolume/data?period=" + period);

            if (!response.ok) {
                throw new Error("판매량 데이터 API 오류: " + response.status);
            }

            const data = await response.json();

            console.log("판매량 데이터:", data);

            const labels = data.map(item => item.label);
            const values = data.map(item => item.totalQty);

            const chartType = period === "hour" ? "line" : "bar";

            if (salesVolumeChart !== null) {
                salesVolumeChart.destroy();
            }

            const ctx = document.getElementById("salesVolumeChart").getContext("2d");

            salesVolumeChart = new Chart(ctx, {
                type: chartType,
                data: {
                    labels: labels,
                    datasets: [{
                        label: "판매량",
                        data: values,
                        tension: 0.35,
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });

        } catch (error) {
            console.error(error);
            alert("판매량 데이터를 불러오지 못했습니다. 콘솔과 서버 로그를 확인하세요.");
        }
    }

    loadSalesVolumeChart("hour");
</script>

<style>
.vendor-salesvolume-page {
    width: 100%;
    padding: 20px 0;
}

.salesvolume-card {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 18px;
    padding: 28px;
    box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
}

.salesvolume-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.salesvolume-top h2 {
    margin: 0;
    color: #0f172a;
    font-size: 26px;
}

.salesvolume-top p {
    margin: 8px 0 0;
    color: #64748b;
    font-size: 14px;
}

.salesvolume-select {
    width: 140px;
    height: 42px;
    border: 1px solid #cbd5e1;
    border-radius: 12px;
    padding: 0 12px;
    font-size: 15px;
    background: #ffffff;
}

.chart-area {
    width: 100%;
    height: 420px;
}
</style>