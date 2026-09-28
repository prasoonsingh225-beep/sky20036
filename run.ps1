# SkyNova / Aeroguard - Automated Startup Script
# Smart India Hackathon 2026 - Problem Statement SIH26073

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  🌩️  SkyNova: Intelligent AWS Anomaly Detection Platform  " -ForegroundColor Green
Write-Host "  Smart India Hackathon 2026 (SIH26073)                   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$pythonExe = "C:\Users\HP5CD\AppData\Local\Programs\Python\Python311\python.exe"

if (-not (Test-Path $pythonExe)) {
    $pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Source
}

if (-not $pythonExe) {
    Write-Error "Python executable not found. Please ensure Python 3.11 is installed."
    Exit 1
}

Write-Host "[1/3] Verifying Python runtime: $pythonExe" -ForegroundColor DarkCyan

# Optional: Launch FastAPI service in background job
Write-Host "[2/3] Starting Streamlit Real-Time Command Center..." -ForegroundColor DarkCyan

# Launch Streamlit on port 8501 and automatically open default browser
& $pythonExe -m streamlit run dashboard/app.py --server.port 8501 --server.headless false
