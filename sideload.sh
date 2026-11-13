#!/data/data/com.termux/files/usr/bin/bash
# Envia a ROM do telemóvel para o tablet (TWRP em modo ADB Sideload) sem root, com termux-adb
cd ~/tab
ROM=lineage-17.1-20250102-UNOFFICIAL-klimtlte.zip
if ! command -v termux-adb >/dev/null; then
  echo ">> A instalar o termux-adb"
  mkdir -p $PREFIX/etc/apt/sources.list.d
  echo "deb https://nohajc.github.io termux extras" > $PREFIX/etc/apt/sources.list.d/termux-adb.list
  apt-get -y install gnupg wget >/dev/null
  wget -qP $PREFIX/etc/apt/trusted.gpg.d https://nohajc.github.io/nohajc.gpg
  apt-get update >/dev/null
  apt-get -y install termux-adb
fi
ls -la "$ROM" || { echo "Falta a ROM. Corre primeiro o rom.sh"; exit 1; }
echo ">> A procurar o tablet (TWRP > Advanced > ADB Sideload > deslizar)..."
termux-adb kill-server >/dev/null 2>&1
for i in $(seq 1 30); do
  termux-adb devices | grep -q sideload && break
  sleep 2
done
termux-adb devices
echo ">> A enviar a ROM"
termux-adb sideload "$ROM"
echo "FIM DO ENVIO. Ver o ecrã do TWRP."
