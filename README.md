# 🌩️ SkyNova / Aeroguard
### AI/ML-Based Intelligent Anomaly Detection & Predictive Maintenance for Automatic Weather Stations (AWS)
**Problem Statement ID:** SIH26073 | **Theme:** Disaster Management (Software) | **Smart India Hackathon 2026**

---

## 📌 1. Project Overview & Challenge
Automatic Weather Stations (AWS) deployed by meteorological departments (such as IMD) in harsh and remote terrains frequently suffer from:
- **Hardware & Sensor Faults**: Calibration drift (+0.5°C/hr), stuck ADC pins (frozen values), debris in tipping bucket rain gauges, loose electrical noise, and out-of-bounds readings.
- **Genuine Extreme Disasters**: Tropical cyclones, squall depressions, severe cloudbursts, flash floods, and extreme heatwaves.

**The Fatal Flaw of Standard Thresholding:**
- Conventional static filters frequently misclassify catastrophic extreme weather events as "faulty outliers", discarding vital disaster warning data.
- Conversely, they mistake single hardware sensor failures for genuine climate events, triggering costly false alarms.

**SkyNova's Solution:**
A **Dual-Engine Intelligent Architecture** pairing an unsupervised **Isolation Forest Machine Learning model** with a **Meteorological Physical Consistency Rule Engine** (based on IMD and WMO guidelines). SkyNova strictly disambiguates between `NORMAL`, `SENSOR_FAULT`, and `EXTREME_WEATHER` in real-time while providing **Predictive Maintenance** alerts before sensor hardware fails completely.

---

## 🏛️ 2. System Architecture

```
+-----------------------------------------------------------------------------------+
|                        AWS Telemetry Simulator / Real AWS                         |
|   (Temp, Humidity, Pressure, Wind Speed/Dir, Rain Gauge, Solar Rad, Soil Moisture)|
|   [Injectable Modes: Normal, Spike, Freeze, Drift, Out-of-Bounds, Cyclone, etc.]   |
+-----------------------------------------------------------------------------------+
                                         │ JSON Stream / HTTP POST
                                         ▼
+-----------------------------------------------------------------------------------+
|                        FastAPI Ingestion & Local Buffer                           |
|       (/api/telemetry, /api/simulate/tick, /api/alerts, /api/sensors/health)      |
|        - Local Queue & Offline Resilience Buffer (SQLite Persistence)             |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
|                      Data Preprocessor & Feature Engineering                      |
|   - Physical Range & Boundary Clamping (WMO/IMD limits)                           |
|   - Rolling Statistics (Mean, Std Dev, Exponential Smoothing, Rate of Change Δ)   |
|   - Cross-Sensor Correlation Features (Magnus Dewpoint, Baric Tendency)           |
+-----------------------------------------------------------------------------------+
                                         │
                    ┌────────────────────┴────────────────────┐
                    ▼                                         ▼
+───────────────────────────────────────+ +─────────────────────────────────────────+
|         Machine Learning Engine       | |     Meteorological Rule Engine          |
|    - Isolation Forest Baseline Model  | | - Physical Boundary Checks              |
|    - Continuous Anomaly Scoring       | | - Multi-Sensor Coherence Matrix         |
|      (Calibrated Score: 0.0 to 1.0)   | | - Thermodynamic Correlation Verification|
+───────────────────────────────────────+ +─────────────────────────────────────────+
                    └────────────────────┬────────────────────┘
                                         ▼
+-----------------------------------------------------------------------------------+
|                      Disambiguation & Classification Logic                         |
|   - Isolated 1-sensor deviation without physical corroboration? -> SENSOR_FAULT   |
|   - Multi-sensor physically coupled shifts (ΔP drop + High Wind + Rain)?          |
|     -> EXTREME_WEATHER (Disaster Alert)                                           |
|   - Baseline diurnal envelope -> NORMAL                                           |
|   - Slow cumulative slope decay -> PREDICTIVE_MAINTENANCE / SENSOR_DRIFT          |
+-----------------------------------------------------------------------------------+
                                         │
                                         ▼
+-----------------------------------------------------------------------------------+
|                   Streamlit Command Center & Visualization                        |
|   - Live multi-parameter time series with Anomaly Score overlays (Plotly)         |
|   - Sensor Fleet Health Cards (Healthy, Degraded, Critical)                       |
|   - Interactive Fault & Disaster Event Injection Controls                         |
|   - Disaster Early-Warning Banner & Predictive Maintenance Logs                   |
+-----------------------------------------------------------------------------------+
```

