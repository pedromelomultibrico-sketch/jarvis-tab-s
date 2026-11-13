#!/data/data/com.termux/files/usr/bin/bash
# Instala MindTheGapps + Magisk no tablet (TWRP), a partir do telemovel.
# Funciona com o tablet em Android, no TWRP, ou ja em ADB Sideload.
cd ~/tab
G=MindTheGapps-10.0.0-arm-20220224_161620.zip
[ -s "$G" ] || curl -fL -o "$G" "https://github.com/MindTheGapps/10.0.0-arm/releases/download/MindTheGapps-10.0.0-arm-20220224_161620/$G"
ls -la "$G" Magisk.zip || exit 1
A=termux-adb
estado() { $A devices | awk 'NR>1 && $2!="" {print $2; exit}'; }
espera() { for i in $(seq 1 300); do s=$(estado); for w in "$@"; do [ "$s" = "$w" ] && { echo "$s"; return 0; }; done; sleep 2; done; return 1; }
$A kill-server >/dev/null 2>&1; $A start-server
echo ">> A procura do tablet (ate 10 min)..."
S=$(espera device recovery sideload) || { echo "Tablet nao encontrado"; exit 1; }
echo ">> Tablet em: $S"
if [ "$S" = device ]; then
  echo ">> Android: reiniciar para o TWRP"; $A reboot recovery; sleep 8
  S=$(espera recovery sideload) || { echo "TWRP nao apareceu"; exit 1; }
fi
if [ "$S" = recovery ]; then
  sleep 4
  echo ">> Apagar dados/cache/dalvik"
  $A shell twrp wipe data; $A shell twrp wipe cache; $A shell twrp wipe dalvik
  $A shell twrp sideload; sleep 3
  espera sideload >/dev/null || { echo "Sideload nao arrancou"; exit 1; }
fi
echo ">> A instalar servicos Google"
$A sideload "$G"
echo ">> A preparar Magisk"; sleep 6
S=$(espera recovery sideload) || { echo "TWRP nao voltou"; exit 1; }
if [ "$S" = recovery ]; then $A shell twrp sideload; sleep 3; espera sideload >/dev/null; fi
$A sideload Magisk.zip
sleep 6
S=$(espera recovery sideload)
[ "$S" = recovery ] && $A shell twrp reboot
echo "GAPPS FEITO - o primeiro arranque demora (se ficar no TWRP, carregue Reiniciar > Sistema)"
