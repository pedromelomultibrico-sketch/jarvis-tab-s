#!/data/data/com.termux/files/usr/bin/bash
# Instalação limpa no tablet: apaga dados, instala GApps (Play Store) e volta a pôr o Magisk
cd ~/tab
G=MindTheGapps-10.0.0-arm-20220224_161620.zip
[ -s "$G" ] || curl -fL -o "$G" "https://github.com/MindTheGapps/10.0.0-arm/releases/download/MindTheGapps-10.0.0-arm-20220224_161620/$G"
ls -la "$G" Magisk.zip || exit 1
A=termux-adb
espera() { for i in $(seq 1 90); do $A devices | grep -qw "$1" && return 0; sleep 2; done; return 1; }
$A start-server >/dev/null 2>&1
echo ">> A espera da autorizacao no tablet (Permitir)..."
for i in $(seq 1 90); do $A devices | grep -qwE 'device|recovery' && break; sleep 2; done
$A devices
if $A devices | grep -qw device; then echo ">> Android: reiniciar para o TWRP"; $A reboot recovery; fi
echo ">> A espera do TWRP..."; espera recovery || { echo "TWRP nao apareceu"; exit 1; }
sleep 4
echo ">> A apagar dados, cache e dalvik"
$A shell twrp wipe data; $A shell twrp wipe cache; $A shell twrp wipe dalvik
echo ">> GApps"
$A shell twrp sideload; espera sideload || exit 1
$A sideload "$G"
sleep 6; espera recovery
echo ">> Magisk"
$A shell twrp sideload; espera sideload || exit 1
$A sideload Magisk.zip
sleep 6; espera recovery && $A shell twrp reboot
echo "GAPPS FEITO - o primeiro arranque demora"
