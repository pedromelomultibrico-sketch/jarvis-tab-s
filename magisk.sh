#!/data/data/com.termux/files/usr/bin/bash
# Instala o Magisk (root) no tablet a partir do telemóvel, por cabo, com termux-adb
cd ~/tab
V=v31.1
[ -s Magisk.apk ] || curl -fL -o Magisk.apk "https://github.com/topjohnwu/Magisk/releases/download/$V/Magisk-$V.apk"
cp -f Magisk.apk Magisk.zip
A=termux-adb
espera() { for i in $(seq 1 60); do $A devices | grep -q "$1" && return 0; sleep 2; done; return 1; }
$A kill-server >/dev/null 2>&1; $A start-server >/dev/null 2>&1
$A devices
if $A devices | grep -qw device; then
  echo ">> Tablet no Android: a reiniciar para o TWRP"
  $A reboot recovery
fi
echo ">> A espera do TWRP..."
espera recovery || { echo "TWRP nao apareceu"; exit 1; }
sleep 3
echo ">> A ligar o modo sideload no TWRP"
$A shell twrp sideload
espera sideload || { echo "Sideload nao arrancou"; exit 1; }
echo ">> A enviar o Magisk"
$A sideload Magisk.zip
sleep 5
espera recovery && $A shell twrp reboot || $A reboot
echo ">> A espera do Android para instalar a app Magisk..."
espera "\bdevice\b" && sleep 20 && $A install -r Magisk.apk
echo "MAGISK FEITO"
