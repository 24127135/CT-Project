# --- File: run_app.ps1 ---

# 1. Tự động tìm IP của máy (Ưu tiên Wi-Fi, nếu dùng dây mạng thì sửa 'Wi-Fi' thành 'Ethernet')
$ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -match 'Wi-Fi' } | Select-Object -ExpandProperty IPAddress | Select-Object -First 1

# Nếu không tìm thấy IP Wi-Fi, thử tìm tất cả các IP khác (phòng trường hợp dùng dây mạng)
if (-not $ip) {
    $ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '192.*' } | Select-Object -ExpandProperty IPAddress | Select-Object -First 1
}

Write-Host "--------------------------------------------" -ForegroundColor Green
Write-Host "Detected Computer IP: $ip" -ForegroundColor Yellow
Write-Host "Launching Flutter App..." -ForegroundColor Cyan
Write-Host "Target API: http://$($ip):8000/api" -ForegroundColor Gray
Write-Host "--------------------------------------------" -ForegroundColor Green

# 2. Chạy Flutter và truyền IP vào code
flutter run --dart-define=SERVER_IP=$ip