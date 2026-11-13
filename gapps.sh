#!/data/data/com.termux/files/usr/bin/bash
# v4: MindTheGapps com instalador corrigido para o klimtlte (sem apagar dados)
cd ~/tab
G=MindTheGapps-10.0.0-arm-20220224_161620.zip
P=MTG-klimt.zip
R=https://raw.githubusercontent.com/pedromelomultibrico-sketch/jarvis-tab-s/main
[ -s "$G" ] || curl -fL -o "$G" "https://github.com/MindTheGapps/10.0.0-arm/releases/download/MindTheGapps-10.0.0-arm-20220224_161620/$G"
command -v zip >/dev/null || apt-get install -y zip
echo ">> A corrigir o instalador"
rm -rf mtgfix; mkdir -p mtgfix/META-INF/com/google/android
curl -fsSL "$R/mtg-update-binary" -o mtgfix/META-INF/com/google/android/update-binary || exit 1
grep -q klimtlte mtgfix/META-INF/com/google/android/update-binary || { echo "instalador errado"; exit 1; }
cp "$G" "$P"
(cd mtgfix && zip -q "../$P" META-INF/com/google/android/update-binary) || exit 1
ls -la "$P"
A=termux-adb
estado() { $A devices | awk 'NR>1 && $2!="" {print $2; exit}'; }
espera() { for i in $(seq 1 300); do s=$(estado); for w in "$@"; do [ "$s" = "$w" ] && { echo "$s"; return 0; }; done; sleep 2; done; return 1; }
$A kill-server >/dev/null 2>&1; $A start-server
echo ">> A procura do tablet (ate 10 min)"
S=$(espera device recovery sideload) || { echo "Tablet nao encontrado"; exit 1; }
echo ">> Tablet em: $S"
if [ "$S" = device ]; then $A reboot recovery; sleep 8; S=$(espera recovery sideload) || exit 1; fi
if [ "$S" = recovery ]; then
  sleep 2
  $A shell 'ls -l /dev/block/platform/*/by-name/ 2>/dev/null | grep -i system; grep -i system /etc/recovery.fstab /etc/twrp.fstab 2>/dev/null'
  $A shell twrp sideload; sleep 3; espera sideload >/dev/null
fi
echo ">> A instalar servicos Google (corrigido)"
$A sideload "$P"
echo "FIM - veja o ecra do tablet (icone das 3 riscas)"
