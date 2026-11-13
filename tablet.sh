#!/data/data/com.termux/files/usr/bin/bash
# Uso: ~/tab/tablet.sh            -> instala o TWRP (recovery)
#      ~/tab/tablet.sh detetar    -> só verifica a ligação
#      ~/tab/tablet.sh pit        -> lê a tabela de partições
cd ~/tab
DEV=$(termux-usb -l | tr -d '[]", ' | grep /dev | head -1)
if [ -z "$DEV" ]; then echo "Tablet não encontrado. Está em modo Download e com o cabo OTG?"; exit 1; fi
echo "Aparelho USB: $DEV"
case "$1" in
  detetar) echo "detect" > hd-args ;;
  pit) echo "print-pit --no-reboot" > hd-args ;;
  *) echo "flash --RECOVERY $HOME/tab/twrp.img --no-reboot" > hd-args ;;
esac
termux-usb -r "$DEV"
termux-usb -e "$HOME/tab/hd.sh" "$DEV"
echo
echo "Se correu bem: desliga o tablet (Volume- + Power ~10 s) e LOGO a seguir"
echo "segura Volume+ + Home + Power para entrar no TWRP (sem deixar arrancar o Android)."
