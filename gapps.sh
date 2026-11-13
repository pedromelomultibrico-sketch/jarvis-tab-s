#!/data/data/com.termux/files/usr/bin/bash
# Reinstala MindTheGapps (sem apagar dados) e mostra o resultado do TWRP.
cd ~/tab
G=MindTheGapps-10.0.0-arm-20220224_161620.zip
[ -s "$G" ] || curl -fL -o "$G" "https://github.com/MindTheGapps/10.0.0-arm/releases/download/MindTheGapps-10.0.0-arm-20220224_161620/$G"
A=termux-adb
estado() { $A devices | awk 'NR>1 && $2!="" {print $2; exit}'; }
espera() { for i in $(seq 1 300); do s=$(estado); for w in "$@"; do [ "$s" = "$w" ] && { echo "$s"; return 0; }; done; sleep 2; done; return 1; }
$A kill-server >/dev/null 2>&1; $A start-server
echo ">> A procura do tablet (ate 10 min). Entre no TWRP: Volume+ Home Ligar"
S=$(espera device recovery sideload) || { echo "Tablet nao encontrado"; exit 1; }
echo ">> Tablet em: $S"
if [ "$S" = device ]; then $A reboot recovery; sleep 8; S=$(espera recovery sideload) || exit 1; fi
if [ "$S" = recovery ]; then
  sleep 3
  echo ">> Espaco no system:"; $A shell 'mount /system 2>/dev/null; df -h /system; ls /system/priv-app | head -50'
  $A shell twrp sideload; sleep 3; espera sideload >/dev/null
fi
echo ">> A instalar servicos Google"
$A sideload "$G"
sleep 6; S=$(espera recovery sideload)
echo ">> RESULTADO DO TWRP:"
$A shell 'grep -iE "error|fail|abort|insufficient|mindthegapps|installing|done|success" /tmp/recovery.log | tail -n 25'
$A shell 'mount /system 2>/dev/null; ls /system/priv-app | grep -iE "vending|gms|phonesky"; ls /system/system/priv-app 2>/dev/null | grep -iE "vending|gms|phonesky"'
echo "FIM - nao reiniciei; diga ao Claude"