---

## 🔬 3. The Dual-Engine Disambiguation Logic

### A. Meteorological Rule Engine & Cross-Sensor Physics
1. **Physical Boundary Violations**:
   - Rejects physically impossible values according to WMO specifications (e.g., $RH > 100\%$, $T > 60^\circ\text{C}$, $P < 870\text{ hPa}$).
2. **Flatline / Frozen Sensor Check**:
   - Monitored via rolling standard deviation:
     $$\sigma_r = \sqrt{\frac{1}{N}\sum_{i=1}^N (x_i - \mu)^2}$$
     If $\sigma_r < 10^{-4}$ for $N \ge 10$ ticks on continuous sensors $\implies$ `SENSOR_FAULT (FROZEN_SENSOR)`.
3. **Psychrometric Coherence (Magnus Dewpoint Formula)**:
   $$T_{dew} = \frac{243.04 \times \alpha}{17.625 - \alpha}, \quad \text{where } \alpha = \frac{17.625 T}{243.04 + T} + \ln\left(\frac{RH}{100}\right)$$
   - If Rain Gauge reports $120\text{ mm/h}$ but $RH < 55\% \implies$ `SENSOR_FAULT` (Mechanical bounce or insect false contact). Genuine rain requires saturated boundary air ($RH > 85\%$).
4. **Tropical Cyclone / Squall Verification**:
   - Simultaneous barometric drop ($\Delta P < -4\text{ hPa}$ or $P < 995\text{ hPa}$) coupled with squall gusts ($WS > 62\text{ km/h}$) $\implies$ `EXTREME_WEATHER (CYCLONE_SQUALL)`.

### B. Machine Learning Isolation Forest
- Evaluates non-linear multi-dimensional interactions across $18$ dynamic features.
- Normalizes tree partition depths into a calibrated Anomaly Score $S \in [0.0, 1.0]$.
- Triggers alert thresholds when $S \ge 0.70$.

---

## 🚀 4. Quick Start & Execution

### Prerequisites
- Windows 10/11 with Python 3.10+ installed.

### Step 1: Install Dependencies
```powershell
python -m pip install -r requirements.txt
```

### Step 2: Launch the Prototype
You can launch either via PowerShell script or Streamlit command:

```powershell
# Option A: One-click launcher
.\run.ps1

# Option B: Direct Streamlit command
python -m streamlit run dashboard/app.py
```
This automatically opens the live interactive Command Center in your default web browser at:
👉 **`http://localhost:8501`**

### Step 3: Run Backend REST API (Optional)
```powershell
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --reload
```
Interactive Swagger API documentation:
👉 **`http://127.0.0.1:8000/docs`**

---

## 🧪 5. Testing & Verification

Run the automated test suite covering all fault modes and disaster disambiguation scenarios:
```powershell
python -m pytest tests/ -v
```

All tests validate:
- ✅ Normal diurnal generation without false alarms
- ✅ Injection of transient spikes, frozen flatlines, and physical bounds
- ✅ Disambiguation between isolated sensor failures vs real cyclonic squalls & cloudbursts
- ✅ Predictive maintenance health score degradation.

---

## 🏆 6. Smart India Hackathon Demo Walkthrough
1. **Normal Operation**: Open the dashboard to see live diurnal time series and green "ALL SENSORS NOMINAL" status.
2. **Inject Single Sensor Spike**: In the sidebar, select `SPIKE` on `temperature` and click "Apply".
   - Notice the amber banner: Flags `SENSOR_FAULT` on Temperature without declaring a heatwave because ambient humidity/pressure remain nominal.
3. **Inject Frozen Sensor**: Select `FREEZE` on `humidity`.
   - After a few ticks, variance drops to 0.0 and the system flags `FROZEN_SENSOR`.
4. **Inject Extreme Disaster**: Select `CYCLONE` and click "Apply".
   - Flashing RED Emergency Disaster Banner activates: Detects coherent barometric drop + 110 km/h squall gusts + heavy rain $\implies$ `EXTREME_WEATHER (CYCLONE)`.
5. **Predictive Maintenance**: Inspect Tab 2 to view fleet health percentages, drift offsets, and automated maintenance recommendations.
