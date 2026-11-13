#!/data/data/com.termux/files/usr/bin/bash
# Descarrega a ROM LineageOS 17.1 (Android 10) para o SM-T705 (klimtlte)
set -e
mkdir -p ~/tab && cd ~/tab
ROM=lineage-17.1-20250102-UNOFFICIAL-klimtlte.zip
curl -fL -C - -o "$ROM" "https://github.com/HazouPH/android_device_samsung_universal5420-common/releases/download/1.9/$ROM"
ls -la "$ROM"
sha256sum "$ROM" | tee "$ROM.sha256"
echo "ROM PRONTA: ~/tab/$ROM"
