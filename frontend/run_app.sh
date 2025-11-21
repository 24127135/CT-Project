#!/bin/bash

# --- File: run_app.sh (Linux equivalent) ---

# 1. Tự động tìm IP của máy (Ưu tiên Wi-Fi/wlan, nếu dùng dây mạng/ethernet thì sửa 'wlan' thành 'eth')
# Try to find the IP for a wireless interface (often starts with 'wlan' or 'wl')
IP=$(ip a | grep 'inet ' | grep 'wlan' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# If no 'wlan' IP is found, try to find the IP for a wired interface (often starts with 'eth' or 'enp')
if [ -z "$IP" ]; then
    IP=$(ip a | grep 'inet ' | grep -E 'eth|enp' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
fi

# Fallback: Try to find any local IP address (e.g., one starting with 192.)
if [ -z "$IP" ]; then
    IP=$(ip a | grep 'inet ' | grep '192.' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
fi

echo "--------------------------------------------"
echo -e "\033[33mDetected Computer IP: $IP\033[0m" # Yellow color
echo -e "\033[36mLaunching Flutter App...\033[0m" # Cyan color
echo -e "\033[37mTarget API: http://$IP:8000/api\033[0m" # Gray/White color
echo "--------------------------------------------"

# 2. Chạy Flutter và truyền IP vào code
flutter run --dart-define=SERVER_IP=$IP
