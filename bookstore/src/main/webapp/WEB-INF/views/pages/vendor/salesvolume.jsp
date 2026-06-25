<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="vendor-salesvolume-page">

    <div class="salesvolume-card">

        <div class="salesvolume-top">
            <div>
                <h2>📊 도서 판매량 통계</h2>
                <p>소비자가 실제 주문한 도서 수량 기준 통계입니다.</p>
            </div>

            <select id="periodSelect" class="salesvolume-select">
                <option value="hour">시간별</option>
                <option value="day">일별</option>
                <option value="week">주별</option>
                <option value="month">월별</option>
                <option value="year">연별</option>
            </select>
        </div>

        <div class="chart-area">
            <canvas id="salesVolumeChart"></canvas>
        </div>

        <p id="emptyMessage" class="salesvolume-empty" style="display:none;">
            표시할 판매량 데이터가 없습니다.
        </p>

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

            const emptyMessage = document.getElementById("emptyMessage");

            if (!data || data.length === 0) {
                emptyMessage.style.display = "block";

                if (salesVolumeChart !== null) {
                    salesVolumeChart.destroy();
                    salesVolumeChart = null;
                }

                return;
            }

            emptyMessage.style.display = "none";

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
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return "판매량: " + context.raw + "권";
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    }
                }
            });

        } catch (error) {
            console.error(error);
            alert("판매량 데이터를 불러오지 못했습니다. 서버 로그와 콘솔을 확인하세요.");
        }
    }

    loadSalesVolumeChart("hour");
</script>

<style>
.vendor-salesvolume-page {
    width: 100%;
    padding: 10px 0 40px;
}

.salesvolume-card {
    background: #ffffff;
    border: 1px solid #edeff2;
    border-radius: 12px;
    padding: 32px;
    box-shadow: 0 10px 30px rgba(11, 19, 43, 0.04);
}

.salesvolume-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    margin-bottom: 28px;
    border-bottom: 2px solid #0b132b;
    padding-bottom: 18px;
}

.salesvolume-top h2 {
    margin: 0;
    color: #0b132b;
    font-size: 24px;
    font-weight: 800;
    letter-spacing: -0.5px;
}

.salesvolume-top p {
    margin: 8px 0 0;
    color: #7f8c8d;
    font-size: 14px;
    font-weight: 500;
}

.salesvolume-select {
    min-width: 130px;
    height: 42px;
    border: 1px solid #dfe4ea;
    border-radius: 6px;
    background: #ffffff;
    color: #0b132b;
    font-size: 14px;
    font-weight: 700;
    padding: 0 12px;
    outline: none;
}

.salesvolume-select:focus {
    border-color: #17a2b8;
    box-shadow: 0 0 0 4px rgba(23, 162, 184, 0.1);
}

.chart-area {
    width: 100%;
    height: 430px;
}

.salesvolume-empty {
    text-align: center;
    color: #a4b0be;
    font-size: 14px;
    font-weight: 700;
    padding: 30px 0 0;
}
</style>